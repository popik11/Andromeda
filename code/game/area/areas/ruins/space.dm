//Space Ruin Parents

/area/ruin/space
	default_gravity = ZERO_GRAVITY
	area_flags = UNIQUE_AREA

/area/ruin/space/unpowered
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

/area/ruin/space/has_grav
	default_gravity = STANDARD_GRAVITY

/area/ruin/space/has_grav/powered
	requires_power = FALSE


// Ruin solars define, /area/solars was moved to /area/station/solars, causing the solars specific areas to lose their properties
/area/ruin/space/solars
	requires_power = FALSE
	area_flags = UNIQUE_AREA
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_SPACE

/area/ruin/space/way_home
	name = "\improper Спасение"
	always_unpowered = FALSE

// Руины корабля "onehalf"

/area/ruin/space/has_grav/onehalf/hallway
	name = "\improper Коридор Полустанции"

/area/ruin/space/has_grav/onehalf/drone_bay
	name = "\improper Ангар Дронов"

/area/ruin/space/has_grav/onehalf/dorms_med
	name = "\improper Жилые помещения"

/area/ruin/space/has_grav/onehalf/bridge
	name = "\improper Мостик Полустанции"

/area/ruin/space/has_grav/powered/dinner_for_two
	name = "Ужин на двоих"

/area/ruin/space/has_grav/powered/cat_man
	name = "\improper Кошачье логово"

/area/ruin/space/has_grav/powered/authorship
	name = "\improper Авторство"

/area/ruin/space/has_grav/powered/aesthetic
	name = "Эстетика"
	ambientsounds = list('sound/ambience/misc/ambivapor1.ogg')


//Руины Отеля

/area/ruin/space/has_grav/hotel
	name = "\improper Отель"

/area/ruin/space/has_grav/hotel/guestroom
	name = "\improper Гостевой Номер Отеля"

/area/ruin/space/has_grav/hotel/guestroom/room_1
	name = "\improper Гостевой Номер 1"

/area/ruin/space/has_grav/hotel/guestroom/room_2
	name = "\improper Гостевой Номер 2"

/area/ruin/space/has_grav/hotel/guestroom/room_3
	name = "\improper Гостевой Номер 3"

/area/ruin/space/has_grav/hotel/guestroom/room_4
	name = "\improper Гостевой Номер 4"

/area/ruin/space/has_grav/hotel/guestroom/room_5
	name = "\improper Гостевой Номер 5"

/area/ruin/space/has_grav/hotel/guestroom/room_6
	name = "\improper Гостевой Номер 6"

/area/ruin/space/has_grav/hotel/security
	name = "\improper Пост Охраны Отеля"

/area/ruin/space/has_grav/hotel/pool
	name = "\improper Бассейн Отеля"

/area/ruin/space/has_grav/hotel/bar
	name = "\improper Бар Отеля"

/area/ruin/space/has_grav/hotel/power
	name = "\improper Генераторная Отеля"

/area/ruin/space/has_grav/hotel/custodial
	name = "\improper Хозяйственная Комната Отеля"

/area/ruin/space/has_grav/hotel/shuttle
	name = "\improper Шаттл Отеля"
	requires_power = FALSE

/area/ruin/space/has_grav/hotel/dock
	name = "\improper Док Шаттла Отеля"

/area/ruin/space/has_grav/hotel/workroom
	name = "\improper Комната Персонала"

/area/ruin/space/has_grav/hotel/storeroom
	name = "\improper Склад Персонала"

//Руины Заброшенного Аванпоста

/area/ruin/space/has_grav/derelictoutpost
	name = "\improper Заброшенный Аванпост"

/area/ruin/space/has_grav/derelictoutpost/cargostorage
	name = "\improper Склад Грузов Аванпоста"

/area/ruin/space/has_grav/derelictoutpost/cargobay
	name = "\improper Грузовой Отсек Аванпоста"

/area/ruin/space/has_grav/derelictoutpost/powerstorage
	name = "\improper Энергохранилище Аванпоста"

/area/ruin/space/has_grav/derelictoutpost/dockedship
	name = "\improper Пристыкованный Корабль"

//Руины Турельного Аванпоста

/area/ruin/space/has_grav/turretedoutpost
	name = "\improper Турельный Аванпост"

//Руины Старого Телепорта

/area/ruin/space/oldteleporter
	name = "\improper Старый Телепорт"

//Руины Транспорта Мехов

/area/ruin/space/has_grav/powered/mechtransport
	name = "\improper Транспорт Мехов"

