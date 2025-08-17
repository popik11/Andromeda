/datum/component/supermatter_crystal

	///Callback for the wrench act call
	var/datum/callback/tool_act_callback
	///Callback used by the SM to get the damage and matter power increase/decrease
	var/datum/callback/consume_callback
	// A whitelist of items that can interact with the SM without dusting the user
	var/static/list/sm_item_whitelist = typecacheof(list(
		/obj/item/melee/roastingstick,
		/obj/item/toy/crayon/spraycan
	))

/datum/component/supermatter_crystal/Initialize(datum/callback/tool_act_callback, datum/callback/consume_callback)

	RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, PROC_REF(blob_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_PAW, PROC_REF(paw_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(animal_hit))
	RegisterSignal(parent, COMSIG_ATOM_HULK_ATTACK, PROC_REF(hulk_hit))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(unarmed_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(hand_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby_hit))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(tool_hit))
	RegisterSignal(parent, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WRENCH), PROC_REF(tool_hit))
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, PROC_REF(bumped_hit))
	RegisterSignal(parent, COMSIG_ATOM_INTERCEPT_Z_FALL, PROC_REF(intercept_z_fall))
	RegisterSignal(parent, COMSIG_ATOM_ON_Z_IMPACT, PROC_REF(on_z_impact))

	src.tool_act_callback = tool_act_callback
	src.consume_callback = consume_callback

/datum/component/supermatter_crystal/Destroy(force)
	tool_act_callback = null
	consume_callback = null
	return ..()

/datum/component/supermatter_crystal/UnregisterFromParent(force, silent)
	var/list/signals_to_remove = list(
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH),
		COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WRENCH),
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_INTERCEPT_Z_FALL,
		COMSIG_ATOM_ON_Z_IMPACT,
	)

	UnregisterSignal(parent, signals_to_remove)

/datum/component/supermatter_crystal/proc/blob_hit(datum/source, obj/structure/blob/blob)
	SIGNAL_HANDLER
	var/atom/atom_source = source
	if(!blob || isspaceturf(atom_source)) //в космосе ничего не делает
		return
	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume_returns(damage_increase = blob.get_integrity() * 0.05)
	if(blob.get_integrity() > 100)
		blob.visible_message(span_danger("[blob] ударяет по [atom_source] и отшатывается!"),
			span_hear("Слышите громкий треск, окутывающий вас волной жара."))
		blob.take_damage(100, BURN)
	else
		blob.visible_message(span_danger("[blob] ударяет по [atom_source] и мгновенно превращается в пепел!"),
			span_hear("Слышите громкий треск, окутывающий вас волной жара."))
		consume(atom_source, blob)

