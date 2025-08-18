/datum/disease/dnaspread
	name = "Космический ретровирус"
	max_stages = 4
	spread_text = "При контакте"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Мутадон"
	cures = list(/datum/reagent/medicine/mutadone)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	agent = "Ретровирус S4E1"
	viable_mobtypes = list(/mob/living/carbon/human)
	var/datum/dna/original_dna = null
	var/transformed = 0
	desc = "Это заболевание переносит генетический код первоначального носителя в новых хозяев."
	severity = DISEASE_SEVERITY_MEDIUM
	bypasses_immunity = TRUE


/datum/disease/dnaspread/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(!affected_mob.dna)
		cure()
		return FALSE

	// Только виды, которые могут быть переданы через укус трансформации, могут распространяться ретровирусом
	if(HAS_TRAIT(affected_mob, TRAIT_NO_DNA_COPY))
		cure()
		return FALSE

	if(!strain_data["dna"])
		// Поглощает ДНК цели
		strain_data["dna"] = new affected_mob.dna.type
		affected_mob.dna.copy_dna(strain_data["dna"])
		carrier = TRUE
		update_stage(4)
		return

	switch(stage)
		if(2, 3) // Притворяется простудой, давая время на распространение
			if(SPT_PROB(4, seconds_per_tick))
				affected_mob.emote("sneeze")
			if(SPT_PROB(4, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Мышцы ноют."))
				if(prob(20))
					affected_mob.take_bodypart_damage(1, updating_health = FALSE)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Болит живот."))
				if(prob(20))
					affected_mob.adjustToxLoss(2, FALSE)
		if(4)
			if(!transformed && !carrier)
				// Сохраняет оригинальную ДНК для излечения
				original_dna = new affected_mob.dna.type
				affected_mob.dna.copy_dna(original_dna)

				to_chat(affected_mob, span_danger("Чувствуете себя не в своей тарелке..."))
				var/datum/dna/transform_dna = strain_data["dna"]

				transform_dna.copy_dna(affected_mob.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
				affected_mob.real_name = affected_mob.dna.real_name
				affected_mob.updateappearance(mutcolor_update=1)
				affected_mob.domutcheck()

				transformed = 1
				carrier = 1 // Остаётся на 4 стадии


/datum/disease/dnaspread/Destroy()
	if (original_dna && transformed && affected_mob)
		original_dna.copy_dna(affected_mob.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
		affected_mob.real_name = affected_mob.dna.real_name
		affected_mob.updateappearance(mutcolor_update=1)
		affected_mob.domutcheck()

		to_chat(affected_mob, span_notice("Снова чувствуете себя собой."))
	return ..()
