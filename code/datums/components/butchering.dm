/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed = 8 SECONDS
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness = 100
	/// Percentage increase to bonus item chance
	var/bonus_modifier = 0
	/// Sound played when butchering
	var/butcher_sound = 'sound/effects/butcher.ogg'
	/// Whether or not this component can be used to butcher currently. Used to temporarily disable butchering
	var/butchering_enabled = TRUE
	/// Whether or not this component is compatible with blunt tools.
	var/can_be_blunt = FALSE
	/// Callback for butchering
	var/datum/callback/butcher_callback

/datum/component/butchering/Initialize(
	speed = 8 SECONDS,
	effectiveness = 100,
	bonus_modifier = 0,
	butcher_sound = 'sound/effects/butcher.ogg',
	disabled = FALSE,
	can_be_blunt = FALSE,
	butcher_callback,
)
	src.speed = speed
	src.effectiveness = effectiveness
	src.bonus_modifier = bonus_modifier
	src.butcher_sound = butcher_sound
	if(disabled)
		src.butchering_enabled = FALSE
	src.can_be_blunt = can_be_blunt
	src.butcher_callback = butcher_callback
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(onItemAttack))

/datum/component/butchering/Destroy(force)
	butcher_callback = null
	return ..()

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	if(!user.combat_mode)
		return
	if(M.stat == DEAD && (M.butcher_results || M.guaranteed_butcher_results)) //can we butcher it?
		if(butchering_enabled && (can_be_blunt || source.get_sharpness()))
			INVOKE_ASYNC(src, PROC_REF(startButcher), source, M, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(M) && source.force && source.get_sharpness())
		var/mob/living/carbon/human/H = M
		if((user.pulling == H && user.grab_state >= GRAB_AGGRESSIVE) && user.zone_selected == BODY_ZONE_HEAD) // Только агрессивный захват позволяет резать.
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, span_warning("Вы не хотите причинять вред живым существам!"))
				return COMPONENT_CANCEL_ATTACK_CHAIN

			if(H.has_status_effect(/datum/status_effect/neck_slice))
				return

			INVOKE_ASYNC(src, PROC_REF(startNeckSlice), source, H, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/M, mob/living/user)
	to_chat(user, span_notice("Вы начинаете разделывать [M]..."))
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_after(user, speed, M) && M.Adjacent(source))
		on_butchering(user, M)

