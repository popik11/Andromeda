// Руины на Ледяной луне

/area/ruin/powered/lizard_gas
	name = "\improper Заправочная станция ящеров"

/area/ruin/unpowered/buried_library
	name = "\improper Захороненная библиотека"

/area/ruin/powered/bathhouse
	name = "\improper Банный комплекс"
	mood_bonus = 10
	mood_message = "Хотел бы я остаться здесь навсегда."

/turf/closed/wall/bathhouse
	desc = "Приятно прохладные на ощупь стены."
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "block"
	base_icon_state = "block"
	smoothing_flags = NONE
	canSmoothWith = null
	rust_resistance = RUST_RESISTANCE_BASIC

/area/ruin/powered/mailroom
	name = "\improper Заброшенное почтовое отделение"

/area/ruin/comms_agent
	name = "\improper Наблюдательный пост"
	sound_environment = SOUND_ENVIRONMENT_CITY

/area/ruin/comms_agent/maint
	name = "\improper Технические помещения поста"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/ruin/plasma_facility/commons
	name = "\improper Общие помещения плазменного комплекса"
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = -5
	mood_message = "Чувствую, что за мной наблюдают..."

/area/ruin/plasma_facility/operations
	name = "\improper Операционный центр комплекса"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -5
	mood_message = "Чувствую, что за мной наблюдают..."

/area/ruin/bughabitat
	name = "\improper Энтомологический центр"
	mood_bonus = 1
	mood_message = "Здесь странно спокойно."

/area/ruin/pizzeria
	name = "\improper Пиццерия 'Моффучи'"

/area/ruin/pizzeria/kitchen
	name = "\improper Кухня 'Моффучи'"

/area/ruin/syndibiodome
	name = "\improper Биокупол Синдиката"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	ambience_index = AMBIENCE_DANGER
	area_flags = NOTELEPORT
	mood_bonus = -10
	mood_message = "Что за черт."

/area/ruin/planetengi
	name = "\improper Инженерный аванпост"

/area/ruin/huntinglodge
	name = "\improper Охотничий домик"
	mood_bonus = -5
	mood_message = "Что-то здесь не так..."

/area/ruin/smoking_room/house
	name = "\improper Табачный дом"
	sound_environment = SOUND_ENVIRONMENT_CITY
	mood_bonus = -1
	mood_message = "Боже, здесь воняет сигаретами."

/area/ruin/smoking_room/room
	name = "\improper Курительная комната"
	sound_environment = SOUND_ENVIRONMENT_DIZZY
	mood_bonus = -8
	mood_message = "Чувствую, как с каждым вдохом сокращается моя жизнь."

/area/ruin/powered/icemoon_phone_booth
	name = "\improper Телефонная будка"

/area/ruin/powered/hermit
	name = "\improper Домик отшельника"

/area/ruin/syndielab
	name = "\improper Лаборатория Синдиката"
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/ruin/outpost31
	name = "\improper Аванпост 31"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -10
	mood_message = "Здесь произошло что-то ужасное..."

/area/ruin/outpost31/medical
	name = "\improper Медблок аванпоста 31"

/area/ruin/outpost31/kitchendiningroom
	name = "\improper Кухня-столовая аванпоста 31"

/area/ruin/outpost31/kennel
	name = "\improper Псарня аванпоста 31"

/area/ruin/outpost31/radiomap
	name = "\improper Радио-картографическая комната"

/area/ruin/outpost31/lab
	name = "\improper Лаборатория аванпоста 31"
	area_flags = NOTELEPORT //арена мегафауны
	requires_power = FALSE

/area/ruin/outpost31/lootroom
	name = "\improper Дополнительное хранилище"
	area_flags = NOTELEPORT //комната с добычей
	requires_power = FALSE

/area/ruin/outpost31/recroom
	name = "\improper Комната отдыха"

/area/ruin/outpost31/crewquarters
	name = "\improper Жилые помещения"

/area/ruin/outpost31/commander_room
	name = "\improper Кабинет командира аванпоста"
