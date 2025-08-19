/area/station/holodeck
	name = "Голодек"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "Holodeck"
	static_lighting = FALSE
	base_lighting_alpha = 255
	flags_1 = NONE
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL

	var/obj/machinery/computer/holodeck/linked
	var/restricted = FALSE // если TRUE, программа попадает в emag-лист

/*
	Отслеживание питания: использует энергосеть компьютера голодека
	Assert'ы для предотвращения бесконечных циклов
*/

/area/station/holodeck/powered(chan)
	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return A.powered(chan)

/area/station/holodeck/addStaticPower(value, powerchannel)
	if(!linked)
		return
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return ..()

/area/station/holodeck/use_energy(amount, chan)
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return ..()

/*
	Стандартный голодек. Позволяет выпустить пар, делая глупости -
	валяясь на полу, кидая сферы в дыры или избивая людей.
*/
/area/station/holodeck/rec_center
	name = "\improper Рекреационный Голодек"

// Не перемещать эту зону, слишком много кода завязано на голодек
/area/station/holodeck/rec_center/offstation_one
	name = "\improper Рекреационный Голодек"
