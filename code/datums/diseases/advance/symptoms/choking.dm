/**Choking
 * Very very noticable.
 * Lowers resistance
 * Decreases stage speed
 * Greatly decreases transmissibility
 * Moderate Level.
 * Bonus: Inflicts spikes of oxyloss
 */

/datum/symptom/choking
	name = "Удушье"
	desc = "Вирус вызывает воспаление дыхательных путей, приводящее к периодическим приступам удушья."
	illness = "Воздушные трубки"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 3
	severity = 3
	base_message_chance = 15
	symptom_delay_min = 10
	symptom_delay_max = 30
	required_organ = ORGAN_SLOT_LUNGS
	threshold_descs = list(
		"Скорость 8" = "Учащает приступы удушья.",
		"Скрытность 4" = "Симптом остаётся скрытым до активации."
	)

/datum/symptom/choking/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 8)
		symptom_delay_min = 7
		symptom_delay_max = 24
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE

/datum/symptom/choking/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob

	switch(advanced_disease.stage)
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(infected_mob, span_warning("[pick("Вам трудно дышать.", "Дыхание становится тяжёлым.")]"))
		if(3, 4)
			if(!suppress_warning)
				to_chat(infected_mob, span_warning("[pick("Гортань будто сузилась до размеров соломинки.", "Дышать становится невыносимо тяжело.")]"))
			else
				to_chat(infected_mob, span_warning("Вы чувствуете сильное [pick("головокружение","недомогание","бессилие")].")) //фальшивые симптомы кровопотери
			Choke_stage_3_4(infected_mob, advanced_disease)
			infected_mob.emote("gasp")
		else
			to_chat(infected_mob, span_userdanger("[pick("Вы задыхаетесь!", "Вы не можете дышать!")]"))
			Choke(infected_mob, advanced_disease)
			infected_mob.emote("gasp")

/datum/symptom/choking/proc/Choke_stage_3_4(mob/living/M, datum/disease/advance/A)
	M.adjustOxyLoss(rand(6,13))
	return 1

/datum/symptom/choking/proc/Choke(mob/living/M, datum/disease/advance/A)
	M.adjustOxyLoss(rand(10,18))
	return 1

/*
//////////////////////////////////////

Asphyxiation

	Very very noticable.
	Decreases stage speed.
	Decreases transmittability.

Bonus
	Inflicts large spikes of oxyloss
	Introduces Asphyxiating drugs to the system
	Causes cardiac arrest on dying victims.

//////////////////////////////////////
*/

/datum/symptom/asphyxiation
	name = "Синдром острой дыхательной недостаточности"
	desc = "Вирус вызывает сокращение лёгких хозяина, приводя к тяжёлой асфиксии. Может также вызывать сердечные приступы."
	illness = "Железные лёгкие"
	stealth = -2
	resistance = -0
	stage_speed = -1
	transmittable = -2
	level = 7
	severity = 6
	base_message_chance = 15
	symptom_delay_min = 14
	symptom_delay_max = 30
	required_organ = ORGAN_SLOT_LUNGS
	threshold_descs = list(
		"Скорость 8" = "Дополнительно синтезирует панкуроний и тиопентал натрия в организме хозяина.",
		"Заразность 8" = "Удваивает урон от симптома."
	)
	var/paralysis = FALSE


/datum/symptom/asphyxiation/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 8)
		paralysis = TRUE
	if(A.totalTransmittable() >= 8)
		power = 2

/datum/symptom/asphyxiation/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(3, 4)
			to_chat(M, span_warning("<b>[pick("Гортань будто сузилась.", "Лёгкие будто сжались.")]</b>"))
			Asphyxiate_stage_3_4(M, A)
			M.emote("gasp")
		if(5)
			to_chat(M, span_userdanger("[pick("Лёгкие горят!", "Больно дышать!")]"))
			Asphyxiate(M, A)
			M.emote("gasp")
			if(M.getOxyLoss() >= (M.maxHealth / (200/120)))
				M.visible_message(span_warning("[M] перестаёт дышать, будто лёгкие полностью отказали!"))
				Asphyxiate_death(M, A)
	return

/datum/symptom/asphyxiation/proc/Asphyxiate_stage_3_4(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(10,15) * power
	M.adjustOxyLoss(get_damage)
	return 1

/datum/symptom/asphyxiation/proc/Asphyxiate(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(15,21) * power
	M.adjustOxyLoss(get_damage)
	if(paralysis)
		M.reagents.add_reagent_list(list(/datum/reagent/toxin/pancuronium = 3, /datum/reagent/toxin/sodium_thiopental = 3))
	return 1

/datum/symptom/asphyxiation/proc/Asphyxiate_death(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(25,35) * power
	M.adjustOxyLoss(get_damage)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, get_damage/2)
	return 1
