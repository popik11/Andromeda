/area/station/maintenance
	name = "Общие технические тоннели"
	ambience_index = AMBIENCE_MAINT
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | PERSISTENT_ENGRAVINGS
	airlock_wires = /datum/wires/airlock/maint
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	forced_ambience = TRUE
	ambient_buzz = 'sound/ambience/maintenance/source_corridor2.ogg'
	ambient_buzz_vol = 20

/*
* Отсечные технические тоннели
*/

/area/station/maintenance/department/chapel
	name = "Техтоннели часовни"
	icon_state = "maint_chapel"

/area/station/maintenance/department/chapel/monastery
	name = "Техтоннели монастыря"
	icon_state = "maint_monastery"

/area/station/maintenance/department/crew_quarters/bar
	name = "Техтоннели бара"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/maintenance/department/crew_quarters/dorms
	name = "Техтоннели жилых отсеков"
	icon_state = "maint_dorms"

/area/station/maintenance/department/eva
	name = "Техтоннели EVA"
	icon_state = "maint_eva"

/area/station/maintenance/department/eva/abandoned
	name = "Заброшенное хранилище EVA"

/area/station/maintenance/department/electrical
	name = "Электротехнические тоннели"
	icon_state = "maint_electrical"

/area/station/maintenance/department/engine/atmos
	name = "Техтоннели атмосферного отдела"
	icon_state = "maint_atmos"

/area/station/maintenance/department/security
	name = "Техтоннели службы безопасности"
	icon_state = "maint_sec"

/area/station/maintenance/department/security/upper
	name = "Верхние техтоннели брига"

/area/station/maintenance/department/security/brig
	name = "Техтоннели брига"
	icon_state = "maint_brig"

/area/station/maintenance/department/medical
	name = "Техтоннели медотсека"
	icon_state = "medbay_maint"

/area/station/maintenance/department/medical/central
	name = "Центральные техтоннели медотсека"
	icon_state = "medbay_maint_central"

/area/station/maintenance/department/medical/morgue
	name = "Техтоннели морга"
	icon_state = "morgue_maint"

/area/station/maintenance/department/science
	name = "Техтоннели научного отдела"
	icon_state = "maint_sci"

/area/station/maintenance/department/science/central
	name = "Центральные техтоннели науки"
	icon_state = "maint_sci_central"

/area/station/maintenance/department/cargo
	name = "Техтоннели карго"
	icon_state = "maint_cargo"

/area/station/maintenance/department/bridge
	name = "Техтоннели мостика"
	icon_state = "maint_bridge"

/area/station/maintenance/department/engine
	name = "Техтоннели инженерии"
	icon_state = "maint_engi"

/area/station/maintenance/department/prison
	name = "Техтоннели тюрьмы"
	icon_state = "sec_prison"

/area/station/maintenance/department/science/xenobiology
	name = "Техтоннели ксенобиологии"
	icon_state = "xenomaint"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE | CULT_PERMITTED

/*
* Основные технические тоннели
*/

/area/station/maintenance/aft
	name = "Южные техтоннели"
	icon_state = "aftmaint"

/area/station/maintenance/aft/upper
	name = "Верхние южные техтоннели"
	icon_state = "upperaftmaint"

/* Use greater variants of area definitions for when the station has two different sections of maintenance on the same z-level.
* Can stand alone without "lesser".
* This one means that this goes more fore/north than the "lesser" maintenance area.
*/
/area/station/maintenance/aft/greater
	name = "Большие южные техтоннели"
	icon_state = "greateraftmaint"

/* Use lesser variants of area definitions for when the station has two different sections of maintenance on the same z-level in conjunction with "greater".
* (just because it follows better).
* This one means that this goes more aft/south than the "greater" maintenance area.
*/

/area/station/maintenance/aft/lesser
	name = "Малые южные техтоннели"
	icon_state = "lesseraftmaint"

/area/station/maintenance/central
	name = "Центральные техтоннели"
	icon_state = "centralmaint"

