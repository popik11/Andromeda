/datum/disease/anxiety
	name = "Тяжёлая тревожность"
	form = "Инфекция"
	max_stages = 4
	spread_text = "При контакте"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Этанол"
	cures = list(/datum/reagent/consumable/ethanol)
	agent = "Избыток Лепидоптицидов"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Без лечения пациент начнёт отрыгивать бабочек."
	severity = DISEASE_SEVERITY_MINOR


/datum/disease/anxiety/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2) // также влияет на речь (см. say.dm)
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_notice("Чувствуете тревогу."))
		if(3)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_notice("В животе трепыхается."))
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_notice("Чувствуете панику."))
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Вас охватывает паника!"))
				affected_mob.adjust_confusion(rand(2 SECONDS, 3 SECONDS))
		if(4)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_danger("В животе порхают бабочки."))
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] мечется в панике."), \
												span_userdanger("У вас приступ паники!"))
				affected_mob.adjust_confusion(rand(6 SECONDS, 8 SECONDS))
				affected_mob.adjust_jitter(rand(12 SECONDS, 16 SECONDS))
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] откашливает бабочек!"), \
													span_userdanger("Вы откашливаете бабочек!"))
				new /mob/living/basic/butterfly(affected_mob.loc)
				new /mob/living/basic/butterfly(affected_mob.loc)
