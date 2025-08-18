/datum/disease/beesease
	name = "Пчелиная болезнь"
	form = "Инфекция"
	max_stages = 4
	spread_text = "При контакте"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Сахар"
	cures = list(/datum/reagent/consumable/sugar)
	agent = "Апидная инфекция"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Без лечения пациент начнёт отрыгивать пчёл."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD //пчёлы гнездятся в трупах


/datum/disease/beesease/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2) // также влияет на речь (см. say.dm)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_notice("Во рту чувствуется вкус мёда."))
		if(3)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_notice("В животе урчит."))
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Живот болезненно жжёт."))
				if(prob(20))
					affected_mob.adjustToxLoss(2)
		if(4)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] жужжит."), \
												span_userdanger("Живот яростно жужжит!"))
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Чувствуете, как что-то шевелится в горле."))
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] откашливает рой пчёл!"), \
													span_userdanger("Вы откашливаете рой пчёл!"))
				new /mob/living/basic/bee(affected_mob.loc)
