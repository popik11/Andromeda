
///global reference to the current theme, if there is one.
GLOBAL_DATUM(current_anonymous_theme, /datum/anonymous_theme)

/*Anon names! A system to make all players have random names/aliases instead of their static, for admin events/fuckery!
	contains both the anon names proc and the datums for each.

	this is the setup, it handles announcing crew and other settings for the mode and then creating the datum singleton
*/
/client/proc/anon_names()
	set category = "Admin.Events"
	set name = "Настройка Анонимных Имён"

	if(GLOB.current_anonymous_theme)
		var/response = tgui_alert(usr, "Анонимный режим уже включен. Отключить?", "Передумывание", list("Отключить Анонимные Имена", "Оставить Включённым"))
		if(response != "Отключить Анонимные Имена")
			return
		message_admins(span_adminnotice("[key_name_admin(usr)] отключил анонимные имена."))
		QDEL_NULL(GLOB.current_anonymous_theme)
		return
	var/list/input_list = list("Отмена")
	for(var/_theme in typesof(/datum/anonymous_theme))
		var/datum/anonymous_theme/theme = _theme
		input_list[initial(theme.name)] = theme
	var/result = input(usr, "Выберите анонимную тему","переход в тень") as null|anything in input_list
	if(!usr || !result || result == "Отмена")
		return
	var/datum/anonymous_theme/chosen_theme = input_list[result]
	var/extras_enabled = "Нет"
	var/alert_players = "Нет"
	if(SSticker.current_state > GAME_STATE_PREGAME) //до выполнения anonnames, для запроса сна
		if(initial(chosen_theme.extras_enabled))
			extras_enabled = tgui_alert(usr, extras_enabled, "дополнительно", list("Да", "Нет"))
		alert_players = tgui_alert(usr, "Уведомить экипаж? Это внутриигровая тематика ОТ ЦентКома.", "объявление", list("Да", "Нет"))
	//превращаем "Да" и "Нет" в TRUE и FALSE
	extras_enabled = extras_enabled == "Да"
	alert_players = alert_players == "Да"
	GLOB.current_anonymous_theme = new chosen_theme(extras_enabled, alert_players)
	message_admins(span_adminnotice("[key_name_admin(usr)] включил анонимные имена. ТЕМА: [GLOB.current_anonymous_theme]."))

/* Datum singleton initialized by the client proc to hold the naming generation */
/datum/anonymous_theme
	///name of the anonymous theme, seen by admins pressing buttons to enable this
	var/name = "Рандомизированные Имена"
	///if admins get the option to enable extras, this is the prompt to enable it.
	var/extras_prompt
	///extra non-name related fluff that is optional for admins to enable. One example is the wizard theme giving everyone random robes.
	var/extras_enabled

/datum/anonymous_theme/New(extras_enabled = FALSE, alert_players = TRUE)
	. = ..()
	src.extras_enabled = extras_enabled
	if(extras_enabled)
		theme_extras()
	if(alert_players)
		announce_to_all_players()
	anonymous_all_players()

/datum/anonymous_theme/Destroy(force)
	restore_all_players()
	. = ..()

/**
 * theme_extras: optional effects enabled here from a proc that will trigger once on creation of anon mode.
 */
/datum/anonymous_theme/proc/theme_extras()
	return

/**
 * player_extras: optional effects enabled here from a proc that will trigger for every player renamed.
 */
/datum/anonymous_theme/proc/player_extras(mob/living/player)
	return

/**
 * announce_to_all_players: sends an annonuncement.
 *
 * it's in a proc so it can be a non-constant expression.
 */
/datum/anonymous_theme/proc/announce_to_all_players()
	priority_announce("Недавняя бюрократическая ошибка привела к необходимости полного отзыва всех идентичностей и имён до дальнейшего уведомления.", "Потеря идентичности", SSstation.announcer.get_rand_alert_sound())

/**
 * anonymous_all_players: sets all crewmembers on station anonymous.
 *
 * called when the anonymous theme is created regardless of extra theming
 */
/datum/anonymous_theme/proc/anonymous_all_players()
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind || (!ishuman(player) && !issilicon(player)) || player.mind.assigned_role.faction != FACTION_STATION)
			continue
		if(issilicon(player))
			player.fully_replace_character_name(player.real_name, anonymous_ai_name(isAI(player)))
			return
		var/mob/living/carbon/human/human_mob = player
		var/original_name = player.real_name //id will not be changed if you do not do this
		randomize_human_normie(player) //do this first so the special name can be given
		player.fully_replace_character_name(original_name, anonymous_name(player))
		if(extras_enabled)
			player_extras(player)
		human_mob.dna.update_dna_identity()

/**
 * restore_all_players: sets all crewmembers on station back to their preference name.
 *
 * called when the anonymous theme is removed regardless of extra theming
 */
/datum/anonymous_theme/proc/restore_all_players()
	priority_announce("Имена и идентичности восстановлены.", "Восстановление идентичности", SSstation.announcer.get_rand_alert_sound())
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind || (!ishuman(player) && !issilicon(player)) || player.mind.assigned_role.faction != FACTION_STATION)
			continue
		var/old_name = player.real_name //before restoration
		if(issilicon(player))
			INVOKE_ASYNC(player, TYPE_PROC_REF(/mob, apply_pref_name), "[isAI(player) ? /datum/preference/name/ai : /datum/preference/name/cyborg]", player.client)
		else
			player.client.prefs.apply_prefs_to(player) // This is not sound logic, as the prefs may have changed since then.
			player.fully_replace_character_name(old_name, player.real_name) //this changes IDs and PDAs and whatnot