//Руины Газ Ящера (Станция)

/area/ruin/space/has_grav/thelizardsgas
	name = "\improper Газ Ящера"


//Руины Глубокого Хранилища

/area/ruin/space/has_grav/deepstorage
	name = "Глубокое Хранилище"

/area/ruin/space/has_grav/deepstorage/airlock
	name = "\improper Шлюз Глубокого Хранилища"

/area/ruin/space/has_grav/deepstorage/power
	name = "\improper Энергетический и Атмосферный Отсек"

/area/ruin/space/has_grav/deepstorage/hydroponics
	name = "Гидропоника Хранилища"

/area/ruin/space/has_grav/deepstorage/armory
	name = "\improper Оружейная Хранилища"

/area/ruin/space/has_grav/deepstorage/storage
	name = "\improper Склад Хранилища"

/area/ruin/space/has_grav/deepstorage/dorm
	name = "\improper Жилые Помещения"

/area/ruin/space/has_grav/deepstorage/kitchen
	name = "\improper Кухня Хранилища"

/area/ruin/space/has_grav/deepstorage/crusher
	name = "\improper Утилизатор Хранилища"

/area/ruin/space/has_grav/deepstorage/pharmacy
	name = "\improper Аптека Хранилища"

//Руины Заброшенного Зоопарка

/area/ruin/space/has_grav/abandonedzoo
	name = "\improper Заброшенный Зоопарк"

//Руины Опасных Исследований

/area/ruin/space/has_grav/dangerous_research
	name = "\improper Лобби ASRC"

/area/ruin/space/has_grav/dangerous_research/medical
	name = "\improper Медблок ASRC"

/area/ruin/space/has_grav/dangerous_research/dorms
	name = "\improper Жилые Отсеки ASRC"

/area/ruin/space/has_grav/dangerous_research/lab
	name = "\improper Лаборатория ASRC"

/area/ruin/space/has_grav/dangerous_research/maint
	name = "\improper Техтоннели ASRC"

//Руины Interdyne

/area/ruin/space/has_grav/interdyne
	name = "\improper Исследовательская база Interdyne"

//Руины Разбитого Корабля

/area/ruin/space/has_grav/crashedship/aft
	name = "\improper Кормовая часть корабля"

/area/ruin/space/has_grav/crashedship/midship
	name = "\improper Центральная часть корабля"

/area/ruin/space/has_grav/crashedship/fore
	name = "\improper Носовая часть корабля"

/area/ruin/space/has_grav/crashedship/big_asteroid
	name = "\improper Астероид"

/area/ruin/space/has_grav/crashedship/small_asteroid
	name = "\improper Астероид"

//Руины Древней Космической Станции (OldStation)

/area/ruin/space/ancientstation
	icon_state = "oldstation"

/area/ruin/space/ancientstation/powered
	name = "Энергопитаемая зона"
	icon_state = "teleporter"
	requires_power = FALSE

/area/ruin/space/ancientstation/beta
	icon_state = "betastation"

/area/ruin/space/ancientstation/beta/atmos
	name = "Атмосфера станции Бета"
	icon_state = "os_beta_atmos"
	ambience_index = AMBIENCE_ENGI

/area/ruin/space/ancientstation/beta/supermatter
	name = "Камера суперматерии станции Бета"
	icon_state = "os_beta_engine"

/area/ruin/space/ancientstation/beta/hall
	name = "Главный коридор станции Бета"
	icon_state = "os_beta_hall"

/area/ruin/space/ancientstation/beta/gravity
	name = "Генератор гравитации станции Бета"
	icon_state = "os_beta_gravity"

/area/ruin/space/ancientstation/beta/mining
	name = "Шахтерское оборудование станции Бета"
	icon_state = "os_beta_mining"
	ambience_index = AMBIENCE_MINING

/area/ruin/space/ancientstation/beta/medbay
	name = "Медблок станции Бета"
	icon_state = "os_beta_medbay"
	ambience_index = AMBIENCE_MEDICAL

/area/ruin/space/ancientstation/beta/storage
	name = "\improper Хранилище станции Бета"
	icon_state = "os_beta_storage"

/area/ruin/space/ancientstation/charlie
	icon_state = "charliestation"

/area/ruin/space/ancientstation/charlie/hall
	name = "Главный коридор станции Чарли"
	icon_state = "os_charlie_hall"

/area/ruin/space/ancientstation/charlie/engie
	name = "Инженерный отсек станции Чарли"
	icon_state = "os_charlie_engine"
	ambience_index = AMBIENCE_ENGI

