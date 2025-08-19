/**********************Шахтёрские зоны**************************/
/area/mine
	icon = 'icons/area/areas_station.dmi'
	icon_state = "mining"
	default_gravity = STANDARD_GRAVITY
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED | CULT_PERMITTED
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

/area/mine/lobby
	name = "Шахтёрская станция"
	icon_state = "mining_lobby"

/area/mine/storage
	name = "Производственное хранилище шахты"
	icon_state = "mining_storage"

/area/mine/storage/public
	name = "Общественное хранилище шахты"
	icon_state = "mining_storage"

/area/mine/lobby/raptor
	name = "Ферма рапторов NanoTrasen"
	icon_state = "mining_storage"

/area/mine/production
	name = "Производственный отсек шахты"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Заброшенная шахта"

/area/mine/living_quarters
	name = "Жилые помещения шахты"
	icon_state = "mining_living"

/area/mine/eva
	name = "EVA шахты"
	icon_state = "mining_eva"

/area/mine/eva/lower
	name = "Нижний EVA шахты"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Техтоннели шахты"

/area/mine/maintenance/production
	name = "Техтоннели производства шахты"

/area/mine/maintenance/living
	name = "Техтоннели жилых помещений"

/area/mine/maintenance/living/north
	name = "Северные техтоннели жилых помещений"

/area/mine/maintenance/living/south
	name = "Южные техтоннели жилых помещений"

/area/mine/maintenance/public
	name = "Общественные техтоннели шахты"

/area/mine/maintenance/public/north
	name = "Северные общественные техтоннели"

/area/mine/maintenance/public/south
	name = "Южные общественные техтоннели"

/area/mine/maintenance/service
	name = "Сервисные техтоннели шахты"

/area/mine/maintenance/service/disposals
	name = "Утилизатор шахты"

/area/mine/maintenance/service/comms
	name = "Коммуникации шахты"

/area/mine/maintenance/labor
	name = "Техтоннели трудового лагеря"

/area/mine/cafeteria
	name = "Кафетерий шахты"
	icon_state = "mining_cafe"

/area/mine/cafeteria/labor
	name = "Кафетерий трудового лагеря"
	icon_state = "mining_labor_cafe"

/area/mine/hydroponics
	name = "Гидропоника шахты"
	icon_state = "mining_hydro"

/area/mine/medical
	name = "Медблок шахты"

/area/mine/mechbay
	name = "Ангар мехов шахты"
	icon_state = "mechbay"

/area/mine/lounge
	name = "Зона отдыха шахты"
	icon_state = "mining_lounge"

/area/mine/laborcamp
	name = "Трудовой лагерь"
	icon_state = "mining_labor"

/area/mine/laborcamp/quarters
	name = "Жилые помещения лагеря"
	icon_state = "mining_labor_quarters"

/area/mine/laborcamp/production
	name = "Производство лагеря"
	icon_state = "mining_labor_production"

/area/mine/laborcamp/security
	name = "Охрана лагеря"
	icon_state = "labor_camp_security"
	ambience_index = AMBIENCE_DANGER

/area/mine/laborcamp/security/maintenance
	name = "Техтоннели охраны лагеря"
	icon_state = "labor_camp_security"
	ambience_index = AMBIENCE_DANGER


/**********************Лаваленд**************************/

/area/lavaland
	icon = 'icons/area/areas_station.dmi'
	icon_state = "mining"
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED
	sound_environment = SOUND_AREA_LAVALAND
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'
	allow_shuttle_docking = TRUE

/area/lavaland/surface
	name = "Лаваленд"
	icon_state = "explored"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambience_index = AMBIENCE_MINING
	area_flags = VALID_TERRITORY | UNIQUE_AREA

/area/lavaland/underground
	name = "Пещеры Лаваленда"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambience_index = AMBIENCE_MINING
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED

/area/lavaland/surface/outdoors
	name = "Пустоши Лаваленда"
	outdoors = TRUE

/area/lavaland/surface/outdoors/unexplored //здесь спавнятся монстры и руины
	icon_state = "unexplored"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	map_generator = /datum/map_generator/cave_generator/lavaland

/area/lavaland/surface/outdoors/unexplored/danger //здесь также спавнится мегафауна
	icon_state = "danger"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED

/// Same thing as parent, but uses a different map generator for the icemoon ruin that needs it.
/area/lavaland/surface/outdoors/unexplored/danger/no_ruins
	map_generator = /datum/map_generator/cave_generator/lavaland/ruin_version

