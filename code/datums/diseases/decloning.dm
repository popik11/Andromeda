/datum/disease/decloning
	form = "Вирус"
	name = "Клеточная дегенерация"
	max_stages = 5
	stage_prob = 0.5
	cure_text = "Резадон, Мутадон для замедления или смерть. (Rezadone, Mutadone)"
	agent = "Тяжёлые генетические повреждения"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = @"Без лечения пациент [УДАЛЕНО]!"
	severity = "Опасно!"
	cures = list(/datum/reagent/medicine/rezadone)
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Органический распад"
	process_dead = TRUE
	bypasses_immunity = TRUE

/datum/disease/decloning/cure(add_resistance = TRUE)
	affected_mob.remove_status_effect(/datum/status_effect/decloning)
	return ..()

/datum/disease/decloning/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(affected_mob.stat == DEAD)
		cure()
		return FALSE

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("yawn")
		if(3)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(1.5, seconds_per_tick))
				affected_mob.apply_status_effect(/datum/status_effect/decloning)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Кожа странно пульсирует."))
		if(4)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.apply_status_effect(/datum/status_effect/decloning)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
			if(SPT_PROB(7.5, seconds_per_tick))
				affected_mob.adjust_stutter(6 SECONDS)
		if(5)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Кожа начинает распадаться!"))
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.apply_status_effect(/datum/status_effect/decloning)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
