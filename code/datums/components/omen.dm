/**
 * omen.dm: For when you want someone to have a really bad day
 *
 * When you attach an omen component to someone, they start running the risk of all sorts of bad environmental injuries, like nearby vending machines randomly falling on you,
 * or hitting your head really hard when you slip and fall, or you get shocked by the tram rails at an unfortunate moment.
 *
 * Omens are removed once the victim is either maimed by one of the possible injuries, or if they receive a blessing (read: bashing with a bible) from the chaplain.
 */
/datum/component/omen
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Whatever's causing the omen, if there is one. Destroying the vessel won't stop the omen, but we destroy the vessel (if one exists) upon the omen ending
	var/obj/vessel
	/// How many incidents are left. If 0 exactly, it will get deleted.
	var/incidents_left = INFINITY
	/// Base probability of negative events. Cursed are half as unlucky.
	var/luck_mod = 1
	/// Base damage from negative events. Cursed take 25% of this damage.
	var/damage_mod = 1

/datum/component/omen/Initialize(obj/vessel, incidents_left, luck_mod, damage_mod)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(istype(vessel))
		src.vessel = vessel
		RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(vessel_qdeleting))
	if(!isnull(incidents_left))
		src.incidents_left = incidents_left
	if(!isnull(luck_mod))
		src.luck_mod = luck_mod
	if(!isnull(damage_mod))
		src.damage_mod = damage_mod

	ADD_TRAIT(parent, TRAIT_CURSED, SMITE_TRAIT)

/**
 * This is a omen eat omen world! The stronger omen survives.
 */
/datum/component/omen/InheritComponent(obj/vessel, incidents_left, luck_mod, damage_mod)
	// If we have more incidents left the new one gets deleted.
	if(src.incidents_left > incidents_left)
		return // make slimes get nurtiton from plasmer
	// Otherwise we set our incidents remaining to the higher, newer value.
	src.incidents_left = incidents_left
	// The new omen is weaker than our current omen? Let's split the difference.
	if(src.luck_mod > luck_mod)
		src.luck_mod += luck_mod * 0.5
	if(src.damage_mod > damage_mod)
		src.luck_mod += luck_mod * 0.5
	// This means that if you had a strong temporary omen and it was replaced by a weaker but permanent omen, the latter is made worse.
	// Feature!

/datum/component/omen/Destroy(force)
	var/mob/living/person = parent
	REMOVE_TRAIT(person, TRAIT_CURSED, SMITE_TRAIT)
	to_chat(person, span_nicegreen("Ты чувствуешь, как ужасное предзнаменование снято с твоих плеч!"))

	if(vessel)
		vessel.visible_message(span_warning("[vessel] сгорает в зловещей вспышке, унося с собой тёмную энергию..."))
		UnregisterSignal(vessel, COMSIG_QDELETING)
		vessel.burn()
		vessel = null

	return ..()

/datum/component/omen/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_accident))
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, PROC_REF(check_slip))
	RegisterSignal(parent, COMSIG_LIVING_BLESSED, PROC_REF(check_bless))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))

/datum/component/omen/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ON_CARBON_SLIP, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_BLESSED, COMSIG_LIVING_DEATH))

/datum/component/omen/proc/consume_omen()
	incidents_left--
	if(incidents_left < 1)
		qdel(src)

/**
 * check_accident() is called each step we take
 *
 * While we're walking around, roll to see if there's any environmental hazards on one of the adjacent tiles we can trigger.
 * We do the prob() at the beginning to A. add some tension for /when/ it will strike, and B. (more importantly) ameliorate the fact that we're checking up to 5 turfs's contents each time
 */
