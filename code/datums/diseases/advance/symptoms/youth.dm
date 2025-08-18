/*Eternal Youth
 * Greatly increases stealth
 * Tremendous increase to resistance
 * Tremendous increase to stage speed
 * Tremendous reduction to transmissibility
 * Critical level
 * Bonus: Can be used to buff your virus
*/

/datum/symptom/youth
	name = "Вечная молодость"
	desc = "Вирус образует симбиотическую связь с клетками организма носителя, предотвращая и обращая старение. \
	Взамен вирус становится более устойчивым, быстрее распространяется и его сложнее обнаружить, хотя без носителя он развивается хуже."
	stealth = 3
	resistance = 4
	stage_speed = 4
	transmittable = -4
	level = 5
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 50

/datum/symptom/youth/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(A.stage)
			if(1)
				if(H.age > 41)
					H.age = 41
					to_chat(H, span_notice("У вас не было столько энергии уже много лет!"))
			if(2)
				if(H.age > 36)
					H.age = 36
					to_chat(H, span_notice("Настроение внезапно улучшилось."))
			if(3)
				if(H.age > 31)
					H.age = 31
					to_chat(H, span_notice("Вы чувствуете себя более подвижным."))
			if(4)
				if(H.age > 26)
					H.age = 26
					to_chat(H, span_notice("Ощущаете прилив сил."))
			if(5)
				if(H.age > 21)
					H.age = 21
					to_chat(H, span_notice("Чувствуете, что можете свернуть горы!"))
