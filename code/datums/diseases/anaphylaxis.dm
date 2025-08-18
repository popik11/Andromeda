/datum/disease/anaphylaxis
	form = "Шок"
	name = "Анафилаксия"
	desc = "У пациента опасная для жизни аллергическая реакция, которая приведёт к смерти без лечения."
	max_stages = 3
	cure_text = "Эпинефрин"
	cures = list(/datum/reagent/medicine/epinephrine)
	cure_chance = 20
	agent = "Аллергия"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CURABLE
	severity = DISEASE_SEVERITY_DANGEROUS
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Нет"
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE
	stage_prob = 5

/datum/disease/anaphylaxis/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(HAS_TRAIT(affected_mob, TRAIT_TOXINLOVER)) // You are no fun
		cure()
		return

	// Cool them enough to feel cold to the touch, and then some, because temperature mechanics are dumb
	affected_mob.adjust_bodytemperature(-10 * seconds_per_tick * stage, min_temp = BODYTEMP_COLD_DAMAGE_LIMIT - 70)

	switch(stage)
		// Ранние симптомы: лёгкая дрожь и головокружение
		if(1)
			if(affected_mob.num_hands >= 1 && SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Чувствуете, как рук[affected_mob.num_hands == 1 ? "а":"и"] начинают дрожать."))
				affected_mob.adjust_jitter_up_to(4 SECONDS * seconds_per_tick, 1 MINUTES)
			if(affected_mob.num_legs >= 1 && SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Чувствуете, как ног[affected_mob.num_hands == 1 ? "а":"и"] начинают дрожать."))
				affected_mob.adjust_jitter_up_to(4 SECONDS * seconds_per_tick, 1 MINUTES)
			if(SPT_PROB(2, seconds_per_tick))
				affected_mob.adjust_dizzy_up_to(5 SECONDS * seconds_per_tick, 1 MINUTES)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Горло чешется."))

		// Опасные симптомы: сильная дрожь, головокружение, помутнение зрения, затруднённое дыхание
		if(2)
			affected_mob.apply_damage(0.33 * seconds_per_tick, TOX, spread_damage = TRUE)

			if(affected_mob.num_hands >= 1 && SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Рук[affected_mob.num_hands == 1 ? "а":"и"] дрожат неконтролируемо."))
				affected_mob.adjust_jitter_up_to(8 SECONDS * seconds_per_tick, 1 MINUTES)
				if(prob(20))
					affected_mob.drop_all_held_items()
			if(affected_mob.num_legs >= 1 && SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Ног[affected_mob.num_hands == 1 ? "а":"и"] дрожат неконтролируемо."))
				affected_mob.adjust_jitter_up_to(8 SECONDS * seconds_per_tick, 1 MINUTES)
				if(prob(40) && affected_mob.getStaminaLoss() < 75)
					affected_mob.adjustStaminaLoss(15)
			if(affected_mob.get_organ_slot(ORGAN_SLOT_EYES) && SPT_PROB(4, seconds_per_tick))
				affected_mob.adjust_eye_blur(4 SECONDS * seconds_per_tick)
				to_chat(affected_mob, span_warning("Зрение становится нечётким."))
			if(!HAS_TRAIT(affected_mob, TRAIT_NOBREATH) && SPT_PROB(4, seconds_per_tick))
				affected_mob.apply_damage(2 * seconds_per_tick, OXY)
				affected_mob.losebreath += (2 * seconds_per_tick)
				to_chat(affected_mob, span_warning("Дышать становится труднее."))
			if(SPT_PROB(2, seconds_per_tick))
				affected_mob.adjust_drowsiness_up_to(3 SECONDS * seconds_per_tick, 30 SECONDS)
			if(SPT_PROB(2, seconds_per_tick))
				affected_mob.adjust_dizzy_up_to(5 SECONDS * seconds_per_tick, 1 MINUTES)
				affected_mob.adjust_confusion_up_to(1 SECONDS * seconds_per_tick, 10 SECONDS)
			if(SPT_PROB(2, seconds_per_tick))
				affected_mob.vomit(MOB_VOMIT_MESSAGE|MOB_VOMIT_HARM)
				affected_mob.Stun(2 SECONDS) // Полные 20 секунд оглушения от рвоты были бы смертельны
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Горло саднит."))

		// "you are too late" symptoms: death.
		if(3)
			affected_mob.apply_damage(3 * seconds_per_tick, TOX, spread_damage = TRUE)
			affected_mob.apply_damage(1 * seconds_per_tick, OXY)
			affected_mob.Unconscious(3 SECONDS * seconds_per_tick)
