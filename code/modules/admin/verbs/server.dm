// Вкладка Сервера - Серверные Глаголы

ADMIN_VERB(toggle_random_events, R_SERVER, "Переключить Случайные События", "Включает или выключает случайные события.", ADMIN_CATEGORY_SERVER)
	var/new_are = !CONFIG_GET(flag/allow_random_events)
	CONFIG_SET(flag/allow_random_events, new_are)
	message_admins("[key_name_admin(user)] [new_are ? "включил" : "выключил"] случайные события.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключить Случайные События", "[new_are ? "Включено" : "Выключено"]")) // Если вы копируете это, убедитесь, что 4-й параметр уникален для нового проца!

ADMIN_VERB(toggle_hub, R_SERVER, "Переключить Хаб", "Переключает видимость сервера в BYOND Хабе.", ADMIN_CATEGORY_SERVER)
	world.update_hub_visibility(!GLOB.hub_visibility)

	log_admin("[key_name(user)] переключил статус хаба сервера на раунд, теперь он [(GLOB.hub_visibility?"включен":"выключен")] в хабе.")
	message_admins("[key_name_admin(user)] переключил статус хаба сервера на раунд, теперь он [(GLOB.hub_visibility?"включен":"выключен")] в хабе.")
	if (GLOB.hub_visibility && !world.reachable)
		message_admins("ВНИМАНИЕ: Сервер не появится в хабе, так как BYOND обнаруживает, что файрвол блокирует входящие подключения.")

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключена Видимость Хаба", "[GLOB.hub_visibility ? "Включена" : "Выключена"]")) // Если вы копируете это, убедитесь, что 4-й параметр уникален для нового проца!

#define REGULAR_RESTART "Regular Restart"
#define REGULAR_RESTART_DELAYED "Regular Restart (with delay)"
#define HARD_RESTART "Hard Restart (No Delay/Feedback Reason)"
#define HARDEST_RESTART "Hardest Restart (No actions, just reboot)"
#define TGS_RESTART "Server Restart (Kill and restart DD)"
ADMIN_VERB(restart, R_SERVER, "Перезагрузить Мир", "Немедленно перезагружает мир.", ADMIN_CATEGORY_SERVER)
	var/list/options = list(REGULAR_RESTART, REGULAR_RESTART_DELAYED, HARD_RESTART)

	// эта опция запускает код, который может привести к утечке подключений к БД, так как пропускает завершение подсистем (особенно SSdbcore)
	if(!SSdbcore.IsConnected())
		options += HARDEST_RESTART

	if(world.TgsAvailable())
		options += TGS_RESTART;

	if(SSticker.admin_delay_notice)
		if(alert(user, "Вы уверены? Админ уже задержал конец раунда по следующей причине: [SSticker.admin_delay_notice]", "Подтверждение", "Да", "Нет") != "Да")
			return FALSE

	var/result = input(user, "Выберите метод перезагрузки", "Перезагрузка Мира", options[1]) as null|anything in options
	if(isnull(result))
		return

	BLACKBOX_LOG_ADMIN_VERB("Перезагрузка Мира")
	var/init_by = "Инициировано [user.holder.fakekey ? "Админом" : user.key]."
	switch(result)
		if(REGULAR_RESTART)
			if(!user.is_localhost())
				if(alert(user, "Вы уверены, что хотите перезагрузить сервер?","Этот сервер жив", "Перезагрузить", "Отмена") != "Перезагрузить")
					return FALSE
			SSticker.Reboot(init_by, "админ перезагрузка - от [user.key] [user.holder.fakekey ? "(скрытно)" : ""]", 10)
		if(REGULAR_RESTART_DELAYED)
			var/delay = input("Какую задержку должна иметь перезагрузка (в секундах)?", "Задержка Перезагрузки", 5) as num|null
			if(!delay)
				return FALSE
			if(!user.is_localhost())
				if(alert(user,"Вы уверены, что хотите перезагрузить сервер?","Этот сервер жив", "Перезагрузить", "Отмена") != "Перезагрузить")
					return FALSE
			SSticker.Reboot(init_by, "админ перезагрузка - от [user.key] [user.holder.fakekey ? "(скрытно)" : ""]", delay * 10)
		if(HARD_RESTART)
			to_chat(world, "Перезагрузка мира - [init_by]")
			world.Reboot()
		if(HARDEST_RESTART)
			to_chat(world, "Жёсткая перезагрузка мира - [init_by]")
			world.Reboot(fast_track = TRUE)
		if(TGS_RESTART)
			to_chat(world, "Перезагрузка сервера - [init_by]")
			world.TgsEndProcess()