/area/lavaland/surface/outdoors/explored
	name = "Трудовой лагерь Лаваленда"
	area_flags = VALID_TERRITORY | UNIQUE_AREA


/**********************Ледяная луна**************************/

/area/icemoon
	icon = 'icons/area/areas_station.dmi'
	icon_state = "mining"
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
	ambience_index = AMBIENCE_ICEMOON
	sound_environment = SOUND_AREA_ICEMOON
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'
	allow_shuttle_docking = TRUE

/area/icemoon/surface
	name = "Ледяная луна"
	icon_state = "explored"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	area_flags = UNIQUE_AREA | FLORA_ALLOWED

/area/icemoon/surface/outdoors
	name = "Пустоши ледяной луны"
	outdoors = TRUE

/area/icemoon/surface/outdoors/Initialize(mapload)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BRIGHT_DAY))
		base_lighting_alpha = 145
	return ..()

/// this is the area you use for stuff to not spawn, but if you still want weather.
/area/icemoon/surface/outdoors/nospawn

/area/icemoon/surface/outdoors/less_spawns
	icon_state = "less_spawns"

/area/icemoon/surface/outdoors/less_spawns/New()
	. = ..()
	// this area SOMETIMES does map generation. Often it doesn't at all
	// so it SHOULD NOT be used with the genturf turf type, as it is not always replaced
	if(HAS_TRAIT(SSstation, STATION_TRAIT_FORESTED))
		map_generator = /datum/map_generator/cave_generator/icemoon/surface/forested
		// flip this on, the generator has already disabled dangerous fauna
		area_flags = MOB_SPAWN_ALLOWED | FLORA_ALLOWED

/area/icemoon/surface/outdoors/always_forested
	icon_state = "forest"
	map_generator = /datum/map_generator/cave_generator/icemoon/surface/forested
	area_flags = MOB_SPAWN_ALLOWED | FLORA_ALLOWED | CAVES_ALLOWED

/area/icemoon/surface/outdoors/rocky
	icon_state = "rocky"
	map_generator = /datum/map_generator/cave_generator/icemoon/surface/rocky
	area_flags = MOB_SPAWN_ALLOWED | FLORA_ALLOWED | CAVES_ALLOWED

/area/icemoon/surface/outdoors/noteleport
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | NOTELEPORT

/area/icemoon/surface/outdoors/noruins
	icon_state = "noruins"
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | CAVES_ALLOWED
	map_generator = /datum/map_generator/cave_generator/icemoon/surface/noruins

/area/icemoon/surface/outdoors/labor_camp
	name = "Трудовой лагерь ледяной луны"
	area_flags = UNIQUE_AREA

/area/icemoon/surface/outdoors/unexplored
	icon_state = "unexplored"
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | CAVES_ALLOWED

/area/icemoon/surface/outdoors/unexplored/rivers
	icon_state = "danger"
	map_generator = /datum/map_generator/cave_generator/icemoon/surface

/area/icemoon/surface/outdoors/unexplored/rivers/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_FORESTED))
		map_generator = /datum/map_generator/cave_generator/icemoon/surface/forested
		area_flags |= MOB_SPAWN_ALLOWED

/area/icemoon/surface/outdoors/unexplored/rivers/no_monsters
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | CAVES_ALLOWED

/area/icemoon/underground
	name = "Пещеры ледяной луны"
	outdoors = TRUE
	always_unpowered = TRUE
	requires_power = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	area_flags = UNIQUE_AREA | FLORA_ALLOWED

/area/icemoon/underground/unexplored
	name = "Пещеры ледяной луны"
	icon_state = "unexplored"
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED

/area/icemoon/underground/unexplored/no_rivers
	icon_state = "norivers"
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED
	map_generator = /datum/map_generator/cave_generator/icemoon

/area/icemoon/underground/unexplored/rivers
	icon_state = "danger"
	map_generator = /datum/map_generator/cave_generator/icemoon

/area/icemoon/underground/unexplored/rivers/deep
	map_generator = /datum/map_generator/cave_generator/icemoon/deep

/area/icemoon/underground/unexplored/rivers/deep/shoreline
	icon_state = "shore"
	area_flags = UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED

/area/icemoon/underground/explored
	name = "Подземелья ледяной луны"
	area_flags = UNIQUE_AREA

/area/icemoon/underground/explored/graveyard
	name = "Кладбище"
	area_flags = UNIQUE_AREA
	ambience_index = AMBIENCE_SPOOKY
	icon = 'icons/area/areas_station.dmi'
	icon_state = "graveyard"

/area/icemoon/underground/explored/graveyard/chapel
	name = "Часовня кладбища"
