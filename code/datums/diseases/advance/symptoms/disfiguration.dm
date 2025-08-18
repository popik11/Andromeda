/**Disfiguration
 * Increases stealth
 * No change to resistance
 * Increases stage speed
 * Slightly increases transmissibility
 * Critical level
 * Bonus: Adds disfiguration trait making the mob appear as "Unknown" to others.
 */
/datum/symptom/disfiguration
	name = "Обезображивание"
	desc = "Вирус разжижает лицевые мышцы, обезображивая носителя."
	illness = "Разрушение лица"
	stealth = 2
	resistance = 0
	stage_speed = 3
	transmittable = 1
	level = 5
	severity = 1
	symptom_delay_min = 25
	symptom_delay_max = 75

/datum/symptom/disfiguration/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	if (HAS_TRAIT(M, TRAIT_DISFIGURED))
		return
	switch(A.stage)
		if(5)
			ADD_TRAIT(M, TRAIT_DISFIGURED, DISEASE_TRAIT)
			M.visible_message(span_warning("Лицо [M] будто проваливается вовнутрь!"), span_notice("Вы чувствуете, как ваше лицо обрушивается и деформируется!"))
		else
			M.visible_message(span_warning("Лицо [M] начинает искажаться..."), span_notice("Ваше лицо кажется влажным и податливым..."))


/datum/symptom/disfiguration/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.affected_mob)
		REMOVE_TRAIT(A.affected_mob, TRAIT_DISFIGURED, DISEASE_TRAIT)
