#define CHALLENGE_TELECRYSTALS 280
#define CHALLENGE_TIME_LIMIT (5 MINUTES)
#define CHALLENGE_SHUTTLE_DELAY (25 MINUTES) // 25 minutes, so the ops have at least 5 minutes before the shuttle is callable.

GLOBAL_LIST_EMPTY(jam_on_wardec)

/obj/item/nuclear_challenge
	name = "Объявление войны (Режим испытания)"
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "nukietalkie"
	inhand_icon_state = "nukietalkie"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	desc = "Используйте, чтобы отправить объявление о враждебных намерениях цели, задержав отправление вашего шаттла на 20 минут, пока они готовятся к вашему нападению.  \
			Подобный дерзкий шаг привлечёт внимание могущественных покровителей внутри Синдиката, которые снабдят вашу команду огромным количеством бонусных телекристаллов.  \
			Должно быть использовано в течение пяти минут, иначе ваши покровители потеряют интерес."
	var/declaring_war = FALSE
	var/uplink_type = /obj/item/uplink/nuclear
	var/announcement_sound = 'sound/announcer/alarm/nuke_alarm.ogg'

/obj/item/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = tgui_alert(user, "Тщательно проконсультируйтесь с вашей командой, прежде чем объявлять войну [station_name()]. Вы уверены, что хотите предупредить вражеский экипаж? У вас есть [DisplayTimeText(CHALLENGE_TIME_LIMIT - world.time - SSticker.round_start_time)] чтобы принять решение.", "Объявить войну?", list("Да", "Нет"))
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure != "Да")
		to_chat(user, span_notice("Подумав, решаем, что фактор внезапности - не такая уж и плохая идея."))
		return

	var/war_declaration = "Периферийная группа Синдиката объявила о своём намерении полностью уничтожить [station_name()] с помощью ядерного устройства и бросает вызов экипажу, пытаясь остановить их."

	declaring_war = TRUE
	var/custom_threat = tgui_alert(user, "Хотите настроить ваше объявление?", "Настроить?", list("Да", "Нет"))
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Да")
		declaring_war = TRUE
		war_declaration = tgui_input_text(user, "Введите ваше собственное объявление", "Объявление", max_length = MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return

	war_was_declared(user, memo = war_declaration)

///Админ-онли процедура для обхода проверок и принудительного объявления войны. Кнопка на панели антагов.
/obj/item/nuclear_challenge/proc/force_war()
	var/are_you_sure = tgui_alert(usr, "Вы уверены, что хотите принудительно объявить войну?[GLOB.player_list.len < CHALLENGE_MIN_PLAYERS ? " Внимание, количество игроков ниже требуемого минимума." : ""]", "Объявить войну?", list("Да", "Нет"))

	if(are_you_sure != "Да")
		return

	var/war_declaration = "Периферийная группа Синдиката объявила о своём намерении полностью уничтожить [station_name()] с помощью ядерного устройства и бросает вызов экипажу, пытаясь остановить их."

	var/custom_threat = tgui_alert(usr, "Хотите настроить объявление?", "Настроить?", list("Да", "Нет"))

	if(custom_threat == "Да")
		war_declaration = tgui_input_text(usr, "Введите ваше собственное объявление", "Объявление", max_length = MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)

	if(!war_declaration)
		tgui_alert(usr, "Неверное объявление войны.", "Неудачный выбор слов")
		return

	for(var/obj/item/circuitboard/computer/syndicate_shuttle/board as anything in GLOB.syndicate_shuttle_boards)
		if(board.challenge_start_time)
			tgui_alert(usr, "Война уже была объявлена!", "Война объявлена")
			return

	war_was_declared(memo = war_declaration)

/obj/item/nuclear_challenge/proc/war_was_declared(mob/living/user, memo)
	priority_announce(
		text = memo,
		title = "Объявление войны",
		sound = announcement_sound,
		has_important_message = TRUE,
		sender_override = "Ударное Подразделение Синдиката",
		color_override = "red",
	)
	if(user)
		to_chat(user, "Вы привлекли внимание могущественных сил внутри Синдиката. \
			Вашей команде предоставлен бонусный набор телекристаллов. Вас ждут великие награды за выполнение миссии.")

	distribute_tc()
	CONFIG_SET(number/shuttle_refuel_delay, max(CONFIG_GET(number/shuttle_refuel_delay), CHALLENGE_SHUTTLE_DELAY))
	SSblackbox.record_feedback("amount", "nuclear_challenge_mode", 1)

	for(var/obj/item/circuitboard/computer/syndicate_shuttle/board as anything in GLOB.syndicate_shuttle_boards)
		board.challenge_start_time = world.time

	for(var/obj/machinery/computer/camera_advanced/shuttle_docker/dock as anything in GLOB.jam_on_wardec)
		dock.jammed = TRUE

	var/datum/techweb/station_techweb = locate(/datum/techweb/science) in SSresearch.techwebs
	if(station_techweb)
		var/obj/machinery/announcement_system/announcement_system = get_announcement_system()
		if (!isnull(announcement_system))
			announcement_system.broadcast("Получены дополнительные исследовательские данные от Нанотрейзен в соответствии с аварийным протоколом.", list(RADIO_CHANNEL_SCIENCE), TRUE)
		station_techweb.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS * 3))

	qdel(src)

