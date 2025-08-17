/// How long it takes from the gunpoint is initiated to reach stage 2
#define GUNPOINT_DELAY_STAGE_2 (2.5 SECONDS)
/// How long it takes from stage 2 starting to move up to stage 3
#define GUNPOINT_DELAY_STAGE_3 (7.5 SECONDS)
/// If the projectile doesn't have a wound_bonus of CANT_WOUND, we add (this * the stage mult) to their wound_bonus and exposed_wound_bonus upon triggering
#define GUNPOINT_BASE_WOUND_BONUS 5
/// How much the damage and wound bonus mod is multiplied when you're on stage 1
#define GUNPOINT_MULT_STAGE_1 1.25
/// As above, for stage 2
#define GUNPOINT_MULT_STAGE_2 2
/// As above, for stage 3
#define GUNPOINT_MULT_STAGE_3 2.5


/datum/component/gunpoint
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Who we're holding up
	var/mob/living/target
	/// The gun we're holding them up with
	var/obj/item/gun/weapon

	/// Which stage we're on
	var/stage = 1
	/// How much the damage and wound values will be multiplied by
	var/damage_mult = GUNPOINT_MULT_STAGE_1
	/// If TRUE, we're committed to firing the shot, for async purposes
	var/point_of_no_return = FALSE

// *extremely bad russian accent* no!
/datum/component/gunpoint/Initialize(mob/living/targ, obj/item/gun/wep)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/shooter = parent
	target = targ
	weapon = wep

	RegisterSignals(targ, list(
		COMSIG_MOB_ATTACK_HAND,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOVABLE_SET_GRAB_STATE,
		COMSIG_LIVING_START_PULL), PROC_REF(trigger_reaction))
	RegisterSignal(targ, COMSIG_ATOM_EXAMINE, PROC_REF(examine_target))
	RegisterSignal(targ, COMSIG_LIVING_PRE_MOB_BUMP, PROC_REF(block_bumps_target))
	RegisterSignals(targ, list(COMSIG_LIVING_DISARM_HIT, COMSIG_LIVING_GET_PULLED), PROC_REF(cancel))
	RegisterSignals(weapon, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), PROC_REF(cancel))

	var/distance = max(get_dist(shooter, target), 1) // считаем нулевую дистанцию как ближнюю
	var/distance_description = (distance <= 1 ? "в упор " : "")

	shooter.visible_message(span_danger("[shooter] наводит [weapon] [distance_description]на [target]!"),
		span_danger("Вы наводите [weapon] [distance_description]на [target]!"), ignored_mobs = target)
	to_chat(target, span_userdanger("[shooter] наводит [weapon] [distance_description]на вас!"))

	shooter.Immobilize(0.75 SECONDS / distance)
	if(!HAS_TRAIT(target, TRAIT_NOFEAR_HOLDUPS))
		target.Immobilize(0.75 SECONDS / distance)
		target.emote("gaspshock", intentional = FALSE)
		add_memory_in_range(target, 7, /datum/memory/held_at_gunpoint, protagonist = target, deuteragonist = shooter, antagonist = weapon)

	shooter.apply_status_effect(/datum/status_effect/holdup, shooter)
	target.apply_status_effect(/datum/status_effect/grouped/heldup, REF(shooter))
	target.do_alert_animation()
	target.playsound_local(target.loc, 'sound/machines/chime.ogg', 50, TRUE)
	target.add_mood_event("gunpoint", /datum/mood_event/gunpoint)

	if(istype(weapon, /obj/item/gun/ballistic/rocketlauncher) && weapon.chambered)
		if(target.stat == CONSCIOUS && IS_NUKE_OP(shooter) && !IS_NUKE_OP(target) && (locate(/obj/item/disk/nuclear) in target.get_contents()) && shooter.client)
			shooter.client.give_award(/datum/award/achievement/misc/rocket_holdup, shooter)

	addtimer(CALLBACK(src, PROC_REF(update_stage), 2), GUNPOINT_DELAY_STAGE_2)

/datum/component/gunpoint/Destroy(force)
	var/mob/living/shooter = parent
	shooter.remove_status_effect(/datum/status_effect/holdup)
	target.remove_status_effect(/datum/status_effect/grouped/heldup, REF(shooter))
	target.clear_mood_event("gunpoint")
	return ..()

