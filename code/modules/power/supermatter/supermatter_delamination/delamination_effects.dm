#define DELAM_MAX_DEVASTATION 17.5

// Эти эффекты должны быть дискретными, чтобы мы могли сразу понять, что делает каждый переопределенный
// метод [/datum/sm_delam/proc/delaminate].
// Пожалуйста, сохраняйте их дискретными и давайте им правильные, описательные имена функций.
// И да, все они возвращают true, если эффект успешно применен.

/// Облучает мобов в радиусе 20 тайлов от СМ.
/// Только мобов, по всей видимости.
/datum/sm_delam/proc/effect_irradiate(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for (var/mob/living/victim in range(DETONATION_RADIATION_RANGE, sm))
		if(!is_valid_z_level(get_turf(victim), sm_turf))
			continue
		if(victim.z == 0)
			continue
		SSradiation.irradiate(victim)
	return TRUE

/// Вызывает галлюцинации и угнетает мобов на уровне Z.
/datum/sm_delam/proc/effect_demoralize(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || !is_valid_z_level(get_turf(victim), sm_turf))
			continue
		if(victim.z == 0)
			continue

		//Забавно, но попадание в шкаф должно ударить по вам сильнее всего.
		//Длительность между минимумом и максимумом, рассчитывается по расстоянию от суперматерии и мощности взрыва делимитации
		var/hallucination_amount = LERP(DETONATION_HALLUCINATION_MIN, DETONATION_HALLUCINATION_MAX, 1 - get_dist(victim, sm) / 128) * LERP(0.75, 1.25, calculate_explosion(sm) * 0.5 / DELAM_MAX_DEVASTATION)
		victim.adjust_hallucinations(hallucination_amount)

	for(var/mob/victim as anything in GLOB.player_list)
		var/turf/victim_turf = get_turf(victim)
		if(!is_valid_z_level(victim_turf, sm_turf))
			continue
		victim.playsound_local(victim_turf, 'sound/effects/magic/charge.ogg')
		if(victim.z == 0) //жертва внутри объекта, это сохранение старого бага, превращенного в фичу со шкафами и прочим. tg issue #69687
			var/message = ""
			var/location = victim.loc
			if(istype(location, /obj/structure/disposalholder)) // иногда ваша локация может быть disposalholder, когда вы внутри мусоропровода, поэтому просто выведем осмысленное сообщение.
				message = "Вы слышите сильный грохот в трубах мусоропровода вокруг вас, пока реальность искажается. Но вы чувствуете себя в безопасности."
			else
				message = "Вы изо всех сил цепляетесь за [victim.loc], пока реальность искажается вокруг. Вы чувствуете себя в безопасности."
			to_chat(victim, span_bolddanger(message))
			continue
		to_chat(victim, span_bolddanger("Вы чувствуете, как реальность искажается на мгновение..."))
		if (isliving(victim))
			var/mob/living/living_victim = victim
			living_victim.add_mood_event("delam", /datum/mood_event/delam)
	return TRUE

/// Спавнит аномалии по всей станции. Половину мгновенно, остальные со временем.
/datum/sm_delam/proc/effect_anomaly(obj/machinery/power/supermatter_crystal/sm)
	var/anomalies = 10
	var/list/anomaly_types = list(GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, DIMENSIONAL_ANOMALY = 35, BIOSCRAMBLER_ANOMALY = 35, FLUX_ANOMALY = 25, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns

	// Спавнит столько аномалий мгновенно. Остальных спавнит через коллбэки.
	var/cutoff_point = round(anomalies * 0.5, 1)

	for(var/i in 1 to anomalies)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)

		if(i < cutoff_point)
			supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)
			continue

		var/current_spawn = rand(5 SECONDS, 10 SECONDS)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(SPT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(supermatter_anomaly_gen), anomaly_location, anomaly_to_spawn, TRUE), current_spawn + extended_spawn)
	return TRUE