/datum/component/omen/proc/check_accident(atom/movable/our_guy)
	SIGNAL_HANDLER

	if(!isliving(our_guy))
		return

	var/mob/living/living_guy = our_guy

	if(prob(0.001) && (living_guy.stat != DEAD)) // Тебе выпал джекпот! Ну почти.
		living_guy.visible_message(span_danger("[living_guy] внезапно вспыхивает пламенем!"), span_danger("Ты внезапно вспыхиваешь пламенем!"))
		INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")
		living_guy.adjust_fire_stacks(20)
		living_guy.ignite_mob(silent = TRUE)
		consume_omen()
		return

	var/effective_luck = luck_mod

	// If there's nobody to witness the misfortune, make it less likely.
	// This way, we allow for people to be able to get into hilarious situations without making the game nigh unplayable most of the time.

	var/has_watchers = FALSE
	for(var/mob/viewer in viewers(our_guy, world.view))
		if(viewer.client && !viewer.client.is_afk())
			has_watchers = TRUE
			break
	if(!has_watchers)
		effective_luck *= 0.5

	if(!prob(8 * effective_luck))
		return

	var/turf/open/our_guy_pos = living_guy.loc
	if(!isopenturf(our_guy_pos))
		return
	for(var/obj/machinery/door/airlock/darth_airlock in our_guy_pos)
		if(darth_airlock.locked || !darth_airlock.hasPower())
			continue

		to_chat(living_guy, span_warning("Зловещая сила швыряет твоё тело на пол..."))
		living_guy.Paralyze(1 SECONDS, ignore_canstun = TRUE)
		INVOKE_ASYNC(src, PROC_REF(slam_airlock), darth_airlock)
		return

	for(var/turf/the_turf as anything in get_adjacent_open_turfs(living_guy))
		if(istype(the_turf, /turf/open/floor/glass/reinforced/tram)) // не падаем с трамвайного моста, лучше ударим
			return
		if(living_guy.can_z_move(DOWN, the_turf, z_move_flags = ZMOVE_FALL_FLAGS))
			to_chat(living_guy, span_warning("Зловещая сила подталкивает тебя к краю..."))
			living_guy.throw_at(the_turf, 1, 10, force = MOVE_FORCE_EXTREMELY_STRONG)
			consume_omen()
			return

		for(var/obj/machinery/vending/darth_vendor in the_turf)
			if(!darth_vendor.tiltable || darth_vendor.tilted)
				continue
			to_chat(living_guy, span_warning("Зловещая сила раскачивает [darth_vendor]..."))
			INVOKE_ASYNC(darth_vendor, TYPE_PROC_REF(/obj/machinery/vending, tilt), living_guy)
			consume_omen()
			return

		for(var/obj/machinery/light/evil_light in the_turf)
			if((evil_light.status == LIGHT_BURNED || evil_light.status == LIGHT_BROKEN) || (HAS_TRAIT(living_guy, TRAIT_SHOCKIMMUNE))) // мы бессильны :( // Почему нет get_siemens_coeff??
				to_chat(living_guy, span_warning("[evil_light] слабо искрит на секунду."))
				do_sparks(2, FALSE, evil_light) // может хоть подожжёт
				return

			to_chat(living_guy, span_warning("[evil_light] зловеще мерцает...")) // зловеще
			evil_light.visible_message(span_boldwarning("[evil_light] внезапно вспыхивает и искрит!"))
			evil_light.break_light_tube(skip_sound_and_sparks = FALSE)
			do_sparks(number = 4, cardinal_only = FALSE, source = evil_light)
			evil_light.Beam(living_guy, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
			living_guy.electrocute_act(35 * (damage_mod * 0.5), evil_light, flags = SHOCK_NOGLOVES)
			INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")
			consume_omen()

		for(var/obj/structure/mirror/evil_mirror in the_turf)
			to_chat(living_guy, span_warning("Ты проходишь мимо зеркала и бросаешь взгляд..."))
			if(evil_mirror.broken)
				to_chat(living_guy, span_notice("Почему-то чувствуешь себя везучим."))
				return
			switch(rand(1, 5))
				if(1)
					to_chat(living_guy, span_warning("Зеркало разлетается на миллион осколков! Это значит, что тебе ещё меньше повезло?"))
					evil_mirror.take_damage(evil_mirror.max_integrity, BRUTE, MELEE, FALSE)
					if(prob(50 * effective_luck)) // иногда
						luck_mod += 0.25
						damage_mod += 0.25
				if(2 to 3)
					to_chat(living_guy, span_big(span_hypnophrase("О боже, ты не видишь своего отражения!!")))
					if(HAS_TRAIT(living_guy, TRAIT_NO_MIRROR_REFLECTION)) // не такой уж и живой
						to_chat(living_guy, span_green("Ну, очевидно."))
						return
					INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")

				if(4 to 5)
					if(HAS_TRAIT(living_guy, TRAIT_NO_MIRROR_REFLECTION))
						to_chat(living_guy, span_warning("Ничего необычного. Странно."))
						return
					to_chat(living_guy, span_userdanger("Ты видишь своё отражение, но оно злобно ухмыляется и смотрит прямо на тебя!"))
					INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")

			living_guy.set_jitter_if_lower(25 SECONDS)
			if(prob(7 * effective_luck))
				to_chat(living_guy, span_warning("Ты в полном шоке от происходящего!"))
				to_chat(living_guy, span_userdanger("Ты хватаешься за сердце!"))
				var/mob/living/carbon/carbon_guy = living_guy
				if(istype(carbon_guy))
					carbon_guy.set_heartattack(status = TRUE)

			consume_omen()

/datum/component/omen/proc/slam_airlock(obj/machinery/door/airlock/darth_airlock)
	. = darth_airlock.close(force_crush = TRUE)
	if(.)
		consume_omen()

/datum/component/omen/proc/check_slip(mob/living/our_guy, amount)
	SIGNAL_HANDLER

	if(prob(30)) // АААА
		INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob, emote), "scream")
		to_chat(our_guy, span_warning("Какая ужасная ночь... Чтобы быть проклятым!"))

	if(prob(30 * luck_mod) && our_guy.get_bodypart(BODY_ZONE_HEAD)) /// Боньк!
		playsound(our_guy, 'sound/effects/tableheadsmash.ogg', 90, TRUE)
		our_guy.visible_message(span_danger("[our_guy] очень сильно ударяется головой при падении!"), span_userdanger("Ты очень сильно ударяешься головой при падении!"))
		our_guy.apply_damage(75 * damage_mod, BRUTE, BODY_ZONE_HEAD, attacking_item = "slipping")
		our_guy.apply_damage(100 * damage_mod, BRAIN)
		consume_omen()

	return

