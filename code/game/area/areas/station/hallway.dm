/area/station/hallway
	icon_state = "hall"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/hallway/primary
	name = "\improper Главный коридор"
	icon_state = "primaryhall"

/area/station/hallway/primary/aft
	name = "\improper Южный главный коридор"
	icon_state = "afthall"

/area/station/hallway/primary/fore
	name = "\improper Северный главный коридор"
	icon_state = "forehall"

/area/station/hallway/primary/starboard
	name = "\improper Восточный главный коридор"
	icon_state = "starboardhall"

/area/station/hallway/primary/port
	name = "\improper Западный главный коридор"
	icon_state = "porthall"

/area/station/hallway/primary/central
	name = "\improper Центральный главный коридор"
	icon_state = "centralhall"

/area/station/hallway/primary/central/fore
	name = "\improper Северный центральный коридор"
	icon_state = "hallCF"

/area/station/hallway/primary/central/aft
	name = "\improper Южный центральный коридор"
	icon_state = "hallCA"

/area/station/hallway/primary/upper
	name = "\improper Верхний центральный коридор"
	icon_state = "centralhall"

/area/station/hallway/primary/tram
	name = "\improper Главный коридор док шаттлов"

/area/station/hallway/primary/tram/left
	name = "\improper Западный док шаттлов"
	icon_state = "halltramL"

/area/station/hallway/primary/tram/center
	name = "\improper Центральный док шаттлов"
	icon_state = "halltramM"

/area/station/hallway/primary/tram/right
	name = "\improper Восточный док шаттлов"
	icon_state = "halltramR"

// Не должно использоваться, но дает иконку для редактора карт
/area/station/hallway/secondary
	icon_state = "secondaryhall"

/area/station/hallway/secondary/command
	name = "\improper Командный коридор"
	icon_state = "bridge_hallway"

/area/station/hallway/secondary/construction
	name = "\improper Строительная зона"
	icon_state = "construction"

/area/station/hallway/secondary/construction/engineering
	name = "\improper Инженерный коридор"

/area/station/hallway/secondary/exit
	name = "\improper Коридор эвакуационного шаттла"
	icon_state = "escape"

/area/station/hallway/secondary/exit/escape_pod
	name = "\improper Отсек спасательных капсул"
	icon_state = "escape_pods"

/area/station/hallway/secondary/exit/departure_lounge
	name = "\improper Зал ожидания отбытия"
	icon_state = "escape_lounge"

/area/station/hallway/secondary/entry
	name = "\improper Коридор прибывающего шаттла"
	icon_state = "entry"
	area_flags = UNIQUE_AREA | EVENT_PROTECTED

/area/station/hallway/secondary/dock
	name = "\improper Вторичный док станции"
	icon_state = "hall"

/area/station/hallway/secondary/service
	name = "\improper Сервисный коридор"
	icon_state = "hall_service"

/area/station/hallway/secondary/spacebridge
	name = "\improper Космический мост"
	icon_state = "hall"

/area/station/hallway/secondary/recreation
	name = "\improper Рекреационный коридор"
	icon_state = "hall"

/*
* Уникальные зоны станции
* Ниже приведены коридоры для станции North Star
*/

//1 этаж
/area/station/hallway/floor1
	name = "\improper Коридор 1 этажа"

/area/station/hallway/floor1/aft
	name = "\improper Южный коридор 1 этажа"
	icon_state = "1_aft"

/area/station/hallway/floor1/fore
	name = "\improper Северный коридор 1 этажа"
	icon_state = "1_fore"

//2 этаж
/area/station/hallway/floor2
	name = "\improper Коридор 2 этажа"

/area/station/hallway/floor2/aft
	name = "\improper Южный коридор 2 этажа"
	icon_state = "2_aft"

/area/station/hallway/floor2/fore
	name = "\improper Северный коридор 2 этажа"
	icon_state = "2_fore"

//3 этаж
/area/station/hallway/floor3
	name = "\improper Коридор 3 этажа"

/area/station/hallway/floor3/aft
	name = "\improper Южный коридор 3 этажа"
	icon_state = "3_aft"

/area/station/hallway/floor3/fore
	name = "\improper Северный коридор 3 этажа"
	icon_state = "3_fore"

//4 этаж
/area/station/hallway/floor4
	name = "\improper Коридор 4 этажа"

/area/station/hallway/floor4/aft
	name = "\improper Южный коридор 4 этажа"
	icon_state = "4_aft"

/area/station/hallway/floor4/fore
	name = "\improper Северный коридор 4 этажа"
	icon_state = "4_fore"
