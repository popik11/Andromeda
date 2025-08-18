/datum/disease/rhumba_beat
	name = "Ритм Румбы"
	max_stages = 5
	spread_text = "При контакте"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Чик чики бум! (Chick Chicky Boom!)"
	cures = list("plasma")
	agent = "Неизвестно"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE

/datum/disease/rhumba_beat/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(26, seconds_per_tick))
				affected_mob.adjustFireLoss(5)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Ты чувствуешь себя странно..."))
		if(3)
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Тебе хочется танцевать..."))
			else if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("gasp")
			else if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Тебе хочется крикнуть 'Чик Чики Бум'..."))
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				if(prob(50))
					affected_mob.adjust_fire_stacks(2)
					affected_mob.ignite_mob()
				else
					affected_mob.emote("gasp")
					to_chat(affected_mob, span_danger("Внутри тебя пылает ритм..."))
		if(5)
			to_chat(affected_mob, span_danger("Твоё тело не может сдержать Ритм Румбы..."))
			if(SPT_PROB(29, seconds_per_tick))
				explosion(affected_mob, devastation_range = -1, light_impact_range = 2, flame_range = 2, flash_range = 3, adminlog = FALSE, explosion_cause = src) // This is equivalent to a lvl 1 fireball
