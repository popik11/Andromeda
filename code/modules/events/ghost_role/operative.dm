/datum/round_event_control/operative
	name = "Одинокий Оперативник"
	typepath = /datum/round_event/ghost_role/operative
	weight = 0 //его вес зависит от того, насколько стационарен и заброшен ядерный диск. Смотри nuclearbomb.dm. Не должен быть доступен для захвата через dynamic.
	max_occurrences = 1
	category = EVENT_CATEGORY_INVASION
	description = "Одинокий ядерный оперативник атакует станцию."

/datum/round_event_control/operative/can_spawn_event(players_amt, allow_magic)
	return ..() && SSdynamic.antag_events_enabled

/datum/round_event/ghost_role/operative
	minimum_required = 1
	role_name = "одинокий оперативник"
	fakeable = FALSE

/datum/round_event/ghost_role/operative/spawn_role()
	var/mob/chosen_one = SSpolling.poll_ghost_candidates(check_jobban = ROLE_OPERATIVE, role = ROLE_LONE_OPERATIVE, alert_pic = /obj/machinery/nuclearbomb, amount_to_pick = 1)
	if(isnull(chosen_one))
		return NOT_ENOUGH_PLAYERS
	var/spawn_location = find_space_spawn()
	if(isnull(spawn_location))
		return MAP_ERROR
	var/mob/living/carbon/human/operative = new(spawn_location)
	operative.randomize_human_appearance(~RANDOMIZE_SPECIES)
	operative.dna.update_dna_identity()
	var/datum/mind/Mind = new /datum/mind(chosen_one.key)
	Mind.set_assigned_role(SSjob.get_job_type(/datum/job/lone_operative))
	Mind.active = TRUE
	Mind.transfer_to(operative)
	if(!operative.client?.prefs.read_preference(/datum/preference/toggle/nuke_ops_species))
		var/species_type = operative.client.prefs.read_preference(/datum/preference/choiced/species)
		operative.set_species(species_type) //Apply the preferred species to our freshly-made body.

	Mind.add_antag_datum(/datum/antagonist/nukeop/lone)

	message_admins("[ADMIN_LOOKUPFLW(operative)] был создан как одинокий оперативник через событие.")
	operative.log_message("был создан как одинокий оперативник через событие.", LOG_GAME)
	spawned_mobs += operative
	return SUCCESSFUL_SPAWN
