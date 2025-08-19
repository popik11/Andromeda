/area/station/medical
	name = "Медотсек"
	icon_state = "medbay"
	ambience_index = AMBIENCE_MEDICAL
	airlock_wires = /datum/wires/airlock/medbay
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/medical/abandoned
	name = "\improper Заброшенный медотсек"
	icon_state = "abandoned_medbay"
	ambientsounds = list(
		'sound/ambience/misc/signal.ogg',
		)
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/medbay/central
	name = "Центральный медотсек"
	icon_state = "med_central"

/area/station/medical/lower
	name = "\improper Нижний медотсек"
	icon_state = "lower_med"

/area/station/medical/medbay/lobby
	name = "\improper Лобби медотсека"
	icon_state = "med_lobby"

/area/station/medical/medbay/aft
	name = "Южный медотсек"
	icon_state = "med_aft"

/area/station/medical/storage
	name = "Склад медотсека"
	icon_state = "med_storage"

/area/station/medical/paramedic
	name = "Диспетчерская парамедиков"
	icon_state = "paramedic"

/area/station/medical/office
	name = "\improper Медицинский офис"
	icon_state = "med_office"

/area/station/medical/break_room
	name = "\improper Комната отдыха медперсонала"
	icon_state = "med_break"

/area/station/medical/coldroom
	name = "\improper Медицинская холодильная камера"
	icon_state = "kitchen_cold"

/area/station/medical/patients_rooms
	name = "\improper Палаты пациентов"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms/room_a
	name = "Палата A"
	icon_state = "patients"

/area/station/medical/patients_rooms/room_b
	name = "Палата B"
	icon_state = "patients"

/area/station/medical/virology
	name = "Вирусология"
	icon_state = "virology"
	ambience_index = AMBIENCE_VIROLOGY

/area/station/medical/virology/isolation
	name = "Изолятор вирусологии"
	icon_state = "virology_isolation"

/area/station/medical/morgue
	name = "\improper Морг"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/chemistry
	name = "Химическая лаборатория"
	icon_state = "chem"

/area/station/medical/chemistry/minisat
	name = "Мини-спутник химии"

/area/station/medical/pharmacy
	name = "\improper Аптека"
	icon_state = "pharmacy"

/area/station/medical/chem_storage
	name = "\improper Хранилище химикатов"
	icon_state = "chem_storage"

/area/station/medical/surgery
	name = "\improper Операционная"
	icon_state = "surgery"

/area/station/medical/surgery/fore
	name = "\improper Северная операционная"
	icon_state = "foresurgery"

/area/station/medical/surgery/aft
	name = "\improper Южная операционная"
	icon_state = "aftsurgery"

/area/station/medical/surgery/theatre
	name = "\improper Главный операционный зал"
	icon_state = "surgerytheatre"

/area/station/medical/cryo
	name = "Криокамеры"
	icon_state = "cryo"

/area/station/medical/exam_room
	name = "\improper Процедурный кабинет"
	icon_state = "exam_room"

/area/station/medical/treatment_center
	name = "\improper Лечебный центр"
	icon_state = "exam_room"

/area/station/medical/psychology
	name = "\improper Кабинет психолога"
	icon_state = "psychology"
	mood_bonus = 3
	mood_message = "Здесь я чувствую себя спокойно."
	ambientsounds = list(
		'sound/ambience/aurora_caelus/aurora_caelus_short.ogg',
		)
