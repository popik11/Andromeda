///Этот станционный трейт дает 5 листов бананиума клоуну (и каждому мертвому клоуну в глубоком космосе или на лаваленде).
/datum/station_trait/bananium_shipment
	name = "Поставка бананиума"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	report_message = "Ходят слухи, что планета клоунов отправляет пакеты поддержки клоунам в этой системе."
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/bananium_shipment/get_pulsar_message()
	var/advisory_string = "Уровень угрозы: <b>Планета Клоунов</b></center><BR>"
	advisory_string += "Уровень угрозы вашего сектора - Планета Клоунов! Наши велосипедные гудки засекли большое хранилище бананиума. На вашей станции наблюдается большой приток клоунов. Мы настоятельно советуем вам подскальзывать любые угрозы для защиты активов Хонкотрейзен в Банановом Секторе. Департамент Разведки рекомендует защищать химическую лабораторию от любых клоунов, пытающихся создать бальдиум или космическую смазку."
	return advisory_string

/datum/station_trait/unnatural_atmosphere
	name = "Неестественные атмосферные свойства"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Местная планета системы обладает нерегулярными атмосферными свойствами."
	trait_to_give = STATION_TRAIT_UNNATURAL_ATMOSPHERE

	// This station trait modifies the atmosphere, which is too far past the time admins are able to revert it
	can_revert = FALSE

/datum/station_trait/spider_infestation
	name = "Нашествие пауков"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Мы внедрили естественную контрмеру для сокращения количества грызунов на борту вашей станции."
	trait_to_give = STATION_TRAIT_SPIDER_INFESTATION

/datum/station_trait/unique_ai
	name = "Уникальный ИИ"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_flags = parent_type::trait_flags | STATION_TRAIT_REQUIRES_AI
	weight = 5
	show_in_report = TRUE
	report_message = "В экспериментальных целях, ИИ этой станции может демонстрировать отклонения от стандартного набора законов. Не вмешивайтесь в этот эксперимент, мы удалили \
		доступ к вашему набору альтернативных модулей загрузки, потому что мы знаем, что вы уже думаете о вмешательстве в этот эксперимент."
	trait_to_give = STATION_TRAIT_UNIQUE_AI

/datum/station_trait/unique_ai/on_round_start()
	. = ..()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		ai.show_laws()

/datum/station_trait/ian_adventure
	name = "Приключение Иана"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	cost = STATION_TRAIT_COST_LOW
	report_message = "Иан отправился исследовать станцию.. где-то."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/basic/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/basic/pet/dog/corgi/ian) || istype(dog, /mob/living/basic/pet/dog/corgi/puppy/ian)))
			continue

		// Makes this station trait more interesting. Ian probably won't go anywhere without a little external help.
		// Also gives him a couple extra lives to survive eventual tiders.
		dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
		dog.AddComponent(/datum/component/multiple_lives, 2)
		RegisterSignal(dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, PROC_REF(do_corgi_respawn))

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)

/// Moves the new dog somewhere safe, equips it with the old one's inventory and makes it deadchat_playable.
/datum/station_trait/ian_adventure/proc/do_corgi_respawn(mob/living/basic/pet/dog/corgi/old_dog, mob/living/basic/pet/dog/corgi/new_dog, gibbed, lives_left)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(new_dog)
	var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

	do_smoke(location=current_turf)
	new_dog.forceMove(adventure_turf)
	do_smoke(location=adventure_turf)

	if(old_dog.inventory_back)
		var/obj/item/old_dog_back = old_dog.inventory_back
		old_dog.inventory_back = null
		old_dog_back.forceMove(new_dog)
		new_dog.inventory_back = old_dog_back

	if(old_dog.inventory_head)
		var/obj/item/old_dog_hat = old_dog.inventory_head
		old_dog.inventory_head = null
		new_dog.place_on_head(old_dog_hat)

	new_dog.update_corgi_fluff()
	new_dog.regenerate_icons()
	new_dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
	if(lives_left)
		RegisterSignal(new_dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, PROC_REF(do_corgi_respawn))

	if(!gibbed) //The old dog will now disappear so we won't have more than one Ian at a time.
		qdel(old_dog)

