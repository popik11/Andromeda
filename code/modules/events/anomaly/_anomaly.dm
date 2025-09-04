/datum/round_event_control/anomaly
	name = "Аномалия: Энергетический поток"
	typepath = /datum/round_event/anomaly

	min_players = 1
	max_occurrences = 0 //Эта аномалия probably shouldn't occur! Она бы работала, но это было бы не очень весело.
	weight = 15
	category = EVENT_CATEGORY_ANOMALIES
	description = "Эта аномалия бьёт током и взрывается. Это базовый тип."
	admin_setup = list(/datum/event_admin_setup/set_location/anomaly)

/datum/round_event/anomaly
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	var/area/impact_area
	var/datum/anomaly_placer/placer = new()
	var/obj/effect/anomaly/anomaly_path = /obj/effect/anomaly/flux
	///The admin-chosen spawn location.
	var/turf/spawn_location

/datum/round_event/anomaly/setup()

	if(spawn_location)
		impact_area = get_area(spawn_location)
	else
		impact_area = placer.findValidArea()

/datum/round_event/anomaly/announce(fake)
	if(isnull(impact_area))
		impact_area = placer.findValidArea()
	priority_announce("Энергетический поток обнаружен на [ANOMALY_ANNOUNCE_DANGEROUS_TEXT] [impact_area.declent_ru(NOMINATIVE)].", "Обнаружена аномалия")

/datum/round_event/anomaly/start()
	var/turf/anomaly_turf

	if(spawn_location)
		anomaly_turf = spawn_location
	else
		anomaly_turf = placer.findValidTurf(impact_area)

	var/newAnomaly
	if(anomaly_turf)
		newAnomaly = new anomaly_path(anomaly_turf)
	if (newAnomaly)
		apply_anomaly_properties(newAnomaly)
		announce_to_ghosts(newAnomaly)

/// Make any further post-creation modifications to the anomaly
/datum/round_event/anomaly/proc/apply_anomaly_properties(obj/effect/anomaly/new_anomaly)
	return

/datum/event_admin_setup/set_location/anomaly
	input_text = "Создать аномалию в вашем текущем местоположении?"

/datum/event_admin_setup/set_location/anomaly/apply_to_event(datum/round_event/anomaly/event)
	event.spawn_location = chosen_turf

