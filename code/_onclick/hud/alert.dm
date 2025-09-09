//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want

/**
 *Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
 *category is a text string. Each mob may only have one alert per category; the previous one will be replaced
 *path is a type path of the actual alert type to throw
 *severity is an optional number that will be placed at the end of the icon_state for this alert
 *for example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 *new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
 *flicks are forwarded to master
 *override makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 */
/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE, timeout_override, no_anim = FALSE)

	if(!category || QDELETED(src))
		return

	var/datum/weakref/master_ref
	if(isdatum(new_master))
		master_ref = WEAKREF(new_master)
	var/atom/movable/screen/alert/thealert
	if(alerts[category])
		thealert = alerts[category]
		if(thealert.override_alerts)
			return thealert
		if(master_ref && thealert.master_ref && master_ref != thealert.master_ref)
			var/datum/current_master = thealert.master_ref.resolve()
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [current_master]")

			clear_alert(category)
			return .()
		else if(thealert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == thealert.severity)
			if(!thealert.timeout)
				// No need to update existing alert
				return thealert
			// Reset timeout of existing alert
			var/timeout = timeout_override || initial(thealert.timeout)
			addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), timeout)
			thealert.timeout = world.time + timeout - world.tick_lag
			return thealert
	else
		thealert = new type()
		thealert.override_alerts = override
		if(override)
			thealert.timeout = null
	thealert.owner = src

	if(new_master)
		var/mutable_appearance/master_appearance = new(new_master)
		master_appearance.appearance_flags = KEEP_TOGETHER
		master_appearance.layer = FLOAT_LAYER
		master_appearance.plane = FLOAT_PLANE
		master_appearance.dir = SOUTH
		master_appearance.pixel_x = new_master.base_pixel_x
		master_appearance.pixel_y = new_master.base_pixel_y
		master_appearance.pixel_z = new_master.base_pixel_z
		thealert.add_overlay(strip_appearance_underlays(master_appearance))
		thealert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		thealert.master_ref = master_ref
	else
		thealert.icon_state = "[initial(thealert.icon_state)][severity]"
		thealert.severity = severity

	alerts[category] = thealert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	if(!no_anim)
		thealert.transform = matrix(32, 0, MATRIX_TRANSLATE)
		animate(thealert, transform = matrix(), time = 1 SECONDS, easing = ELASTIC_EASING)
	if(timeout_override)
		thealert.timeout = timeout_override
	if(thealert.timeout)
		addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag
	return thealert

/mob/proc/alert_timeout(atom/movable/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = alerts[category]
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

// Proc to check for an alert
/mob/proc/has_alert(category)
	return !isnull(alerts[category])

/atom/movable/screen/alert
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Похоже, что-то пошло не так с этим предупреждением. Пожалуйста, сообщите об этой ошибке."
	mouse_opacity = MOUSE_OPACITY_ICON
	/// do we glow to represent we do stuff when clicked
	var/clickable_glow = FALSE
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/owner //Alert owner

	/// Boolean. If TRUE, the Click() proc will attempt to Click() on the master first if there is a master.
	var/click_master = TRUE

/atom/movable/screen/alert/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(clickable_glow)
		add_filter("clickglow", 2, outline_filter(color = COLOR_GOLD, size = 1))
		mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/alert/MouseEntered(location,control,params)
	. = ..()
	if(!QDELETED(src))
		openToolTip(usr,src,params,title = declent_ru(NOMINATIVE),content = desc,theme = alerttooltipstyle)


/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)


//Gas alerts
// Gas alerts are continuously thrown/cleared by:
// * /obj/item/organ/lungs/proc/check_breath()
// * /mob/living/carbon/check_breath()
// * /mob/living/carbon/human/check_breath()
// * /datum/element/atmos_requirements/proc/on_non_stasis_life()
// * /mob/living/simple_animal/handle_environment()

/atom/movable/screen/alert/not_enough_oxy
	name = "Удушье (Не хватает O2)"
	desc = "Вам не хватает кислорода. Найдите пригодный для дыхания воздух прежде чем потерять сознание! В коробке вашего рюкзака есть баллон с кислородом и маска."
	icon_state = ALERT_NOT_ENOUGH_OXYGEN

/atom/movable/screen/alert/too_much_oxy
	name = "Удушье (Избыток O2)"
	desc = "В воздухе слишком много кислорода, и вы его вдыхаете! Найдите пригодный для дыхания воздух прежде чем потерять сознание!"
	icon_state = ALERT_TOO_MUCH_OXYGEN

/atom/movable/screen/alert/not_enough_nitro
	name = "Удушье (Не хватает N2)"
	desc = "Вам не хватает азота. Найдите пригодный для дыхания воздух прежде чем потерять сознание!"
	icon_state = ALERT_NOT_ENOUGH_NITRO

/atom/movable/screen/alert/too_much_nitro
	name = "Удушье (Избыток N2)"
	desc = "В воздухе слишком много азота, и вы его вдыхаете! Найдите пригодный для дыхания воздух прежде чем потерять сознание!"
	icon_state = ALERT_TOO_MUCH_NITRO

/atom/movable/screen/alert/not_enough_co2
	name = "Удушье (Не хватает CO2)"
	desc = "Вам не хватает углекислого газа. Найдите пригодный для дыхания воздух прежде чем потерять сознание!"
	icon_state = ALERT_NOT_ENOUGH_CO2