/datum/station_trait/glitched_pdas
    name = "Сбой КПК"
    trait_type = STATION_TRAIT_NEUTRAL
    weight = 5
    show_in_report = TRUE
    cost = STATION_TRAIT_COST_MINIMAL
    report_message = "Что-то не так с КПК, выданными вам в эту смену. Это не связанно с мессенджером 'МаксиНТ', не удаляйте его ни в коем случае!"
    trait_to_give = STATION_TRAIT_PDA_GLITCHED

//datum/station_trait/announcement_intern /// Rewokin: Убрал это, т.к. он меняет анонсера.
//	name = "Стажёр объявлений"
//	trait_type = STATION_TRAIT_NEUTRAL
//	weight = 1
//	show_in_report = TRUE
//	report_message = "Пожалуйста, будьте к нему добры."
//	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/birthday)

//datum/station_trait/announcement_intern/New()
//	. = ..()
//	SSstation.announcer = /datum/centcom_announcer/intern

//datum/station_trait/announcement_intern/get_pulsar_message()
//	var/advisory_string = "Advisory Level: <b>(TITLE HERE)</b></center><BR>"
//	advisory_string += "(Copy/Paste the summary provided by the Threat Intelligence Office in this field. You shouldn't have any trouble with this just make sure to replace this message before hitting the send button. Also, make sure there's coffee ready for the meeting at 06:00 when you're done.)"
//	return advisory_string

//datum/station_trait/announcement_medbot
//	name = "Announcement \"System\""
//	trait_type = STATION_TRAIT_NEUTRAL
//	weight = 1
//	show_in_report = TRUE
//	report_message = "Our announcement system is under scheduled maintanance at the moment. Thankfully, we have a backup."
//	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/birthday)

///datum/station_trait/announcement_medbot/New()
//	. = ..()
//	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/colored_assistants
	name = "Разноцветные асистенты"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 10
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "Из-за нехватки комбинезонов стандартного образца, мы предоставили вашим ассистентам один из наших резервных запасов."
	blacklist = list(/datum/station_trait/assistant_gimmicks)

/datum/station_trait/colored_assistants/New()
	. = ..()

	var/new_colored_assistant_type = pick(subtypesof(/datum/colored_assistant) - get_configured_colored_assistant_type())
	GLOB.colored_assistant = new new_colored_assistant_type

/datum/station_trait/birthday
	name = "День рождения сотрудника"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 2
	show_in_report = TRUE
	report_message = "Мы в Нанотрейзен хотим поздравить Имя Сотрудника с днём рождения"
	trait_to_give = STATION_TRAIT_BIRTHDAY
//	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/announcement_medbot) //Переопределение диктора скрывает именинника в сообщении объявления.
	///Переменная, хранящая ссылку на человека, выбранного для празднования дня рождения.
	var/mob/living/carbon/human/birthday_person
	///Переменная, хранящая настоящее имя именинника после выбора, на случай изменения real_name именинника.
	var/birthday_person_name = ""
	///Переменная, которую админы могут переопределить ckey игрока, чтобы установить его именинником при начале раунда.
	var/birthday_override_ckey

/datum/station_trait/birthday/New()
	. = ..()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_JOB_AFTER_SPAWN), PROC_REF(on_job_after_spawn))

/datum/station_trait/birthday/revert()
	for (var/obj/effect/landmark/start/hangover/party_spot in GLOB.start_landmarks_list)
		QDEL_LIST(party_spot.party_debris)
	return ..()

/datum/station_trait/birthday/on_round_start()
	. = ..()
	if(birthday_override_ckey)
		if(!check_valid_override())
			message_admins("Попытка сделать [birthday_override_ckey] именинником провалилась, так как они не являются валидной станционной ролью. Вместо этого выбран случайный именинник.")

	if(!birthday_person)
		var/list/birthday_options = list()
		for(var/mob/living/carbon/human/human in GLOB.human_list)
			if(human.mind?.assigned_role.job_flags & JOB_CREW_MEMBER)
				birthday_options += human
		if(length(birthday_options))
			birthday_person = pick(birthday_options)
			birthday_person_name = birthday_person.real_name
			ADD_TRAIT(birthday_person, TRAIT_BIRTHDAY_BOY, REF(src))
	addtimer(CALLBACK(src, PROC_REF(announce_birthday)), 10 SECONDS)

