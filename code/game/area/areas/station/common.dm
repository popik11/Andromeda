/area/station/commons
	name = "\improper Общественные помещения"
	icon_state = "commons"
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/*
* Жилые помещения
*/

/area/station/commons/dorms
	name = "\improper Жилые отсеки"
	icon_state = "dorms"

/area/station/commons/dorms/room1
	name = "\improper Жилая комната 1"
	icon_state = "room1"

/area/station/commons/dorms/room2
	name = "\improper Жилая комната 2"
	icon_state = "room2"

/area/station/commons/dorms/room3
	name = "\improper Жилая комната 3"
	icon_state = "room3"

/area/station/commons/dorms/room4
	name = "\improper Жилая комната 4"
	icon_state = "room4"

/area/station/commons/dorms/apartment1
	name = "\improper Апартаменты 1"
	icon_state = "apartment1"

/area/station/commons/dorms/apartment2
	name = "\improper Апартаменты 2"
	icon_state = "apartment2"

/area/station/commons/dorms/barracks
	name = "\improper Общежитие"

/area/station/commons/dorms/barracks/male
	name = "\improper Мужское общежитие"
	icon_state = "dorms_male"

/area/station/commons/dorms/barracks/female
	name = "\improper Женское общежитие"
	icon_state = "dorms_female"

/area/station/commons/dorms/laundry
	name = "\improper Прачечная"
	icon_state = "laundry_room"

/area/station/commons/toilet
	name = "\improper Туалеты жилых отсеков"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/commons/toilet/auxiliary
	name = "\improper Вспомогательные туалеты"
	icon_state = "toilet"

/area/station/commons/toilet/locker
	name = "\improper Туалеты раздевалок"
	icon_state = "toilet"

/area/station/commons/toilet/restrooms
	name = "\improper Санузлы"
	icon_state = "toilet"

/area/station/commons/toilet/shower
	name = "\improper Душевые"
	icon_state = "shower"

/*
* Комнаты отдыха и раздевалки
*/

/area/station/commons/locker
	name = "\improper Раздевалка"
	icon_state = "locker"

/area/station/commons/lounge
	name = "\improper Барная зона"
	icon_state = "lounge"
	mood_bonus = 5
	mood_message = "Мне нравится находиться в баре!"
	mood_trait = TRAIT_EXTROVERT
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/commons/fitness
	name = "\improper Спортзал"
	icon_state = "fitness"

/area/station/commons/fitness/locker_room
	name = "\improper Общая раздевалка"
	icon_state = "locker"

/area/station/commons/fitness/locker_room/male
	name = "\improper Мужская раздевалка"
	icon_state = "locker_male"

/area/station/commons/fitness/locker_room/female
	name = "\improper Женская раздевалка"
	icon_state = "locker_female"

/area/station/commons/fitness/recreation
	name = "\improper Зона отдыха"
	icon_state = "rec"

/area/station/commons/fitness/recreation/entertainment
	name = "\improper Развлекательный центр"
	icon_state = "entertainment"

/area/station/commons/fitness/recreation/pool
	name = "\improper Бассейн"
	icon_state = "pool"

/area/station/commons/fitness/recreation/lasertag
	name = "\improper Арена лазертага"
	icon_state = "lasertag"

/area/station/commons/fitness/recreation/sauna
	name = "\improper Сауна"
	icon_state = "sauna"

/*
* Свободные помещения
*/

/area/station/commons/vacant_room
	name = "\improper Свободное помещение"
	icon_state = "vacant_room"
	ambience_index = AMBIENCE_MAINT

/area/station/commons/vacant_room/office
	name = "\improper Свободный офис"
	icon_state = "vacant_office"

/area/station/commons/vacant_room/commissary
	name = "\improper Свободная комиссариата"
	icon_state = "vacant_commissary"

/*
* Складские помещения
*/

/area/station/commons/storage
	name = "\improper Общий склад"

/area/station/commons/storage/tools
	name = "\improper Вспомогательный склад инструментов"
	icon_state = "tool_storage"

/area/station/commons/storage/primary
	name = "\improper Основной склад инструментов"
	icon_state = "primary_storage"

/area/station/commons/storage/art
	name = "\improper Склад художественных принадлежностей"
	icon_state = "art_storage"

/area/station/commons/storage/emergency/starboard
	name = "\improper Восточный аварийный склад"
	icon_state = "emergency_storage"

/area/station/commons/storage/emergency/port
	name = "\improper Западный аварийный склад"
	icon_state = "emergency_storage"

/area/station/commons/storage/mining
	name = "\improper Общественный шахтерский склад"
	icon_state = "mining_storage"
