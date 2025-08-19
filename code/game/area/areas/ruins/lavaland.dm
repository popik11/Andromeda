//Руины Лаваленда
//ВАЖНО: /unpowered означает, что питание никогда не появится. Спасибо Fikou

/area/ruin/powered/beach

/area/ruin/powered/lavaland_phone_booth
	name = "\improper Телефонная будка"

/area/ruin/powered/clownplanet
	name = "\improper Биодом Клоунов"
	ambientsounds = list('sound/music/lobby_music/clown.ogg')

/area/ruin/unpowered/gaia
	name = "\improper Уголок Эдема"

/area/ruin/powered/snow_biodome

/area/ruin/powered/gluttony

/area/ruin/powered/golem_ship
	name = "\improper Корабль Свободных Големов"

/area/ruin/powered/greed

/area/ruin/unpowered/hierophant
	name = "\improper Арена Иерофанта"

/area/ruin/powered/pride

/area/ruin/powered/seedvault

/area/ruin/unpowered/elephant_graveyard
	name = "\improper Кладбище Слонов"

/area/ruin/powered/graveyard_shuttle
	name = "\improper Кладбище Слонов"

/area/ruin/syndicate_lava_base
	name = "\improper Секретная База"
	ambience_index = AMBIENCE_DANGER
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

/area/ruin/unpowered/cultaltar
	name = "\improper Алтарь Культа"
	area_flags = CULT_PERMITTED
	ambience_index = AMBIENCE_SPOOKY

/area/ruin/thelizardsgas_lavaland
	name = "\improper Газ Ящера"
	icon_state = "lizardgas"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

//База Синдиката на Лаваленде

/area/ruin/syndicate_lava_base/engineering
	name = "Инженерный отсек Синдиката"

/area/ruin/syndicate_lava_base/medbay
	name = "Медбей Синдиката"

/area/ruin/syndicate_lava_base/arrivals
	name = "Зона прибытия Синдиката"

/area/ruin/syndicate_lava_base/bar
	name = "\improper Бар Синдиката"

/area/ruin/syndicate_lava_base/main
	name = "\improper Главный коридор базы Синдиката"

/area/ruin/syndicate_lava_base/cargo
	name = "\improper Карго-отсек Синдиката"

/area/ruin/syndicate_lava_base/chemistry
	name = "Химическая лаборатория Синдиката"

/area/ruin/syndicate_lava_base/virology
	name = "Вирусология Синдиката"

/area/ruin/syndicate_lava_base/testlab
	name = "\improper Лаборатория испытаний Синдиката"

/area/ruin/syndicate_lava_base/dormitories
	name = "\improper Жилые помещения Синдиката"

/area/ruin/syndicate_lava_base/telecomms
	name = "\improper Телекоммуникации Синдиката"

//Гнездо Ксеносов

/area/ruin/unpowered/xenonest
	name = "Улей"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

//ash walker nest
/area/ruin/unpowered/ash_walkers
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'
/area/ruin/unpowered/ratvar
	outdoors = TRUE
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'
