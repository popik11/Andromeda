/datum/disease/parasite
	form = "Паразит"
	name = "Паразитарная инфекция"
	max_stages = 4
	cure_text = "Хирургическое удаление печени."
	agent = "Поедание живых паразитов"
	spread_text = "Небиологический"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	desc = "Без лечения жертва будет постепенно терять питательные вещества, а в итоге лишится печени."
	severity = DISEASE_SEVERITY_HARMFUL
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	required_organ = ORGAN_SLOT_LIVER
	bypasses_immunity = TRUE

/datum/disease/parasite/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("cough")
		if(2)
			if(SPT_PROB(5, seconds_per_tick))
				if(prob(50))
					to_chat(affected_mob, span_notice("Ты уже чувствуешь, как худеешь!"))
				affected_mob.adjust_nutrition(-3)
		if(3)
			if(SPT_PROB(10, seconds_per_tick))
				if(prob(20))
					to_chat(affected_mob, span_notice("Ты... СЕРЬЁЗНО начинаешь ощущать потерю веса."))
				affected_mob.adjust_nutrition(-6)
		if(4)
			if(SPT_PROB(16, seconds_per_tick))
				if(affected_mob.nutrition >= 100)
					if(prob(10))
						to_chat(affected_mob, span_warning("Чувствуешь, как твоё тело стремительно теряет вес!"))
					affected_mob.adjust_nutrition(-12)
				else
					to_chat(affected_mob, span_warning("Ты чувствуешь себя НАМНОГО легче!"))
					affected_mob.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 20)
					// код болезни уже проверяет наличие печени, иначе излечивает
					var/obj/item/organ/liver/affected_liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
					affected_liver.Remove(affected_mob)
					affected_liver.forceMove(get_turf(affected_mob))
					cure()
					return FALSE
