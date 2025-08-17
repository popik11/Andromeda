SUBSYSTEM_DEF(nightshift)
	name = "Ночная Смена"
	wait = 10 MINUTES

	var/nightshift_active = FALSE
	var/nightshift_start_time = 702000 //19:30, по станционному времени
	var/nightshift_end_time = 270000 //7:30, по станционному времени
	var/nightshift_first_check = 30 SECONDS

	var/high_security_mode = FALSE
	var/list/currentrun

/datum/controller/subsystem/nightshift/Initialize()
	if(!CONFIG_GET(flag/enable_night_shifts))
		can_fire = FALSE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(resumed)
		update_nightshift(resumed = TRUE)
		return
	if(world.time - SSticker.round_start_time < nightshift_first_check)
		return
	check_nightshift()

/datum/controller/subsystem/nightshift/proc/announce(message)
	priority_announce(
		text = message,
		sound = 'sound/announcer/notice/notice2.ogg',
		sender_override = "Автоматизированная система освещения",
		color_override = "grey",
	)

/datum/controller/subsystem/nightshift/proc/check_nightshift()
	var/emergency = SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED
	var/announcing = TRUE
	var/time = station_time()
	var/night_time = (time < nightshift_end_time) || (time > nightshift_start_time)
	if(high_security_mode != emergency)
		high_security_mode = emergency
		if(night_time)
			announcing = FALSE
			if(!emergency)
				announce("Возвращаем ночное освещение в стандартный режим работы.")
			else
				announce("Отключаем ночное освещение: станция находится в режиме ЧС.")
	if(emergency)
		night_time = FALSE
	if(nightshift_active != night_time)
		update_nightshift(night_time, announcing)

/datum/controller/subsystem/nightshift/proc/update_nightshift(active, announce = TRUE, resumed = FALSE, forced = FALSE)
	if(!resumed)
		currentrun = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
		nightshift_active = active
		if(announce)
			if (active)
				announce("Добрый вечер, экипаж. Для снижения энергопотребления и стимуляции циркадных ритмов некоторых видов, освещение станции было приглушено на ночь.")
			else
				announce("Доброе утро, экипаж. Так как наступило дневное время, освещение станции было возвращено к стандартной яркости.")
	for(var/obj/machinery/power/apc/APC as anything in currentrun)
		currentrun -= APC
		if (APC.area && (APC.area.type in GLOB.the_station_areas))
			APC.set_nightshift(nightshift_active)
		if(MC_TICK_CHECK && !forced) // подсистема будет в состоянии SS_IDLE, если вызвана админом
			return