#undef REGULAR_RESTART
#undef REGULAR_RESTART_DELAYED
#undef HARD_RESTART
#undef HARDEST_RESTART
#undef TGS_RESTART

ADMIN_VERB(cancel_reboot, R_SERVER, "Отменить Перезагрузку", "Отменяет ожидающую перезагрузку мира.", ADMIN_CATEGORY_SERVER)
	if(!SSticker.cancel_reboot(user))
		return
	log_admin("[key_name(user)] отменил ожидающую перезагрузку мира.")
	message_admins("[key_name_admin(user)] отменил ожидающую перезагрузку мира.")

ADMIN_VERB(end_round, R_SERVER, "Завершить Раунд", "Принудительно завершает раунд и позволяет серверу перезагрузиться нормально.", ADMIN_CATEGORY_SERVER)
	var/confirm = tgui_alert(user, "Завершить раунд и перезагрузить игровой мир?", "Завершить Раунд", list("Да", "Отмена"))
	if(confirm != "Да")
		return
	SSticker.force_ending = FORCE_END_ROUND
	BLACKBOX_LOG_ADMIN_VERB("Завершить Раунд")

ADMIN_VERB(toggle_ooc, R_ADMIN, "Переключить OOC", "Включает или выключает канал OOC.", ADMIN_CATEGORY_SERVER)
	toggle_ooc()
	log_admin("[key_name(user)] переключил OOC.")
	message_admins("[key_name_admin(user)] переключил OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключить OOC", "[GLOB.ooc_allowed ? "Включен" : "Выключен"]"))

ADMIN_VERB(toggle_ooc_dead, R_ADMIN, "Переключить Мёртвый OOC", "Включает или выключает канал OOC для мёртвых игроков.", ADMIN_CATEGORY_SERVER)
	toggle_dooc()
	log_admin("[key_name(user)] переключил OOC.")
	message_admins("[key_name_admin(user)] переключил Мёртвый OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключить Мёртвый OOC", "[GLOB.dooc_allowed ? "Включен" : "Выключен"]"))

ADMIN_VERB(toggle_vote_dead, R_ADMIN, "Переключить Голос Мёртвых", "Включает или выключает голосование для мёртвых игроков.", ADMIN_CATEGORY_SERVER)
	SSvote.toggle_dead_voting(user)