/area/ruin/space/ancientstation/charlie/bridge
	name = "Командный мостик станции Чарли"
	icon_state = "os_charlie_bridge"

/area/ruin/space/ancientstation/charlie/hydro
	name = "Гидропоника станции Чарли"
	icon_state = "os_charlie_hydro"

/area/ruin/space/ancientstation/charlie/kitchen
	name = "\improper Кухня станции Чарли"
	icon_state = "os_charlie_kitchen"

/area/ruin/space/ancientstation/charlie/sec
	name = "Служба безопасности станции Чарли"
	icon_state = "os_charlie_sec"

/area/ruin/space/ancientstation/charlie/dorms
	name = "Жилые помещения станции Чарли"
	icon_state = "os_charlie_dorms"

/area/ruin/space/solars/ancientstation/charlie/solars
	name = "\improper Солнечные панели станции Чарли"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "os_charlie_solars"
	requires_power = FALSE
	area_flags = UNIQUE_AREA
	sound_environment = SOUND_AREA_SPACE

/area/ruin/space/ancientstation/charlie/storage
	name = "Хранилище станции Чарли"
	icon_state = "os_charlie_storage"

/area/ruin/space/ancientstation/delta
	icon_state = "deltastation"

/area/ruin/space/ancientstation/delta/hall
	name = "Главный коридор станции Дельта"
	icon_state = "os_delta_hall"

/area/ruin/space/ancientstation/delta/proto
	name = "\improper Лаборатория прототипов станции Дельта"
	icon_state = "os_delta_protolab"

/area/ruin/space/ancientstation/delta/rnd
	name = "Исследовательский отдел станции Дельта"
	icon_state = "os_delta_rnd"

/area/ruin/space/ancientstation/delta/ai
	name = "\improper Ядро ИИ станции Дельта"
	icon_state = "os_delta_ai"
	ambientsounds = list('sound/ambience/misc/ambimalf.ogg', 'sound/ambience/engineering/ambitech.ogg', 'sound/ambience/engineering/ambitech2.ogg', 'sound/ambience/engineering/ambiatmos.ogg', 'sound/ambience/engineering/ambiatmos2.ogg')

/area/ruin/space/ancientstation/delta/storage
	name = "\improper Хранилище станции Дельта"
	icon_state = "os_delta_storage"

/area/ruin/space/ancientstation/delta/biolab
	name = "Биолаборатория станции Дельта"
	icon_state = "os_delta_biolab"

//KC13, также известный как TheDerelict.dmm

/area/ruin/space/ks13
	name = "\improper Заброшенная Станция 13"
	icon_state = "ks13"

// Области для организации
/area/ruin/space/ks13/hallway

/area/ruin/space/ks13/hallway/central
	name = "\improper Центральный коридор станции"
	icon_state = "ks13_cent_hall"

/area/ruin/space/ks13/hallway/aft
	name = "\improper Южный коридор станции"
	icon_state = "ks13_aft_hall"

/area/ruin/space/ks13/hallway/starboard_bow
	name = "\improper Восточный северный коридор"
	icon_state = "ks13_sb_bow_hall"

// Инженерные помещения
/area/ruin/space/ks13/engineering

/area/ruin/space/ks13/engineering/supermatter
	name = "\improper Суперматериальный двигатель"
	icon_state = "ks13_supermatter"

/area/ruin/space/ks13/engineering/atmos
	name = "\improper Атмосферный отсек"
	icon_state = "ks13_atmos"

/area/ruin/space/ks13/engineering/secure_storage
	name = "\improper Защищенное хранилище"
	icon_state = "ks13_secure_storage"

/area/ruin/space/ks13/engineering/tech_storage
	name = "\improper Техническое хранилище"
	icon_state = "ks13_tech_storage"

/area/ruin/space/ks13/engineering/aux_storage
	name = "\improper Вспомогательное хранилище"
	icon_state = "ks13_aux_storage"

/area/ruin/space/ks13/engineering/grav_gen
	name = "\improper Генератор гравитации"
	icon_state = "ks13_grav_gen"

/area/ruin/space/ks13/engineering/sb_bow_solars_control
	name = "\improper Контроль восточных солнечных батарей"
	icon_state = "ks13_sb_bow_solars_control"

/area/ruin/space/ks13/engineering/aft_solars_control
	name = "\improper Контроль южных солнечных батарей"
	icon_state = "ks13_aft_solars_control"