/datum/station_trait/birthday/proc/check_valid_override()

	var/mob/living/carbon/human/birthday_override_mob = get_mob_by_ckey(birthday_override_ckey)

	if(isnull(birthday_override_mob))
		return FALSE

	if(birthday_override_mob.mind?.assigned_role.job_flags & JOB_CREW_MEMBER)
		birthday_person = birthday_override_mob
		birthday_person_name = birthday_person.real_name
		return TRUE
	else
		return FALSE


/datum/station_trait/birthday/proc/announce_birthday()
	report_message = "Мы в Нанотрейзен хотим поздравить [birthday_person ? birthday_person_name : "Имя Сотрудника"] с днём рождения."
	priority_announce("С днём рождения [birthday_person ? birthday_person_name : "Имя Сотрудника"]! Нанотрейзен поздравляет вас с [birthday_person ? thtotext(birthday_person.age + 1) : "255-м"] днём рождения.")
	if(birthday_person)
		playsound(birthday_person, 'sound/items/party_horn.ogg', 50)
		birthday_person.add_mood_event("birthday", /datum/mood_event/birthday)
		birthday_person = null

/datum/station_trait/birthday/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned_mob)
	SIGNAL_HANDLER

	var/obj/item/hat = pick_weight(list(
		/obj/item/clothing/head/costume/party/festive = 12,
		/obj/item/clothing/head/costume/party = 12,
		/obj/item/clothing/head/costume/festive = 2,
		/obj/item/clothing/head/utility/hardhat/cakehat = 1,
	))
	hat = new hat(spawned_mob)
	if(!spawned_mob.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE))
		spawned_mob.equip_to_storage(hat, ITEM_SLOT_BACK, indirect_action = TRUE)
	var/obj/item/toy = pick_weight(list(
		/obj/item/reagent_containers/spray/chemsprayer/party = 4,
		/obj/item/toy/balloon = 2,
		/obj/item/sparkler = 2,
		/obj/item/clothing/mask/party_horn = 2,
		/obj/item/storage/box/tail_pin = 1,
	))
	toy = new toy(spawned_mob)
	if(istype(toy, /obj/item/toy/balloon))
		spawned_mob.equip_to_slot_or_del(toy, ITEM_SLOT_HANDS) //Balloons do not fit inside of backpacks.
	else
		spawned_mob.equip_to_storage(toy, ITEM_SLOT_BACK, indirect_action = TRUE)
	if(birthday_person_name) //Anyone who joins after the annoucement gets one of these.
		var/obj/item/birthday_invite/birthday_invite = new(spawned_mob)
		birthday_invite.setup_card(birthday_person_name)
		if(!spawned_mob.equip_to_slot_if_possible(birthday_invite, ITEM_SLOT_HANDS, disable_warning = TRUE))
			spawned_mob.equip_to_storage(birthday_invite, ITEM_SLOT_BACK, indirect_action = TRUE) //Just incase someone spawns with both hands full.

/obj/item/birthday_invite
	name = "birthday invitation"
	desc = "Открытка с сообщением, что у кого-то сегодня день рождения."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/birthday_invite/proc/setup_card(birthday_name)
	desc = "Открытка с сообщением, что сегодня день рождения у [birthday_name]."
	icon_state = "paperslip_words"
	icon = 'icons/obj/service/bureaucracy.dmi'