/obj/item/nuclear_challenge/proc/distribute_tc()
	var/list/orphans = list()
	var/list/uplinks = list()

	for (var/datum/mind/M in get_antag_minds(/datum/antagonist/nukeop))
		if (iscyborg(M.current))
			continue
		var/datum/component/uplink/uplink = M.find_syndicate_uplink()
		if (!uplink)
			orphans += M.current
			continue
		uplinks += uplink

	var/tc_to_distribute = CHALLENGE_TELECRYSTALS
	var/tc_per_nukie = round(tc_to_distribute / (length(orphans)+length(uplinks)))

	for (var/datum/component/uplink/uplink in uplinks)
		uplink.uplink_handler.add_telecrystals(tc_per_nukie)
		tc_to_distribute -= tc_per_nukie

	for (var/mob/living/L in orphans)
		var/TC = new /obj/item/stack/telecrystal(L.drop_location(), tc_per_nukie)
		to_chat(L, span_warning("Ваш аплинк не был найден, поэтому ваша доля бонусных телекристаллов команды была блюспейснута к вашим [L.put_in_hands(TC) ? "рукам" : "ногам"]."))
		tc_to_distribute -= tc_per_nukie

	if (tc_to_distribute > 0) // Что же нам делать с остатком...
		for (var/mob/living/basic/carp/pet/cayenne/C in GLOB.mob_living_list)
			if (C.stat != DEAD)
				var/obj/item/stack/telecrystal/TC = new(C.drop_location(), tc_to_distribute)
				TC.throw_at(get_step(C, C.dir), 3, 3)
				C.visible_message(span_notice("[C] отрыгивает полупереваренный телекристалл"),span_notice("Вы отрыгиваете полупереваренный телекристалл!"))
				break


/obj/item/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, span_boldwarning("Вы уже в процессе объявления войны! Определитесь."))
		return FALSE
	if(GLOB.player_list.len < CHALLENGE_MIN_PLAYERS)
		to_chat(user, span_boldwarning("Вражеский экипаж слишком мал, чтобы объявлять ему войну."))
		return FALSE
	if(!user.onSyndieBase())
		to_chat(user, span_boldwarning("Вы должны находиться на своей базе, чтобы использовать это."))
		return FALSE
	if(world.time - SSticker.round_start_time > CHALLENGE_TIME_LIMIT)
		to_chat(user, span_boldwarning("Слишком поздно объявлять враждебность. Ваши покровители уже заняты другими схемами. Вам придётся обходиться тем, что есть под рукой."))
		return FALSE
	for(var/obj/item/circuitboard/computer/syndicate_shuttle/board as anything in GLOB.syndicate_shuttle_boards)
		if(board.moved)
			to_chat(user, span_boldwarning("Шаттл уже был перемещён! Вы утратили право объявлять войну."))
			return FALSE
		if(board.challenge_start_time)
			to_chat(user, span_boldwarning("Война уже была объявлена!"))
			return FALSE
	return TRUE

/obj/item/nuclear_challenge/clownops
	uplink_type = /obj/item/uplink/clownop
	announcement_sound = 'sound/announcer/alarm/clownops.ogg'

/// Подтип, который ничего не делает, кроме воспроизведения сообщения об объявлении войны. Предназначен для отладки.
/obj/item/nuclear_challenge/literally_just_does_the_message
	name = "\"Declaration of War\""
	desc = "Это штуковина Синдиката для объявления войны, но она только воспроизводит громкий звук и сообщение. Больше ничего."
	var/admin_only = TRUE

/obj/item/nuclear_challenge/literally_just_does_the_message/check_allowed(mob/living/user)
	if(admin_only && !check_rights_for(user.client, R_SPAWN|R_FUN|R_DEBUG))
		to_chat(user, span_hypnophrase("Этого у вас быть не должно!"))
		return FALSE

	return TRUE

/obj/item/nuclear_challenge/literally_just_does_the_message/war_was_declared(mob/living/user, memo)
#ifndef TESTING
	// Напоминание для наших друзей-админов
	var/are_you_sure = tgui_alert(user, "Последнее напоминание, что фальшивые объявления войны - это ужасная идея, и да, \
		это запустит весь механизм, так что будьте осторожны в своих действиях.", "Не делай этого", list("Я уверен", "Вы правы"))
	if(are_you_sure != "Я уверен")
		return
#endif

	priority_announce(
		text = memo,
		title = "Объявление войны",
		sound = announcement_sound,
		has_important_message = TRUE,
		sender_override = "Ударное Подразделение Синдиката",
		color_override = "red",
	)

/obj/item/nuclear_challenge/literally_just_does_the_message/distribute_tc()
	return

#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_TIME_LIMIT
#undef CHALLENGE_SHUTTLE_DELAY