/datum/component/butchering/proc/startNeckSlice(obj/item/source, mob/living/carbon/human/H, mob/living/user)
	if(DOING_INTERACTION_WITH_TARGET(user, H))
		to_chat(user, span_warning("Вы уже взаимодействуете с [H]!"))
		return

	user.visible_message(span_danger("[user] перерезает горло [H]!"), \
					span_danger("Вы начинаете резать горло [H]!"), \
					span_hear("Слышите режущий звук!"), ignored_mobs = H)
	H.show_message(span_userdanger("[user] перерезает вам горло!"), MSG_VISUAL, \
					span_userdanger("Что-то режет вашу шею!"), NONE)
	log_combat(user, H, "попытка перерезать горло", source)

	playsound(H.loc, butcher_sound, 50, TRUE, -1)
	if(do_after(user, clamp(500 / source.force, 30, 100), H) && H.Adjacent(source))
		if(H.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message(span_warning("Горло [H] уже порезано, вы не можете усугубить кровотечение!"), MSG_VISUAL, \
							span_warning("Горло уже порезано, вы не можете усугубить кровотечение!"))
			return

		H.visible_message(span_danger("[user] перерезает горло [H]!"), \
					span_userdanger("[user] перерезает вам горло..."))
		log_combat(user, H, "рана от перерезания горла", source)
		H.apply_damage(source.force, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND) // полегче, мы ещё до этого дойдём
		var/obj/item/bodypart/slit_throat = H.get_bodypart(BODY_ZONE_HEAD)
		if (H.cause_wound_of_type_and_severity(WOUND_SLASH, slit_throat, WOUND_SEVERITY_CRITICAL))
			H.apply_status_effect(/datum/status_effect/neck_slice)

/**
 * Обрабатывает процесс разделки моба
 *
 * Аргументы:
 * - [butcher][/mob/living]: Моб, выполняющий разделку
 * - [target][/mob/living]: Моб, которого разделывают
 */
/datum/component/butchering/proc/on_butchering(atom/butcher, mob/living/target)
	var/list/results = list()
	var/turf/location = target.drop_location()
	var/final_effectiveness = effectiveness - target.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) // например, 125 общей эффективности = 25% дополнительного шанса

	if(target.flags_1 & HOLOGRAM_1)
		butcher.visible_message(span_notice("[butcher] пытается разделать [target], но тот исчезает."), \
			span_notice("Вы пытаетесь разделать [target], но он исчезает."))
		qdel(target)
		return

	for(var/result_typepath in target.butcher_results)
		var/obj/remains = result_typepath
		var/amount = target.butcher_results[remains]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, span_warning("Вам не удаётся собрать часть [initial(remains.name)] с [target]."))
				continue

			if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, span_info("Вы собрали дополнительно [initial(remains.name)] с [target]!"))
				results += new remains (location)
			results += new remains (location)

		target.butcher_results.Remove(remains) //in case you want to, say, have it drop its results on gib

	for(var/guaranteed_result_typepath in target.guaranteed_butcher_results)
		var/obj/guaranteed_remains = guaranteed_result_typepath
		var/amount = target.guaranteed_butcher_results[guaranteed_remains]
		for(var/i in 1 to amount)
			results += new guaranteed_remains (location)
		target.guaranteed_butcher_results.Remove(guaranteed_remains)

	for(var/obj/item/carrion in results)
		var/list/meat_mats = carrion.has_material_type(/datum/material/meat)
		if(!length(meat_mats))
			continue
		carrion.set_custom_materials((carrion.custom_materials - meat_mats) + list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, target) = counterlist_sum(meat_mats)))

	// transfer delicious reagents to meat
	if(target.reagents)
		var/meat_produced = 0
		for(var/obj/item/food/meat/slab/target_meat in results)
			meat_produced += 1
		for(var/obj/item/food/meat/slab/target_meat in results)
			target.reagents.trans_to(target_meat, target.reagents.total_volume / meat_produced, remove_blacklisted = TRUE)

	// dont forget yummy diseases either!
	if(iscarbon(target))
		var/mob/living/carbon/host_target = target
		var/list/diseases = host_target.get_static_viruses()
		if(LAZYLEN(diseases))
			var/list/datum/disease/diseases_to_add = list()
			for(var/datum/disease/disease as anything in diseases)
				// admin or special viruses that should not be reproduced
				if(disease.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
					continue

				diseases_to_add += disease
			if(LAZYLEN(diseases_to_add))
				for(var/obj/diseased_remains in results)
					diseased_remains.AddComponent(/datum/component/infective, diseases_to_add)

	if(butcher)
		butcher.visible_message(span_notice("[butcher] разделывает [target]."), \
			span_notice("Вы разделали [target]."))
	butcher_callback?.Invoke(butcher, target)
	target.harvest(butcher)
	target.log_message("был разделано [key_name(butcher)]", LOG_ATTACK)
	target.gib(DROP_BRAIN|DROP_ORGANS)

///Enables the butchering mechanic for the mob who has equipped us.
/datum/component/butchering/proc/enable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = TRUE

///Disables the butchering mechanic for the mob who has dropped us.
/datum/component/butchering/proc/disable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = FALSE

///Special snowflake component only used for the recycler.
/datum/component/butchering/recycler


/datum/component/butchering/recycler/Initialize(
	speed,
	effectiveness,
	bonus_modifier,
	butcher_sound,
	disabled,
	can_be_blunt,
	butcher_callback,
)
	if(!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/butchering/recycler/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return
	var/mob/living/victim = arrived
	var/obj/machinery/recycler/eater = parent
	if(eater.safety_mode || (eater.machine_stat & (BROKEN|NOPOWER))) //I'm so sorry.
		return
	if(victim.stat == DEAD && (victim.butcher_results || victim.guaranteed_butcher_results))
		on_butchering(parent, victim)

/datum/component/butchering/mecha

/datum/component/butchering/mecha/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_ATTACHED, PROC_REF(enable_butchering))
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_DETACHED, PROC_REF(disable_butchering))
	RegisterSignal(parent, COMSIG_MECHA_DRILL_MOB, PROC_REF(on_drill))

/datum/component/butchering/mecha/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MECHA_DRILL_MOB,
		COMSIG_MECHA_EQUIPMENT_ATTACHED,
		COMSIG_MECHA_EQUIPMENT_DETACHED,
	))

///When we are ready to drill through a mob
/datum/component/butchering/mecha/proc/on_drill(datum/source, obj/vehicle/sealed/mecha/chassis, mob/living/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(on_butchering), chassis, target)

/datum/component/butchering/wearable

/datum/component/butchering/wearable/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(worn_enable_butchering))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(worn_disable_butchering))

/datum/component/butchering/wearable/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

///Same as enable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_enable_butchering(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	//check if the item is being not worn
	if(!(slot & source.slot_flags))
		return
	butchering_enabled = TRUE
	RegisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(butcher_target))

///Same as disable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_disable_butchering(obj/item/source, mob/user)
	SIGNAL_HANDLER
	butchering_enabled = FALSE
	UnregisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK)

/datum/component/butchering/wearable/proc/butcher_target(mob/user, atom/target, proximity)
	SIGNAL_HANDLER
	if(!isliving(target))
		return NONE
	return onItemAttack(parent, target, user)
