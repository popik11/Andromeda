ADMIN_VERB(change_shuttle_events, R_ADMIN|R_FUN, "Изменить События Шаттла", "Изменить события на шаттле.", ADMIN_CATEGORY_SHUTTLE)
	//Пока что достаточно позволить админам изменять аварийный шаттл
	var/obj/docking_port/mobile/port = SSshuttle.emergency

	if(!port)
		to_chat(user, span_admin("Ой, не удалось найти шаттл эвакуации!"))

	var/list/options = list("Очистить"="Очистить")

	//Соберём активные события, чтобы знать, какие можно Добавить или Удалить
	var/list/active = list()
	for(var/datum/shuttle_event/event in port.event_list)
		active[event.type] = event

	for(var/datum/shuttle_event/event as anything in subtypesof(/datum/shuttle_event))
		options[((event in active) ? "(Удалить)" : "(Добавить)") + initial(event.name)] = event

	//Покажем простое меню с событиями шаттла и опциями добавления/удаления или очистки всех
	var/result = input(user, "Выберите событие для добавления/удаления", "События Шаттла") as null|anything in sort_list(options)

	if(result == "Очистить")
		port.event_list.Cut()
		message_admins("[key_name_admin(user)] очистил события шаттла на: [port]")
	else if(options[result])
		var/typepath = options[result]
		if(typepath in active)
			port.event_list.Remove(active[options[result]])
			message_admins("[key_name_admin(user)] удалил '[active[result]]' из [port].")
		else
			message_admins("[key_name_admin(user)] добавил '[typepath]' на [port].")
			port.add_shuttle_event(typepath)

ADMIN_VERB(call_shuttle, R_ADMIN, "Вызвать Шаттл", "Принудительно вызвать шаттл с дополнительными модификаторами.", ADMIN_CATEGORY_SHUTTLE)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	var/confirm = tgui_alert(user, "Вы уверены?", "Подтверждение", list("Да", "Да (Без отзыва)", "Нет"))
	switch(confirm)
		if(null, "Нет")
			return
		if("Да (Без отзыва)")
			SSshuttle.admin_emergency_no_recall = TRUE
			SSshuttle.emergency.mode = SHUTTLE_IDLE

	SSshuttle.emergency.request()
	BLACKBOX_LOG_ADMIN_VERB("Вызвать Шаттл")
	log_admin("[key_name(user)] администратор вызвал аварийный шаттл.")
	message_admins(span_adminnotice("[key_name_admin(user)] администратор вызвал аварийный шаттл[confirm == "Да (Без отзыва)" ? " (без возможности отзыва)" : ""]."))

ADMIN_VERB(cancel_shuttle, R_ADMIN, "Отозвать Шаттл", "Отозвать шаттл, независимо от обстоятельств.", ADMIN_CATEGORY_SHUTTLE)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(tgui_alert(user, "Вы уверены?", "Подтверждение", list("Да", "Нет")) != "Да")
		return
	SSshuttle.admin_emergency_no_recall = FALSE
	SSshuttle.emergency.cancel()
	BLACKBOX_LOG_ADMIN_VERB("Отозвать Шаттл")
	log_admin("[key_name(user)] администратор отозвал аварийный шаттл.")
	message_admins(span_adminnotice("[key_name_admin(user)] администратор отозвал аварийный шаттл."))