/// Взрыв
/datum/sm_delam/proc/effect_explosion(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	explosion(origin = sm_turf,
		devastation_range = calculate_explosion(sm) * 0.5, // max 17.5
		heavy_impact_range = calculate_explosion(sm) + 2, // max 37
		light_impact_range = calculate_explosion(sm) + 4, // max 39
		flash_range = calculate_explosion(sm) + 6, //max 41
		adminlog = TRUE,
		ignorecap = TRUE
	)
	return TRUE

/datum/sm_delam/proc/calculate_explosion(obj/machinery/power/supermatter_crystal/sm)
	return sm.explosion_power * max(sm.gas_heat_power_generation, 0.205)

/// Спавнит скранга и поглощает СМ.
/datum/sm_delam/proc/effect_singulo(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Суперматерия [sm] не смогла заспавнить сингулярность, не удалось получить текущий тайл.")
		return FALSE
	var/obj/singularity/created_singularity = new(sm_turf)
	created_singularity.energy = 800
	created_singularity.consume(sm)
	return TRUE

/// Теслы
/datum/sm_delam/proc/effect_tesla(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Суперматерия [sm] не смогла заспавнить теслу, не удалось получить текущий тайл.")
		return FALSE
	var/obj/energy_ball/created_tesla = new(sm_turf)
	created_tesla.energy = 200 //Даёт нам около 9 шаров
	return TRUE

/// Отправляет шаттл за молоком.
/datum/sm_delam/proc/effect_strand_shuttle()
	set waitfor = FALSE
	// устанавливаем таймер на бесконечность, чтобы шаттл никогда не прибыл
	SSshuttle.emergency.setTimer(INFINITY)
	// запрещаем отзыв шаттла, чтобы нельзя было обойти таймер
	SSshuttle.emergency_no_recall = TRUE
	// устанавливаем суперматериальный каскад в true, чтобы предотвратить автоматическую эвакуацию из-за невозможности вызова шаттла
	SSshuttle.supermatter_cascade = TRUE
	// устанавливаем таймер завершения захвата на бесконечность, чтобы нельзя было преждевременно завершить раунд захватом
	for(var/obj/machinery/computer/emergency_shuttle/console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/emergency_shuttle))
		console.hijack_completion_flight_time_set = INFINITY

	/* Эта логика нужна, чтобы незаказанные шаттлы оставались незаказанными
	В SSshuttle нет нормального способа предотвратить вызов шаттла, кроме как через админские переменные
	SHUTTLE_STRANDED здесь работает иначе, потому что он *может* блокировать вызов шаттла, однако если мы не зарегистрируем враждебную
	среду, он сразу же снимается. Внутренне он проверяет, если количество HE равно нулю
	и что шаттл в режиме блокировки, затем разблокирует его с объявлением.
	Это костыльное решение проблемы, которую можно было бы решить небольшим изменением кода шаттла, однако-
	*/
	if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
		SSshuttle.emergency.mode = SHUTTLE_STRANDED
		SSshuttle.registerHostileEnvironment(src)
		return

	// попрощайся со своим шаттлом
	if(SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
		priority_announce(
			text = "Критическая ошибка в линии связи аварийного шаттла во время транзита. Невозможно восстановить соединение.",
			title = "Сбой шаттла",
			sound =  'sound/announcer/announcement/announce_dig.ogg',
			sender_override = "Диспетчерская Флота",
			color_override = "grey",
		)
	else
	// кроме случаев, когда ты уже на нём, тогда ты в безопасности c:
		minor_announce("ОШИБКА: Обнаружена коррупция навигационных протоколов. Соединение с транспондером #XCC-P5831-ES13 потеряно. \
				Протокол резервного маршрута выхода расшифрован. Калибровка маршрута...",
			"Аварийный шаттл", TRUE) // ждём, пока разлом на станции не будет уничтожен и не прозвучит финальное сообщение
		var/list/mobs = mobs_in_area_type(list(/area/shuttle/escape))
		for(var/mob/living/mob as anything in mobs) // эмулируем поведение mob/living/lateShuttleMove()
			if(mob.buckled)
				continue
			if(mob.client)
				shake_camera(mob, 3 SECONDS * 0.25, 1)
			mob.Paralyze(3 SECONDS, TRUE)

/datum/sm_delam/proc/effect_cascade_demoralize()
	for(var/mob/player as anything in GLOB.player_list)
		if(!isdead(player))
			var/mob/living/living_player = player
			to_chat(player, span_bolddanger("Всё вокруг резонирует с мощной энергией. Это не к добру."))
			living_player.add_mood_event("cascade", /datum/mood_event/cascade)
		SEND_SOUND(player, 'sound/effects/magic/charge.ogg')

/datum/sm_delam/proc/effect_emergency_state()
	if(SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA) // пропускаем объявление и корректировку таймера шаттла в set_security_level()
	make_maint_all_access()
	for(var/obj/machinery/light/light_to_break as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
		if(prob(35))
			light_to_break.set_major_emergency_light()
			continue
		light_to_break.break_light_tube()

/// Создаёт эвакуационный разлом для прохода людей.
/datum/sm_delam/proc/effect_evac_rift_start()
	var/obj/cascade_portal/rift = new /obj/cascade_portal(get_turf(pick(GLOB.generic_event_spawns)))
	priority_announce("Мы подверглись общесекторному электромагнитному импульсу. Все наши системы серьёзно повреждены, включая \
		системы навигации шаттлов. Мы можем разумно заключить, что суперматериальный каскад происходит на или около вашей станции.\n\n\
		Эвакуация обычными средствами более невозможна; однако нам удалось открыть разлом около [get_area_name(rift)]. \
		Весь персонал обязан пройти через разлом любыми доступными средствами.\n\n\
		[Gibberish("Эвакуация выживших будет проведена после восстановления необходимых объектов.", FALSE, 5)] \
		[Gibberish("Удачи--", FALSE, 25)]")
	return rift

/// Объявляет о разрушении разлома и завершает раунд.
/datum/sm_delam/proc/effect_evac_rift_end()
	priority_announce("[Gibberish("Разлом уничтожен, мы больше не можем помочь вам.", FALSE, 5)]")

	sleep(25 SECONDS)

	priority_announce("Отчёты указывают на формирование кристаллических семян после события резонансного сдвига. \
		Быстрое расширение кристаллической массы пропорционально растущей гравитационной силе. \
		Предвидится коллапс материи due to гравитационного притяжения.",
		"Ассоциация Звёздного Наблюдения Nanotrasen")

	sleep(25 SECONDS)

	priority_announce("[Gibberish("Все попытки эвакуации прекращены, все активы изъяты из вашего сектора.\n \
		Оставшимся выжившим на [station_name()], прощайте.", FALSE, 5)]")

	if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		// специальное сообщение для захватов
		var/shuttle_msg = "Навигационный протокол установлен на [SSshuttle.emergency.is_hijacked() ? "\[ОШИБКА\]" : "резервный маршрут"]. \
			Перенаправление блюспейс-судна на вектор выхода. Прибытие через 15 секунд."
		// искажаем специальное сообщение
		if(SSshuttle.emergency.is_hijacked())
			shuttle_msg = Gibberish(shuttle_msg, TRUE, 15)
		minor_announce(shuttle_msg, "Аварийный шаттл", TRUE)
		SSshuttle.emergency.setTimer(15 SECONDS)
		return

	sleep(10 SECONDS)

	SSticker.news_report = SUPERMATTER_CASCADE
	SSticker.force_ending = FORCE_END_ROUND

/// Распределяет кристаллическую массу по точкам спавна событий, пока они находятся хотя бы в 30 тайлах от того, чего мы хотим избежать.
/datum/sm_delam/proc/effect_crystal_mass(obj/machinery/power/supermatter_crystal/sm, avoid)
	new /obj/crystal_mass(get_turf(sm))
	var/list/possible_spawns = GLOB.generic_event_spawns.Copy()
	for(var/i in 1 to rand(4,6))
		var/spawn_location
		do
			spawn_location = pick_n_take(possible_spawns)
		while(get_dist(spawn_location, avoid) < 30)
		new /obj/crystal_mass(get_turf(spawn_location))

#undef DELAM_MAX_DEVASTATION
