/*Headache
 * Slightly reduces stealth
 * Increases resistance tremendously
 * Increases stage speed
 * No change to transmissibility
 * Low level
 * Bonus: Displays an annoying message! Should be used for buffing your disease.
*/
/datum/symptom/headache
	name = "Головная боль"
	desc = "Вирус вызывает воспаление в мозге, приводящее к постоянным головным болям."
	illness = "Мозговой холод"
	stealth = -1
	resistance = 4
	stage_speed = 2
	transmittable = 0
	level = 1
	severity = 1
	base_message_chance = 100
	symptom_delay_min = 15
	symptom_delay_max = 30
	threshold_descs = list(
		"Скорость 6" = "Головные боли становятся мучительными, ослабляя носителя.",
		"Скорость 9" = "Боли возникают реже, но становятся настолько сильными, что полностью парализуют носителя.",
		"Скрытность 4" = "Снижает частоту головных болей до поздних стадий.",
	)

/datum/symptom/headache/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		base_message_chance = 50
	if(A.totalStageSpeed() >= 6) //severe pain
		power = 2
	if(A.totalStageSpeed() >= 9) //cluster headaches
		symptom_delay_min = 30
		symptom_delay_max = 60
		power = 3

/datum/symptom/headache/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	if(power < 2)
		if(prob(base_message_chance) || A.stage >= 4)
			to_chat(M, span_warning("[pick("Голова болит.", "Голова пульсирует.")]"))
	if(power >= 2 && A.stage >= 4)
		to_chat(M, span_warning("[pick("Голова сильно болит.", "Непрерывная пульсация в голове.")]"))
		M.adjustStaminaLoss(25)
	if(power >= 3 && A.stage >= 5)
		to_chat(M, span_userdanger("[pick("Невыносимая головная боль!", "Ощущение раскалённого ножа в мозгу!", "Волна боли накрывает голову!")]"))
		M.Stun(35)