/datum/component/gunpoint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_deescalate))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(flinch))
	RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND, PROC_REF(check_shove))
	RegisterSignal(parent, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(check_deescalate))
	RegisterSignals(parent, list(COMSIG_LIVING_START_PULL, COMSIG_MOVABLE_BUMP), PROC_REF(check_bump))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_LIVING_PRE_MOB_BUMP, PROC_REF(block_bumps_parent))
	RegisterSignal(parent, COMSIG_LIVING_DISARM_HIT, PROC_REF(cancel))

/datum/component/gunpoint/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(parent, COMSIG_MOB_UPDATE_SIGHT)
	UnregisterSignal(parent, COMSIG_MOB_ATTACK_HAND)
	UnregisterSignal(parent, list(COMSIG_LIVING_START_PULL, COMSIG_MOVABLE_BUMP))
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(parent, COMSIG_LIVING_PRE_MOB_BUMP)
	UnregisterSignal(parent, COMSIG_LIVING_DISARM_HIT)

/// Если стрелок сталкивается с целью, отменяем удержание, чтобы избежать читерства и форсирования заряженного выстрела
/datum/component/gunpoint/proc/check_bump(atom/B, atom/A)
	SIGNAL_HANDLER

	if(A != target)
		return
	var/mob/living/shooter = parent
	shooter.visible_message(span_danger("[shooter] сталкивается с [target] и теряет прицел!"), \
		span_danger("Вы сталкиваетесь с [target] и теряете прицел!"), ignored_mobs = target)
	to_chat(target, span_userdanger("[shooter] сталкивается с вами и теряет прицел!"))
	qdel(src)

/// Если стрелок толкает или хватает цель, отменяем удержание, чтобы избежать читерства и форсирования заряженного выстрела
/datum/component/gunpoint/proc/check_shove(mob/living/carbon/shooter, mob/shooter_again, mob/living/T, datum/martial_art/attacker_style, modifiers)
	SIGNAL_HANDLER

	if(T != target || LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	shooter.visible_message(span_danger("[shooter] сталкивается с [target] и теряет прицел!"), \
		span_danger("Вы сталкиваетесь с [target] и теряете прицел!"), ignored_mobs = target)
	to_chat(target, span_userdanger("[shooter] сталкивается с вами и теряет прицел!"))
	qdel(src)

/// Обновляем множитель урона для текущей стадии
/datum/component/gunpoint/proc/update_stage(new_stage)
	if(check_deescalate())
		return
	stage = new_stage
	if(stage == 2)
		to_chat(parent, span_danger("Вы твёрдо наводите [weapon] на [target]."))
		to_chat(target, span_userdanger("[parent] твёрдо навёл [weapon] на вас!"))
		damage_mult = GUNPOINT_MULT_STAGE_2
		addtimer(CALLBACK(src, PROC_REF(update_stage), 3), GUNPOINT_DELAY_STAGE_3)
	else if(stage == 3)
		to_chat(parent, span_danger("Вы полностью сфокусировали [weapon] на [target]."))
		to_chat(target, span_userdanger("[parent] полностью сфокусировал [weapon] на вас!"))
		damage_mult = GUNPOINT_MULT_STAGE_3

///Cancel the holdup if the shooter moves out of sight or out of range of the target
/datum/component/gunpoint/proc/check_deescalate()
	SIGNAL_HANDLER

	if(!can_see(parent, target, GUNPOINT_SHOOTER_STRAY_RANGE))
		cancel()
		return TRUE

///Bang bang, we're firing a charged shot off
/datum/component/gunpoint/proc/trigger_reaction()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(async_trigger_reaction))

