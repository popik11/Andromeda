/**
 * # Компонент кладки яиц!
 *
 * Управляет количеством яиц, которые можно отложить, чем можно кормить моба для увеличения кладки, и что именно откладывается.
 * Поскольку основное взаимодействие с компонентом - это attackby, мы можем сделать это процедурой уровня атома.
 * egg_layer будет явно выдавать ошибки при отсутствии аргументов, чтобы обеспечить ясность.
 */
/datum/component/egg_layer
	/// тип откладываемого яйца
	var/egg_type
	/// чем можно кормить моба для увеличения кладки
	var/list/food_types
	/// сообщения при кормлении
	var/list/feed_messages
	/// сообщения при откладывании яйца
	var/list/lay_messages
	/// сколько яиц осталось отложить
	var/eggs_left
	/// сколько яиц добавляется при кормлении
	var/eggs_added_from_eating
	/// максимальное количество хранимых яиц
	var/max_eggs_held
	/// колбэк для модификации новых яиц
	var/datum/callback/egg_laid_callback

/datum/component/egg_layer/Initialize(egg_type, food_types, feed_messages, lay_messages, eggs_left, eggs_added_from_eating, max_eggs_held, egg_laid_callback)
	if(!isatom(parent)) // да, можно сделать ручной ящик с инструментами
		return COMPONENT_INCOMPATIBLE

	src.egg_type = egg_type
	src.food_types = food_types
	src.feed_messages = feed_messages
	src.lay_messages = lay_messages
	src.eggs_left = eggs_left
	src.eggs_added_from_eating = eggs_added_from_eating
	src.max_eggs_held = max_eggs_held
	src.egg_laid_callback = egg_laid_callback

	START_PROCESSING(SSobj, src)

/datum/component/egg_layer/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(feed_food))

/datum/component/egg_layer/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)

/datum/component/egg_layer/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	egg_laid_callback = null

/datum/component/egg_layer/proc/feed_food(datum/source, obj/item/food, mob/living/attacker, params)
	SIGNAL_HANDLER

	var/atom/at_least_atom = parent
	if(!is_type_in_list(food, food_types))
		return
	if(isliving(at_least_atom))
		var/mob/living/potentially_dead_horse = at_least_atom
		if(potentially_dead_horse.stat == DEAD)
			to_chat(attacker, span_warning("[parent] мёртв!"))
			return COMPONENT_CANCEL_ATTACK_CHAIN
	if(eggs_left > max_eggs_held)
		to_chat(attacker, span_warning("[parent] не выглядит голодным!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	attacker.visible_message(span_notice("[attacker] кормит [parent] с руки [food]."), span_notice("Вы кормите [parent] с руки [food]."))
	at_least_atom.visible_message(pick(feed_messages))
	qdel(food)
	eggs_left = min(eggs_left + eggs_added_from_eating, max_eggs_held)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/egg_layer/process(seconds_per_tick = SSOBJ_DT)
	var/atom/at_least_atom = parent
	if(isliving(at_least_atom))
		var/mob/living/potentially_dead_horse = at_least_atom
		if(potentially_dead_horse.stat != CONSCIOUS)
			return
	if(!eggs_left || !SPT_PROB(1.5, seconds_per_tick))
		return

	at_least_atom.visible_message(span_alertalien("[at_least_atom] [pick(lay_messages)]"))
	eggs_left--
	var/obj/item/egg = new egg_type(get_turf(at_least_atom))
	egg.pixel_x = rand(-6, 6)
	egg.pixel_y = rand(-6, 6)
	egg_laid_callback?.Invoke(egg)