ADMIN_VERB(start_now, R_SERVER, "Начать Сейчас", "Начинает раунд ПРЯМО СЕЙЧАС.", ADMIN_CATEGORY_SERVER)
	var/static/list/waiting_states = list(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
	if(!(SSticker.current_state in waiting_states))
		to_chat(user, span_warning(span_red("Игра уже началась!")))
		return

	if(SSticker.start_immediately)
		SSticker.start_immediately = FALSE
		SSticker.SetTimeLeft(3 MINUTES)
		to_chat(world, span_big(span_notice("Игра начнётся через 3 минуты.")))
		SEND_SOUND(world, sound('sound/announcer/default/attention.ogg'))
		message_admins(span_adminnotice("[key_name_admin(user)] отменил немедленное начало игры. Игра начнётся через 3 минуты."))
		log_admin("[key_name(user)] отменил немедленное начало игры.")
		return

	if(!user.is_localhost())
		var/response = tgui_alert(user, "Вы уверены, что хотите начать раунд?", "Начать Сейчас", list("Начать Сейчас", "Отмена"))
		if(response != "Начать Сейчас")
			return
	SSticker.start_immediately = TRUE

	log_admin("[key_name(user)] начал игру.")
	message_admins("[key_name_admin(user)] начал игру.")
	if(SSticker.current_state == GAME_STATE_STARTUP)
		message_admins("Сервер всё ещё настраивается, но раунд будет запущен как можно скорее.")
	BLACKBOX_LOG_ADMIN_VERB("Начать Сейчас")

ADMIN_VERB(delay_round_end, R_SERVER, "Задержать Конец Раунда", "Предотвращает перезагрузку сервера.", ADMIN_CATEGORY_SERVER)
	if(SSticker.delay_end)
		tgui_alert(user, "Конец раунда уже задержан. Причина текущей задержки: \"[SSticker.admin_delay_notice]\"", "Внимание", list("Ок"))
		return

	var/delay_reason = input(user, "Введите причину задержки конца раунда", "Причина Задержки Раунда") as null|text

	if(isnull(delay_reason))
		return

	if(SSticker.delay_end)
		tgui_alert(user, "Конец раунда уже задержан. Причина текущей задержки: \"[SSticker.admin_delay_notice]\"", "Внимание", list("Ок"))
		return

	SSticker.delay_end = TRUE
	SSticker.admin_delay_notice = delay_reason
	if(SSticker.reboot_timer)
		SSticker.cancel_reboot(user)

	log_admin("[key_name(user)] задержал конец раунда по причине: [SSticker.admin_delay_notice]")
	message_admins("[key_name_admin(user)] задержал конец раунда по причине: [SSticker.admin_delay_notice]")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Задержать Конец Раунда", "Причина: [delay_reason]")) // Если вы копируете это, убедитесь, что 4-й параметр уникален для нового проца!

ADMIN_VERB(toggle_enter, R_SERVER, "Переключить Вход", "Переключает возможность входа в игру.", ADMIN_CATEGORY_SERVER)
	if(!SSlag_switch.initialized)
		return
	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, !SSlag_switch.measures[DISABLE_NON_OBSJOBS])
	log_admin("[key_name(user)] переключил вход новых игроков в игру. Лаг-свитч на индексе ([DISABLE_NON_OBSJOBS])")
	message_admins("[key_name_admin(user)] переключил вход новых игроков в игру [SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "ВЫКЛ" : "ВКЛ"].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключить Вход", "[!SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "Включен" : "Выключен"]")) // Если вы копируете это, убедитесь, что 4-й параметр уникален для нового проца!

ADMIN_VERB(toggle_ai, R_SERVER, "Переключить ИИ", "Переключает возможность выбора профессий ИИ.", ADMIN_CATEGORY_SERVER)
	var/alai = CONFIG_GET(flag/allow_ai)
	CONFIG_SET(flag/allow_ai, !alai)
	if (alai)
		to_chat(world, span_bold("Профессия ИИ больше недоступна для выбора."), confidential = TRUE)
	else
		to_chat(world, "<B>Профессия ИИ теперь доступна для выбора.</B>", confidential = TRUE)
	log_admin("[key_name(user)] переключил разрешение ИИ.")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключить ИИ", "[!alai ? "Выключен" : "Включен"]")) // Если вы копируете это, убедитесь, что 4-й параметр уникален для нового проца!

ADMIN_VERB(toggle_respawn, R_SERVER, "Переключить Респавн", "Переключает возможность респавна.", ADMIN_CATEGORY_SERVER)
	var/respawn_state = CONFIG_GET(flag/allow_respawn)
	var/new_state = -1
	var/new_state_text = ""
	switch(respawn_state)
		if(RESPAWN_FLAG_DISABLED) // респавн в настоящее время отключен
			new_state = RESPAWN_FLAG_FREE
			new_state_text = "Включен"
			to_chat(world, span_bold("Теперь вы можете респавниться."), confidential = TRUE)

		if(RESPAWN_FLAG_FREE) // респавн в настоящее время включен
			new_state = RESPAWN_FLAG_NEW_CHARACTER
			new_state_text = "Включен, Другой Слот"
			to_chat(world, span_bold("Теперь вы можете респавниться как другой персонаж."), confidential = TRUE)

		if(RESPAWN_FLAG_NEW_CHARACTER) // респавн в настоящее время включен только для других слотов персонажей
			new_state = RESPAWN_FLAG_DISABLED
			new_state_text = "Выключен"
			to_chat(world, span_bold("Теперь вы не можете респавниться."), confidential = TRUE)

		else
			WARNING("Неверное состояние респавна в конфиге: [respawn_state]")

	if(new_state == -1)
		to_chat(user, span_warning("Конфиг для респавна установлен неправильно, пожалуйста, пожалуйтесь вашему ближайшему хостинг-провайдеру (или исправьте сами). \
			В то же время респавн был установлен в \"Выключен\"."))
		new_state = RESPAWN_FLAG_DISABLED
		new_state_text = "Выключен"

	CONFIG_SET(flag/allow_respawn, new_state)

	message_admins(span_adminnotice("[key_name_admin(user)] переключил респавн в \"[new_state_text]\"."))
	log_admin("[key_name(user)] переключил респавн в \"[new_state_text]\".")

	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключить Респавн", "[new_state_text]")) // Если вы копируете это, убедитесь, что 4-й параметр уникален для нового проца!

