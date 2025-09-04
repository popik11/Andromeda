/// Global list of areas which are considered to be inside the same department for our purposes
GLOBAL_LIST_INIT(battle_royale_regions, list(
	"Medical Bay" = list(
		/area/station/command/heads_quarters/cmo,
		/area/station/medical,
		/area/station/security/checkpoint/medical,
	),
	"Research Division" = list(
		/area/station/command/heads_quarters/rd,
		/area/station/security/checkpoint/science,
		/area/station/science,
	),
	"Engineering Bay" = list(
		/area/station/command/heads_quarters/ce,
		/area/station/engineering,
		/area/station/maintenance/disposal/incinerator,
		/area/station/security/checkpoint/engineering,
	),
	"Cargo Bay" = list(
		/area/station/cargo,
		/area/station/command/heads_quarters/qm,
		/area/station/security/checkpoint/supply,
	),
))

/// Quietly implants people with battle royale implants
/obj/item/royale_implanter
	name = "royale implanter"
	desc = "Subtly implants people with rumble royale implants, \
		preparing them to struggle for their life for the enjoyment of the Syndicate's paying audience. \
		Implants may cause irritation at site of implantation."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "nanite_hypo"
	w_class = WEIGHT_CLASS_SMALL
	/// Do we have a linked remote? Just to prevent headdesk moments
	var/linked = FALSE

/obj/item/royale_implanter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		if (!istype(interacting_with, /obj/item/royale_remote))
			return NONE
		var/obj/item/royale_remote/remote = interacting_with
		remote.link_implanter(src, user)
		return ITEM_INTERACT_SUCCESS
	if (!linked)
		balloon_alert(user, "no linked remote!")
		return ITEM_INTERACT_BLOCKING
	if (DOING_INTERACTION_WITH_TARGET(user, interacting_with))
		balloon_alert(user, "busy!")
		return ITEM_INTERACT_BLOCKING
	var/mob/living/potential_winner = interacting_with
	if (potential_winner.stat != CONSCIOUS)
		balloon_alert(user, "target unconscious!")
		return ITEM_INTERACT_BLOCKING
	if (!potential_winner.mind)
		balloon_alert(user, "target too boring!")
		return ITEM_INTERACT_BLOCKING
	log_combat(user, potential_winner, "tried to implant a battle royale implant into")
	if (!do_after(user, 1.5 SECONDS, potential_winner))
		balloon_alert(user, "interrupted!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/implant/explosive/battle_royale/encouragement_implant = new
	if(!encouragement_implant.implant(potential_winner, user))
		qdel(encouragement_implant) // no balloon alert - feedback is usually provided by the implant
		return ITEM_INTERACT_BLOCKING

	potential_winner.balloon_alert(user, "implanted")
	SEND_SIGNAL(src, COMSIG_ROYALE_IMPLANTED, encouragement_implant)
	return ITEM_INTERACT_SUCCESS

/// Activates implants implanted by linked royale implanter
/obj/item/royale_remote
	name = "royale remote"
	desc = "A single use device which will activate any linked rumble royale implants, starting the show."
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "designator_syndicate"
	w_class = WEIGHT_CLASS_SMALL
	/// Minimum number of contestants we should have
	var/required_contestants = 6
	/// List of implanters we are linked to
	var/list/linked_implanters = list()
	/// List of implants of lucky contestants
	var/list/implanted_implants = list()

/obj/item/royale_remote/Destroy(force)
	linked_implanters = null
	implanted_implants = null
	return ..()

/obj/item/royale_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!istype(interacting_with, /obj/item/royale_implanter))
		return NONE
	link_implanter(interacting_with)
	return ITEM_INTERACT_SUCCESS

/obj/item/royale_remote/attack_self(mob/user, modifiers)
	. = ..()
	if (.)
		return
	var/contestant_count = length(implanted_implants)
	if (contestant_count < required_contestants)
		balloon_alert(user, "[required_contestants - contestant_count] contestants needed!")
		return

	GLOB.battle_royale_master.start_battle(implanted_implants)

	for (var/obj/implanter as anything in linked_implanters)
		do_sparks(3, cardinal_only = FALSE, source = implanter)
		qdel(implanter)
	do_sparks(3, cardinal_only = FALSE, source = src)
	qdel(src)

/// Link to an implanter
/obj/item/royale_remote/proc/link_implanter(obj/item/royale_implanter/implanter, mob/user)
	if (implanter in linked_implanters)
		if (user)
			balloon_alert(user, "already linked!")
		return

	if (user)
		balloon_alert(user, "link established")

	implanter.linked = TRUE
	linked_implanters += implanter
	RegisterSignal(implanter, COMSIG_ROYALE_IMPLANTED, PROC_REF(record_contestant))
	RegisterSignal(implanter, COMSIG_QDELETING, PROC_REF(implanter_destroyed))

