/datum/disease/cold
	name = "Простуда"
	desc = "Без лечения у пациента разовьётся грипп."
	max_stages = 3
	cure_text = "Отдых и спейсациллин (spaceacillin)"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "XY-риновирус"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 0.5
	spread_text = "Воздушно-капельный"
	severity = DISEASE_SEVERITY_NONTHREAT
	required_organ = ORGAN_SLOT_LUNGS


/datum/disease/cold/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("sneeze")
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Горло першит."))
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Слизь стекает по задней стенке горла."))
			if((affected_mob.body_position == LYING_DOWN && SPT_PROB(23, seconds_per_tick)) || SPT_PROB(0.025, seconds_per_tick))  //изменено с prob(10) до починки сна // Сон уже починен?
				to_chat(affected_mob, span_notice("Самочувствие улучшается."))
				cure()
				return FALSE
		if(3)
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("sneeze")
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Горло першит."))
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Слизь стекает по задней стенке горла."))
			if(SPT_PROB(0.25, seconds_per_tick) && !LAZYFIND(affected_mob.disease_resistances, /datum/disease/flu))
				var/datum/disease/Flu = new /datum/disease/flu()
				affected_mob.ForceContractDisease(Flu, FALSE, TRUE)
				cure()
				return FALSE
			if((affected_mob.body_position == LYING_DOWN && SPT_PROB(12.5, seconds_per_tick)) || SPT_PROB(0.005, seconds_per_tick))  //изменено с prob(5) до починки сна
				to_chat(affected_mob, span_notice("Самочувствие улучшается."))
				cure()
				return FALSE
