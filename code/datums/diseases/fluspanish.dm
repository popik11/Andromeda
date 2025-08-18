/datum/disease/fluspanish
	name = "Испанский Инквизиторский Грипп"
	max_stages = 3
	spread_text = "Воздушно-капельный"
	cure_text = "Спейсациллин и антитела к обычному гриппу"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 5
	agent = "Вирион гриппа 1nqu1s1t10n"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 0.75
	desc = "Без лечения пациент сгорит заживо за ересь."
	severity = DISEASE_SEVERITY_DANGEROUS
	required_organ = ORGAN_SLOT_LUNGS

/datum/disease/fluspanish/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			affected_mob.adjust_bodytemperature(5 * seconds_per_tick)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("sneeze")
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Кожа горит огнём!"))
				affected_mob.take_bodypart_damage(0, 5, updating_health = FALSE)

		if(3)
			affected_mob.adjust_bodytemperature(10 * seconds_per_tick)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("sneeze")
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Кожа пылает как в аду!"))
				affected_mob.take_bodypart_damage(0, 5, updating_health = FALSE)
