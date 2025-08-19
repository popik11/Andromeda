/area/station/science
	name = "\improper Научный отдел"
	icon_state = "science"
	airlock_wires = /datum/wires/airlock/science
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/science/lobby
	name = "\improper Лобби научного отдела"
	icon_state = "science_lobby"

/area/station/science/lower
	name = "\improper Нижний научный отдел"
	icon_state = "lower_science"

/area/station/science/breakroom
	name = "\improper Комната отдыха науки"
	icon_state = "science_breakroom"

/area/station/science/lab
	name = "Исследования и разработки"
	icon_state = "research"

/area/station/science/xenobiology
	name = "\improper Лаборатория ксенобиологии"
	icon_state = "xenobio"

/area/station/science/xenobiology/hallway
	name = "\improper Коридор ксенобиологии"
	icon_state = "xenobio_hall"

/area/station/science/cytology
	name = "\improper Лаборатория цитологии"
	icon_state = "cytology"

/area/station/science/cubicle
	name = "\improper Научные кабинки"
	icon_state = "science"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/science/genetics
	name = "\improper Лаборатория генетики"
	icon_state = "geneticssci"

/area/station/science/server
	name = "\improper Серверная научного отдела"
	icon_state = "server"

/area/station/science/circuits
	name = "\improper Лаборатория схемотехники"
	icon_state = "cir_lab"

/area/station/science/explab
	name = "\improper Экспериментальная лаборатория"
	icon_state = "exp_lab"

/area/station/science/auxlab
	name = "\improper Вспомогательная лаборатория"
	icon_state = "aux_lab"

/area/station/science/auxlab/firing_range
	name = "\improper Научный тир"

/area/station/science/robotics
	name = "Робототехника"
	icon_state = "robotics"

/area/station/science/robotics/mechbay
	name = "\improper Ангар мехов"
	icon_state = "mechbay"

/area/station/science/robotics/lab
	name = "\improper Лаборатория робототехники"
	icon_state = "ass_line"

/area/station/science/robotics/storage
	name = "\improper Склад робототехники"
	icon_state = "ass_line"

/area/station/science/robotics/augments
	name = "\improper Операционная аугментаций"
	icon_state = "robotics"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/station/science/research
	name = "\improper Исследовательский отдел"
	icon_state = "science"

/area/station/science/research/abandoned
	name = "\improper Заброшенная исследовательская лаборатория"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/science/zoo
	name = "\improper Научный зоопарк"
	icon_state = "cytology"

/*
* Зоны вооружений
*/

// Use this for the main lab. If test equipment, storage, etc is also present use this one too.
/area/station/science/ordnance
	name = "\improper Лаборатория вооружений"
	icon_state = "ord_main"

/area/station/science/ordnance/office
	name = "\improper Офис вооружений"
	icon_state = "ord_office"

/area/station/science/ordnance/storage
	name = "\improper Склад вооружений"
	icon_state = "ord_storage"

/area/station/science/ordnance/burnchamber
	name = "\improper Термокамера вооружений"
	icon_state = "ord_burn"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/science/ordnance/freezerchamber
	name = "\improper Криокамера вооружений"
	icon_state = "ord_freeze"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

// Room for equipments and such
/area/station/science/ordnance/testlab
	name = "\improper Испытательная лаборатория"
	icon_state = "ord_test"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/science/ordnance/bomb
	name = "\improper Испытательный полигон"
	icon_state = "ord_boom"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | NO_GRAVITY

/area/station/science/ordnance/bomb/planet
	area_flags = /area/station/science/ordnance/bomb::area_flags & ~NO_GRAVITY