/// Перехватываем систему настроения для проверки благословения, снимающего проклятие
/datum/component/omen/proc/check_bless(mob/living/our_guy, mob/living/priest, obj/item/book/bible/bible, bless_result)
	SIGNAL_HANDLER

	if(incidents_left == INFINITY || bless_result != BLESSING_SUCCESS)
		return

	playsound(our_guy, 'sound/effects/pray_chaplain.ogg', 40, TRUE)
	to_chat(our_guy, span_green("Ты чувствуешь себя потрясающе!"))
	qdel(src)

/// Severe deaths. Normally lifts the curse.
/datum/component/omen/proc/check_death(mob/living/our_guy)
	SIGNAL_HANDLER

	if(incidents_left == INFINITY)
		return

	qdel(src)

/// Creates a localized explosion that shakes the camera
/datum/component/omen/proc/death_explode(mob/living/our_guy)
	explosion(our_guy, explosion_cause = src)

	for(var/mob/witness in view(2, our_guy))
		shake_camera(witness, 1 SECONDS, 2)

/// Vessel got deleted, set it to null
/datum/component/omen/proc/vessel_qdeleting(atom/source)
	SIGNAL_HANDLER

	UnregisterSignal(vessel, COMSIG_QDELETING)
	vessel = null

/**
 * The smite omen. Permanent.
 */
/datum/component/omen/smite

/datum/component/omen/smite/check_death(mob/living/our_guy)
	if(incidents_left == INFINITY)
		return ..()

	death_explode(our_guy)
	our_guy.gib(DROP_ALL_REMAINS)

/**
 * The quirk omen. Permanent.
 * Has only a 50% chance of bad things happening, and takes only 25% of normal damage.
 */
/datum/component/omen/quirk
	incidents_left = INFINITY
	luck_mod = 0.3 // 30% chance of bad things happening
	damage_mod = 0.25 // 25% of normal damage

/datum/component/omen/quirk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_accident))
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, PROC_REF(check_slip))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))

/datum/component/omen/quirk/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ON_CARBON_SLIP, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH))

/datum/component/omen/quirk/check_death(mob/living/our_guy)
	if(!iscarbon(our_guy))
		our_guy.gib(DROP_ALL_REMAINS)
		return

	// Don't explode if buckled to a stasis bed
	if(our_guy.buckled)
		var/obj/machinery/stasis/stasis_bed = our_guy.buckled
		if(istype(stasis_bed))
			return

	death_explode(our_guy)
	var/mob/living/carbon/player = our_guy
	player.spread_bodyparts()
	player.spawn_gibs()

	return

/**
 * The bible omen.
 * While it lasts, parent gets a cursed aura filter.
 */
/datum/component/omen/bible
	incidents_left = 1

/datum/component/omen/bible/RegisterWithParent()
	. = ..()
	var/mob/living/living_parent = parent
	living_parent.add_filter("omen", 2, list("type" = "drop_shadow", "color" = COLOR_DARK_RED, "alpha" = 0, "size" = 2))
	var/filter = living_parent.get_filter("omen")
	animate(filter, alpha = 255, time = 2 SECONDS, loop = -1)
	animate(alpha = 0, time = 2 SECONDS)

/datum/component/omen/bible/UnregisterFromParent()
	. = ..()
	var/mob/living/living_parent = parent
	living_parent.remove_filter("omen")