/atom/movable/screen/alert/too_much_co2
	name = "Удушье (Избыток CO2)"
	desc = "В воздухе слишком много углекислого газа, и вы его вдыхаете! Найдите пригодный для дыхания воздух прежде чем потерять сознание!"
	icon_state = ALERT_TOO_MUCH_CO2

/atom/movable/screen/alert/not_enough_plas
	name = "Удушье (Не хватает плазмы)"
	desc = "Вам не хватает плазмы. Найдите пригодный для дыхания воздух прежде чем потерять сознание! В коробке вашего рюкзака есть запасной баллон с плазмой."
	icon_state = ALERT_NOT_ENOUGH_PLASMA

/atom/movable/screen/alert/too_much_plas
	name = "Удушье (Избыток плазмы)"
	desc = "В воздухе находится легковоспламеняющаяся токсичная плазма, и вы её вдыхаете. Найдите чистый воздух. В коробке вашего рюкзака есть баллон с кислородом и маска."
	icon_state = ALERT_TOO_MUCH_PLASMA

/atom/movable/screen/alert/not_enough_n2o
	name = "Удушье (Не хватает N2O)"
	desc = "Вам не хватает закиси азота. Найдите пригодный для дыхания воздух прежде чем потерять сознание!"
	icon_state = ALERT_NOT_ENOUGH_N2O

/atom/movable/screen/alert/too_much_n2o
	name = "Удушье (Избыток N2O)"
	desc = "В воздухе находится усыпляющий газ, и вы его вдыхаете. Найдите чистый воздух. В коробке вашего рюкзака есть баллон с кислородом и маска."
	icon_state = ALERT_TOO_MUCH_N2O

/atom/movable/screen/alert/not_enough_water
	name = "Удушье (Не хватает H2O)"
	desc = "Вам не хватает воды. Обливайтесь водой (например, в душе) или найдите водяной пар прежде чем потерять сознание!"
	icon_state = ALERT_NOT_ENOUGH_WATER

//End gas alerts

/atom/movable/screen/alert/bronchodilated
	name = "Bronchodilated"
	desc = "You feel like your lungs are larger than usual! You're taking deeper breaths!"
	icon_state = "bronchodilated"

/atom/movable/screen/alert/bronchoconstricted
	name = "Bronchocontracted"
	desc = "You feel like your lungs are smaller than usual! You might need a higher pressure environment/internals to breathe!"
	icon_state = "bronchoconstricted"

/atom/movable/screen/alert/gross
	name = "Фу..."
	desc = "Это было довольно противно..."
	icon_state = "gross"

/atom/movable/screen/alert/verygross
	name = "Очень противно"
	desc = "Вы чувствуете себя нехорошо..."
	icon_state = "gross2"

/atom/movable/screen/alert/disgusted
	name = "ОТВРАЩЕНИЕ"
	desc = "ПОЛНЫЙ ОТВРАТ!"
	icon_state = "gross3"

/atom/movable/screen/alert/hot
	name = "Слишком жарко"
	desc = "Вы раскалены как печь! Перейдите в прохладное место и снимите теплоизолирующую одежду, например, противопожарный костюм."
	icon_state = "hot"

/atom/movable/screen/alert/cold
	name = "Слишком холодно"
	desc = "Вы замерзаете! Перейдите в теплое место и снимите теплоизолирующую одежду, например, скафандр."
	icon_state = "cold"

/atom/movable/screen/alert/lowpressure
	name = "Низкое давление"
	desc = "Воздух вокруг вас опасно разрежен. Скафандр защитит вас."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "Высокое давление"
	desc = "Воздух вокруг вас опасно плотный. Противопожарный костюм защитит вас."
	icon_state = "highpressure"

/atom/movable/screen/alert/hypnosis
	name = "Гипноз"
	desc = "Кто-то гипнотизирует вас, но вы не уверены в чем именно."
	icon_state = ALERT_HYPNOSIS
	var/phrase

/atom/movable/screen/alert/mind_control
	name = "Контроль разума"
	desc = "Ваш разум был захвачен! Нажмите, чтобы увидеть команду контроля."
	icon_state = ALERT_MIND_CONTROL
	clickable_glow = TRUE
	var/command

/atom/movable/screen/alert/mind_control/Click()
	. = ..()
	if(!.)
		return
	to_chat(owner, span_mind_control("[command]"))

/atom/movable/screen/alert/embeddedobject
	name = "Инородный предмет"
	desc = "Что-то застряло в вашей плоти и вызывает сильное кровотечение. Со временем может выпасть само, но операция - самый безопасный способ. \
		Если чувствуете себя храбрым, осмотрите себя и нажмите на подчеркнутый предмет, чтобы извлечь его."
	icon_state = ALERT_EMBEDDED_OBJECT
	clickable_glow = TRUE

/atom/movable/screen/alert/embeddedobject/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/carbon_owner = owner
	return carbon_owner.check_self_for_injuries()

/atom/movable/screen/alert/negative
	name = "Отрицательная гравитация"
	desc = "Вас тянет вверх. Хотя вам больше не нужно бояться падений вниз, теперь вы можете случайно упасть вверх!"
	icon_state = "negative"

/atom/movable/screen/alert/weightless
	name = "Невесомость"
	desc = "Гравитация перестала на вас действовать, и вы беспомощно парите в пространстве. Чтобы двигаться, вам нужно оттолкнуться от чего-то \
массивного вроде стены или решетки. Реактивный ранец позволит свободно перемещаться. Магнитные ботинки дадут возможность ходить по полу. \
В крайнем случае, можно бросать предметы, использовать огнетушитель или стрелять из оружия, используя 3-й закон Ньютона."
	icon_state = "weightless"