/// Record that someone just got implanted
/obj/item/royale_remote/proc/record_contestant(obj/item/implanter, obj/item/implant)
	SIGNAL_HANDLER
	implanted_implants |= implant
	RegisterSignal(implant, COMSIG_QDELETING, PROC_REF(implant_destroyed))

/// A linked implanter was destroyed
/obj/item/royale_remote/proc/implanter_destroyed(obj/item/implanter)
	SIGNAL_HANDLER
	linked_implanters -= implanter

/obj/item/royale_remote/proc/implant_destroyed(obj/item/implant)
	SIGNAL_HANDLER
	implanted_implants -= implant

GLOBAL_DATUM_INIT(battle_royale_master, /datum/battle_royale_master, new)

/// Basically just exists to hold references to datums so that they don't GC
/datum/battle_royale_master
	/// List of battle royale datums currently running
	var/list/active_battles

/// Start a new battle royale using a passed list of implants
/datum/battle_royale_master/proc/start_battle(list/competitors)
	var/datum/battle_royale_controller/controller = new()
	if (!controller.start(competitors))
		return FALSE
	LAZYADD(active_battles, controller)
	if (LAZYLEN(active_battles) == 1)
		start_broadcasting_network(BATTLE_ROYALE_CAMERA_NET)
	RegisterSignal(controller, COMSIG_QDELETING, PROC_REF(battle_ended))
	return TRUE

/// Drop reference when it kills itself
/datum/battle_royale_master/proc/battle_ended(datum/source)
	SIGNAL_HANDLER
	LAZYREMOVE(active_battles, source)
	if (!LAZYLEN(active_battles))
		stop_broadcasting_network(BATTLE_ROYALE_CAMERA_NET)

/// Datum which controls the conflict
/datum/battle_royale_controller
	/// Where is our battle taking place?
	var/chosen_area
	/// Is the battle currently in progress?
	var/battle_running = TRUE
	/// Should we let everyone know that someone has died?
	var/announce_deaths = TRUE
	/// List of implants involved
	var/list/contestant_implants = list()
	/// Ways to describe that someone has died
	var/static/list/euphemisms = list(
		"cashed their last paycheque.",
		"didn't make it...",
		"didn't make the cut.",
		"had their head blown clean off!",
		"has been killed!",
		"has failed the challenge!",
		"has passed away.",
		"has died.",
		"is in a better place now.",
		"isn't going to be clocking in tomorrow!",
		"just flatlined.",
		"isn't today's winner.",
		"seems to have exploded!",
		"was just murdered on live tv!",
		"won't be making it to retirement.",
		"won't be getting back up after that one.",
	)
	/// Ways to tell people not to salt in deadchat, surely effective
	var/static/list/condolences = list(
		"Better luck next time!",
		"But stay tuned, there's still everything to play for!",
		"Did you catch who did it?",
		"It looked like that one really hurt...",
		"Let's get that one on action replay!",
		"Let's have a moment of silence, please.",
		"Let's hope the next one does better.",
		"Someone please notify their next of kin.",
		"They had a good run.",
		"Too bad!",
		"What a shame!",
		"What an upset!",
		"What's going to happen next?",
		"Who could have seen that coming?",
		"Who will be next?",
	)

/datum/battle_royale_controller/Destroy(force)
	contestant_implants = null
	return ..()

/// Start a battle royale with the list of provided implants
/datum/battle_royale_controller/proc/start(list/implants, battle_time = 10 MINUTES)
	chosen_area = pick(GLOB.battle_royale_regions)
	for (var/obj/item/implant/explosive/battle_royale/contestant_implant in implants)
		contestant_implant.start_battle(chosen_area, GLOB.battle_royale_regions[chosen_area])
		if (isnull(contestant_implant))
			continue // Might have exploded if it was removed from a person
		RegisterSignal(contestant_implant, COMSIG_QDELETING, PROC_REF(implant_destroyed))
		contestant_implants |= contestant_implant

	if (length(contestant_implants) <= 1)
		return FALSE // Well there's not much point is there

	priority_announce(
		text = "Поздравляем [station_name()], вы выбраны следующей площадкой для Грохочущего Рояля! \n\
			Зрители по всему сектору будут наблюдать, как наши [convert_integer_to_words(length(contestant_implants))] счастливчиков пробиваются в ваш [chosen_area] и сражаются до последнего выжившего! \n\
			Если они не успеют за пять минут, они будут дисквалифицированы. Если вы увидите, что один из наших игроков пытается пробраться внутрь, помогите ему... или не помогайте, если готовы жить с последствиями!  \n\
			В знак благодарности мы предоставляем нашу премиальную трансляцию на ваши развлекательные мониторы бесплатно, чтобы вы могли наслаждаться зрелищем. \n\
			Сторонним наблюдателям не рекомендуется вмешиваться... но если вмешаетесь, сделайте это зрелищно для камер!",
		title = "Начало Грохочущего Рояля",
		sound = 'sound/announcer/alarm/nuke_alarm.ogg',
		has_important_message = TRUE,
		sender_override = "Пиратская Вещательная Станция",
		color_override = "red",
	)

	for (var/obj/item/implant/explosive/battle_royale/contestant_implant as anything in contestant_implants)
		contestant_implant.announce()
	addtimer(CALLBACK(src, PROC_REF(limit_area)), battle_time / 2, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(finish)), battle_time, TIMER_DELETE_ME)
	return TRUE