/obj/item/clothing/head/costume/party
	name = "party hat"
	desc = "Дерьмовая бумажная шляпа, которую вы ОБЯЗАНЫ носить."
	icon_state = "party_hat"
	greyscale_config =  /datum/greyscale_config/party_hat
	greyscale_config_worn = /datum/greyscale_config/party_hat/worn
	flags_inv = 0
	armor_type = /datum/armor/none
	var/static/list/hat_colors = list(
		COLOR_PRIDE_RED,
		COLOR_PRIDE_ORANGE,
		COLOR_PRIDE_YELLOW,
		COLOR_PRIDE_GREEN,
		COLOR_PRIDE_BLUE,
		COLOR_PRIDE_PURPLE,
	)

/obj/item/clothing/head/costume/party/Initialize(mapload)
	set_greyscale(colors = list(pick(hat_colors)))
	return ..()

/obj/item/clothing/head/costume/party/festive
	name = "festive paper hat"
	icon_state = "xmashat_grey"
	greyscale_config = /datum/greyscale_config/festive_hat
	greyscale_config_worn = /datum/greyscale_config/festive_hat/worn

/datum/station_trait/scryers
	name = "Ясновидящие"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 2
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Нанотрейзен выбрала вашу станцию для эксперимента - у всех есть бесплатные устройства! Используйте их для лёгкого и приватного общения с другими людьми."

/datum/station_trait/scryers/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/scryers/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/humanspawned = spawned
	// Put their silly little scarf or necktie somewhere else
	var/obj/item/silly_little_scarf = humanspawned.wear_neck
	if(silly_little_scarf)
		var/list/backup_slots = list(LOCATION_LPOCKET, LOCATION_RPOCKET, LOCATION_BACKPACK)
		humanspawned.temporarilyRemoveItemFromInventory(silly_little_scarf)
		silly_little_scarf.forceMove(get_turf(humanspawned))
		humanspawned.equip_in_one_of_slots(silly_little_scarf, backup_slots, qdel_on_fail = FALSE)

	var/obj/item/clothing/neck/link_scryer/loaded/new_scryer = new(spawned)
	new_scryer.label = spawned.name
	new_scryer.update_name()

	spawned.equip_to_slot_or_del(new_scryer, ITEM_SLOT_NECK, initial = FALSE)

/datum/station_trait/wallets
	name = "Кошельки!"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = TRUE
	weight = 5
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "Временно стало модно использовать кошельки, поэтому каждый на станции получил по одному."

/datum/station_trait/wallets/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/wallets/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/living_mob, mob/M, joined_late)
	SIGNAL_HANDLER

	var/obj/item/card/id/advanced/id_card = living_mob.get_item_by_slot(ITEM_SLOT_ID)
	if(!istype(id_card))
		return

	living_mob.temporarilyRemoveItemFromInventory(id_card, force=TRUE)

	// "Doc, what's wrong with me?"
	var/obj/item/storage/wallet/wallet = new(src)
	// "You've got a wallet embedded in your chest."
	wallet.add_fingerprint(living_mob, ignoregloves = TRUE)

	living_mob.equip_to_slot_if_possible(wallet, ITEM_SLOT_ID, initial=TRUE)

	id_card.forceMove(wallet)

	var/holochip_amount = id_card.registered_account.account_balance
	new /obj/item/holochip(wallet, holochip_amount)
	id_card.registered_account.adjust_money(-holochip_amount, "Система: Снятие средств")

	new /obj/effect/spawner/random/entertainment/wallet_storage(wallet)

	// Put our filthy fingerprints all over the contents
	for(var/obj/item/item in wallet)
		item.add_fingerprint(living_mob, ignoregloves = TRUE)

// Говорит генератору карты области ДОБАВИТЬ БОЛЬШЕ ДЕРЕЕЕЕЕЕВЕЕЕВ
/datum/station_trait/forested
	name = "Лесистость"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_to_give = STATION_TRAIT_FORESTED
	trait_flags = STATION_TRAIT_PLANETARY
	weight = 10
	show_in_report = TRUE
	report_message = "Здесь действительно много деревьев."

/datum/station_trait/linked_closets
	name = "Аномалия Шкафов"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = TRUE
	weight = 1
	report_message = "Мы получили сообщения о высоком содержании следов эйгенстазиума на вашей станции. Убедитесь, что ваши шкафы работают.. правильно?"

