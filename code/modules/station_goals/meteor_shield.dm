/// number of emagged meteor shields to get the first warning, a simple say message
#define EMAGGED_METEOR_SHIELD_THRESHOLD_ONE 3
/// number of emagged meteor shields to get the second warning, telling the user an announcement is coming
#define EMAGGED_METEOR_SHIELD_THRESHOLD_TWO 6
/// number of emagged meteor shields to get the third warning + an announcement to the crew
#define EMAGGED_METEOR_SHIELD_THRESHOLD_THREE 7
/// number of emagged meteor shields to get the fourth... ah shit the dark matt-eor is coming.
#define EMAGGED_METEOR_SHIELD_THRESHOLD_FOUR 10
/// how long between emagging meteor shields you have to wait
#define METEOR_SHIELD_EMAG_COOLDOWN 1 MINUTES

//Station Shield
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/station_shield
	name = "Орбитальная Защита Станции"
	requires_space = TRUE
	var/coverage_goal = 500
	VAR_PRIVATE/cached_coverage_length

/datum/station_goal/station_shield/get_report()
	return list(
		"<blockquote>Станция расположена в зоне, полной космического мусора.",
		"Вы должны развернуть прототип системы защиты для сокращения аварий, связанных со столкновениями.",
		"",
		"Вы можете заказать спутники и системы управления через карго.</blockquote>",
	).Join("\n")


/datum/station_goal/station_shield/on_report()
	//Unlock
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat_control]
	P.special_enabled = TRUE

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	update_coverage()
	if(cached_coverage_length >= coverage_goal)
		return TRUE
	return FALSE

/datum/station_goal/station_shield/proc/get_coverage()
	return cached_coverage_length

/// Gets the coverage of all active meteor shield satellites
/// Can be expensive, ensure you need this before calling it
/datum/station_goal/station_shield/proc/update_coverage()
	var/list/coverage = list()
	for(var/obj/machinery/satellite/meteor_shield/shield_satt as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/satellite/meteor_shield))
		if(!shield_satt.active || !is_station_level(shield_satt.z))
			continue
		for(var/turf/covered in view(shield_satt.kill_range, shield_satt))
			coverage |= covered
	cached_coverage_length = length(coverage)

/obj/machinery/satellite/meteor_shield
	name = "Meteor Shield Satellite"
	desc = "Спутник противометеоритной обороны."
	mode = "M-SHIELD"
	/// the range a meteor shield sat can destroy meteors
	var/kill_range = 14

	//emag behavior dark matt-eor stuff

	/// Proximity monitor associated with this atom, needed for it to work.
	var/datum/proximity_monitor/proximity_monitor

	/// amount of emagged active meteor shields
	var/static/emagged_active_meteor_shields = 0
	/// the highest amount of shields you've ever emagged
	var/static/highest_emagged_threshold_reached = 0
	/// cooldown on emagging meteor shields because instantly summoning a dark matt-eor is very unfun
	STATIC_COOLDOWN_DECLARE(shared_emag_cooldown)

/obj/machinery/satellite/meteor_shield/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("В настоящее время активен. Вы можете взаимодействовать с ним, чтобы отключить.")
		if(obj_flags & EMAGGED)
			. += span_warning("Вместо обычных звуков бипов и пингов, он издаёт странное и постоянное шипение белого шума…")
		else
			. += span_notice("Он периодически издаёт бипы и пинги, общаясь со спутниковой сетью.")
	else
		. += span_notice("В настоящее время отключён. Вы можете взаимодействовать с ним, чтобы настроить.")
		if(obj_flags & EMAGGED)
			. += span_warning("Но что-то в нём кажется не таким...?")

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T in get_line(src,meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, /* range = */ 0)

/obj/machinery/satellite/meteor_shield/HasProximity(atom/movable/proximity_check_mob)
	. = ..()
	if(!istype(proximity_check_mob, /obj/effect/meteor))
		return
	var/obj/effect/meteor/meteor_to_destroy = proximity_check_mob
	if(space_los(meteor_to_destroy))
		var/turf/beam_from = get_turf(src)
		beam_from.Beam(get_turf(meteor_to_destroy), icon_state="sat_beam", time = 5)
		if(meteor_to_destroy.shield_defense(src))
			qdel(meteor_to_destroy)