/**
 * anonymous_name: generates a random name, based off of whatever the round's anonymousnames is set to.
 *
 * examples:
 * Employee = "Employee Q5460Z"
 * Wizards = "Gulstaff of Void"
 * Spider Clan = "Initiate Hazuki"
 * Stations? = "Refactor Port One"
 * Arguments:
 * * target - mob for preferences and gender
 */
/datum/anonymous_theme/proc/anonymous_name(mob/target)
	var/datum/client_interface/client = GET_CLIENT(target)
	var/species_type = client.prefs.read_preference(/datum/preference/choiced/species)
	return generate_random_name_species_based(target.gender, TRUE, species_type)

/**
 * anonymous_ai_name: generates a random name, based off of whatever the round's anonymousnames is set to (but for sillycones).
 *
 * examples:
 * Employee = "Employee Assistant Assuming Delta"
 * Wizards = "Crystallized Knowledge Nexus +23"
 * Spider Clan = "'Leaping Viper' MSO"
 * Stations? = "System Port 10"
 * Arguments:
 * * is_ai - boolean to decide whether the name has "Core" (AI) or JOB_ASSISTANT (Cyborg)
 */
/datum/anonymous_theme/proc/anonymous_ai_name(is_ai = FALSE)
	return pick(GLOB.ai_names)

/datum/anonymous_theme/employees
	name = "Employees"

/datum/anonymous_theme/employees/announce_to_all_players()
	priority_announce("В качестве наказания за низкую продуктивность этой станции по сравнению с соседними станциями, имена и идентичности будут ограничены до дальнейшего уведомления.", "Финансовый отчёт", SSstation.announcer.get_rand_alert_sound())

/datum/anonymous_theme/employees/anonymous_name(mob/target)
	var/is_head_of_staff = target.mind.assigned_role.job_flags & JOB_HEAD_OF_STAFF
	var/name = "[is_head_of_staff ? "Менеджер" : "Сотрудник"] "
	for(var/i in 1 to 6)
		if(prob(30) || i == 1)
			name += ascii2text(rand(65, 90)) //A - Z
		else
			name += ascii2text(rand(48, 57)) //0 - 9
	return name

/datum/anonymous_theme/employees/anonymous_ai_name(is_ai = FALSE)
	var/verbs = capitalize(pick(GLOB.ing_verbs))
	var/phonetic = pick(GLOB.phonetic_alphabet)
	return "Сотрудник [is_ai ? "Ядро" : JOB_ASSISTANT] [verbs] [phonetic]"

/datum/anonymous_theme/wizards
	name = "Академия Волшебников"
	extras_prompt = "Также выдать всем случайные мантии?"

/datum/anonymous_theme/wizards/player_extras(mob/living/player)
	var/random_path = pick(
		/obj/item/storage/box/wizard_kit,
		/obj/item/storage/box/wizard_kit/red,
		/obj/item/storage/box/wizard_kit/yellow,
		/obj/item/storage/box/wizard_kit/magusred,
		/obj/item/storage/box/wizard_kit/magusblue,
		/obj/item/storage/box/wizard_kit/black,
	)
	player.put_in_hands(new random_path())

/datum/anonymous_theme/wizards/announce_to_all_players()
	priority_announce("Ваша станция подверглась меметической угрозе Федерации Волшебников. Вы не являетесь с0б0й, и в@ 2Е 34!НЕ4--- Добро пожаловать в Академию, ученики!", "Меметическая угроза", SSstation.announcer.get_rand_alert_sound())

/datum/anonymous_theme/wizards/anonymous_name(mob/target)
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	return "[wizard_name_first] [wizard_name_second]"

/datum/anonymous_theme/wizards/anonymous_ai_name(is_ai = FALSE)
	return "Кристаллизованное Знание [is_ai ? "Нексус" : "Осколок"] +[rand(1,99)]" //Могут ли два человека выпасть на одно число? Да, вероятно. Мне ВАЖНО? Неаа

/datum/anonymous_theme/spider_clan
	name = "Клан Пауков"

/datum/anonymous_theme/spider_clan/anonymous_name(mob/target)
	return "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"

/datum/anonymous_theme/spider_clan/announce_to_all_players()
	priority_announce("Ваша станция продана Клану Пауков. Ваши новые обозначения будут применены сейчас.", "Новое руководство", SSstation.announcer.get_rand_alert_sound())

/datum/anonymous_theme/spider_clan/anonymous_ai_name(is_ai = FALSE)
	var/posibrain_name = pick(GLOB.posibrain_names)
	if(is_ai)
		return "Шаолиньский Мастер Храма [posibrain_name]"
	else
		var/martial_prefix = capitalize(pick(GLOB.martial_prefix))
		var/martial_style = pick("Обезьяны", "Тигра", "Гадюки", "Богомола", "Журавля", "Панды", "Летучей Мыши", "Медведя", "Сороконожки", "Лягушки")
		return "\"[martial_prefix] [martial_style]\" [posibrain_name]"

/datum/anonymous_theme/station
	name = "Станции?"
	extras_prompt = "Также установить название станции как случайное человеческое имя?"

/datum/anonymous_theme/station/theme_extras()
	set_station_name("[pick(GLOB.first_names)] [pick(GLOB.last_names)]")

/datum/anonymous_theme/station/announce_to_all_players()
	priority_announce("Подтверждено событие ошибки реальности 9 уровня вблизи [station_name()]. Весь персонал должен стараться продолжать работу в обычном режиме, чтобы случайно не спровоцировать дополнительные события реальности.", "Дела высших измерений", 'sound/announcer/notice/notice1.ogg')

/datum/anonymous_theme/station/anonymous_name(mob/target)
	return new_station_name()

/datum/anonymous_theme/station/anonymous_ai_name(is_ai = FALSE)
	return new_station_name()