/datum/station_trait/linked_closets/on_round_start()
	. = ..()
	var/list/roundstart_closets = GLOB.roundstart_station_closets.Copy()

	/**
	 * The number of links to perform. the chance of a closet being linked are about 1 in 10
	 * There are more than 220 roundstart closets on meta, so, about 22 closets will be affected on average.
	 */
	var/number_of_links = round(length(roundstart_closets) * (rand(400, 430)*0.0001), 1)
	for(var/repetition in 1 to number_of_links)
		var/list/targets = list()
		for(var/how_many in 1 to rand(2,3))
			targets += pick_n_take(roundstart_closets)
		GLOB.eigenstate_manager.create_new_link(targets)


#define PRO_SKUB "за-скаб"
#define ANTI_SKUB "против-скаб"
#define SKUB_IDFC "мне всё равно"
#define RANDOM_SKUB null //This means that if you forgot to opt in/against/out, there's a 50/50 chance to be pro or anti

/// Трейт, позволяющий игрокам выбрать, хотят ли они быть за-скаб или против-скаб (или ни то, ни другое), и получить соответствующее снаряжение.
/datum/station_trait/skub
	name = "Великий скаб спор"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = FALSE
	weight = 2
	sign_up_button = TRUE
	/// Список людей, записавшихся быть либо за_скаб, либо против_скаб
	var/list/skubbers = list()

/datum/station_trait/skub/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/skub/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	lobby_button.desc = "Вы за-скаб или против-скаб? Нажмите для переключения между за-скаб, против-скаб, рандомным или остаться нейтрального мения."
	return ..()

/// Let late-joiners jump on this gimmick too.
/datum/station_trait/skub/can_display_lobby_button(client/player)
	return sign_up_button

/// We don't destroy buttons on round start for those who are still in the lobby.
/datum/station_trait/skub/on_round_start()
	return

/datum/station_trait/skub/on_lobby_button_update_icon(atom/movable/screen/lobby/button/sign_up/lobby_button, location, control, params, mob/dead/new_player/user)
	var/mob/player = lobby_button.get_mob()
	var/skub_stance = skubbers[player.ckey]
	switch(skub_stance)
		if(PRO_SKUB)
			lobby_button.base_icon_state = "signup_on"
		if(ANTI_SKUB)
			lobby_button.base_icon_state = "signup"
		else
			lobby_button.base_icon_state = "signup_neutral"

/datum/station_trait/skub/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	var/mob/player = lobby_button.get_mob()
	var/skub_stance = skubbers[player.ckey]
	switch(skub_stance)
		if(PRO_SKUB)
			skubbers[player.ckey] = ANTI_SKUB
			lobby_button.balloon_alert(player, "против-скаб")
		if(ANTI_SKUB)
			skubbers[player.ckey] = SKUB_IDFC
			lobby_button.balloon_alert(player, "всё равно")
		if(SKUB_IDFC)
			skubbers[player.ckey] = RANDOM_SKUB
			lobby_button.balloon_alert(player, "святой рандом")
		if(RANDOM_SKUB)
			skubbers[player.ckey] = PRO_SKUB
			lobby_button.balloon_alert(player, "за-скаб")

/datum/station_trait/skub/proc/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	SIGNAL_HANDLER
	var/mob/player = lobby_button.get_mob()
	var/skub_stance = skubbers[player.ckey]
	switch(skub_stance)
		if(PRO_SKUB)
			overlays += "pro_skub"
		if(ANTI_SKUB)
			overlays += "anti_skub"
		if(SKUB_IDFC)
			overlays += "neutral_skub"
		if(RANDOM_SKUB)
			overlays += "random_skub"

