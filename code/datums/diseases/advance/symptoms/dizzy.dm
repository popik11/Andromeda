/**Dizziness
 * Increases stealth
 * Lowers resistance
 * Decreases stage speed considerably
 * Slightly reduces transmissibility
 * Intense Level
 * Bonus: Shakes the affected mob's screen for short periods.
 */

/datum/symptom/dizzy // Не яйцо
	name = "Головокружение"
	desc = "Вирус вызывает воспаление вестибулярного аппарата, приводя к приступам головокружения."
	illness = "Морская болезнь"
	resistance = -2
	stage_speed = -3
	transmittable = -1
	level = 4
	severity = 2
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 30
	threshold_descs = list(
		"Заразность 6" = "Также вызывает наркотическое зрение.",
		"Скрытность 4" = "Симптом остаётся скрытым до активации.",
	)

/datum/symptom/dizzy/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalTransmittable() >= 6) //druggy
		power = 2

/datum/symptom/dizzy/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("Кружится голова.", "Мир вокруг плывёт.")]"))
		else
			to_chat(M, span_userdanger("Волна головокружения накатывает на вас!"))
			M.adjust_dizzy_up_to(1 MINUTES, 140 SECONDS)
			if(power >= 2)
				M.set_drugginess(80 SECONDS)