// Медицинские помещения
/area/ruin/space/ks13/medical

/area/ruin/space/ks13/medical/morgue
	name = "\improper Морг"
	icon_state = "ks13_morgue"

/area/ruin/space/ks13/medical/medbay
	name = "\improper Медблок"
	icon_state = "ks13_med"

// Сервисные помещения
/area/ruin/space/ks13/service

/area/ruin/space/ks13/service/kitchen
	name = "\improper Кухня"
	icon_state = "ks13_kitchen"

/area/ruin/space/ks13/service/bar
	name = "\improper Бар"
	icon_state = "ks13_bar"

/area/ruin/space/ks13/service/chapel
	name = "\improper Часовня"
	icon_state = "ks13_chapel"

/area/ruin/space/ks13/service/chapel_office
	name = "\improper Офис часовни"
	icon_state = "ks13_chapel_office"

/area/ruin/space/ks13/service/cafe
	name = "\improper Кафе"
	icon_state = "ks13_cafe"

/area/ruin/space/ks13/service/hydro
	name = "\improper Гидропоника"
	icon_state = "ks13_hydro"

/area/ruin/space/ks13/service/jani
	name = "\improper Кладовая уборщика"
	icon_state = "ks13_jani"

// Научные помещения
/area/ruin/space/ks13/science

/area/ruin/space/ks13/science/rnd
	name = "\improper Исследовательский отдел"
	icon_state = "ks13_sci"

/area/ruin/space/ks13/science/genetics
	name = "\improper Генетическая лаборатория"
	icon_state = "ks13_gen"

/area/ruin/space/ks13/science/ordnance
	name = "\improper Отдел вооружений"
	icon_state = "ks13_ord"

/area/ruin/space/ks13/science/ordnance_hall
	name = "\improper Коридор отдела вооружений"
	icon_state = "ks13_ord_hall"

// Зоны безопасности
/area/ruin/space/ks13/security

/area/ruin/space/ks13/security/sec
	name = "\improper Служба безопасности"
	icon_state = "ks13_sec"

/area/ruin/space/ks13/security/cell
	name = "\improper Караульная"
	icon_state = "ks13_sec_cell"

/area/ruin/space/ks13/security/court
	name = "\improper Зал суда"
	icon_state = "ks13_court"

/area/ruin/space/ks13/security/court_hall
	name = "\improper Коридор зала суда"
	icon_state = "ks13_court_hall"

// Командные помещения
/area/ruin/space/ks13/command

/area/ruin/space/ks13/command/bridge
	name = "\improper Мостик"
	icon_state = "ks13_bridge"

/area/ruin/space/ks13/command/bridge_hall
	name = "\improper Коридор мостика"
	icon_state = "ks13_bridge_hall"

/area/ruin/space/ks13/command/eva
	name = "\improper Отсек E.V.A"
	icon_state = "ks13_eva"

// Помещения ИИ
/area/ruin/space/ks13/ai

/area/ruin/space/ks13/ai/vault
	name = "\improper Хранилище ИИ"
	icon_state = "ks13_ai_vault"

/area/ruin/space/ks13/ai/corridor
	name = "\improper Коридор ИИ"
	icon_state = "ks13_ai_corridor"

// Разные помещения
/area/ruin/space/ks13/tool_storage
	name = "\improper Кладовая инструментов"
	icon_state = "ks13_tool_storage"

/area/ruin/space/ks13/dorms
	name = "\improper Жилые помещения"
	icon_state = "ks13_dorms"

/area/ruin/space/solars/ks13/sb_bow_solars
	name = "\improper Солнечные восточные батареи"
	icon_state = "ks13_sb_bow_solars"

/area/ruin/space/solars/ks13/aft_solars
	name = "\improper Южные солнечные батареи"
	icon_state = "ks13_aft_solars"

//DJ СТАНЦИЯ

/area/ruin/space/djstation
	name = "\improper DJ станция 'Русская'"
	icon_state = "DJ"
	default_gravity = STANDARD_GRAVITY

/area/ruin/space/djstation/solars
	name = "\improper Солнечные панели DJ станции"
	icon_state = "DJ"
	area_flags = UNIQUE_AREA
	default_gravity = ZERO_GRAVITY

/area/ruin/space/djstation/service
	name = "\improper Сервис DJ станции"
	icon_state = "DJ"
	default_gravity = STANDARD_GRAVITY

//ЗАБРОШЕННЫЙ ТЕЛЕПОРТ

