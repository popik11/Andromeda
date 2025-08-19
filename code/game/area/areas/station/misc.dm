/*
* Only put an area here if it wouldn't fit sorting criteria
* If more areas are created of an area in this file, please
* make a new file for it!
*/

/*
* This is the ROOT for all station areas
* It keeps the work tree in SDMM nice and pretty :)
*/
/area/station
	name = "Зоны станции"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "station"

/*
* Уникальные зоны Tramstation
*/

/area/station/escapepodbay
	name = "\improper Ангар спасательных капсул"
	icon_state = "podbay"

/area/station/asteroid
	name = "\improper Станционный астероид"
	icon_state = "station_asteroid"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambience_index = AMBIENCE_MINING
	area_flags = UNIQUE_AREA
	outdoors = TRUE
	allow_shuttle_docking = TRUE