/datum/component/gunpoint/proc/async_trigger_reaction()
	var/mob/living/shooter = parent
	shooter.remove_status_effect(/datum/status_effect/holdup) // try doing these before the trigger gets pulled since the target (or shooter even) may not exist after pulling the trigger, dig?
	target.remove_status_effect(/datum/status_effect/grouped/heldup, REF(shooter))
	target.clear_mood_event("gunpoint")

	if(point_of_no_return)
		return
	point_of_no_return = TRUE

	if(weapon.chambered && weapon.chambered.loaded_projectile)
		weapon.chambered.loaded_projectile.damage *= damage_mult
		if(weapon.chambered.loaded_projectile.wound_bonus != CANT_WOUND)
			weapon.chambered.loaded_projectile.wound_bonus += damage_mult * GUNPOINT_BASE_WOUND_BONUS
			weapon.chambered.loaded_projectile.exposed_wound_bonus += damage_mult * GUNPOINT_BASE_WOUND_BONUS

	var/fired = weapon.fire_gun(target, shooter)
	if(!fired && weapon.chambered?.loaded_projectile)
		weapon.chambered.loaded_projectile.damage /= damage_mult
		if(weapon.chambered.loaded_projectile.wound_bonus != CANT_WOUND)
			weapon.chambered.loaded_projectile.wound_bonus -= damage_mult * GUNPOINT_BASE_WOUND_BONUS
			weapon.chambered.loaded_projectile.exposed_wound_bonus -= damage_mult * GUNPOINT_BASE_WOUND_BONUS

	qdel(src)

/// Стрелок отменил выстрел - либо уронил/сменил оружие, либо вышел из зоны видимости/дистанции, либо нажал на уведомление
/datum/component/gunpoint/proc/cancel()
	SIGNAL_HANDLER

	var/mob/living/shooter = parent
	shooter.visible_message(span_danger("[shooter] прекращает удерживать прицел на [target]!"), \
		span_danger("Вы больше не удерживаете [weapon] на [target]."), ignored_mobs = target)
	to_chat(target, span_userdanger("[shooter] прекращает удерживать прицел на вас!"))
	qdel(src)

/// Если стрелка атакуют, есть 50% шанс дёрнуться и выстрелить. При попадании в руку с оружием - 80%
/datum/component/gunpoint/proc/flinch(mob/living/source, damage_amount, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if(!attack_direction) // Не дёргаемся от своих действий
		return

	var/flinch_chance = 50
	var/gun_hand = IS_LEFT_INDEX(source.get_held_index_of_item(weapon)) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM

	if(isbodypart(def_zone))
		var/obj/item/bodypart/hitting = def_zone
		def_zone = hitting.body_zone

	if(def_zone == gun_hand)
		flinch_chance = 80

	if(prob(flinch_chance))
		source.visible_message(
			span_danger("[source] дёргается!"),
			span_danger("Вы дёргаетесь!"),
		)
		INVOKE_ASYNC(src, PROC_REF(trigger_reaction))

/// Показывает, что родитель держит кого-то под прицелом
/datum/component/gunpoint/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(user in viewers(target))
		examine_list += span_boldwarning("[parent] держит [target] под прицелом [weapon]!")

/// Показывает, что цель осмотра находится под прицелом
/datum/component/gunpoint/proc/examine_target(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(user in viewers(parent))
		examine_list += span_boldwarning("[target] находится под прицелом [parent]!")

/// Блокирует толчки стрелка, чтобы не сбить прицел (толчки уже обрабатываются отдельно)
/datum/component/gunpoint/proc/block_bumps_parent(mob/bumped, mob/living/bumper)
	SIGNAL_HANDLER
	to_chat(bumper, span_warning("[bumped] держит [target] под прицелом, нельзя пройти!"))
	return COMPONENT_LIVING_BLOCK_PRE_MOB_BUMP

/// Блокирует толчки цели союзниками, чтобы не форсировать выстрел
/datum/component/gunpoint/proc/block_bumps_target(mob/bumped, mob/living/bumper)
	SIGNAL_HANDLER
	to_chat(bumper, span_warning("[bumped] под прицелом, толкать [bumped.p_them()] неразумно!"))
	return COMPONENT_LIVING_BLOCK_PRE_MOB_BUMP

#undef GUNPOINT_DELAY_STAGE_2
#undef GUNPOINT_DELAY_STAGE_3
#undef GUNPOINT_BASE_WOUND_BONUS
#undef GUNPOINT_MULT_STAGE_1
#undef GUNPOINT_MULT_STAGE_2
#undef GUNPOINT_MULT_STAGE_3
