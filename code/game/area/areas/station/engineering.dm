/area/station/engineering
	icon_state = "engie"
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/engine_smes
	name = "\improper Инженерные СМЕС"
	icon_state = "engine_smes"

/area/station/engineering/main
	name = "Инженерный отдел"
	icon_state = "engine"

/area/station/engineering/hallway
	name = "Коридор инженерного отдела"
	icon_state = "engine_hallway"

/area/station/engineering/atmos
	name = "Атмосферный отдел"
	icon_state = "atmos"

/area/station/engineering/atmos/upper
	name = "Верхний атмосферный отдел"

/*внешние атмосферные помещения*/
/area/station/engineering/atmos/space_catwalk
	name = "\improper Атмосферный космический трап"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	sound_environment = SOUND_AREA_SPACE
	ambience_index = AMBIENCE_SPACE
	ambient_buzz = null //Космос оглушительно тихий

/area/station/engineering/atmos/project
	name = "\improper Проектная комната атмосферного отдела"
	icon_state = "atmos_projectroom"

/area/station/engineering/atmos/pumproom
	name = "\improper Насосная атмосферного отдела"
	icon_state = "atmos_pump_room"

/area/station/engineering/atmos/mix
	name = "\improper Смесительная атмосферного отдела"
	icon_state = "atmos_mix"

/area/station/engineering/atmos/storage
	name = "\improper Склад атмосферного отдела"
	icon_state = "atmos_storage"

/area/station/engineering/atmos/storage/gas
	name = "\improper Газовый склад атмосферного отдела"
	icon_state = "atmos_storage_gas"

/area/station/engineering/atmos/office
	name = "\improper Офис атмосферного отдела"
	icon_state = "atmos_office"

/area/station/engineering/atmos/hfr_room
	name = "\improper Комната ВТР атмосферного отдела"
	icon_state = "atmos_HFR"

/area/station/engineering/atmospherics_engine
	name = "\improper Атмосферный двигатель"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/engineering/lobby
	name = "\improper Лобби инженерного отдела"
	icon_state = "engi_lobby"

/area/station/engineering/supermatter
	name = "\improper Суперматериальный двигатель"
	icon_state = "engine_sm"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/supermatter/waste
	name = "\improper Камера отходов суперматерии"
	icon_state = "engine_sm_waste"

/area/station/engineering/supermatter/room
	name = "\improper Комната суперматерии"
	icon_state = "engine_sm_room"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/supermatter/room/upper
	name = "\improper Верхняя комната суперматерии"
	icon_state = "engine_sm_room_upper"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/break_room
	name = "\improper Фойе инженерного отдела"
	icon_state = "engine_break"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/gravity_generator
	name = "\improper Комната гравитационного генератора"
	icon_state = "grav_gen"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage
	name = "Инженерный склад"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage_shared
	name = "Общий инженерный склад"
	icon_state = "engine_storage_shared"

/area/station/engineering/transit_tube
	name = "\improper Транзитная труба"
	icon_state = "transit_tube"

/area/station/engineering/storage/tech
	name = "Технический склад"
	icon_state = "tech_storage"

/area/station/engineering/storage/tcomms
	name = "Склад телекоммуникаций"
	icon_state = "tcom_storage"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/*
* Строительные зоны
*/

/area/station/construction
	name = "\improper Строительная зона"
	icon_state = "construction"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/construction/mining/aux_base
	name = "Строительство вспомогательной базы"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/construction/storage_wing
	name = "\improper Складское крыло"
	icon_state = "storage_wing"