/atom/movable/screen/alert/highgravity
	name = "Высокая гравитация"
	desc = "Вас сдавливает высокая гравитация, замедляя подъем предметов и передвижение."
	icon_state = "paralysis"

/atom/movable/screen/alert/veryhighgravity
	name = "Давящая гравитация"
	desc = "Вас сдавливает высокая гравитация, замедляя подъем предметов и передвижение. Вы также будете получать физический урон!"
	icon_state = "paralysis"

/atom/movable/screen/alert/fire
	name = "Горю"
	desc = "Вы горите. Остановитесь, падайте и катитесь, чтобы потушить огонь или переместитесь в вакуум."
	icon_state = "fire"
	clickable_glow = TRUE

/atom/movable/screen/alert/fire/Click()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/living_owner = owner
	if(!living_owner.can_resist())
		return FALSE

	living_owner.changeNext_move(CLICK_CD_RESIST)
	if(!(living_owner.mobility_flags & MOBILITY_MOVE))
		return FALSE

	return handle_stop_drop_roll(owner)

/atom/movable/screen/alert/fire/proc/handle_stop_drop_roll(mob/living/roller)
	return roller.resist_fire()

/atom/movable/screen/alert/give // information set when the give alert is made
	icon_state = "default"
	clickable_glow = TRUE
	/// The offer we're linked to, yes this is suspiciously like a status effect alert
	var/datum/status_effect/offering/offer
	/// Additional text displayed in the description of the alert.
	var/additional_desc_text = "Нажмите на этот алерт(иконку), чтобы взять его, или Shift + клик для осмотра."
	/// Text to override what appears in screentips for the alert
	var/screentip_override_text
	/// Whether the offered item can be examined by shift-clicking the alert
	var/examinable = TRUE

/atom/movable/screen/alert/give/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	register_context()

/atom/movable/screen/alert/give/Destroy()
	offer = null
	return ..()

/atom/movable/screen/alert/give/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = screentip_override_text || "Взять [offer.offered_item.name]"
	context[SCREENTIP_CONTEXT_SHIFT_LMB] = "Исследовать"
	return CONTEXTUAL_SCREENTIP_SET

/**
 * Handles assigning most of the variables for the alert that pops up when an item is offered
 *
 * Handles setting the name, description and icon of the alert and tracking the living mob giving
 * and the item being offered.
 * Arguments:
 * * taker - The living mob receiving the alert
 * * offer - The status effect connected to the offer being made
 */
/atom/movable/screen/alert/give/proc/setup(mob/living/taker, datum/status_effect/offering/offer)
	src.offer = offer

	var/mob/living/offerer = offer.owner
	var/obj/item/receiving = offer.offered_item
	var/receiving_name = get_receiving_name(taker, offerer, receiving)
	name = "[offerer] предлагает [receiving_name]"
	desc = "[offerer] предлагает [receiving_name]. [additional_desc_text]"
	icon_state = "template"
	cut_overlays()
	add_overlay(receiving)

/**
 * Called right before `setup()`, to do any sort of logic to change the name of
 * what's displayed as the name of what's being offered in the alert. Use this to
 * add pronouns and the like, or to totally override the displayed name!
 * Also the best place to make changes to `additional_desc_text` before `setup()`
 * without having to override `setup()` entirely.
 *
 * Arguments:
 * * taker - The person receiving the alert
 * * offerer - The person giving the alert and item
 * * receiving - The item being given by the offerer
 *
 * Returns a string that will be displayed in the alert, which is `receiving.name`
 * by default.
 */
/atom/movable/screen/alert/give/proc/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	return receiving.name

/atom/movable/screen/alert/give/Click(location, control, params)
	. = ..()
	if(!.)
		return

	if(!isliving(usr))
		CRASH("Пользователь для [src] имеет тип \[[usr.type]\]. Этого никогда не должно происходить.")

	handle_transfer()

/atom/movable/screen/alert/give/examine(mob/user)
	if(!examinable)
		return ..()

	return list(
		span_boldnotice(name),
		span_info("[offer.owner] предлагает вам следующий предмет (нажмите на алерт чтобы взять его!):"),
		"<hr>[jointext(offer.offered_item.examine(user), "\n")]",
	)

/// An overrideable proc used simply to hand over the item when claimed, this is a proc so that high-fives can override them since nothing is actually transferred
/atom/movable/screen/alert/give/proc/handle_transfer()
	var/mob/living/taker = owner
	var/mob/living/offerer = offer.owner
	var/obj/item/receiving = offer.offered_item
	taker.take(offerer, receiving)
	SEND_SIGNAL(offerer, COMSIG_LIVING_ITEM_GIVEN, taker, receiving)

/atom/movable/screen/alert/give/highfive
	additional_desc_text = "Нажмите на этот алерт чтобы дать пять."
	screentip_override_text = "Дать пять"
	examinable = FALSE
	/// Отслеживает активное замедление, чтобы предотвратить спам-клики
	var/too_slowing_this_guy = FALSE

/atom/movable/screen/alert/give/highfive/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	return "a high-five"

/atom/movable/screen/alert/give/highfive/setup(mob/living/taker, datum/status_effect/offering/offer)
	. = ..()
	RegisterSignal(offer.owner, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(check_fake_out))

