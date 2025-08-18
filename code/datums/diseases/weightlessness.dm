/datum/disease/weightlessness
	name = "Локальное нарушение гравитации"
	max_stages = 4
	spread_text = "При контакте"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Жидкая тёмная материя"
	cures = list(/datum/reagent/liquid_dark_matter)
	agent = "Субквантовое ДНК-отталкивание"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	spreading_modifier = 0.5
	cure_chance = 4
	desc = "Это заболевание вызывает изменение биоэлектрической сигнатуры пациента, заставляя его отвергать феномен \"веса\". Жидкая тёмная материя стабилизирует поле."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC


/datum/disease/weightlessness/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("На мгновение теряешь равновесие."))
		if(2)
			if(SPT_PROB(3, seconds_per_tick) && !HAS_TRAIT_FROM(affected_mob, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT))
				to_chat(affected_mob, span_danger("Чувствуешь, как отрываешься от земли."))
				affected_mob.reagents.add_reagent(/datum/reagent/gravitum, 1)

		if(4)
			if(SPT_PROB(3, seconds_per_tick) && !affected_mob.has_quirk(/datum/quirk/spacer_born))
				to_chat(affected_mob, span_danger("Тошнит, когда мир начинает вращаться вокруг."))
				affected_mob.adjust_confusion(3 SECONDS)
			if(SPT_PROB(8, seconds_per_tick) && !HAS_TRAIT_FROM(affected_mob, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT))
				to_chat(affected_mob, span_danger("Внезапно отрываешься от пола."))
				affected_mob.reagents.add_reagent(/datum/reagent/gravitum, 5)

/datum/disease/weightlessness/cure(add_resistance)
	. = ..()
	affected_mob.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 95, purge_ratio = 0.4)
	to_chat(affected_mob, span_danger("Падаешь на пол, когда тело перестаёт отвергать гравитацию."))
