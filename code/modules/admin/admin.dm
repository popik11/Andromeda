////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ЛОГИ АДМИНИСТРАТОРА:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

/proc/relay_msg_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">НАПРАВЛЕННО:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/Game()
	if(!check_rights(0))
		return

	var/dat

	dat += "<a href='byond://?src=[REF(src)];[HrefToken()];gamemode_panel=1'>Dynamic Panel</a><BR>"
	dat += "<hr/>"
	dat += {"
		<A href='byond://?src=[REF(src)];[HrefToken()];create_object=1'>Create Object</A><br>
		<A href='byond://?src=[REF(src)];[HrefToken()];quick_create_object=1'>Quick Create Object</A><br>
		<A href='byond://?src=[REF(src)];[HrefToken()];create_turf=1'>Create Turf</A><br>
		<A href='byond://?src=[REF(src)];[HrefToken()];create_mob=1'>Create Mob</A><br>
		"}

	if(marked_datum && istype(marked_datum, /atom))
		dat += "<A href='byond://?src=[REF(src)];[HrefToken()];dupe_marked_datum=1'>Duplicate Marked Datum</A><br>"

	var/datum/browser/browser = new(usr, "admin2", "Game Panel", 240, 280)
	browser.set_content(dat)
	browser.open()
	return

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

ADMIN_VERB(spawn_atom, R_SPAWN, "Спавн", "Заспавнить атом.", ADMIN_CATEGORY_DEBUG, object as text)
	if(!object)
		return
	var/list/preparsed = splittext(object,":")
	var/path = preparsed[1]
	var/amount = 1
	if(preparsed.len > 1)
		amount = clamp(text2num(preparsed[2]),1,ADMIN_SPAWN_CAP)

	var/chosen = pick_closest_path(path)
	if(!chosen)
		return
	var/turf/T = get_turf(user.mob)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		for(var/i in 1 to amount)
			var/atom/A = new chosen(T)
			A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user)] заспавнил [amount] x [chosen] в [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Спавн Атома")

ADMIN_VERB(spawn_atom_pod, R_SPAWN, "Спавн (Под)", "Заспавнить атом через сброс припасов.", ADMIN_CATEGORY_DEBUG, object as text)
	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	var/turf/target_turf = get_turf(user.mob)

	if(ispath(chosen, /turf))
		target_turf.ChangeTurf(chosen)
	else
		var/obj/structure/closet/supplypod/pod = podspawn(list(
			"target" = target_turf,
			"path" = /obj/structure/closet/supplypod/centcompod,
		))
		//we need to set the admin spawn flag for the spawned items so we do it outside of the podspawn proc
		var/atom/A = new chosen(pod)
		A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user)] заспавнил под [chosen] в [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Спавн Под Атома")

ADMIN_VERB(spawn_cargo, R_SPAWN, "Спавн Ящика", "Заспавнить грузовой ящик.", ADMIN_CATEGORY_DEBUG, object as text)
	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/datum/supply_pack)))
	if(!chosen)
		return
	var/datum/supply_pack/S = new chosen
	S.admin_spawned = TRUE
	S.generate(get_turf(user.mob))

	log_admin("[key_name(user)] заспавнил грузовой пакет [chosen] в [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Спавн Ящика")

ADMIN_VERB(create_or_modify_area, R_DEBUG, "Создать Или Изменить Зону", "Создать или изменить зону. вау.", ADMIN_CATEGORY_DEBUG)
	create_area(user.mob)

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message, confidential = TRUE)
			kicked_client_names.Add("[C.key]")
			qdel(C)
	return kicked_client_names

//returns TRUE to let the dragdrop code know we are trapping this event
//returns FALSE if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return FALSE

	if (!frommob.ckey)
		return FALSE

	var/question = ""
	if (tomob.ckey)
		question = "Это моб уже имеет пользователя ([tomob.key]) под контролем! "
	question += "Вы уверены, что хотите поместить [frommob.name]([frommob.key]) под контроль [tomob.name]?"

	var/ask = tgui_alert(usr, question, "Поместить призрака под контроль моба?", list("Да", "Нет"))
	if (ask != "Да")
		return TRUE

	if (!frommob || !tomob) //убедиться, что мобы не исчезли, пока мы ждали ответа
		return TRUE

	// Отсоединяет разум наблюдателя от разума тела
	if(tomob.client)
		tomob.ghostize(FALSE)
	else
		for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
			if(tomob.mind == ghost.mind)
				ghost.mind = null

	message_admins(span_adminnotice("[key_name_admin(usr)] поместил [frommob.key] под контроль [tomob.name]."))
	log_admin("[key_name(usr)] поместил [frommob.key] в [tomob.name].")
	BLACKBOX_LOG_ADMIN_VERB("Поместил Призрака В Моба")

	tomob.PossessByPlayer(frommob.key)
	tomob.client?.init_verbs()
	qdel(frommob)

	return TRUE

/// Отправляет сообщение в админ-чат при входе или выходе любого пользователя с правами.
/// Зависит от предпочтений админов и настроек конфигурации, что означает, что этот прок может сработать без отправки сообщения.
/client/proc/adminGreet(logout = FALSE)
	if(!SSticker.HasRoundStarted())
		return

	if(logout && CONFIG_GET(flag/announce_admin_logout))
		message_admins("Выход админа: [key_name(src)]")
		return

	if(!logout && CONFIG_GET(flag/announce_admin_login) && (prefs.toggles & ANNOUNCE_LOGIN))
		message_admins("Вход админа: [key_name(src)]")
		return