/area/ruin/space/abandoned_tele
	name = "\improper Заброшенный телепорт"
	ambientsounds = list('sound/ambience/misc/ambimalf.ogg', 'sound/ambience/misc/signal.ogg')

//СТАРЫЙ СПУТНИК ИИ

/area/ruin/space/tcommsat_oldaisat
	name = "\improper Заброшенный спутник"
	ambientsounds = list('sound/ambience/engineering/ambisin2.ogg', 'sound/ambience/misc/signal.ogg', 'sound/ambience/misc/signal.ogg', 'sound/ambience/general/ambigen9.ogg', 'sound/ambience/engineering/ambitech.ogg',\
											'sound/ambience/engineering/ambitech2.ogg', 'sound/ambience/engineering/ambitech3.ogg', 'sound/ambience/misc/ambimystery.ogg')
	airlock_wires = /datum/wires/airlock/engineering

// РАЗБИВШИЙСЯ ТЮРЕМНЫЙ ШАТТЛ
/area/ruin/space/prison_shuttle
	name = "\improper Разбившийся тюремный шаттл"

//ЗАБРОШЕННЫЙ БЕЛЫЙ КОРАБЛЬ

/area/ruin/space/has_grav/whiteship/box
	name = "\improper Заброшенный корабль"


//СТАНЦИЯ ПРОСЛУШКИ СИНДИКАТА

/area/ruin/space/has_grav/listeningstation
	name = "\improper Станция прослушки"

/area/ruin/space/has_grav/powered/ancient_shuttle
	name = "\improper Древний шаттл"

//ПРОИЗВОДСТВЕННЫЙ ЦЕНТР "АДСКАЯ ФАБРИКА"
/area/ruin/space/has_grav/hellfactory
	name = "\improper Адская Фабрика"

/area/ruin/space/has_grav/hellfactoryoffice
	name = "\improper Офис Адской Фабрики"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | NOTELEPORT

//Руины Spinward Smoothies

/area/ruin/space/has_grav/spinwardsmoothies
	name = "Spinward Smoothies"

// Планета клоунов
/area/ruin/space/has_grav/powered/clownplanet
	name = "\improper Планета Клоунов"
	ambientsounds = list('sound/music/lobby_music/clown.ogg')

//ЗАБРОШЕННЫЙ СУЛАКО
/area/ruin/space/has_grav/derelictsulaco
	name = "\improper Заброшенный Сулако"

/area/ruin/space/has_grav/powered/biooutpost
	name = "\improper Биоисследовательский аванпост"
	area_flags = UNIQUE_AREA | NOTELEPORT

/area/ruin/space/has_grav/powered/biooutpost/vault
	name = "\improper Сектор испытаний аванпоста"

// Космическое Приведение Кухня
/area/ruin/space/space_ghost_restaurant
	name = "\improper Ресторан 'Космическое Приведение'"

//Руины хаба масс-драйверов
/area/ruin/space/massdriverhub
	name = "\improper Маршрутизатор масс-драйверов"
	always_unpowered = FALSE

// Заброшенная капсула 'Приют Путешественника'
/area/ruin/space/has_grav/travelers_rest
	name = "\improper Приют Путешественника"

// Телефонная будка
/area/ruin/space/has_grav/powered/space_phone_booth
	name = "\improper Телефонная будка"

// Ботанический рай
/area/ruin/space/has_grav/powered/botanical_haven
	name = "\improper Ботанический рай"

// Руины заброшенной стройки
/area/ruin/space/has_grav/derelictconstruction
	name = "\improper Заброшенная стройплощадка"

/// Астероид с атмосферой, имеет подтип для быстрой идентификации из-за уникальных атмосферных свойств
/area/ruin/space/has_grav/atmosasteroid

// Руины станции Waystation
/area/ruin/space/has_grav/waystation
	name = "Техтоннели Waystation"

/area/ruin/space/has_grav/waystation/qm
	name = "Офис квартирмейстера Waystation"

/area/ruin/space/has_grav/waystation/dorms
	name = "Жилые помещения Waystation"

/area/ruin/space/has_grav/waystation/kitchen
	name = "Кухня Waystation"

/area/ruin/space/has_grav/waystation/cargobay
	name = "Грузовой отсек Waystation"

/area/ruin/space/has_grav/waystation/securestorage
	name = "Хранилище Waystation"

/area/ruin/space/has_grav/waystation/cargooffice
	name = "Офис карго Waystation"

/area/ruin/space/has_grav/powered/waystation/assaultpod
	name = "Штурмовая капсула Waystation"