/datum/station_trait/skub/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/skub_stance = skubbers[player_client.ckey]
	if(skub_stance == SKUB_IDFC)
		return

	if((skub_stance == RANDOM_SKUB && prob(50)) || skub_stance == PRO_SKUB)
		var/obj/item/storage/box/stickers/skub/boxie = new(spawned.loc)
		spawned.equip_to_storage(boxie, ITEM_SLOT_BACK, indirect_action = TRUE)
		if(ishuman(spawned))
			var/obj/item/clothing/suit/costume/wellworn_shirt/skub/shirt = new(spawned.loc)
			if(!spawned.equip_to_slot_if_possible(shirt, ITEM_SLOT_OCLOTHING, indirect_action = TRUE))
				shirt.forceMove(boxie)
		return

	var/obj/item/storage/box/stickers/anti_skub/boxie = new(spawned.loc)
	spawned.equip_to_storage(boxie, ITEM_SLOT_BACK, indirect_action = TRUE)
	if(!ishuman(spawned))
		return
	var/obj/item/clothing/suit/costume/wellworn_shirt/skub/anti/shirt = new(spawned.loc)
	if(!spawned.equip_to_slot_if_possible(shirt, ITEM_SLOT_OCLOTHING, indirect_action = TRUE))
		shirt.forceMove(boxie)

#undef PRO_SKUB
#undef ANTI_SKUB
#undef SKUB_IDFC
#undef RANDOM_SKUB

/// Crew don't ever spawn as enemies of the station. Obsesseds, blob infection, space changelings etc can still happen though
/datum/station_trait/background_checks
	name = "Проверки биографий"
	report_message = "Мы заменили стажёра, занимавшегося проверкой биографий вашего экипажа, на обученного специалиста на эту смену! \
		Тем не менее, наши враги могут найти другой способ проникнуть на станцию, так что будьте осторожны."
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	can_revert = FALSE

	dynamic_threat_id = "Проверки биографий"

/datum/station_trait/background_checks/New()
	. = ..()
	RegisterSignal(SSdynamic, COMSIG_DYNAMIC_PRE_ROUNDSTART, PROC_REF(modify_config))

/datum/station_trait/background_checks/proc/modify_config(datum/source, list/dynamic_config)
	SIGNAL_HANDLER

	for(var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		if(ruleset.ruleset_flags & RULESET_INVADER)
			continue
		dynamic_config[initial(ruleset.config_tag)] ||= list()
		dynamic_config[initial(ruleset.config_tag)][NAMEOF(ruleset, weight)] = 0

/datum/station_trait/pet_day
	name = "Приводи питомца на работу"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = FALSE
	weight = 2
	sign_up_button = TRUE

/datum/station_trait/pet_day/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/pet_day/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	lobby_button.desc = "Хотите привести своего невинного питомца в гигантскую металлическую ловушку смерти? Нажмите здесь, чтобы настроить его!"
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	return ..()

/datum/station_trait/pet_day/can_display_lobby_button(client/player)
	return sign_up_button

/datum/station_trait/pet_day/on_round_start()
	return

/datum/station_trait/pet_day/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	var/mob/our_player = lobby_button.get_mob()
	var/client/player_client = our_player.client
	if(isnull(player_client))
		return
	var/datum/pet_customization/customization = GLOB.customized_pets[REF(player_client)]
	if(isnull(customization))
		customization = new(player_client)
	INVOKE_ASYNC(customization, TYPE_PROC_REF(/datum, ui_interact), our_player)

/datum/station_trait/pet_day/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/datum/pet_customization/customization = GLOB.customized_pets[REF(player_client)]
	if(isnull(customization))
		return
	INVOKE_ASYNC(customization, TYPE_PROC_REF(/datum/pet_customization, create_pet), spawned, player_client)

/datum/station_trait/pet_day/proc/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	overlays += "select_pet"

/// Мы делаем Джима Крамера с этим, парни
/datum/station_trait/gmm_spotlight
	name = "Экономическое оповещение ГМР"
	report_message = "В эту смену Галактический Минеральный Рынок проводит демонстрацию благосостояния вашего экипажа! Каждую зарплату станционные дикторы будут оповещать экипаж о том, у кого больше всего кредитов."
	trait_type = STATION_TRAIT_NEUTRAL
	trait_to_give = STATION_TRAIT_ECONOMY_ALERTS
	weight = 2
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE

	dynamic_threat_id = "Экономическое оповещение ГМР"
