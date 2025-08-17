/// Component which allows mobs to be smashed onto this surface like a wrestling move
/datum/component/table_smash
	/// If true, mobs will be placed gently on the table even if they're in an aggressive grab
	var/gentle_push
	/// Callback invoked after a hostile table action
	var/datum/callback/after_smash

/datum/component/table_smash/Initialize(gentle_push = FALSE, after_smash = null)
	. = ..()
	if (!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	src.gentle_push = gentle_push
	src.after_smash = after_smash

/datum/component/table_smash/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_interaction))
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))

	var/static/list/loc_connections = list(
		COMSIG_LIVING_DISARM_COLLIDE = PROC_REF(on_pushed_into),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/table_smash/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ITEM_INTERACTION))

/// Called when someone clicks on our surface
/datum/component/table_smash/proc/on_interaction(obj/table, mob/user)
	SIGNAL_HANDLER

	if (!table.Adjacent(user) || !user.pulling)
		return

	if (!isliving(user.pulling))
		if (!(user.pulling.pass_flags & PASSTABLE))
			return

		user.Move_Pulled(table)

		if (user.pulling.loc == table.loc)
			user.visible_message(span_notice("[user] кладёт [user.pulling] на [table]."),
				span_notice("Ты кладёшь [user.pulling] на [table]."))
			user.stop_pulling()

		return COMPONENT_CANCEL_ATTACK_CHAIN

	var/mob/living/pushed_mob = user.pulling
	if (pushed_mob.buckled)
		if (pushed_mob.buckled == table)
			//Already buckled to the table, you probably meant to unbuckle them
			return

		to_chat(user, span_warning("[pushed_mob] пристёгнут к [pushed_mob.buckled]!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(perform_table_smash), table, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// We have a mob being pressed onto the table, but how strongly?
/datum/component/table_smash/proc/perform_table_smash(obj/table, mob/living/user)
	var/mob/living/pushed_mob = user.pulling
	if (user.combat_mode)
		switch(user.grab_state)
			if (GRAB_PASSIVE)
				to_chat(user, span_warning("Нужно крепче схватить для этого!"))
				return
			if (GRAB_AGGRESSIVE)
				if (gentle_push)
					tableplace(user, pushed_mob)
				else
					tablepush(user, pushed_mob)
			if (GRAB_NECK to GRAB_KILL)
				tablelimbsmash(user, pushed_mob)
	else
		pushed_mob.visible_message(span_notice("[user] начинает укладывать [pushed_mob] на [table]..."), \
							span_userdanger("[user] начинает укладывать тебя на [table]..."))
		if (do_after(user, 3.5 SECONDS, target = pushed_mob))
			tableplace(user, pushed_mob)
		else
			return

	user.stop_pulling()

/// Called when someone clicks on our surface with an item
/datum/component/table_smash/proc/on_item_interaction(obj/table, mob/living/user, obj/item/item, modifiers)
	SIGNAL_HANDLER
	if (!istype(item, /obj/item/riding_offhand))
		return NONE

	var/obj/item/riding_offhand/riding_item = item
	var/mob/living/carried_mob = riding_item.rider
	if (carried_mob == user) //Piggyback user.
		return NONE

	INVOKE_ASYNC(src, PROC_REF(riding_offhand_act), user, item)
	return ITEM_INTERACT_BLOCKING

/// Called when someone clicks on our surface using a fireman's carry
/datum/component/table_smash/proc/riding_offhand_act(mob/living/user, obj/item/riding_offhand/riding_item)
	var/mob/living/carried_mob = riding_item.rider
	if (user.combat_mode)
		user.unbuckle_mob(carried_mob)
		tablelimbsmash(user, carried_mob)
		return ITEM_INTERACT_SUCCESS

	var/tableplace_delay = 3.5 SECONDS
	var/skills_space = ""
	if (HAS_TRAIT(user, TRAIT_QUICKER_CARRY))
		tableplace_delay = 2 SECONDS
		skills_space = " умело"
	else if (HAS_TRAIT(user, TRAIT_QUICK_CARRY))
		tableplace_delay = 2.75 SECONDS
		skills_space = " быстро"

	var/obj/item/organ/cyberimp/chest/spine/potential_spine = user.get_organ_slot(ORGAN_SLOT_SPINE)
	if (istype(potential_spine))
		tableplace_delay *= potential_spine.athletics_boost_multiplier

	carried_mob.visible_message(span_notice("[user] начинает[skills_space] укладывать [carried_mob] на [parent]..."),
		span_userdanger("[user] начинает[skills_space] укладывать тебя на [parent]..."))
	if (!do_after(user, tableplace_delay, target = carried_mob))
		return ITEM_INTERACT_BLOCKING
	user.unbuckle_mob(carried_mob)
	tableplace(user, carried_mob)
	return ITEM_INTERACT_SUCCESS

/// Gently place the mob onto the table
/datum/component/table_smash/proc/tableplace(mob/living/user, mob/living/pushed_mob)
	var/obj/table = parent
	pushed_mob.forceMove(table.loc)
	pushed_mob.set_resting(TRUE, TRUE)
	pushed_mob.visible_message(span_notice("[user] кладёт [pushed_mob] на [parent]."), \
		span_notice("[user] кладёт тебя на [parent]."))
	log_combat(user, pushed_mob, "положил", null, "на [parent]")

/// Aggressively smash the mob onto the table
/datum/component/table_smash/proc/tablepush(mob/living/user, mob/living/pushed_mob)
	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_danger("Бросание [pushed_mob] на стол может причинить боль!"))
		return

	var/passtable_key = REF(user)
	passtable_on(pushed_mob, passtable_key)
	for (var/obj/obj in user.loc.contents)
		if (!obj.CanAllowThrough(pushed_mob))
			return

	var/obj/table = parent
	pushed_mob.Move(table.loc)
	passtable_off(pushed_mob, passtable_key)
	if (pushed_mob.loc != table.loc) //Something prevented the tabling
		return

	pushed_mob.Knockdown(3 SECONDS)
	pushed_mob.apply_damage(10, BRUTE)
	pushed_mob.apply_damage(40, STAMINA)
	playsound(pushed_mob, 'sound/effects/tableslam.ogg', 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] швыряет [pushed_mob] на [parent]!"), \
		span_userdanger("[user] швыряет тебя на [parent]!"))
	log_combat(user, pushed_mob, "швырнул", null, "на [parent]")
	pushed_mob.add_mood_event("table", /datum/mood_event/table)
	SEND_SIGNAL(user, COMSIG_LIVING_TABLE_SLAMMING, pushed_mob, parent)
	after_smash?.Invoke(pushed_mob)

/// Even more aggressively smash a single part of a mob onto the table
/datum/component/table_smash/proc/tablelimbsmash(mob/living/user, mob/living/pushed_mob)
	var/obj/table = parent
	pushed_mob.Knockdown(3 SECONDS)
	var/obj/item/bodypart/banged_limb = pushed_mob.get_bodypart(user.zone_selected) || pushed_mob.get_bodypart(BODY_ZONE_HEAD)
	var/extra_wound = 0
	if (HAS_TRAIT(user, TRAIT_HULK))
		extra_wound = 20
	pushed_mob.apply_damage(30, BRUTE, banged_limb, wound_bonus = extra_wound)
	pushed_mob.apply_damage(60, STAMINA)
	playsound(pushed_mob, 'sound/effects/bang.ogg', 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] с размаху бьёт [pushed_mob] [banged_limb.plaintext_zone] об [parent]!"),
		span_userdanger("[user] с размаху бьёт твою [banged_limb.plaintext_zone] об [parent]"))
	log_combat(user, pushed_mob, "ударил головой", null, "об [parent]")
	pushed_mob.add_mood_event("table", /datum/mood_event/table_limbsmash, banged_limb)
	table.take_damage(50)
	SEND_SIGNAL(user, COMSIG_LIVING_TABLE_LIMB_SLAMMING, pushed_mob, parent)
	after_smash?.Invoke(pushed_mob)

/// Called when someone is shoved into our tile
/datum/component/table_smash/proc/on_pushed_into(turf/source, mob/living/shover, mob/living/target, shove_flags, obj/item/weapon)
	SIGNAL_HANDLER
	if((shove_flags & SHOVE_KNOCKDOWN_BLOCKED) || !(shove_flags & SHOVE_BLOCKED))
		return
	target.Knockdown(SHOVE_KNOCKDOWN_TABLE, daze_amount = 3 SECONDS)
	target.visible_message(span_danger("[shover.name] толкает [target.name] на [parent]!"),
		span_userdanger("[shover.name] толкает тебя на [parent]!"), span_hear("Слышится агрессивная возня и громкий удар!"), COMBAT_MESSAGE_RANGE, shover)
	to_chat(shover, span_danger("Ты толкаешь [target.name] на [parent]!"))
	target.throw_at(parent, 1, 1, null, FALSE) //Бросок с малой скоростью без вращения - фактически просто перемещение с проверкой столкновения
	log_combat(shover, target, "толкнул", "на [parent] (стол)[weapon ? " используя [weapon]" : ""]")
	after_smash?.Invoke(target)
	return COMSIG_LIVING_SHOVE_HANDLED