/obj/machinery/satellite/meteor_shield/toggle(user)
	if(user)
		balloon_alert(user, "ищу кнопку включения [active ? "выключения" : "включения"]")
	if(user && !do_after(user, 2 SECONDS, src, IGNORE_HELD_ITEM))
		return FALSE
	if(!..(user))
		return FALSE
	if(obj_flags & EMAGGED)
		update_emagged_meteor_sat(user)

	if(active)
		proximity_monitor.set_range(kill_range)
	else
		proximity_monitor.set_range(0)


	var/datum/station_goal/station_shield/goal = SSstation.get_station_goal(/datum/station_goal/station_shield)
	goal?.update_coverage()

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	QDEL_NULL(proximity_monitor)
	if(obj_flags & EMAGGED)
		//satellites that are destroying are not active, this will count down the number of emagged sats
		update_emagged_meteor_sat()

/obj/machinery/satellite/meteor_shield/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "уже емагнут!")
		return FALSE
	if(!COOLDOWN_FINISHED(src, shared_emag_cooldown))
		balloon_alert(user, "на перезарядке!")
		to_chat(user, span_warning("Последнему емагнотому спутнику требуется [DisplayTimeText(COOLDOWN_TIMELEFT(src, shared_emag_cooldown))] для перекалибровки. Слишком ранний эмэг другого может повредить спутниковую сеть."))
		return FALSE
	var/cooldown_applied = METEOR_SHIELD_EMAG_COOLDOWN
	COOLDOWN_START(src, shared_emag_cooldown, cooldown_applied)
	obj_flags |= EMAGGED
	to_chat(user, span_notice("Вы получаете доступ к режиму отладки спутника, и он начинает излучать странный сигнал, увеличивая вероятность метеоритных ударов."))
	AddComponent(/datum/component/gps, "Сигнал Привлечения Испорченного Метеоритного Щита")
	say("Перекалибровка... Примерное время:[DisplayTimeText(cooldown_applied)].")
	if(active) //если бы мы разрешали обновления неактивных, спутник мог бы стоить -1 активных метеоритных щитов при первом эмэге
		update_emagged_meteor_sat(user)
	return TRUE

/obj/machinery/satellite/meteor_shield/proc/update_emagged_meteor_sat(mob/user)
	if(!active)
		change_meteor_chance(0.5)
		emagged_active_meteor_shields--
		if(user)
			balloon_alert(user, "вероятность метеоров уменьшена вдвое")
		return
	change_meteor_chance(2)
	emagged_active_meteor_shields++
	if(user)
		balloon_alert(user, "вероятность метеоров удвоена")
	if(emagged_active_meteor_shields > highest_emagged_threshold_reached)
		highest_emagged_threshold_reached = emagged_active_meteor_shields
		handle_new_emagged_shield_threshold()

/obj/machinery/satellite/meteor_shield/proc/handle_new_emagged_shield_threshold()
	switch(highest_emagged_threshold_reached)
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_ONE)
			say("Предупреждение. Вероятность метеоритных ударов входит в опасный диапазон для более экзотических метеоров.")
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_TWO)
			say("Предупреждение. Риск сгущения тёмной материи входит в существующие диапазоны. Дальнейшие вмешательства будут сообщены.")
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_THREE)
			say("Предупреждение. Дальнейшие вмешательства были сообщены.")
			priority_announce("Внимание. Вмешательство в работу метеорных спутников подвергает станцию риску экзотических, смертоносных метеорных столкновений. Пожалуйста, примите меры, проверив ваши GPS-устройства на наличие странных сигналов и демонтировав повреждённые метеорные щиты.", "Странный Сигнал")
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_FOUR)
			say("Предупреждение. Предупреждение. Тёмный Мат-теор на курсе к станции.")
			force_event_async(/datum/round_event_control/dark_matteor, "массив повреждённых метеорных спутников")

/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod)
	// Update the weight of all meteor events
	for(var/datum/round_event_control/meteor_wave/meteors in SSevents.control)
		meteors.weight *= mod
	for(var/datum/round_event_control/stray_meteor/stray_meteor in SSevents.control)
		stray_meteor.weight *= mod


#undef EMAGGED_METEOR_SHIELD_THRESHOLD_ONE
#undef EMAGGED_METEOR_SHIELD_THRESHOLD_TWO
#undef EMAGGED_METEOR_SHIELD_THRESHOLD_THREE
#undef EMAGGED_METEOR_SHIELD_THRESHOLD_FOUR

#undef METEOR_SHIELD_EMAG_COOLDOWN