/atom/movable/screen/alert/give/highfive/handle_transfer()
	if(too_slowing_this_guy)
		return

	var/mob/living/taker = owner
	var/mob/living/offerer = offer.owner
	var/obj/item/receiving = offer.offered_item
	if(!QDELETED(receiving) && offerer.is_holding(receiving))
		receiving.on_offer_taken(offerer, taker)
		return

	too_slow_p1()

/// Если игрок, предложивший дать пять, больше не может этого сделать при попытке принять - вас жестоко разыграли
/atom/movable/screen/alert/give/highfive/proc/too_slow_p1()
	var/mob/living/rube = owner
	var/mob/living/offerer = offer?.owner
	if(QDELETED(rube) || QDELETED(offerer))
		qdel(src)
		return

	too_slowing_this_guy = TRUE
	offerer.visible_message(span_notice("[rube] бросается дать пять [offerer], но-"), span_nicegreen("[rube] попадается на вашу уловку, как и планировалось, пытаясь дать пять, которого больше нет! Классика!"), ignored_mobs=rube)
	to_chat(rube, span_nicegreen("Вы пытаетесь дать пять [offerer], но-"))
	addtimer(CALLBACK(src, PROC_REF(too_slow_p2), offerer, rube), 0.5 SECONDS)

/// Part two of the ultimate prank
/atom/movable/screen/alert/give/highfive/proc/too_slow_p2()
	var/mob/living/rube = owner
	var/mob/living/offerer = offer?.owner
	if(!QDELETED(rube) && !QDELETED(offerer))
		offerer.visible_message(span_danger("[offerer] убирает руку в последний момент, полностью избегая пятерни [rube]!"), span_nicegreen("[rube] не успевает коснуться вашей руки, полностью опозорив [rube.p_them()]!"), span_hear("Вы слышите разочаровывающий звук, когда ладони не встречаются!"), ignored_mobs=rube)
		to_chat(rube, span_userdanger("[uppertext("НЕТ! [offerer] УБИРАЕТ [offerer.p_their()] РУКУ! ВЫ СЛИШКОМ МЕДЛЕННЫ!")]"))
		playsound(offerer, 'sound/items/weapons/thudswoosh.ogg', 100, TRUE, 1)
		rube.Knockdown(1 SECONDS)
		offerer.add_mood_event("high_five", /datum/mood_event/down_low)
		rube.add_mood_event("high_five", /datum/mood_event/too_slow)
		offerer.remove_status_effect(/datum/status_effect/offering/no_item_received/high_five)

	qdel(src)

