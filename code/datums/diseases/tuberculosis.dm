/datum/disease/tuberculosis
	form = "Заболевание"
	name = "Грибковый туберкулёз"
	max_stages = 5
	spread_text = "Воздушно-капельный"
	cure_text = "Спейсациллин и Конвермол (Spaceacillin & Convermol)"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/c2/convermol)
	agent = "Грибковая туберкулёзная палочка Космозис"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 2.5 //чертовски мал шанс выбраться из ада
	desc = "Редкий высококонтагиозный вирус. Сохранилось несколько образцов, предположительно культивируемых разработчиками биологического оружия. Вызывает жар, кровавую рвоту, повреждение лёгких, потерю веса и усталость."
	required_organ = ORGAN_SLOT_LUNGS
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE // ТБ поражает лёгкие; имеет бактериальную/грибковую природу; вирусный иммунитет неэффективен.

/datum/disease/tuberculosis/stage_act(seconds_per_tick, times_fired) //начало
	. = ..()
	if(!.)
		return

	if(SPT_PROB(stage * 2, seconds_per_tick))
		affected_mob.emote("cough")
		to_chat(affected_mob, span_danger("В груди больно."))

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Живот болезненно сводит!"))
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Появляется холодный пот."))
		if(4)
			var/need_mob_update = FALSE
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("Всё расплывается перед глазами!"))
				affected_mob.set_dizzy_if_lower(10 SECONDS)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Резкая боль в нижней части груди!"))
				need_mob_update += affected_mob.adjustOxyLoss(5, updating_health = FALSE)
				affected_mob.emote("gasp")
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Воздух болезненно вырывается из лёгких."))
				need_mob_update += affected_mob.adjustOxyLoss(25, updating_health = FALSE)
				affected_mob.emote("gasp")
			if(need_mob_update)
				affected_mob.updatehealth()
		if(5)
			var/need_mob_update = FALSE
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("[pick("Сердце замедляется...", "Расслабляешься, сердцебиение замедляется.")]"))
				need_mob_update += affected_mob.adjustStaminaLoss(70, updating_stamina = FALSE)
			if(SPT_PROB(5, seconds_per_tick))
				need_mob_update += affected_mob.adjustStaminaLoss(100, updating_stamina = FALSE)
				affected_mob.visible_message(span_warning("[affected_mob] падает в обморок!"), span_userdanger("Сдаёшься и ощущаешь покой..."))
				affected_mob.AdjustSleeping(10 SECONDS)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("Сознание затуманивается, мысли уплывают!"))
				affected_mob.adjust_confusion_up_to(8 SECONDS, 100 SECONDS)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 20)
			if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(affected_mob, span_warning("<i>[pick("Живот тихо урчит...", "Живот немеет, мышцы становятся вялыми.", "Съел бы и мелок")]</i>"))
				affected_mob.overeatduration = max(affected_mob.overeatduration - (200 SECONDS), 0)
				affected_mob.adjust_nutrition(-100)
			if(SPT_PROB(7.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("[pick("Становится душно...", "Хочется расстегнуть комбинезон...", "Хочется снять одежду...")]"))
				affected_mob.adjust_bodytemperature(40)
			if(need_mob_update)
				affected_mob.updatehealth()
