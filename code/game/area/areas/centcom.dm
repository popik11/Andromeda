
// CENTCOM
// CentCom itself
/area/centcom
	name = "ЦентКом"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "centcom"
	static_lighting = TRUE
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE

// Категория для зон ЦентКома
/area/centcom/central_command_areas
	name = "Зоны Центрального Командования"

/area/centcom/central_command_areas/control
	name = "Центральный контроль ЦентКома"
	icon_state = "centcom_control"

/area/centcom/central_command_areas/evacuation
	name = "Эвакуационное крыло ЦентКома"
	icon_state = "centcom_evacuation"

/area/centcom/central_command_areas/evacuation/ship
	name = "Эвакуационный корабль ЦентКома"
	icon_state = "centcom_evacuation_ship"

/area/centcom/central_command_areas/fore
	name = "Северный док ЦентКома"
	icon_state = "centcom_fore"

/area/centcom/central_command_areas/supply
	name = "Снабженческое крыло ЦентКома"
	icon_state = "centcom_supply"

/area/centcom/central_command_areas/ferry
	name = "Док транспортных шаттлов ЦентКома"
	icon_state = "centcom_ferry"

/area/centcom/central_command_areas/briefing
	name = "Брифинг-зал ЦентКома"
	icon_state = "centcom_briefing"

/area/centcom/central_command_areas/armory
	name = "Оружейная ЦентКома"
	icon_state = "centcom_armory"

/area/centcom/central_command_areas/admin
	name = "Административный офис ЦентКома"
	icon_state = "centcom_admin"

/area/centcom/central_command_areas/admin/storage
	name = "Склад административного офиса ЦентКома"
	icon_state = "centcom_admin_storage"

/area/centcom/central_command_areas/prison
	name = "Тюрьма ЦентКома"
	icon_state = "centcom_prison"

/area/centcom/central_command_areas/prison/cells
	name = "Камеры тюрьмы ЦентКома"
	icon_state = "centcom_cells"

/area/centcom/central_command_areas/courtroom
	name = "Верховный суд NanoTrasen"
	icon_state = "centcom_court"

/area/centcom/central_command_areas/holding
	name = "Следственный изолятор"
	icon_state = "centcom_holding"

/area/centcom/central_command_areas/supplypod/supplypod_temp_holding
	name = "Транспортный коридор грузовых капсул"
	icon_state = "supplypod_flight"

/area/centcom/central_command_areas/supplypod
	name = "Комплекс грузовых капсул"
	icon_state = "supplypod"

/area/centcom/central_command_areas/supplypod/pod_storage
	name = "Хранилище грузовых капсул"
	icon_state = "supplypod_holding"

/area/centcom/central_command_areas/supplypod/loading
	name = "Загрузочный комплекс грузовых капсул"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/central_command_areas/supplypod/loading/Initialize(mapload)
	. = ..()
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/central_command_areas/supplypod/loading/one
	name = "Док #1"
	loading_id = "1"

/area/centcom/central_command_areas/supplypod/loading/two
	name = "Док #2"
	loading_id = "2"

/area/centcom/central_command_areas/supplypod/loading/three
	name = "Док #3"
	loading_id = "3"

/area/centcom/central_command_areas/supplypod/loading/four
	name = "Док #4"
	loading_id = "4"

/area/centcom/central_command_areas/supplypod/loading/ert
	name = "Док ОБР"
	loading_id = "5"

//THUNDERDOME
/area/centcom/tdome
	name = "Громодром"
	icon_state = "thunder"

/area/centcom/tdome/arena
	name = "Арена Громодрома"
	icon_state = "thunder"
	area_flags = parent_type::area_flags | UNLIMITED_FISHING

/area/centcom/tdome/tdome1
	name = "Громодром (Команда 1)"
	icon_state = "thunder_team_one"

/area/centcom/tdome/tdome2
	name = "Громодром (Команда 2)"
	icon_state = "thunder_team_two"

