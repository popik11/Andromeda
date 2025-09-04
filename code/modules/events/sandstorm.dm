/**
 * Sandstorm Event: Throws dust/sand at one side of the station. High-intensity and relatively short,
 * however the incoming direction is given along with time to prepare. Damages can be reduced or
 * mitigated with a few people actively working to fix things as the storm hits, but leaving the event to run on its own can lead to widespread breaches.
 *
 * Meant to be encountered mid-round, with enough spare manpower among the crew to properly respond.
 * Anyone with a welder or metal can contribute.
 */

/datum/round_event_control/sandstorm
	name = "Песчаная буря: Направленная"
	typepath = /datum/round_event/sandstorm
	max_occurrences = 3
	min_players = 35
	earliest_start = 35 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "Волна космической пыли постоянно истирает одну из сторон станции."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7
	admin_setup = list(/datum/event_admin_setup/listed_options/sandstorm)
	map_flags = EVENT_SPACE_ONLY

/datum/round_event/sandstorm
	start_when = 60
	end_when = 100
	announce_when = 1
	///Which direction the storm will come from.
	var/start_side

/datum/round_event/sandstorm/setup()
	start_when = rand(70, 90)
	end_when = rand(110, 140)

/datum/round_event/sandstorm/announce(fake)
	if(!start_side)
		start_side = pick(GLOB.cardinals)

	var/start_side_text = "неизвестно"
	switch(start_side)
		if(NORTH)
			start_side_text = "северной"
		if(SOUTH)
			start_side_text = "южной"
		if(EAST)
			start_side_text = "восточной"
		if(WEST)
			start_side_text = "западной"
		else
			stack_trace("Событие песчаной бури получило [start_side] как нераспознанное направление. Отмена события...")
			kill()
			return

	priority_announce("К станции приближается крупная волна космической пыли с [start_side_text] стороны. \
		Столкновение ожидается в течение следующих двух минут. Все сотрудники при возможности призываются \
		к участию в ремонте и минимизации ущерба.", "Оповещение о столкновении")

/datum/round_event/sandstorm/tick()
	spawn_meteors(15, GLOB.meteors_sandstorm, start_side)

/**
 * The original sandstorm event. An admin-only disasterfest that sands down all sides of the station
 * Uses space dust, meaning walls/rwalls are quickly chewed up very quickly.
 *
 * Super dangerous, super funny, preserved for future admin use in case the new event reminds
 * them that this exists. It is unchanged from its original form and is arguably perfect.
 */

/datum/round_event_control/sandstorm_classic
	name = "Песчаная буря: Классическая"
	typepath = /datum/round_event/sandstorm_classic
	weight = 0
	max_occurrences = 0
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "Станция подвергается интенсивной бомбардировке пылью со всех сторон в течение нескольких минут. Очень разрушительно и может вызвать лаги. Использовать на свой страх и риск."

/datum/round_event/sandstorm_classic
	start_when = 1
	end_when = 150 // ~5 min //I don't think this actually lasts 5 minutes unless you're including the lag it induces
	announce_when = 0
	fakeable = FALSE

/datum/round_event/sandstorm_classic/tick()
	spawn_meteors(10, GLOB.meteors_dust)

/datum/event_admin_setup/listed_options/sandstorm
	input_text = "Выберите сторону для песчаной бури?"
	normal_run_option = "Случайное направление песчаной бури"

/datum/event_admin_setup/listed_options/sandstorm/get_list()
	return list("Север", "Юг", "Восток", "Запад")

/datum/event_admin_setup/listed_options/sandstorm/apply_to_event(datum/round_event/sandstorm/event)
	switch(chosen)
		if("Север")
			event.start_side = NORTH
		if("Юг")
			event.start_side = SOUTH
		if("Восток")
			event.start_side = EAST
		if("Запад")
			event.start_side = WEST
