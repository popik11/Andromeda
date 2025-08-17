/**
 * Компонент для возврата родителя в предыдущее состояние через некоторое время
 */
/datum/component/dejavu
	dupe_mode = COMPONENT_DUPE_ALLOWED

	///Сообщение при срабатывании эффекта дежавю
	var/rewind_message = "Вы вспоминаете события недавнего прошлого..."
	///Сообщение когда эффекты дежавю закончились
	var/no_rewinds_message = "Но воспоминания ускользают от вас."

	///Турф, на котором находился родитель при создании компонента
	var/turf/starting_turf
	///Тип перемотки, определяется типом родителя для разного поведения
	var/rewind_type
	///Сколько раз ещё сработает эффект
	var/rewinds_remaining
	///Интервал между срабатываниями
	var/rewind_interval
	///Добавлять ли новый компонент перед телепортацией цели?
	var/repeating_component

	///Начальный уровень токсинов
	var/tox_loss = 0
	///Начальный уровень кислородного голодания
	var/oxy_loss = 0
	///Начальный уровень усталости
	var/stamina_loss = 0
	///Начальный уровень повреждения мозга
	var/brain_loss = 0
	///Начальный уровень физических повреждений (только для простых мобов)
	var/brute_loss
	///Начальный уровень прочности (только для объектов)
	var/integrity
	///Список сохранённых частей тела
	var/list/datum/saved_bodypart/saved_bodyparts

/datum/component/dejavu/Initialize(rewinds = 1, interval = 10 SECONDS, add_component = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	starting_turf = get_turf(parent)
	rewinds_remaining = rewinds
	rewind_interval = interval
	repeating_component = add_component

	if(isliving(parent))
		var/mob/living/L = parent
		tox_loss = L.getToxLoss()
		oxy_loss = L.getOxyLoss()
		stamina_loss = L.getStaminaLoss()
		brain_loss = L.get_organ_loss(ORGAN_SLOT_BRAIN)
		rewind_type = PROC_REF(rewind_living)

	if(iscarbon(parent))
		var/mob/living/carbon/C = parent
		saved_bodyparts = C.save_bodyparts()
		rewind_type = PROC_REF(rewind_carbon)

	else if(isanimal_or_basicmob(parent))
		var/mob/living/animal = parent
		brute_loss = animal.bruteloss
		rewind_type = PROC_REF(rewind_animal)

	else if(isobj(parent))
		var/obj/O = parent
		integrity = O.get_integrity()
		rewind_type = PROC_REF(rewind_obj)

	addtimer(CALLBACK(src, rewind_type), rewind_interval)

/datum/component/dejavu/Destroy()
	starting_turf = null
	saved_bodyparts = null
	return ..()

/datum/component/dejavu/proc/rewind()
	to_chat(parent, span_notice(rewind_message))

	// идёт после лечения, поэтому новые конечности комично падают на пол
	if(starting_turf)
		if(!check_teleport_valid(parent, starting_turf))
			to_chat(parent, span_warning("По какой-то причине вашу голову заполняет туманная боль, когда вы пытаетесь вспомнить, где были... Чувствуется, будто вы сталкиваетесь с какой-то тупой, неостановимой силой вселенной."))
		else
			var/atom/movable/master = parent
			master.forceMove(starting_turf)

	rewinds_remaining --
	if(rewinds_remaining || rewinds_remaining < 0)
		addtimer(CALLBACK(src, rewind_type), rewind_interval)
	else
		to_chat(parent, span_notice(no_rewinds_message))
		qdel(src)

/datum/component/dejavu/proc/rewind_living()
	if (rewinds_remaining == 1 && repeating_component && !iscarbon(parent) && !isanimal_or_basicmob(parent))
		parent.AddComponent(type, 1, rewind_interval, TRUE)

	var/mob/living/master = parent
	master.setToxLoss(tox_loss)
	master.setOxyLoss(oxy_loss)
	master.setStaminaLoss(stamina_loss)
	master.setOrganLoss(ORGAN_SLOT_BRAIN, brain_loss)
	rewind()

/datum/component/dejavu/proc/rewind_carbon()
	if (rewinds_remaining == 1 && repeating_component)
		parent.AddComponent(type, 1, rewind_interval, TRUE)

	if(saved_bodyparts)
		var/mob/living/carbon/master = parent
		master.apply_saved_bodyparts(saved_bodyparts)
	rewind_living()

/datum/component/dejavu/proc/rewind_animal()
	if (rewinds_remaining == 1 && repeating_component)
		parent.AddComponent(type, 1, rewind_interval, TRUE)

	var/mob/living/master = parent
	master.bruteloss = brute_loss
	master.updatehealth()
	rewind_living()

/datum/component/dejavu/proc/rewind_obj()
	if (rewinds_remaining == 1 && repeating_component)
		parent.AddComponent(type, 1, rewind_interval, TRUE)

	var/obj/master = parent
	master.update_integrity(integrity)
	rewind()

///дежавю с другой тематикой для модульных скафандров
/datum/component/dejavu/timeline
	rewind_message = "Скафандр перематывает время, перенося вас через пространство-время!"
	no_rewinds_message = "\"Перемотка завершена. Вы прибыли на: 10 секунд назад.\""

/datum/component/dejavu/timeline/rewind()
	playsound(get_turf(parent), 'sound/items/modsuit/rewinder.ogg')
	. = ..()

/datum/component/dejavu/wizard
	rewind_message = "Ваш временной оберег сработал, перенося вас через пространство-время!"

/datum/component/dejavu/wizard/rewind()
	playsound(get_turf(parent), 'sound/items/modsuit/rewinder.ogg')
	. = ..()