/area/centcom/tdome/administration
	name = "Администрация Громодрома"
	icon_state = "thunder_admin"

/area/centcom/tdome/observation
	name = "Наблюдательная Громодрома"
	icon_state = "thunder_observe"

// ВРАЖДЕБНЫЕ

// Колдуны
/area/centcom/wizard_station
	name = "Логово Колдуна"
	icon_state = "wizards_den"
	static_lighting = TRUE
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE

// Похитители
/area/centcom/abductor_ship
	name = "Корабль Похитителей"
	icon_state = "abductor_ship"
	requires_power = FALSE
	area_flags = UNIQUE_AREA | NOTELEPORT
	static_lighting = FALSE
	base_lighting_alpha = 255
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE

// Синдикат
/area/centcom/syndicate_mothership
	name = "Флагман Синдиката"
	icon_state = "syndie-ship"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE
	ambience_index = AMBIENCE_DANGER

/area/centcom/syndicate_mothership/control
	name = "Командный центр Синдиката"
	icon_state = "syndie-control"
	static_lighting = TRUE

/area/centcom/syndicate_mothership/expansion_bombthreat
	name = "Лаборатория боеприпасов Синдиката"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_ENGI

/area/centcom/syndicate_mothership/expansion_bioterrorism
	name = "Лаборатория биологического оружия Синдиката"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_MEDICAL

/area/centcom/syndicate_mothership/expansion_chemicalwarfare
	name = "Завод химического оружия Синдиката"
	icon_state = "syndie-elite"
	static_lighting = TRUE
	ambience_index = AMBIENCE_REEBE

/area/centcom/syndicate_mothership/expansion_fridgerummage
	name = "Хранилище скоропортящихся продуктов Синдиката"
	icon_state = "syndie-elite"
	static_lighting = TRUE

/area/centcom/syndicate_mothership/elite_squad
	name = "Элитный отряд Синдиката"
	icon_state = "syndie-elite"

/area/centcom/syndicate_mothership/expansion_custodialcloset
	name = "Подсобка уборщика Синдиката"
	icon_state = "syndie-elite"

// МАФИЯ
/area/centcom/mafia
	name = "Мини-игра Мафия"
	icon_state = "mafia"
	static_lighting = FALSE
	base_lighting_alpha = 255
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = BLOCK_SUICIDE | UNIQUE_AREA

// ЗАХВАТ ФЛАГА
/area/centcom/ctf
	name = "Захват Флага"
	icon_state = "ctf"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_DEATH_MESSAGE | BLOCK_SUICIDE

/area/centcom/ctf/control_room
	name = "Комната управления A"
	icon_state = "ctf_room_a"

/area/centcom/ctf/control_room2
	name = "Комната управления B"
	icon_state = "ctf_room_b"

/area/centcom/ctf/central
	name = "Центральная зона"
	icon_state = "ctf_central"

/area/centcom/ctf/main_hall
	name = "Главный зал A"
	icon_state = "ctf_hall_a"

/area/centcom/ctf/main_hall2
	name = "Главный зал B"
	icon_state = "ctf_hall_b"

/area/centcom/ctf/corridor
	name = "Коридор A"
	icon_state = "ctf_corr_a"

/area/centcom/ctf/corridor2
	name = "Коридор B"
	icon_state = "ctf_corr_b"

/area/centcom/ctf/flag_room
	name = "Комната флага A"
	icon_state = "ctf_flag_a"

/area/centcom/ctf/flag_room2
	name = "Комната флага B"
	icon_state = "ctf_flag_b"

// Зоны астероидов
/area/centcom/asteroid
	name = "\improper Астероид"
	icon_state = "asteroid"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA
	ambience_index = AMBIENCE_MINING
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_ASTEROID

/area/centcom/asteroid/nearstation
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	area_flags = UNIQUE_AREA | BLOBS_ALLOWED

/area/centcom/asteroid/nearstation/bomb_site
	name = "\improper Астероид для испытаний бомб"
