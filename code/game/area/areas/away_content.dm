/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Миссии вне станции
/area/awaymission
	name = "Странное место"
	icon = 'icons/area/areas_away_missions.dmi'
	icon_state = "away"
	default_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	area_flags = UNIQUE_AREA

/area/awaymission/museum
	name = "Музей NanoTrasen"
	icon_state = "awaycontent28"
	sound_environment = SOUND_ENVIRONMENT_CONCERT_HALL

/area/awaymission/museum/mothroachvoid
	static_lighting = FALSE
	base_lighting_alpha = 200
	base_lighting_color = "#FFF4AA"
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	ambientsounds = list('sound/ambience/beach/shore.ogg', 'sound/ambience/misc/ambiodd.ogg','sound/ambience/medical/ambinice.ogg')

/area/awaymission/museum/cafeteria
	name = "Кафетерий музея NanoTrasen"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/errorroom
	name = "Сверхсекретная комната"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = UNIQUE_AREA|NOTELEPORT
	default_gravity = STANDARD_GRAVITY

/area/awaymission/secret
	area_flags = UNIQUE_AREA|NOTELEPORT|HIDDEN_AREA

/area/awaymission/secret/unpowered
	always_unpowered = TRUE

/area/awaymission/secret/unpowered/outdoors
	outdoors = TRUE

/area/awaymission/secret/unpowered/no_grav
	default_gravity = ZERO_GRAVITY

/area/awaymission/secret/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/secret/powered
	requires_power = FALSE

/area/awaymission/secret/powered/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255