ADMIN_VERB(delay, R_SERVER, "Задержать Пре-Игру", "Задерживает начало игры.", ADMIN_CATEGORY_SERVER)
	var/newtime = input(user, "Установите новое время в секундах. Установите -1 для бесконечной задержки.", "Установить Задержку", round(SSticker.GetTimeLeft()/10)) as num|null
	if(!newtime)
		return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return tgui_alert(user, "Слишком поздно... Игра уже началась!")
	newtime = newtime*10
	SSticker.SetTimeLeft(newtime)
	SSticker.start_immediately = FALSE
	if(newtime < 0)
		to_chat(world, span_infoplain("<b>Начало игры было задержано.</b>"), confidential = TRUE)
		log_admin("[key_name(user)] задержал начало раунда.")
	else
		to_chat(world, span_infoplain(span_bold("Игра начнётся через [DisplayTimeText(newtime)].")), confidential = TRUE)
		SEND_SOUND(world, sound('sound/announcer/default/attention.ogg'))
		log_admin("[key_name(user)] установил задержку пре-игры на [DisplayTimeText(newtime)].")
	BLACKBOX_LOG_ADMIN_VERB("Задержать Начало Игры")

ADMIN_VERB(set_admin_notice, R_SERVER, "Установить Уведомление Админа", "Устанавливает объявление, которое видят все присоединяющиеся к серверу. Действует только этот раунд.", ADMIN_CATEGORY_SERVER)
	var/new_admin_notice = input(
		user,
		"Установите публичное уведомление для этого раунда. Все, кто присоединится к серверу, увидят его.\n(Оставьте пустым, чтобы удалить текущее уведомление):",
		"Установить Уведомление",
		GLOB.admin_notice,
	) as message|null
	if(new_admin_notice == null)
		return
	if(new_admin_notice == GLOB.admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(user)] удалил уведомление админа.")
		log_admin("[key_name(user)] удалил уведомление админа:\n[GLOB.admin_notice]")
	else
		message_admins("[key_name(user)] установил уведомление админа.")
		log_admin("[key_name(user)] установил уведомление админа:\n[new_admin_notice]")
		to_chat(world, span_adminnotice("<b>Уведомление Админа:</b>\n \t [new_admin_notice]"), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Установить Уведомление Админа")
	GLOB.admin_notice = new_admin_notice

ADMIN_VERB(toggle_guests, R_SERVER, "Переключить Гостей", "Переключает возможность входа гостей в игру.", ADMIN_CATEGORY_SERVER)
	var/new_guest_ban = !CONFIG_GET(flag/guest_ban)
	CONFIG_SET(flag/guest_ban, new_guest_ban)
	if (new_guest_ban)
		to_chat(world, span_bold("Гости больше не могут входить в игру."), confidential = TRUE)
	else
		to_chat(world, "<B>Гости теперь могут входить в игру.</B>", confidential = TRUE)
	log_admin("[key_name(user)] переключил вход гостей в игру [!new_guest_ban ? "разрешен" : "запрещен"].")
	message_admins(span_adminnotice("[key_name_admin(user)] переключил вход гостей в игру [!new_guest_ban ? "разрешен" : "запрещен"]."))
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Переключить Гостей", "[!new_guest_ban ? "Включен" : "Выключен"]")) // Если вы копируете это, убедитесь, что 4-й параметр уникален для нового проца!
