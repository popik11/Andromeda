/*Hallucigen
 * Slightly increases stealth
 * Lowers resistance tremendously
 * Slightly decreases stage speed
 * Slightly reduces transmissibility
 * Critical level
 * Bonus:Makes the affected mob be hallucinated for short periods of time.
*/

/datum/symptom/hallucigen
	name = "Галлюциноген"
	desc = "Вирус стимулирует мозг, вызывая периодические галлюцинации."
	illness = "Паранойя"
	stealth = 1
	resistance = -4
	stage_speed = 1
	transmittable = -1
	level = 5
	severity = 2
	base_message_chance = 25
	symptom_delay_min = 25
	symptom_delay_max = 90
	var/fake_healthy = FALSE
	threshold_descs = list(
		"Скорость 7" = "Увеличивает количество галлюцинаций.",
		"Скрытность 4" = "Вирус имитирует положительные симптомы.",
	)

/datum/symptom/hallucigen/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4) //fake good symptom messages
		fake_healthy = TRUE
		base_message_chance = 50
	if(A.totalStageSpeed() >= 7) //stronger hallucinations
		power = 2

/datum/symptom/hallucigen/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	var/list/healthy_messages = list("Легкие работают прекрасно.", "Вы понимаете, что не дышали.", "Вам не нужно дышать.",\
					"Глаза чувствуют себя отлично.", "Слух обострился.", "Вам не нужно моргать.")
	switch(A.stage)
		if(1, 2)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, span_notice("[pick("Краем глаза вы что-то заметили, но оно исчезло.", "Слышен тихий шепот без источника.", "Голова болит.")]"))
				else
					to_chat(M, span_notice("[pick(healthy_messages)]"))
		if(3, 4)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, span_danger("[pick("Кто-то преследует вас.", "За вами следят.", "Шёпот прямо в ухо.", "Громкие шаги приближаются из ниоткуда.")]"))
				else
					to_chat(M, span_notice("[pick(healthy_messages)]"))
		else
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, span_userdanger("[pick("Ох, голова...", "Голова пульсирует.", "Они повсюду! Бегите!", "Что-то в тенях...")]"))
				else
					to_chat(M, span_notice("[pick(healthy_messages)]"))
			M.adjust_hallucinations(90 SECONDS * power)
