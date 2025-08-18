/*Narcolepsy
 * Slight reduction to stealth
 * Reduces resistance
 * Greatly reduces stage speed
 * No change to transmissibility
 * Fatal level
 * Bonus: Causes drowsiness and sleep.
*/
/datum/symptom/narcolepsy
	name = "Нарколепсия"
	desc = "Вирус вызывает гормональный дисбаланс, приводящий к сонливости и нарколептическим приступам."
	illness = "Северное храпение"
	stealth = -1
	resistance = -2
	stage_speed = -3
	transmittable = 0
	level = 6
	symptom_delay_min = 30
	symptom_delay_max = 85
	severity = 4
	var/yawning = FALSE
	threshold_descs = list(
		"Заразность 4" = "Носитель периодически зевает, распространяя вирус среди окружающих в радиусе 6 метров.",
		"Скорость 10" = "Учащает нарколептические приступы, увеличивая вероятность внезапного засыпания.",
	)

/datum/symptom/narcolepsy/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalTransmittable() >= 4) //yawning (mostly just some copy+pasted code from sneezing, with a few tweaks)
		yawning = TRUE
	if(A.totalStageSpeed() >= 10) //act more often
		symptom_delay_min = 20
		symptom_delay_max = 45

/datum/symptom/narcolepsy/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return

	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(50))
				to_chat(M, span_warning("Вы чувствуете усталость."))
		if(2)
			if(prob(50))
				to_chat(M, span_warning("Вы чувствуете сильную усталость."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("Вы пытаетесь сосредоточиться, чтобы не уснуть."))

			M.adjust_drowsiness_up_to(10 SECONDS, 140 SECONDS)

		if(4)
			if(prob(50))
				if(yawning)
					to_chat(M, span_warning("Вы безуспешно пытаетесь сдержать зевок."))
				else
					to_chat(M, span_warning("Вы на мгновение проваливаетесь в сон.")) //не очень-то получится зевать во время этого

			M.adjust_drowsiness_up_to(20 SECONDS, 140 SECONDS)

			if(yawning)
				M.emote("yawn")
				A.airborne_spread(6)

		if(5)
			if(prob(50))
				to_chat(M, span_warning("[pick("Так хочется спать...","Невыносимо хочется спать.","Тяжело держать глаза открытыми.","Вы изо всех сил пытаетесь не уснуть.")]"))

			M.adjust_drowsiness_up_to(80 SECONDS, 140 SECONDS)

			if(yawning)
				M.emote("yawn")
				A.airborne_spread(6)
