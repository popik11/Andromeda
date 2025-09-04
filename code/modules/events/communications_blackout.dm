/datum/round_event_control/communications_blackout
	name = "Коммуникационный сбой"
	typepath = /datum/round_event/communications_blackout
	weight = 30
	category = EVENT_CATEGORY_ENGINEERING
	description = "Сильно ЭМИрует все телекоммуникационные машины, блокируя всю связь на некоторое время."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 3

/datum/round_event/communications_blackout
	announce_when = 1

/datum/round_event/communications_blackout/announce(fake)
	var/alert = pick( "Обнаружены ионосферные аномалии. Неминуем временный сбой телекоммуникаций. Пожалуйста, свяжитесь с ва*%fj00)`5вк-БЗЗТ",
		"Обнаружены ионосферные аномалии. Неминуем временный сбой телекоммуникац*3мга;б4;'1в¬-БЗЗЗТ",
		"Обнаружены ионосферные аномалии. Неминуем временный телек#MСи46:5.;@63-БЗЗЗЗЗТ",
		"Обнаружены ионосферные аномалии 'fZ\\кг5_0-БЗЗЗЗЗТ",
		"Ионосфери:%£ MКаюй^й<.3-БЗЗЗЗЗТ",
		"#4нд%;ф4й6,>£%-БЗЗЗЗЗЗЗТ",
	)

	for(var/mob/living/silicon/ai/A in GLOB.ai_list) //ИИ всегда знают о коммуникационных сбоях.
		to_chat(A, "<br>[span_warning("<b>[alert]</b>")]<br>")
		to_chat(A, span_notice("Помните, вы можете передавать данные через голопады, нажав на них правой кнопкой мыши, и говорить через них с помощью \".[/datum/saymode/holopad::key]\"."))

	if(prob(30) || fake) //большую часть времени мы не хотим объявления, чтобы позволить ИИ имитировать сбои.
		priority_announce(alert, "Обнаружена аномалия")


/datum/round_event/communications_blackout/start()
	for(var/obj/machinery/telecomms/shhh as anything in GLOB.telecomm_machines)
		shhh.emp_act(EMP_HEAVY)
	for(var/datum/transport_controller/linear/tram/transport as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(!isnull(transport.home_controller))
			var/obj/machinery/transport/tram_controller/tcomms/controller = transport.home_controller
			controller.emp_act(EMP_HEAVY)