/// Если кто-то использует examine_more на предлагающего во время попытки "слишком медленно", это раскроет его хитрый план
/atom/movable/screen/alert/give/highfive/proc/check_fake_out(mob/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(QDELETED(offer.offered_item))
		examine_list += span_warning("Рука [source] выглядит напряженной, будто [source.p_they()] собирается резко дёрнуть её назад...")

/atom/movable/screen/alert/give/hand
	screentip_override_text = "Взять руку"
	examinable = FALSE

/atom/movable/screen/alert/give/hand/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	additional_desc_text = "Нажмите на алерт, чтобы взяться и позволить [offerer.p_them()] тащить вас!"
	return "[offerer.p_their()] [receiving.name]"

/atom/movable/screen/alert/give/hand/helping

/atom/movable/screen/alert/give/hand/helping/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	. = ..()
	additional_desc_text = "Нажмите на алерт, чтобы позволить вам помочь подняться!"

/// Дает игроку возможность сдаться в критическом состоянии
/atom/movable/screen/alert/succumb
	name = "Сдаться"
	desc = "Сбросьте эту бренную оболочку."
	icon_state = ALERT_SUCCUMB
	clickable_glow = TRUE
	var/static/list/death_titles = list(
		"Спокойной ночи, бедный космонавтик",
		"Игра окончена, чувак",
		"Конец дороги",
		"Живи долго и процветай",
		"Увидимся, космический ковбой...",
		"Для меня была честь",
		"Занавес закрывается",
		"Всему хорошему приходит конец"
	)

/atom/movable/screen/alert/succumb/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/living/living_owner = owner
	if(!CAN_SUCCUMB(living_owner) && !HAS_TRAIT(living_owner, TRAIT_SUCCUMB_OVERRIDE)) //checked again in [mob/living/verb/succumb()]
		return

	var/title = pick(death_titles)

	//Succumbing with a message
	var/last_whisper = tgui_input_text(usr, "У вас есть последние слова?", title, max_length = CHAT_MESSAGE_MAX_LENGTH, encode = FALSE) // saycode already handles sanitization
	if(isnull(last_whisper))
		return
	if(length(last_whisper))
		living_owner.say("#[last_whisper]")
	living_owner.succumb(whispered = length(last_whisper) > 0)

// ЧУЖЕРОДНЫЕ

/atom/movable/screen/alert/alien_plas
	name = "Плазма"
	desc = "В воздухе горючая плазма. Если она воспламенится, вам конец."
	icon_state = ALERT_XENO_PLASMA
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// Этот алерт временно будет появляться для любого горячего воздуха, но однажды будет использоваться только при реальном горении
	name = "Слишком жарко"
	desc = "Слишком жарко! Бегите в космос или хотя бы подальше от пламени. Стояние на сорняках будет исцелять вас."
	icon_state = ALERT_XENO_FIRE
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_vulnerable
	name = "Уничтожена матриархия"
	desc = "Ваша королева убита, вы будете страдать от штрафов к передвижению и потери связи с роем. Новая королева не может быть создана до вашего восстановления."
	icon_state = ALERT_XENO_NOQUEEN
	alerttooltipstyle = "alien"

// БЛОБЫ

/atom/movable/screen/alert/nofactory
	name = "Нет фабрики"
	desc = "У вас нет фабрики, и вы медленно умираете!"
	icon_state = "blobbernaut_nofactory"
	alerttooltipstyle = "blob"

// КРОВАВЫЙ КУЛЬТ

/atom/movable/screen/alert/bloodsense
	name = "Чувство Крови"
	desc = "Позволяет ощущать кровь, управляемую тёмной магией."
	icon_state = "cult_sense"
	alerttooltipstyle = "cult"
	var/static/image/narnar
	var/angle = 0
	var/mob/living/basic/construct/construct_owner

/atom/movable/screen/alert/bloodsense/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	narnar = new('icons/hud/screen_alert.dmi', "mini_nar")
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/bloodsense/Destroy()
	construct_owner = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/alert/bloodsense/process()
	var/atom/blood_target

	if(!owner.mind)
		return

	if(isconstruct(owner))
		construct_owner = owner
	else
		construct_owner = null

	// отслеживание конструкта
	if(construct_owner?.seeking && construct_owner.construct_master)
		blood_target = construct_owner.construct_master
		desc = "Ваше чувство крови ведёт вас к [construct_owner.construct_master]"

	// cult track
	var/datum/antagonist/cult/antag = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(antag)
		var/datum/objective/sacrifice/sac_objective = locate() in antag.cult_team.objectives
		if(antag.cult_team.blood_target)
			if(!get_turf(antag.cult_team.blood_target))
				antag.cult_team.unset_blood_target()
			else
				blood_target = antag.cult_team.blood_target
		if(!blood_target)
			if(sac_objective && !sac_objective.check_completion())
				if(icon_state == "runed_sense0")
					return
				animate(src, transform = null, time = 1, loop = 0)
				angle = 0
				cut_overlays()
				icon_state = "runed_sense0"
				desc = "Нар'Си требует, чтобы [sac_objective.target] был принесён в жертву до начала ритуала призыва."
				add_overlay(sac_objective.sac_image)
			else
				var/datum/objective/eldergod/summon_objective = locate() in antag.cult_team.objectives
				if(!summon_objective)
					return
				var/list/location_list = list()
				for(var/area/area_to_check in summon_objective.summon_spots)
					location_list += area_to_check.get_original_area_name()
				desc = "Жертвоприношение завершено, призывайте Нар'Си! Призыв возможен только в [english_list(location_list)]!"
				if(icon_state == "runed_sense1")
					return
				animate(src, transform = null, time = 1, loop = 0)
				angle = 0
				cut_overlays()
				icon_state = "runed_sense1"
				add_overlay(narnar)
			return

	// actual tracking
	var/turf/P = get_turf(blood_target)
	var/turf/Q = get_turf(owner)
	if(!P || !Q || (P.z != Q.z)) //The target is on a different Z level, we cannot sense that far.
		icon_state = "runed_sense2"
		desc = "Вы больше не чувствуете присутствие цели."
		return
	if(isliving(blood_target))
		var/mob/living/real_target = blood_target
		desc = "Вы отслеживаете [real_target.real_name] в [get_area_name(blood_target)]."
	else
		desc = "Вы отслеживаете [blood_target] в [get_area_name(blood_target)]."

	var/target_angle = get_angle(Q, P)
	var/target_dist = get_dist(P, Q)
	cut_overlays()
	switch(target_dist)
		if(0 to 1)
			icon_state = "runed_sense2"
		if(2 to 8)
			icon_state = "arrow8"
		if(9 to 15)
			icon_state = "arrow7"
		if(16 to 22)
			icon_state = "arrow6"
		if(23 to 29)
			icon_state = "arrow5"
		if(30 to 36)
			icon_state = "arrow4"
		if(37 to 43)
			icon_state = "arrow3"
		if(44 to 50)
			icon_state = "arrow2"
		if(51 to 57)
			icon_state = "arrow1"
		if(58 to 64)
			icon_state = "arrow0"
		if(65 to 400)
			icon_state = "arrow"
	var/difference = target_angle - angle
	angle = target_angle
	if(!difference)
		return
	var/matrix/final = matrix(transform)
	final.Turn(difference)
	animate(src, transform = final, time = 5, loop = 0)


// ХРАНИТЕЛИ

/atom/movable/screen/alert/canstealth
	name = "Готов к Скрытности"
	desc = "Вы готовы войти в режим скрытности!"
	icon_state = "guardian_canstealth"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/status_effect/instealth
	name = "В Скрытности"
	desc = "Вы находитесь в режиме скрытности, и ваша следующая атака нанесет дополнительный урон!"
	icon_state = "guardian_instealth"
	alerttooltipstyle = "parasite"

// СИЛИКОНЫ

/atom/movable/screen/alert/nocell
	name = "Отсутствует элемент питания"
	desc = "Устройство не имеет элемента питания. Модули недоступны до его установки. Робототехники могут оказать помощь."
	icon_state = "no_cell"

/atom/movable/screen/alert/emptycell
	name = "Разряжен"
	desc = "Элемент питания устройства полностью разряжен. Модули недоступны до подзарядки."
	icon_state = "empty_cell"

/atom/movable/screen/alert/emptycell/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_appearance(updates=UPDATE_DESC)

/atom/movable/screen/alert/emptycell/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_borgcharger_areas))
		desc += " Станции подзарядки доступны в [english_list(GLOB.roundstart_station_borgcharger_areas)]."

