// Простуда
/datum/disease/advance/cold
	copy_type = /datum/disease/advance

/datum/disease/advance/cold/New()
	name = "Простуда"
	symptoms = list(new/datum/symptom/sneeze)
	..()

// Грипп
/datum/disease/advance/flu
	copy_type = /datum/disease/advance

/datum/disease/advance/flu/New()
	name = "Грипп"
	symptoms = list(new/datum/symptom/cough)
	..()

// Случайно сгенерированная болезнь для ящиков с вирусами и событий
/datum/disease/advance/random
	name = "Экспериментальная Болезнь"
	copy_type = /datum/disease/advance

/datum/disease/advance/random/New(max_symptoms, max_level = 8)
	if(!max_symptoms)
		max_symptoms = rand(1, VIRUS_SYMPTOM_LIMIT)
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(initial(S.level) > max_level)
			continue
		if(initial(S.level) <= 0) //недоступные симптомы
			continue
		possible_symptoms += S
	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/S = new chosen_symptom
			symptoms += S
	Refresh()

	name = "Образец #[rand(1,10000)]"