/// An implant was destroyed, hopefully because it exploded. Count how many competitors remain.
/datum/battle_royale_controller/proc/implant_destroyed(obj/item/implant/implant)
	SIGNAL_HANDLER
	contestant_implants -= implant
	if (!battle_running)
		return

	if (length(contestant_implants) <= 1)
		announce_winner(implant)
	else if (announce_deaths)
		var/message = ""
		if (isnull(implant.imp_in))
			message = "Looks like someone removed and destroyed their implant, that's cheating!"
		else
			message = "[implant.imp_in.real_name] [pick(euphemisms)] [pick(condolences)]"
		priority_announce(
			text = message,
			title = "Отчёт о жертвах Грохочущего Рояля",
			sound = 'sound/announcer/notice/notice1.ogg',
			has_important_message = TRUE,
			sender_override = "Пиратская Вещательная Станция",
			color_override = "red",
		)

/// There's only one person left, we have a winner!
/datum/battle_royale_controller/proc/announce_winner(obj/item/implant/losing_implant)
	battle_running = FALSE
	if (length(contestant_implants) > 1)
		return

	var/message = ""
	var/mob/living/loser = losing_implant.imp_in
	var/obj/item/implant/winning_implant = pop(contestant_implants)
	var/mob/living/winner = winning_implant?.imp_in

	if (isnull(winner) && isnull(loser))
		message = "Somehow, it seems like there's no winner tonight. What a disappointment!"
	else
		var/loser_text = isnull(loser) ? "With the disqualification of the other remaining contestant" : "With the death of [loser.real_name]"
		var/winner_text = isnull(winner) ? "we must sadly announce that the would-be winner has also been disqualified. Such bad showmanship!" : "only [winner.real_name] remains. Congratulations, we have a winner!"
		message = "[loser_text], [winner_text]"

	if (!isnull(winner))
		podspawn(list(
			"target" = get_turf(winner),
			"style" = /datum/pod_style/syndicate,
			"spawn" = /obj/item/food/roast_dinner,
		))

	priority_announce(
		text = message,
		title = "Победитель Грохочущего Рояля",
		sound = 'sound/announcer/notice/notice1.ogg',
		has_important_message = TRUE,
		sender_override = "Пиратская Вещательная Станция",
		color_override = "red",
	)

	qdel(winning_implant) // You get to live!
	winner?.mind?.remove_antag_datum(/datum/antagonist/survivalist/battle_royale)
	qdel(src)

/// Called halfway through the battle, if you've not made it to the designated battle zone we kill you
/datum/battle_royale_controller/proc/limit_area()
	priority_announce(
		text = "Мы на полпути, народ! И плохие новости для тех, кто не добрался до [chosen_area]... вы выбыли!",
		title = "Обновление Грохочущего Рояля",
		sound = 'sound/announcer/notice/notice1.ogg',
		has_important_message = TRUE,
		sender_override = "Пиратская Вещательная Станция",
		color_override = "red",
	)

	for (var/obj/item/implant/explosive/battle_royale/contestant_implant as anything in contestant_implants)
		contestant_implant.limit_areas()

/// Well you're out of time, bad luck
/datum/battle_royale_controller/proc/finish()
	battle_running = FALSE

	priority_announce(
		text = "Сожалеем, оставшиеся участники, ваше время вышло. \
			Мы с сожалением сообщаем, что в этом выпуске Грохочущего Рояля нет победителя. \n\
			Удачи в следующий раз!",
		title = "Завершение Грохочущего Рояля",
		sound = 'sound/announcer/notice/notice1.ogg',
		has_important_message = TRUE,
		sender_override = "Пиратская Вещательная Станция",
		color_override = "red",
	)

	for (var/obj/item/implant/explosive/battle_royale/contestant_implant as anything in contestant_implants)
		contestant_implant.explode()

	qdel(src)