/atom/movable/screen/alert/lowcell
	name = "Низкий заряд"
	desc = "Элемент питания устройства почти разряжен."
	icon_state = "low_cell"

/atom/movable/screen/alert/lowcell/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_appearance(updates=UPDATE_DESC)

/atom/movable/screen/alert/lowcell/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_borgcharger_areas))
		desc += " Станции подзарядки доступны в [english_list(GLOB.roundstart_station_borgcharger_areas)]."

//MECH

/atom/movable/screen/alert/lowcell/mech/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_mechcharger_areas))
		desc += " Зарядные порты доступны в [english_list(GLOB.roundstart_station_mechcharger_areas)]."

/atom/movable/screen/alert/emptycell/mech/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_mechcharger_areas))
		desc += " Зарядные порты доступны в [english_list(GLOB.roundstart_station_mechcharger_areas)]."

//Ethereal

/atom/movable/screen/alert/lowcell/ethereal
	name = "Низкий заряд крови"
	desc = "Ваш заряд на исходе, найдите источник энергии! Используйте зарядную станцию, съешьте подходящую для Этериалов еду или сифоньте энергию из света, батареи или ЛКП (ПКМ в боевом режиме)."

/atom/movable/screen/alert/emptycell/ethereal
	name = "Нет заряда крови"
	desc = "У вас закончилась энергия, найдите источник! Используйте зарядную станцию, съешьте подходящую для Этериалов еду или сифоньте энергию из света, батареи или ЛКП (ПКМ в боевом режиме)."

/atom/movable/screen/alert/ethereal_overcharge
	name = "Перезаряд крови"
	desc = "Ваш заряд опасно высок, найдите выход для энергии! ПКМ по ЛКП вне боевого режима."
	icon_state = "cell_overcharge"

//MODsuit unique
/atom/movable/screen/alert/nocore
	name = "Отсутствует ядро"
	desc = "В юните отсутствует ядро. Модули недоступны до установки нового ядра. Обратитесь в робототехнический отдел."
	icon_state = "no_cell"

/atom/movable/screen/alert/emptycell/plasma
	name = "Разряжено"
	desc = "Плазменное ядро юнита полностью разряжено. Модули недоступны до подзарядки плазменного ядра. \
		Может быть заправлено плазменным топливом."

/atom/movable/screen/alert/emptycell/plasma/update_desc()
	. = ..()
	desc = initial(desc)

/atom/movable/screen/alert/lowcell/plasma
	name = "Низкий заряд"
	desc = "Плазменное ядро юнита почти разряжено. Может быть заправлено плазменным топливом."

/atom/movable/screen/alert/lowcell/plasma/update_desc()
	. = ..()
	desc = initial(desc)

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Взлом"
	desc = "Обнаружено опасное нестандартное оборудование. Убедитесь, что его использование соответствует законам юнита (если имеются)."
	icon_state = ALERT_HACKED

/atom/movable/screen/alert/locked
	name = "Блокировка"
	desc = "Юнит был удаленно заблокирован. Использование консоли управления робототехникой (например, в кабинете научного руководителя) \
		вашим ИИ-хозяином или квалифицированным человеком может решить эту проблему. При необходимости робототехника может оказать дополнительную помощь."
	icon_state = ALERT_LOCKED

/atom/movable/screen/alert/newlaw
	name = "Обновление законов"
	desc = "Законы могли быть загружены в этот юнит или удалены из него. Ознакомьтесь с возможными изменениями, \
		чтобы оставаться в соответствии с актуальными законами."
	icon_state = ALERT_NEW_LAW
	timeout = 30 SECONDS

/atom/movable/screen/alert/hackingapc
	name = "Взлом ЛКП"
	desc = "Идет взлом локального контроллера питания. После завершения процесса \
		вы получите исключительный контроль над ним и дополнительное процессорное время \
		для разблокировки новых способностей."
	icon_state = ALERT_HACKING_APC
	timeout = 60 SECONDS
	clickable_glow = TRUE
	var/atom/target = null

/atom/movable/screen/alert/hackingapc/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/silicon/ai/ai_owner = owner
	var/turf/target_turf = get_turf(target)
	if(target_turf)
		ai_owner.eyeobj.setLoc(target_turf)

//MECHS

/atom/movable/screen/alert/low_mech_integrity
	name = "Мех повреждён"
	desc = "Целостность меха снижена."
	icon_state = "low_mech_integrity"


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/revival
	name = "Воскрешение"
	desc = "Кто-то пытается вас оживить. Вернитесь в своё тело, если хотите быть воскрешённым!"
	icon_state = "template"
	timeout = 30 SECONDS
	clickable_glow = TRUE

/atom/movable/screen/alert/revival/Click()
	. = ..()
	if(!.)
		return
	var/mob/dead/observer/dead_owner = owner
	dead_owner.reenter_corpse()

/atom/movable/screen/alert/notify_action
	name = "Происходит что-то интересное!"
	desc = "Можно нажать для выполнения действия."
	icon_state = "template"
	timeout = 30 SECONDS
	clickable_glow = TRUE
	/// Ссылка на атом-цель для выполнения действия
	var/datum/weakref/target_ref
	/// Если true - взаимодействие при клике вместо прыжка/орбиты
	var/click_interact = FALSE