/area/ruin/space/has_grav/waystation/power
	name = "Энергоотсек Waystation"

// Руины "Американской Закусочной"
/area/ruin/space/has_grav/allamericandiner
	name = "\improper Американская Закусочная"

// Транзитная будка
/area/ruin/space/has_grav/transit_booth
	name = "Транзитная будка"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	requires_power = FALSE
	ambientsounds = list('sound/ambience/general/ambigen12.ogg','sound/ambience/general/ambigen13.ogg','sound/ambience/medical/ambinice.ogg')

// Торговый центр
/area/ruin/space/has_grav/the_outlet/storefront
	name = "\improper Торговая зона"

/area/ruin/space/has_grav/the_outlet/employeesection
	name = "\improper Служебные помещения"

/area/ruin/space/has_grav/the_outlet/researchrooms
	name = "\improper Исследовательские лаборатории"

/area/ruin/space/has_grav/the_outlet/cultinfluence
	name = "\improper Зона культового влияния"

//SYN-C Брутус, заброшенный фрегат
/area/ruin/space/has_grav/infested_frigate
	name = "SYN-C Брутус"

//Мусоровозы
/area/ruin/space/has_grav/garbagetruck
	name = "Списанный мусоровоз"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	ambience_index = AMBIENCE_MAINT

/area/ruin/space/has_grav/garbagetruck/foodwaste

/area/ruin/space/has_grav/garbagetruck/medicalwaste

/area/ruin/space/has_grav/garbagetruck/squat

/area/ruin/space/has_grav/garbagetruck/toystore

//Торговая застава Donk Co
/area/ruin/space/has_grav/hauntedtradingpost
	name = "\improper Торговая застава Donk Co."
	icon_state = "donk_public"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ruin/space/has_grav/hauntedtradingpost/public
	name = "\improper Общая зона и кафетерий заставы Donk Co."

/area/ruin/space/has_grav/hauntedtradingpost/public/corridor
	name = "\improper Доки и коридоры заставы Donk Co."
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/ruin/space/has_grav/hauntedtradingpost/employees
	name = "\improper Комната отдыха персонала Donk Co."
	icon_state = "donk_employees"
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/ruin/space/has_grav/hauntedtradingpost/employees/workstation
	name = "\improper Инженерный пост Donk Co."

/area/ruin/space/has_grav/hauntedtradingpost/employees/corridor
	name = "\improper Защищенный коридор Donk Co."
	icon_state = "donk_command"

/area/ruin/space/has_grav/hauntedtradingpost/employees/breakroom
	name = "\improper Комната отдыха Donk Co."

/area/ruin/space/has_grav/hauntedtradingpost/maint
	name = "\improper Вспомогательное хранилище Donk Co."
	icon_state = "donk_maints"
	airlock_wires = /datum/wires/airlock/maint
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	ambience_index = AMBIENCE_MAINT

/area/ruin/space/has_grav/hauntedtradingpost/maint/toolstorage

/area/ruin/space/has_grav/hauntedtradingpost/maint/toystorage

/area/ruin/space/has_grav/hauntedtradingpost/maint/disposals
	name = "\improper Станция утилизации отходов Donk Co."
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ruin/space/has_grav/hauntedtradingpost/office
	name = "\improper Кабинет капитана Donk Co."
	icon_state = "donk_command"
	airlock_wires = /datum/wires/airlock/cargo
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ruin/space/has_grav/hauntedtradingpost/office/meetingroom
	name = "\improper Переговорная Donk Co."

/area/ruin/space/has_grav/hauntedtradingpost/aicore
	name = "\improper Ядро ИИ Cybersun"
	icon_state = "donk_command"
	airlock_wires = /datum/wires/airlock/security
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	ambience_index = AMBIENCE_DANGER

//Киностудия
/area/ruin/space/has_grav/film_studio
	name = "\improper Генераторная киностудии"

/area/ruin/space/has_grav/film_studio/dorms
	name = "\improper Жилые помещения киностудии"

/area/ruin/space/has_grav/film_studio/stage
	name = "\improper Основная съёмочная площадка"

/area/ruin/space/has_grav/film_studio/backstage
	name = "\improper Закулисье киностудии"

/area/ruin/space/has_grav/film_studio/director
	name = "\improper Кабинет режиссёра"

/area/ruin/space/has_grav/film_studio/solars
	name = "\improper Сервисные солнечные панели"

/area/ruin/space/has_grav/film_studio/starboard
	name = "\improper Восточный корпус киностудии"
