

/datum/round_event_control/shuttle_insurance
	name = "Страховка шаттла"
	typepath = /datum/round_event/shuttle_insurance
	max_occurrences = 1
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Сомнительное, но легальное страховое предложение."

/datum/round_event_control/shuttle_insurance/can_spawn_event(players, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	if(!SSeconomy.get_dep_account(ACCOUNT_CAR))
		return FALSE //They can't pay?
	if(SSshuttle.shuttle_purchased == SHUTTLEPURCHASE_FORCED)
		return FALSE //don't do it if there's nothing to insure
	if(istype(SSshuttle.emergency, /obj/docking_port/mobile/emergency/shuttle_build))
		return FALSE //this shuttle prevents the catastrophe event from happening making this event effectively useless
	if(EMERGENCY_AT_LEAST_DOCKED)
		return FALSE //catastrophes won't trigger so no point
	return TRUE

/datum/round_event/shuttle_insurance
	var/ship_name = "\"На случай непредвиденных обстоятельств\""
	var/datum/comm_message/insurance_message
	var/insurance_evaluation = 0

/datum/round_event/shuttle_insurance/announce(fake)
	priority_announce("Входящее подпространственное сообщение. Безопасный канал открыт на всех коммуникационных консолях.", "Входящее сообщение", SSstation.announcer.get_rand_report_sound())

/datum/round_event/shuttle_insurance/setup()
	ship_name = pick(strings(PIRATE_NAMES_FILE, "rogue_names"))
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]
		if(template.name == SSshuttle.emergency.name) //found you slackin
			insurance_evaluation = template.credit_cost/2
			break
	if(!insurance_evaluation)
		insurance_evaluation = 5000 //gee i dunno

/datum/round_event/shuttle_insurance/start()
	insurance_message = new("Страховка шаттла", "Привет, приятель, это [ship_name]. Не могу не заметить, что у вас там дикий и безумный шаттл БЕЗ СТРАХОВКИ! Безумие. А что, если с ним что-то случится, а?! Мы провели быструю оценку ваших тарифов в этом секторе и предлагаем [insurance_evaluation] для покрытия вашего шаттла на случай любой катастрофы.", list("Приобрести страховку.","Отклонить предложение."))
	insurance_message.answer_callback = CALLBACK(src, PROC_REF(answered))
	GLOB.communications_controller.send_message(insurance_message, unique = TRUE)

/datum/round_event/shuttle_insurance/proc/answered()
	if(EMERGENCY_AT_LEAST_DOCKED)
		priority_announce("Вы определенно опоздали с приобретением страховки, друзья мои. Наши агенты не работают на месте.", sender_override = ship_name, color_override = "red")
		return
	if(insurance_message && insurance_message.answered == 1)
		var/datum/bank_account/station_balance = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(!station_balance?.adjust_money(-insurance_evaluation))
			priority_announce("Вы не отправили нам достаточно денег для страховки шаттла. Это, на языке космических простолюдинов, считается мошенничеством. Мы оставляем ваши деньги, мошенники!", sender_override = ship_name, color_override = "red")
			return
		priority_announce("Спасибо за приобретение страховки шаттла!", sender_override = ship_name, color_override = "red")
		SSshuttle.shuttle_insurance = TRUE