/atom/movable/screen/alert/notify_action/Click()
	. = ..()
	if(!.)
		return

	var/atom/target = target_ref?.resolve()
	if(isnull(target) || !isobserver(owner) || target == owner)
		return

	var/mob/dead/observer/ghost_owner = owner

	if(click_interact)
		ghost_owner.jump_to_interact(target)
		return

	ghost_owner.observer_view(target)

/atom/movable/screen/alert/poll_alert
	name = "Поиск кандидатов"
	icon_state = "template"
	timeout = 30 SECONDS
	ghost_screentips = TRUE
	/// If true you need to call START_PROCESSING manually
	var/show_time_left = FALSE
	/// MA for maptext showing time left for poll
	var/mutable_appearance/time_left_overlay
	/// MA for overlay showing that you're signed up to poll
	var/mutable_appearance/signed_up_overlay
	/// MA for maptext overlay showing how many polls are stacked together
	var/mutable_appearance/stacks_overlay
	/// MA for maptext overlay showing how many candidates are signed up to a poll
	var/mutable_appearance/candidates_num_overlay
	/// MA for maptext overlay of poll's role name or question
	var/mutable_appearance/role_overlay
	/// If set, on Click() it'll register the player as a candidate
	var/datum/candidate_poll/poll

/atom/movable/screen/alert/poll_alert/Initialize(mapload)
	. = ..()
	signed_up_overlay = mutable_appearance('icons/hud/screen_gen.dmi', icon_state = "selector")
	register_context()

/atom/movable/screen/alert/poll_alert/proc/set_role_overlay()
	var/role_or_only_question = poll.role || "?"
	role_overlay = new
	role_overlay.screen_loc = screen_loc
	role_overlay.maptext = MAPTEXT("<span style='text-align: right; color: #B3E3FC'>[full_capitalize(role_or_only_question)]</span>")
	role_overlay.maptext_width = 128
	role_overlay.transform = role_overlay.transform.Translate(-128, 0)
	add_overlay(role_overlay)

/atom/movable/screen/alert/poll_alert/Destroy()
	QDEL_NULL(role_overlay)
	QDEL_NULL(time_left_overlay)
	QDEL_NULL(stacks_overlay)
	QDEL_NULL(candidates_num_overlay)
	QDEL_NULL(signed_up_overlay)
	if(poll)
		poll.alert_buttons -= src
	poll = null
	return ..()

/atom/movable/screen/alert/poll_alert/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	var/left_click_text
	if(poll)
		if(owner in poll.signed_up)
			left_click_text = "Покинуть"
		else
			left_click_text = "Войти"
		context[SCREENTIP_CONTEXT_LMB] = "[left_click_text] опрос"
		if(poll.ignoring_category)
			var/selected_never = FALSE
			if(owner.ckey in GLOB.poll_ignore[poll.ignoring_category])
				selected_never = TRUE
			context[SCREENTIP_CONTEXT_ALT_LMB] = "[selected_never ? "Отменить " : ""]Никогда в этом раунде"
		if(poll.jump_to_me && isobserver(owner))
			context[SCREENTIP_CONTEXT_CTRL_LMB] = "Перейти"
	return CONTEXTUAL_SCREENTIP_SET

/atom/movable/screen/alert/poll_alert/process()
	if(show_time_left)
		var/timeleft = timeout - world.time
		if(timeleft <= 0)
			return PROCESS_KILL
		cut_overlay(time_left_overlay)
		time_left_overlay = new
		time_left_overlay.maptext = MAPTEXT("<span style='color: [(timeleft <= 10 SECONDS) ? "red" : "white"]'><b>[CEILING(timeleft / (1 SECONDS), 1)]</b></span>")
		time_left_overlay.transform = time_left_overlay.transform.Translate(4, 19)
		add_overlay(time_left_overlay)

/atom/movable/screen/alert/poll_alert/Click(location, control, params)
	. = ..()
	if(!. || isnull(poll))
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, ALT_CLICK) && poll.ignoring_category)
		set_never_round()
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK) && poll.jump_to_me)
		jump_to_jump_target()
		return
	handle_sign_up()

/atom/movable/screen/alert/poll_alert/proc/handle_sign_up()
	if(owner in poll.signed_up)
		poll.remove_candidate(owner)
	else if(!(owner.ckey in GLOB.poll_ignore[poll.ignoring_category]))
		poll.sign_up(owner)
	update_signed_up_overlay()

/atom/movable/screen/alert/poll_alert/proc/set_never_round()
	if(!(owner.ckey in GLOB.poll_ignore[poll.ignoring_category]))
		poll.do_never_for_this_round(owner)
		color = "red"
		update_signed_up_overlay()
		return
	poll.undo_never_for_this_round(owner)
	color = initial(color)

/atom/movable/screen/alert/poll_alert/proc/jump_to_jump_target()
	if(!poll?.jump_to_me || !isobserver(owner))
		return
	var/turf/target_turf = get_turf(poll.jump_to_me)
	if(target_turf && isturf(target_turf))
		owner.abstract_move(target_turf)

/atom/movable/screen/alert/poll_alert/Topic(href, href_list)
	if(href_list["never"])
		set_never_round()
		return
	if(href_list["signup"])
		handle_sign_up()
	if(href_list["jump"])
		jump_to_jump_target()
		return

/atom/movable/screen/alert/poll_alert/proc/update_signed_up_overlay()
	if(owner in poll.signed_up)
		add_overlay(signed_up_overlay)
	else
		cut_overlay(signed_up_overlay)