/area/station/maintenance/central/greater
	name = "Большие центральные техтоннели"
	icon_state = "greatercentralmaint"

/area/station/maintenance/central/lesser
	name = "Малые центральные техтоннели"
	icon_state = "lessercentralmaint"

/area/station/maintenance/fore
	name = "Северные техтоннели"
	icon_state = "foremaint"

/area/station/maintenance/fore/upper
	name = "Верхние северные техтоннели"
	icon_state = "upperforemaint"

/area/station/maintenance/fore/greater
	name = "Большие северные техтоннели"
	icon_state = "greaterforemaint"

/area/station/maintenance/fore/lesser
	name = "Малые северные техтоннели"
	icon_state = "lesserforemaint"

/area/station/maintenance/starboard
	name = "восточные техтоннели"
	icon_state = "starboardmaint"

/area/station/maintenance/starboard/upper
	name = "Верхние восточные техтоннели"
	icon_state = "upperstarboardmaint"

/area/station/maintenance/starboard/central
	name = "Центральные восточные техтоннели"
	icon_state = "centralstarboardmaint"

/area/station/maintenance/starboard/greater
	name = "Большие восточные техтоннели"
	icon_state = "greaterstarboardmaint"

/area/station/maintenance/starboard/lesser
	name = "Малые восточные техтоннели"
	icon_state = "lesserstarboardmaint"

/area/station/maintenance/starboard/aft
	name = "Южные восточные техтоннели"
	icon_state = "asmaint"

/area/station/maintenance/starboard/fore
	name = "Северные восточные техтоннели"
	icon_state = "fsmaint"

/area/station/maintenance/port
	name = "западные техтоннели"
	icon_state = "portmaint"

/area/station/maintenance/port/central
	name = "Центральные западные техтоннели"
	icon_state = "centralportmaint"

/area/station/maintenance/port/greater
	name = "Большие западные техтоннели"
	icon_state = "greaterportmaint"

/area/station/maintenance/port/lesser
	name = "Малые западные техтоннели"
	icon_state = "lesserportmaint"

/area/station/maintenance/port/aft
	name = "Южные западные техтоннели"
	icon_state = "apmaint"

/area/station/maintenance/port/fore
	name = "Северные западные техтоннели"
	icon_state = "fpmaint"

/area/station/maintenance/tram
	name = "Техтоннели шаттла"

/area/station/maintenance/tram/left
	name = "\improper Западный техтонель шаттла"
	icon_state = "mainttramL"

/area/station/maintenance/tram/mid
	name = "\improper Центральный техтонель шаттла"
	icon_state = "mainttramM"

/area/station/maintenance/tram/right
	name = "\improper Восточный техтонель шаттла"
	icon_state = "mainttramR"

/*
* Отдельные технические зоны
*/

/area/station/maintenance/disposal
	name = "Утилизация отходов"
	icon_state = "disposal"

/area/station/maintenance/hallway/abandoned_command
	name = "\improper Заброшенный командный коридор"
	icon_state = "maint_bridge"

/area/station/maintenance/hallway/abandoned_recreation
	name = "\improper Заброшенный рекреационный коридор"
	icon_state = "maint_dorms"

/area/station/maintenance/disposal/incinerator
	name = "\improper Термогенераторная"
	icon_state = "incinerator"

/area/station/maintenance/space_hut
	name = "\improper Космическая хижина"
	icon_state = "spacehut"

/area/station/maintenance/space_hut/cabin
	name = "Заброшенная каюта"

/area/station/maintenance/space_hut/plasmaman
	name = "\improper Заброшенный стартап для плазмаменов"

/area/station/maintenance/space_hut/observatory
	name = "\improper Космическая обсерватория"

/*
* Убежища от радиационных бурь
*/

/area/station/maintenance/radshelter
	name = "\improper Убежище от радиации"
	icon_state = "radstorm_shelter"

