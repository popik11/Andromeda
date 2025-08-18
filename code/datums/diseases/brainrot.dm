/datum/disease/brainrot
	name = "Гниение мозга" /// Пользователь ТикТока
	max_stages = 4
	spread_text = "При контакте"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Маннитол"
	cures = list(/datum/reagent/medicine/mannitol)
	agent = "Криптококк космозис"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 7.5 //больший шанс излечения, так как требуются два реагента
	desc = "Эта болезнь разрушает клетки мозга, вызывая мозговую лихорадку, некроз мозга и общую интоксикацию."
	required_organ = ORGAN_SLOT_BRAIN
	severity = DISEASE_SEVERITY_HARMFUL
	bypasses_immunity = TRUE

/datum/disease/brainrot/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("blink")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("yawn")
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Вы чувствуете себя не в своей тарелке."))
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
		if(3)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("stare")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
				if(prob(2))
					to_chat(affected_mob, span_danger("Вы пытаетесь вспомнить что-то важное... но не можете."))

		if(4)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("stare")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(7.5, seconds_per_tick))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 170)
				if(prob(2))
					to_chat(affected_mob, span_danger("Странное жужжание заполняет вашу голову, вытесняя все мысли."))
			if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Вы теряете сознание..."))
				affected_mob.visible_message(span_warning("[affected_mob] внезапно падает!"), \
											span_userdanger("Вы внезапно падаете!"))
				affected_mob.Unconscious(rand(100, 200))
				if(prob(1))
					affected_mob.emote("snore")
			if(SPT_PROB(7.5, seconds_per_tick))
				affected_mob.adjust_stutter(6 SECONDS)
