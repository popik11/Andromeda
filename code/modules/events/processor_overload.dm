/datum/round_event_control/processor_overload
	name = "Перегрузка процессора"
	typepath = /datum/round_event/processor_overload
	weight = 15
	min_players = 20
	category = EVENT_CATEGORY_ENGINEERING
	description = "ЭМИрует телекоммуникационные процессоры, шифруя радиопереговоры. Может взорвать несколько."

/datum/round_event/processor_overload
	announce_when = 1

/datum/round_event/processor_overload/announce(fake)
	var/alert = pick("Входящая экзосферная аномалия. Вероятна перегрузка процессоров. Пожалуйста, свяжитесь*%xp25)`6cq-БЗЗТ",
		"Входящая экзосферная аномалия. Вероятна перегрузка процессоров*1eta;c5;'1v¬-БЗЗЗЗТ",
		"Входящая экзосферная аномалия. Перегрузка процессоров#MCi46:5.;@63-БЗЗЗЗЗЗТ",
		"Входящая экзосферная аномалия'Fz\\k55_@-БЗЗЗЗЗЗТ",
		"Экзосфери:%£ QCbyj^j</.3-БЗЗЗЗЗЗТ",
		"!!hy%;f3l7e,<$^-БЗЗЗЗЗЗЗЗТ",
	)

	//ИИ всегда знают о перегрузке процессоров
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		to_chat(ai, "<br>[span_warning("<b>[alert]</b>")]<br>")

	// Объявляем большую часть времени, но оставляем небольшой промежуток, чтобы люди не знали,
	// является ли это, скажем, воздействием теслы на телекомы, или некоторым
	// избирательным изменением шины телекомов
	if(prob(80) || fake)
		priority_announce(alert, "Обнаружена аномалия")

/datum/round_event/processor_overload/start()
	for(var/obj/machinery/telecomms/processor/spinny_thing in GLOB.telecomm_machines)
		if(!prob(10))
			spinny_thing.emp_act(EMP_HEAVY)
			continue
		announce_to_ghosts(spinny_thing)
		// Damage the surrounding area to indicate that it popped
		explosion(spinny_thing, light_impact_range = 2, explosion_cause = src)
		// Only a level 1 explosion actually damages the machine
		// at all
		SSexplosions.high_mov_atom += spinny_thing
