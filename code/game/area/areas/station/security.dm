// При добавлении новых зон безопасности не забудьте добавить их в /datum/bounty/item/security/paperwork!

/area/station/security
	name = "Служба безопасности"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/security/office
	name = "\improper Офис безопасности"
	icon_state = "security"

/area/station/security/breakroom
	name = "\improper Комната отдыха брига"
	icon_state = "brig"

/area/station/security/tram
	name = "\improper Транспортный шаттл брига"
	icon_state = "security"

/area/station/security/lockers
	name = "\improper Раздевалка брига"
	icon_state = "securitylockerroom"

/area/station/security/brig
	name = "\improper Бриг"
	icon_state = "brig"

/area/station/security/holding_cell
	name = "\improper Камера временного содержания"
	icon_state = "holding_cell"

/area/station/security/medical
	name = "\improper Медпункт брига"
	icon_state = "security_medical"

/area/station/security/brig/upper
	name = "\improper Обзорная брига"
	icon_state = "upperbrig"

/area/station/security/brig/lower
	name = "\improper Нижний бриг"
	icon_state = "lower_brig"

/area/station/security/brig/entrance
	name = "\improper Вход в бриг"
	icon_state = "brigentry"

/area/station/security/courtroom
	name = "\improper Зал суда"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/security/courtroom/holding
	name = "\improper Комната содержания подсудимых"

/area/station/security/processing
	name = "\improper Док трудового шаттла"
	icon_state = "sec_labor_processing"

/area/station/security/processing/cremation
	name = "\improper Крематорий брига"
	icon_state = "sec_cremation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/interrogation
	name = "\improper Допросная"
	icon_state = "interrogation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/warden
	name = "Пост Смотрителя"
	icon_state = "warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/evidence
	name = "Хранилище улик"
	icon_state = "evidence"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/detectives_office
	name = "\improper Кабинет детектива"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
		)

/area/station/security/detectives_office/private_investigators_office
	name = "\improper Кабинет частного детектива"
	icon_state = "investigate_office"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/range
	name = "\improper Стрельбище"
	icon_state = "firingrange"

/area/station/security/eva
	name = "\improper EVA брига"
	icon_state = "sec_eva"

/area/station/security/execution
	icon_state = "execution_room"

/area/station/security/execution/transfer
	name = "\improper Трансферный центр"
	icon_state = "sec_processing"

/area/station/security/execution/education
	name = "\improper Камера перевоспитания"

/area/station/security/mechbay
	name = "Ангар мехов брига"
	icon_state = "sec_mechbay"

/*
* Контрольно-пропускные пункты
*/

/area/station/security/checkpoint
	name = "\improper КПП брига"
	icon_state = "checkpoint"

/area/station/security/checkpoint/escape
	name = "\improper КПП убытия"
	icon_state = "checkpoint_esc"

/area/station/security/checkpoint/arrivals
	name = "\improper КПП прибытия"
	icon_state = "checkpoint_arr"

/area/station/security/checkpoint/supply
	name = "Пост брига - Карго"
	icon_state = "checkpoint_supp"

/area/station/security/checkpoint/engineering
	name = "Пост брига - Инженерный"
	icon_state = "checkpoint_engi"

/area/station/security/checkpoint/medical
	name = "Пост брига - Медотсек"
	icon_state = "checkpoint_med"

/area/station/security/checkpoint/medical/medsci
	name = "Пост брига - Меднаука"

/area/station/security/checkpoint/science
	name = "Пост брига - Наука"
	icon_state = "checkpoint_sci"

/area/station/security/checkpoint/science/research
	name = "Пост брига - Исследования"
	icon_state = "checkpoint_res"

/area/station/security/checkpoint/customs
	name = "Таможня"
	icon_state = "customs_point"

/area/station/security/checkpoint/customs/auxiliary
	name = "Вспомогательная таможня"
	icon_state = "customs_point_aux"

/area/station/security/checkpoint/customs/fore
	name = "Северная таможня"
	icon_state = "customs_point_fore"

/area/station/security/checkpoint/customs/aft
	name = "Южная таможня"
	icon_state = "customs_point_aft"

/area/station/security/checkpoint/first
	name = "Пост брига - 1 этаж"
	icon_state = "checkpoint_1"

/area/station/security/checkpoint/second
	name = "Пост брига - 2 этаж"
	icon_state = "checkpoint_2"

/area/station/security/checkpoint/third
	name = "Пост брига - 3 этаж"
	icon_state = "checkpoint_3"

/area/station/security/prison
	name = "\improper Тюремный блок"
	icon_state = "sec_prison"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | PERSISTENT_ENGRAVINGS

// Защищено от радиации
/area/station/security/prison/toilet
	name = "\improper Тюремный туалет"
	icon_state = "sec_prison_safe"

// Защищено от радиации
/area/station/security/prison/safe
	name = "\improper Тюремные камеры"
	icon_state = "sec_prison_safe"

/area/station/security/prison/upper
	name = "\improper Верхний тюремный блок"
	icon_state = "prison_upper"

/area/station/security/prison/visit
	name = "\improper Комната свиданий"
	icon_state = "prison_visit"

/area/station/security/prison/rec
	name = "\improper Тюремная комната отдыха"
	icon_state = "prison_rec"

/area/station/security/prison/mess
	name = "\improper Тюремная столовая"
	icon_state = "prison_mess"

/area/station/security/prison/work
	name = "\improper Тюремная рабочая зона"
	icon_state = "prison_work"

/area/station/security/prison/shower
	name = "\improper Тюремный душ"
	icon_state = "prison_shower"

/area/station/security/prison/workout
	name = "\improper Тюремный спортзал"
	icon_state = "prison_workout"

/area/station/security/prison/garden
	name = "\improper Тюремный сад"
	icon_state = "prison_garden"