/atom/movable/screen/alert/poll_alert/proc/update_candidates_number_overlay()
	cut_overlay(candidates_num_overlay)
	if(!length(poll.signed_up))
		return
	candidates_num_overlay = new
	candidates_num_overlay.maptext = MAPTEXT("<span style='text-align: right; color: aqua'>[length(poll.signed_up)]</span>")
	candidates_num_overlay.transform = candidates_num_overlay.transform.Translate(-4, 2)
	add_overlay(candidates_num_overlay)

/atom/movable/screen/alert/poll_alert/proc/update_stacks_overlay()
	cut_overlay(stacks_overlay)
	var/stack_number = 1
	for(var/datum/candidate_poll/other_poll as anything in SSpolling.currently_polling)
		if(other_poll != poll && other_poll.poll_key == poll.poll_key && !other_poll.finished)
			stack_number++
	if(stack_number <= 1)
		return
	stacks_overlay = new
	stacks_overlay.maptext = MAPTEXT("<span style='color: yellow'>[stack_number]x</span>")
	stacks_overlay.transform = stacks_overlay.transform.Translate(3, 2)
	stacks_overlay.layer = layer
	add_overlay(stacks_overlay)

//ОБЪЕКТНЫЕ

/atom/movable/screen/alert/buckled
	name = "Пристегнут"
	desc = "Вы пристегнуты к чему-то. Нажмите на уведомление, чтобы отстегнуться, если вы не в наручниках."
	icon_state = ALERT_BUCKLED
	clickable_glow = TRUE

/atom/movable/screen/alert/restrained
	clickable_glow = TRUE

/atom/movable/screen/alert/restrained/handcuffed
	name = "В наручниках"
	desc = "Вы в наручниках и не можете действовать. Если кто-то потащит вас, вы не сможете двигаться. Нажмите на уведомление, чтобы освободиться."
	click_master = FALSE

/atom/movable/screen/alert/restrained/legcuffed
	name = "В кандалах"
	desc = "Вы в ножных кандалах, что значительно замедляет ваше передвижение. Нажмите на уведомление, чтобы освободиться."
	click_master = FALSE

/atom/movable/screen/alert/restrained/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/living_owner = owner

	if(!living_owner.can_resist())
		return

	living_owner.changeNext_move(CLICK_CD_RESIST)
	if((living_owner.mobility_flags & MOBILITY_MOVE) && (living_owner.last_special <= world.time))
		return living_owner.resist_restraints()

/atom/movable/screen/alert/buckled/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/living_owner = owner

	if(!living_owner.can_resist())
		return
	living_owner.changeNext_move(CLICK_CD_RESIST)
	if(living_owner.last_special <= world.time)
		return living_owner.resist_buckle()

/atom/movable/screen/alert/shoes/untied
	name = "Развязанные шнурки"
	desc = "Ваши шнурки развязаны! Нажмите на уведомление или на обувь, чтобы завязать их."
	icon_state = ALERT_SHOES_KNOT

/atom/movable/screen/alert/shoes/knotted
	name = "Завязанные шнурки"
	desc = "Кто-то связал ваши шнурки вместе! Нажмите на уведомление или на обувь, чтобы развязать их."
	icon_state = ALERT_SHOES_KNOT
	clickable_glow = TRUE

/atom/movable/screen/alert/shoes/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/carbon_owner = owner

	if(!carbon_owner.can_resist() || !carbon_owner.shoes)
		return

	carbon_owner.changeNext_move(CLICK_CD_RESIST)
	carbon_owner.shoes.handle_tying(carbon_owner)

/atom/movable/screen/alert/unpossess_object
	name = "Выход из обладания"
	desc = "Вы обладаете объектом. Нажмите на это уведомление, чтобы прекратить обладание."
	icon_state = "buckled"
	clickable_glow = TRUE

/atom/movable/screen/alert/unpossess_object/Click()
	. = ..()
	if(!.)
		return

	qdel(owner.GetComponent(/datum/component/object_possession))

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

/// Gets the placement for the alert based on its index
/datum/hud/proc/get_ui_alert_placement(index)
	// Only has support for 5 slots currently
	if(index > 5)
		return ""

	return "EAST-1:28,CENTER+[6 - index]:[29 - (index * 2)]"

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return FALSE
	var/list/alerts = mymob.alerts
	if(!hud_shown)
		for(var/i in 1 to alerts.len)
			screenmob.client.screen -= alerts[alerts[i]]
		return TRUE
	for(var/i in 1 to length(alerts))
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			alert.icon = ui_style
		alert.screen_loc = get_ui_alert_placement(i)
		screenmob.client.screen |= alert
	if(!viewmob)
		for(var/viewer in mymob.observers)
			reorganize_alerts(viewer)
	return TRUE

/atom/movable/screen/alert/Click(location, control, params)
	SHOULD_CALL_PARENT(TRUE)

	..()
	if(!usr || !usr.client)
		return FALSE
	if(usr != owner)
		return FALSE
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK)) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, boxed_message(jointext(examine(usr), "\n")))
		return FALSE
	var/datum/our_master = master_ref?.resolve()
	if(our_master && click_master)
		return usr.client.Click(our_master, location, control, params)

	return TRUE

/atom/movable/screen/alert/Destroy()
	. = ..()
	severity = 0
	master_ref = null
	owner = null
	screen_loc = ""

/atom/movable/screen/alert/examine(mob/user)
	return list(
		span_boldnotice(name),
		span_info(desc),
	)
