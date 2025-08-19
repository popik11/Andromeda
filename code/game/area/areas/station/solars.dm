/*
* Внешние солнечные зоны
*/

/area/station/solars
	icon_state = "panels"
	requires_power = FALSE
	area_flags = UNIQUE_AREA|NO_GRAVITY
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_SPACE
	default_gravity = ZERO_GRAVITY

/area/station/solars/fore
	name = "\improper Северная солнечная батарея"
	icon_state = "panelsF"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/solars/aft
	name = "\improper Южная солнечная батарея"
	icon_state = "panelsAF"

/area/station/solars/aux/port
	name = "\improper Западная вспомогательная солнечная батарея"
	icon_state = "panelsA"

/area/station/solars/aux/starboard
	name = "\improper Восточная вспомогательная солнечная батарея"
	icon_state = "panelsA"

/area/station/solars/starboard
	name = "\improper Восточная солнечная батарея"
	icon_state = "panelsS"

/area/station/solars/starboard/aft
	name = "\improper Восточная южная солнечная батарея"
	icon_state = "panelsAS"

/area/station/solars/starboard/fore
	name = "\improper Восточная северная солнечная батарея"
	icon_state = "panelsFS"

/area/station/solars/starboard/fore/asteriod
	name = "\improper Восточная северная солнечная батарея на астероиде"
	icon_state = "panelsFS"
	area_flags = UNIQUE_AREA // солнечные панели на астероиде имеют гравитацию

/area/station/solars/port
	name = "\improper Западная солнечная батарея"
	icon_state = "panelsP"

/area/station/solars/port/asteriod
	name = "\improper Западная солнечная батарея на астероиде"
	icon_state = "panelsP"
	area_flags = UNIQUE_AREA // солнечные панели на астероиде имеют гравитацию

/area/station/solars/port/aft
	name = "\improper Западная южная солнечная батарея"
	icon_state = "panelsAP"

/area/station/solars/port/fore
	name = "\improper Западная северная солнечная батарея"
	icon_state = "panelsFP"

/area/station/solars/aisat
	name = "\improper Солнечные панели ИИ спутника"
	icon_state = "panelsAI"

/*
* Внутренние солнечные зоны
* Помещения с СМЕС и компьютерами
* Размещены не в файле техобслуживания для удобства организации с внешними солнечными зонами
*/

/area/station/maintenance/solars
	name = "Техобслуживание солнечных батарей"
	icon_state = "yellow"

/area/station/maintenance/solars/port
	name = "Техобслуживание западных солнечных батарей"
	icon_state = "SolarcontrolP"

/area/station/maintenance/solars/port/aft
	name = "Техобслуживание западных южных солнечных батарей"
	icon_state = "SolarcontrolAP"

/area/station/maintenance/solars/port/fore
	name = "Техобслуживание западных северных солнечных батарей"
	icon_state = "SolarcontrolFP"

/area/station/maintenance/solars/starboard
	name = "Техобслуживание восточных солнечных батарей"
	icon_state = "SolarcontrolS"

/area/station/maintenance/solars/starboard/aft
	name = "Техобслуживание восточных южных солнечных батарей"
	icon_state = "SolarcontrolAS"

/area/station/maintenance/solars/starboard/fore
	name = "Техобслуживание восточных северных солнечных батарей"
	icon_state = "SolarcontrolFS"