/area/station/maintenance/radshelter/medical
	name = "\improper Медицинское убежище"

/area/station/maintenance/radshelter/sec
	name = "\improper Убежище брига"

/area/station/maintenance/radshelter/service
	name = "\improper Сервисное убежище"

/area/station/maintenance/radshelter/civil
	name = "\improper Гражданское убежище"

/area/station/maintenance/radshelter/sci
	name = "\improper Научное убежище"

/area/station/maintenance/radshelter/cargo
	name = "\improper Карго-убежище"

/*
* Внешние доступы к корпусу
*/

/area/station/maintenance/external
	name = "\improper Внешний доступ к корпусу"
	icon_state = "amaint"

/area/station/maintenance/external/aft
	name = "\improper Южный внешний доступ"

/area/station/maintenance/external/port
	name = "\improper Западный внешний доступ"

/area/station/maintenance/external/port/bow
	name = "\improper Северный западный доступ"

/*
* Уникальные зоны станции
* Технические помещения станции North Star
*/

//1 этаж
/area/station/maintenance/floor1
	name = "\improper Техтоннели 1 этажа"

/area/station/maintenance/floor1/port
	name = "\improper Центральные западные техтоннели 1 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor1/port/fore
	name = "\improper Северные западные техтоннели 1 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor1/port/aft
	name = "\improper Южные западные техтоннели 1 этажа"
	icon_state = "maintaft"

/area/station/maintenance/floor1/starboard
	name = "\improper Центральные восточные техтоннели 1 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor1/starboard/fore
	name = "\improper Северные восточные техтоннели 1 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor1/starboard/aft
	name = "\improper Южные восточные техтоннели 1 этажа"
	icon_state = "maintaft"

//2 этаж
/area/station/maintenance/floor2
	name = "\improper Техтоннели 2 этажа"

/area/station/maintenance/floor2/port
	name = "\improper Центральные западные техтоннели 2 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor2/port/fore
	name = "\improper Северные западные техтоннели 2 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor2/port/aft
	name = "\improper Южные западные техтоннели 2 этажа"
	icon_state = "maintaft"

/area/station/maintenance/floor2/starboard
	name = "\improper Центральные восточные техтоннели 2 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor2/starboard/fore
	name = "\improper Северные восточные техтоннели 2 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor2/starboard/aft
	name = "\improper Южные восточные техтоннели 2 этажа"
	icon_state = "maintaft"

//3 этаж
/area/station/maintenance/floor3
	name = "\improper Техтоннели 3 этажа"

/area/station/maintenance/floor3/port
	name = "\improper Центральные западные техтоннели 3 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor3/port/fore
	name = "\improper Северные западные техтоннели 3 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor3/port/aft
	name = "\improper Южные западные техтоннели 3 этажа"
	icon_state = "maintaft"

/area/station/maintenance/floor3/starboard
	name = "\improper Центральные восточные техтоннели 3 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor3/starboard/fore
	name = "\improper Северные восточные техтоннели 3 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor3/starboard/aft
	name = "\improper Южные восточные техтоннели 3 этажа"
	icon_state = "maintaft"

//4 этаж
/area/station/maintenance/floor4
	name = "\improper Техтоннели 4 этажа"

/area/station/maintenance/floor4/port
	name = "\improper Центральные западные техтоннели 4 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor4/port/fore
	name = "\improper Северные западные техтоннели 4 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor4/port/aft
	name = "\improper Южные западные техтоннели 4 этажа"
	icon_state = "maintaft"

/area/station/maintenance/floor4/starboard
	name = "\improper Центральные восточные техтоннели 4 этажа"
	icon_state = "maintcentral"

/area/station/maintenance/floor4/starboard/fore
	name = "\improper Северные восточные техтоннели 4 этажа"
	icon_state = "maintfore"

/area/station/maintenance/floor4/starboard/aft
	name = "\improper Южные восточные техтоннели 4 этажа"
	icon_state = "maintaft"
