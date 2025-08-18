/**Deafness
 * Slightly decreases stealth
 * Lowers Resistance
 * Slightly decreases stage speed
 * Decreases transmissibility
 * Intense level
 * Bonus: Causes intermittent loss of hearing.
*/
/datum/symptom/deafness
	name = "Глухота"
	desc = "Вирус вызывает воспаление барабанных перепонок, приводящее к временной потере слуха."
	illness = "Разрыв барабанной перепонки"
	stealth = -1
	resistance = -2
	stage_speed = -1
	transmittable = -3
	level = 4
	severity = 4
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80
	required_organ = ORGAN_SLOT_EARS
	threshold_descs = list(
		"Устойчивость 9" = "Вызывает постоянную глухоту вместо временной.",
		"Скрытность 4" = "Симптом остаётся скрытым до активации.",
	)
	var/causes_permanent_deafness = FALSE

/datum/symptom/deafness/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalResistance() >= 9) //permanent deafness
		causes_permanent_deafness = TRUE

/datum/symptom/deafness/End(datum/disease/advance/advanced_disease)
	REMOVE_TRAIT(advanced_disease.affected_mob, TRAIT_DEAF, DISEASE_TRAIT)
	return ..()

/datum/symptom/deafness/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	var/obj/item/organ/ears/ears = infected_mob.get_organ_slot(ORGAN_SLOT_EARS)

	switch(advanced_disease.stage)
		if(3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(infected_mob, span_warning("[pick("В ушах звенит.", "В ушах что-то хлопнуло.")]"))
		if(5)
			if(causes_permanent_deafness)
				if(ears.damage < ears.maxHealth)
					to_chat(infected_mob, span_userdanger("Уши болезненно хлопают и начинают кровоточить!"))
					// Просто ужасная боль
					ears.apply_organ_damage(ears.maxHealth)
					infected_mob.emote("scream")
					ADD_TRAIT(infected_mob, TRAIT_DEAF, DISEASE_TRAIT)
			else
				to_chat(infected_mob, span_userdanger("В ушах хлопает и начинается оглушительный звон!"))
				ears.deaf = min(20, ears.deaf + 15)

/datum/symptom/deafness/on_stage_change(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	if(advanced_disease.stage < 5 || !causes_permanent_deafness)
		REMOVE_TRAIT(infected_mob, TRAIT_DEAF, DISEASE_TRAIT)
	return TRUE