ADMIN_VERB(disable_shuttle, R_ADMIN, "Отключить Шаттл", "Этим ублюдкам не выбраться. Вуахахахах!!", ADMIN_CATEGORY_SHUTTLE)
	if(SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		to_chat(user, span_warning("Ошибка, шаттл уже отключён."))
		return

	if(tgui_alert(user, "Вы уверены?", "Подтверждение", list("Да", "Нет")) != "Да")
		return

	message_admins(span_adminnotice("[key_name_admin(user)] отключил шаттл."))

	SSshuttle.last_mode = SSshuttle.emergency.mode
	SSshuttle.last_call_time = SSshuttle.emergency.timeLeft(1)
	SSshuttle.admin_emergency_no_recall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED
	priority_announce(
		text = "Сбой связи с аварийным шаттлом, ожидайте восстановления связи.",
		title = "Сбой связи",
		sound = 'sound/announcer/announcement/announce_dig.ogg',
		sender_override = "Диспетчерская Флота",
		color_override = "grey",
	)

ADMIN_VERB(enable_shuttle, R_ADMIN, "Включить Шаттл", "Этим ублюдкам ВСЁ-ТАКИ выбраться. К сожалению..", ADMIN_CATEGORY_SHUTTLE)
	if(SSshuttle.emergency.mode != SHUTTLE_DISABLED)
		to_chat(user, span_warning("Ошибка, шаттл не отключён."))
		return

	if(tgui_alert(user, "Вы уверены?", "Подтверждение", list("Да", "Нет")) != "Да")
		return

	message_admins(span_adminnotice("[key_name_admin(user)] включил аварийный шаттл."))
	SSshuttle.admin_emergency_no_recall = FALSE
	SSshuttle.emergency_no_recall = FALSE
	if(SSshuttle.last_mode == SHUTTLE_DISABLED) //Если всё пошло к чёрту, починим.
		SSshuttle.last_mode = SHUTTLE_IDLE

	SSshuttle.emergency.mode = SSshuttle.last_mode
	if(SSshuttle.last_call_time < 10 SECONDS && SSshuttle.last_mode != SHUTTLE_IDLE)
		SSshuttle.last_call_time = 10 SECONDS //Убедимся, что нет мгновенных отправлений.
	SSshuttle.emergency.setTimer(SSshuttle.last_call_time)
	priority_announce(
		text = "Связь с аварийным шаттлом восстановлена.",
		title = "Связь восстановлена",
		sound = 'sound/announcer/announcement/announce_dig.ogg',
		sender_override = "Диспетчерская Флота",
		color_override = "green",
	)

ADMIN_VERB(hostile_environment, R_ADMIN, "Враждебная Среда", "Естественным образом отключить шаттл.", ADMIN_CATEGORY_SHUTTLE)
	switch(tgui_alert(user, "Выберите опцию", "Менеджер Враждебной Среды", list("Включить", "Отключить", "Очистить Все")))
		if("Включить")
			if (SSshuttle.hostile_environments["Admin"] == TRUE)
				to_chat(user, span_warning("Ошибка, административная враждебная среда уже включена."))

			else
				message_admins(span_adminnotice("[key_name_admin(user)] Включил административную враждебную среду"))
				SSshuttle.registerHostileEnvironment("Admin")

		if("Отключить")
			if (!SSshuttle.hostile_environments["Admin"])
				to_chat(user, span_warning("Ошибка, административная враждебная среда не найдена."))

			else
				message_admins(span_adminnotice("[key_name_admin(user)] Отключил административную враждебную среду"))
				SSshuttle.clearHostileEnvironment("Admin")

		if("Очистить Все")
			message_admins(span_adminnotice("[key_name_admin(user)] Отключил все текущие источники враждебной среды"))
			SSshuttle.hostile_environments.Cut()
			SSshuttle.checkHostileEnvironment()

ADMIN_VERB(shuttle_panel, R_ADMIN, "Shuttle Manipulator", "Opens the shuttle manipulator UI.", ADMIN_CATEGORY_SHUTTLE)
	SSshuttle.ui_interact(user.mob)

/obj/docking_port/mobile/proc/admin_fly_shuttle(mob/user)
	var/list/options = list()

	for(var/port in SSshuttle.stationary_docking_ports)
		if (istype(port, /obj/docking_port/stationary/transit))
			continue  // please don't do this
		var/obj/docking_port/stationary/S = port
		if (canDock(S) == SHUTTLE_CAN_DOCK)
			options[S.name || S.shuttle_id] = S

	options += "--------"
	options += "Infinite Transit"
	options += "Delete Shuttle"
	options += "Into The Sunset (delete & greentext 'escape')"

	var/selection = tgui_input_list(user, "Выберите куда лететь [name || shuttle_id]:", "Полет Шаттла", options)
	if(isnull(selection))
		return

	switch(selection)
		if("Бесконечный Транзит")
			destination = null
			mode = SHUTTLE_IGNITING
			setTimer(ignitionTime)

		if("Удалить Шаттл")
			if(tgui_alert(user, "Действительно удалить [name || shuttle_id]?", "Удалить Шаттл", list("Отмена", "Точно!")) != "Точно!")
				return
			jumpToNullSpace()

		if("В Закат (удалить и 'побег' для гринтекста)")
			if(tgui_alert(user, "Действительно удалить [name || shuttle_id] и засчитать побег для целей?", "Удалить Шаттл", list("Отмена", "Точно!")) != "Точно!")
				return
			intoTheSunset()

		else
			if(options[selection])
				request(options[selection])

/obj/docking_port/mobile/emergency/admin_fly_shuttle(mob/user)
	return  // use the existing verbs for this

/obj/docking_port/mobile/arrivals/admin_fly_shuttle(mob/user)
	switch(tgui_alert(user, "Вы хотите отправить шаттл прибытия один раз или изменить его пункт назначения?", "Полет Шаттла", list("Отправить", "Изменить цель", "Отмена")))
		if("Отмена")
			return
		if("Отправить")
			return ..()

	var/list/options = list()

	for(var/port in SSshuttle.stationary_docking_ports)
		if (istype(port, /obj/docking_port/stationary/transit))
			continue  // пожалуйста, не делайте этого
		var/obj/docking_port/stationary/S = port
		if (canDock(S) == SHUTTLE_CAN_DOCK)
			options[S.name || S.shuttle_id] = S

	var/selection = tgui_input_list(user, "Новый пункт назначения прибытия", "Полет Шаттла", options)
	if(isnull(selection))
		return
	target_dock = options[selection]
	if(!QDELETED(target_dock))
		destination = target_dock