/datum/component/supermatter_crystal/proc/paw_hit(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(isliving(user))
		var/mob/living/living_mob = user
		if(living_mob.incorporeal_move || HAS_TRAIT(living_mob, TRAIT_GODMODE))
			return
	if(isalien(user))
		dust_mob(source, user, cause = "alien attack")
		return
	dust_mob(source, user, cause = "monkey attack")

/datum/component/supermatter_crystal/proc/animal_hit(datum/source, mob/living/simple_animal/user, list/modifiers)
	SIGNAL_HANDLER
	if(user.incorporeal_move || HAS_TRAIT(user, TRAIT_GODMODE))
		return
	var/atom/atom_source = source
	var/murder
	if(!user.melee_damage_upper && !user.melee_damage_lower)
		murder = user.friendly_verb_continuous
	else
		murder = user.attack_verb_continuous
	dust_mob(source, user, \
	span_danger("[user] неосмотрительно [murder] [atom_source], и [user.p_their()] тело вспыхивает, превращаясь в пепел!"), \
	span_userdanger("Ты неосторожно касаешься [atom_source], и твоё тело рассыпается в пыль, пока последние проблески сознания угасают в ярком свете. Ой."), \
	"атака животного")

/datum/component/supermatter_crystal/proc/hulk_hit(datum/source, mob/user)
	SIGNAL_HANDLER
	dust_mob(source, user, cause = "hulk attack")

/datum/component/supermatter_crystal/proc/unarmed_hit(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(isliving(user))
		var/mob/living/living_mob = user
		if(living_mob.incorporeal_move || HAS_TRAIT(living_mob, TRAIT_GODMODE))
			return
	var/atom/atom_source = source
	if(iscyborg(user) && atom_source.Adjacent(user))
		dust_mob(source, user, cause = "cyborg attack")
		return
	if(iscameramob(user))
		return
	if(islarva(user))
		dust_mob(source, user, cause = "larva attack")
		return

/datum/component/supermatter_crystal/proc/hand_hit(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(user.incorporeal_move || HAS_TRAIT(user, TRAIT_GODMODE))
		return
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		dust_mob(source, user, cause = "hand")
		return
	var/atom/atom_source = source
	if(!user.is_mouth_covered())
		if(user.combat_mode)
			dust_mob(source, user,
				span_danger("[user] пытается откусить кусочек от [atom_source], но всё вокруг затихает, пока [user.p_their()] тело не начинает светиться и вспыхивает, превращаясь в пепел."),
				span_userdanger("Ты пытаешься откусить кусочек от [atom_source], но он оказывается слишком твёрдым, прежде чем всё вокруг начинает гореть, а в ушах раздаётся звон!"),
				"attempted lick"
			)
			return

		var/obj/item/organ/tongue/licking_tongue = user.get_organ_slot(ORGAN_SLOT_TONGUE)
		if(licking_tongue)
			dust_mob(source, user,
				span_danger("[user] осторожно облизывает [atom_source], но всё вокруг затихает, пока [user.p_their()] тело не начинает светиться и вспыхивает, превращаясь в пепел!"),
				span_userdanger("Ты осторожно облизываешь [atom_source], но не успеваешь распознать вкус, как всё вокруг начинает гореть, а в ушах раздаётся звон!"),
				"failed lick"
			)
			return

	var/obj/item/bodypart/head/forehead = user.get_bodypart(BODY_ZONE_HEAD)
	if(forehead)
		dust_mob(source, user,
			span_danger("Лоб [user] касается [atom_source], вызывая резонанс... Всё затихает, прежде чем [user.p_their()] [forehead] вспыхивает и превращается в пепел!"),
			span_userdanger("Ты чувствуешь, как твой лоб касается [atom_source], и внезапно всё затихает. Голова наполняется звоном, и ты понимаешь, что это было не самое мудрое решение."),
			"failed lick"
		)
		return

	dust_mob(source, user,
		span_danger("[user] наклоняется, чтобы лизнуть [atom_source], вызывая резонанс... [user.p_their()] тело начинает светиться и вспыхивает, превращаясь в пыль!"),
		span_userdanger("Ты наклоняешься, чтобы лизнуть [atom_source]. Всё вокруг начинает гореть, и ты слышишь только звон. Последняя мысль: \"Это было не самое мудрое решение.\""),
		"failed lick"
	)

/datum/component/supermatter_crystal/proc/attackby_hit(datum/source, obj/item/item, mob/living/user, params)
	SIGNAL_HANDLER
	var/atom/atom_source = source
	if(!istype(item) || (item.item_flags & ABSTRACT) || !istype(user))
		return
	if(is_type_in_typecache(item, sm_item_whitelist))
		return FALSE
	if(istype(item, /obj/item/cigarette))
		var/obj/item/cigarette/cig = item
		var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
		if(clumsy)
			var/obj/item/bodypart/dust_arm = user.get_active_hand()
			dust_arm.dismember()
			user.visible_message(span_danger("[item] исчезает в вспышке при контакте с [atom_source], резонируя с ужасающим звуком..."),\
				span_danger("Ой! [item] исчезает при контакте с [atom_source], унося с собой твою руку! Это было неловко!"))
			playsound(atom_source, 'sound/effects/supermatter.ogg', 150, TRUE)
			consume(atom_source, dust_arm)
			qdel(item)
			return
		if(cig.lit || user.combat_mode)
			user.visible_message(span_danger("Ужасный звук раздаётся, когда [item] превращается в пепел при контакте с [atom_source]. Кажется, это было плохой идеей..."))
			playsound(atom_source, 'sound/effects/supermatter.ogg', 150, TRUE)
			consume(atom_source, item)
			radiation_pulse(atom_source, max_range = 3, threshold = 0.1, chance = 50)
			return
		else
			cig.light()
			user.visible_message(span_danger("Когда [user] прикуривает [item] от [atom_source], в комнате воцаряется тишина..."),\
				span_danger("Время будто замедляется, когда ты касаешься [atom_source] [item].</span>\n<span class='notice'>[item] вспыхивает жутким светом, когда ты небрежно отдергиваешь руку от [atom_source]. Чёрт."))
			playsound(atom_source, 'sound/effects/supermatter.ogg', 50, TRUE)
			radiation_pulse(atom_source, max_range = 1, threshold = 0, chance = 100)
			return

	if(user.dropItemToGround(item))
		user.visible_message(span_danger("Когда [user] касается [atom_source] [item], в комнате воцаряется тишина..."),\
			span_userdanger("Ты касаешься [atom_source] [item], и внезапно всё затихает.</span>\n<span class='notice'>[item] рассыпается в пыль, когда ты отдергиваешь руку от [atom_source]."),\
			span_hear("Внезапно всё затихает."))
		user.investigate_log("был атакован ([item]) [key_name(user)]", INVESTIGATE_ENGINE)
		consume(atom_source, item)
		playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)

		radiation_pulse(atom_source, max_range = 3, threshold = 0.1, chance = 50)
		return

	if(atom_source.Adjacent(user)) // если предмет прикреплён к человеку, убиваем и человека тоже
		if(user.incorporeal_move || HAS_TRAIT(user, TRAIT_GODMODE))
			return
		var/vis_msg = span_danger("[user] протягивает руку и касается [atom_source] [item], вызывая резонанс... [item] ненадолго вспыхивает, прежде чем свет перекидывается на тело [user]. [user.p_They()] вспыхивает[user.p_s()] и превращается в пепел!")
		var/mob_msg = span_userdanger("Ты протягиваешь руку и касаешься [atom_source] [item]. Всё вокруг начинает гореть, и ты слышишь только звон. Последняя мысль: \"Это было не самое мудрое решение.\"")
		dust_mob(source, user, vis_msg, mob_msg)

/datum/component/supermatter_crystal/proc/tool_hit(datum/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(tool_act_callback)
		tool_act_callback.Invoke(user, tool)
		return ITEM_INTERACT_BLOCKING
	attackby_hit(source, tool, user)

/datum/component/supermatter_crystal/proc/bumped_hit(datum/source, atom/movable/hit_object)
	SIGNAL_HANDLER
	if(isliving(hit_object))
		var/mob/living/hit_mob = hit_object
		if(hit_mob.incorporeal_move || HAS_TRAIT(hit_mob, TRAIT_GODMODE))
			return
	var/atom/atom_source = source
	var/obj/machinery/power/supermatter_crystal/our_supermatter = parent // Почему это компонент?
	if(istype(our_supermatter))
		our_supermatter.log_activation(who = hit_object)
	if(isliving(hit_object))
		hit_object.visible_message(span_danger("[hit_object] врезается в [atom_source], вызывая резонанс... [hit_object.p_their()] тело начинает светиться и вспыхивает, превращаясь в пыль!"),
			span_userdanger("Ты врезаешься в [atom_source], и твои уши наполняются жутким звоном. Последняя мысль: \"Ох, чёрт.\""),
			span_hear("Слышится жуткий звук, и тебя окутывает волна жара."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("[hit_object] ударяется об [atom_source] и мгновенно превращается в пепел."), null,
			span_hear("Слышится громкий треск, и тебя окутывает волна жара."))
	else
		return

	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(atom_source, hit_object)

/datum/component/supermatter_crystal/proc/intercept_z_fall(datum/source, list/falling_movables, levels)
	SIGNAL_HANDLER
	for(var/atom/movable/hit_object as anything in falling_movables)
		if(parent == hit_object)
			return

		bumped_hit(parent, hit_object)
	return FALL_INTERCEPTED | FALL_NO_MESSAGE

/datum/component/supermatter_crystal/proc/on_z_impact(datum/source, turf/impacted_turf, levels)
	SIGNAL_HANDLER

	var/atom/atom_source = source

	for(var/mob/living/poor_target in impacted_turf)
		consume(atom_source, poor_target)
		playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
		poor_target.visible_message(span_danger("[atom_source] внезапно обрушивается на [poor_target], вызывая резонанс... [poor_target.p_their()] тело начинает светиться и вспыхивает, превращаясь в пыль!"),
			span_userdanger("[atom_source] внезапно обрушивается на тебя, уши наполняются жутким звоном. Последняя мысль: \"Чё за херня?\""),
			span_hear("Слышится жуткий звук, и тебя окутывает волна жара."))

	for(var/atom/movable/hit_object as anything in impacted_turf)
		if(parent == hit_object)
			return

		if(iseffect(hit_object))
			continue

		consume(atom_source, hit_object)
		playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
		atom_source.visible_message(span_danger("[atom_source] внезапно врезается в палубу, превращая всё вокруг в пепел."), null,
			span_hear("Слышится громкий треск, и тебя окутывает волна жара."))

/datum/component/supermatter_crystal/proc/dust_mob(datum/source, mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || HAS_TRAIT(nom, TRAIT_GODMODE)) // сохраняем синхронизацию условий распыления с суперматерией и гемостатом
		return
	var/atom/atom_source = source
	if(!vis_msg)
		vis_msg = span_danger("[nom] протягивает руку и касается [atom_source], вызывая резонанс... [nom.p_their()] тело начинает светиться и вспыхивает, превращаясь в пыль!")
	if(!mob_msg)
		mob_msg = span_userdanger("Ты протягиваешь руку и касаешься [atom_source]. Всё вокруг начинает гореть, и ты слышишь только звон. Последняя мысль: \"Это было не самое мудрое решение.\"")
	if(!cause)
		cause = "контакт"
	nom.visible_message(vis_msg, mob_msg, span_hear("Слышится жуткий звук, и тебя окутывает волна жара."))
	atom_source.investigate_log("атакован ([cause]) [key_name(nom)]", INVESTIGATE_ENGINE)
	add_memory_in_range(atom_source, 7, /datum/memory/witness_supermatter_dusting, protagonist = nom, antagonist = atom_source)
	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(atom_source, nom)

/datum/component/supermatter_crystal/proc/consume(atom/source, atom/movable/consumed_object)
	if(consumed_object.flags_1 & SUPERMATTER_IGNORES_1)
		return
	if(HAS_TRAIT(consumed_object, TRAIT_GODMODE))
		return

	var/atom/atom_source = source
	SEND_SIGNAL(consumed_object, COMSIG_SUPERMATTER_CONSUMED, atom_source)

	var/object_size = 0
	var/matter_increase = 0
	var/damage_increase = 0
	var/radiation_range = 6
	var/effects_calculated = FALSE

	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		object_size = consumed_mob.mob_size + 2
		message_admins("[atom_source] поглотил [key_name_admin(consumed_mob)] [ADMIN_JMP(atom_source)].")
		atom_source.investigate_log("поглотил [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.investigate_log("был распылен [atom_source].", INVESTIGATE_DEATHS)
		if(istype(consumed_mob, /mob/living/basic/parrot/poly)) // Уничтожение Поли вызывает скачок энергии
			force_event(/datum/round_event_control/supermatter_surge/poly, "Месть Поли")
			notify_ghosts(
				"[consumed_mob.real_name] был распылен [atom_source]!",
				source = atom_source,
				header = "Политехнические трудности",
			)
		consumed_mob.dust(force = TRUE)
		matter_increase += 100 * object_size * 2
		if(is_clown_job(consumed_mob.mind?.assigned_role))
			damage_increase += rand(-30, 30) * 2 // HONK
		effects_calculated = TRUE
	else if(isobj(consumed_object))
		if(!iseffect(consumed_object))
			var/suspicion = ""
			if(consumed_object.fingerprintslast)
				suspicion = "последний контакт: [consumed_object.fingerprintslast]"
				message_admins("[atom_source] поглотил [consumed_object], [suspicion] [ADMIN_JMP(atom_source)].")
			atom_source.investigate_log("поглотил [consumed_object] - [suspicion].", INVESTIGATE_ENGINE)

		var/is_nuke = FALSE
		if (consumed_object.type == /obj/item/nuke_core) // No subtypes, the supermatter sliver shouldn't trigger this
			is_nuke = TRUE
		else if (istype(consumed_object, /obj/machinery/nuclearbomb))
			var/obj/machinery/nuclearbomb/bomb = consumed_object
			is_nuke = !!bomb.core

		if (is_nuke)
			object_size = 10
			radiation_range *= 2
			matter_increase += 10000
			damage_increase += 110
			effects_calculated = TRUE

		qdel(consumed_object)

	if(!iseffect(consumed_object) && !effects_calculated)
		if(isitem(consumed_object))
			var/obj/item/consumed_item = consumed_object
			object_size = consumed_item.w_class
			matter_increase += 70 * object_size
		else
			matter_increase += min(0.5 * consumed_object.max_integrity, 1000)

	//Какой-то бедолага был поглощён, пора облучить окружающих
	radiation_pulse(atom_source, max_range = radiation_range, threshold = 1.2 / max(object_size, 1), chance = 10 * object_size)
	for(var/mob/living/near_mob in range(10))
		atom_source.investigate_log("облучил [key_name(near_mob)] после поглощения [consumed_object].", INVESTIGATE_ENGINE)
		if (HAS_TRAIT(near_mob, TRAIT_RADIMMUNE) || issilicon(near_mob))
			continue
		if(ishuman(near_mob) && SSradiation.wearing_rad_protected_clothing(near_mob))
			continue
		if(near_mob in view())
			near_mob.show_message(span_danger("Когда [atom_source] перестаёт резонировать, твоя кожа покрывается свежими радиационными ожогами."), MSG_VISUAL,
				span_danger("Жуткий звон стихает, и твоя кожа покрывается свежими радиационными ожогами."), MSG_AUDIBLE)
		else
			near_mob.show_message(span_hear("Жуткий звон наполняет твои уши, а кожа покрывается свежими радиационными ожогами."), MSG_AUDIBLE)
	consume_returns(matter_increase, damage_increase)
	var/obj/machinery/power/supermatter_crystal/our_crystal = parent
	if(istype(our_crystal))
		our_crystal.log_activation(who = consumed_object)

/datum/component/supermatter_crystal/proc/consume_returns(matter_increase = 0, damage_increase = 0)
	if(consume_callback)
		consume_callback.Invoke(matter_increase, damage_increase)
