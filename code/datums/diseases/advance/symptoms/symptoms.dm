// Symptoms are the effects that engineered advanced diseases do.

/datum/symptom
	var/name = "8-битные баги"
	///Базовое описание симптома
	var/desc = "Если вы это видите, что-то пошло очень не так."
	///Потенциальное название болезни, вызываемой симптомом
	var/illness = "Неопознано"
	///Описание эффектов пороговых значений
	var/threshold_descs = list()
	///Как симптом влияет на скрытность болезни (положительные значения делают её менее заметной)
	var/stealth = 0
	///Как симптом влияет на устойчивость болезни (положительные значения затрудняют лечение)
	var/resistance = 0
	///Как симптом влияет на скорость развития стадий болезни (положительные значения ускоряют прогрессирование)
	var/stage_speed = 0
	///Как симптом влияет на заразность болезни
	var/transmittable = 0
	///Уровень сложности симптома. Чем выше - тем сложнее создать.
	var/level = 0
	///Уровень опасности симптома. Чем выше - тем опаснее.
	var/severity = 0
	///Хэш-идентификатор для наших болезней (складывается с другими симптомами для получения уникального ID)
	var/id = ""
	///Базовый шанс отправки предупреждающих сообщений (может модифицироваться)
	var/base_message_chance = 10
	///Подавлять ли ранние предупреждения
	var/suppress_warning = FALSE
	///Тики между активациями
	var/next_activation = 0
	var/symptom_delay_min = 1
	var/symptom_delay_max = 1
	///Может использоваться для умножения эффектов вируса
	var/power = 1
	///"Кастрированный" симптом не имеет эффекта и влияет только на статистику
	var/neutered = FALSE
	var/list/thresholds
	///Может ли симптом появляться при /datum/disease/advance/GenerateSymptoms()
	var/naturally_occuring = TRUE
	///Требуется ли орган для работы эффектов (робоорганы иммунны к болезням, если нет симптома неорганической биологии)
	var/required_organ

/datum/symptom/New()
	var/list/S = SSdisease.list_symptoms
	for(var/i = 1; i <= S.len; i++)
		if(type == S[i])
			id = "[i]"
			return
	CRASH("We couldn't assign an ID!")

///Called when processing of the advance disease that holds this symptom infects a host and upon each Refresh() of that advance disease.
/datum/symptom/proc/Start(datum/disease/advance/A)
	if(neutered)
		return FALSE
	return TRUE

///Called when the advance disease is going to be deleted or when the advance disease stops processing.
/datum/symptom/proc/End(datum/disease/advance/A)
	if(neutered)
		return FALSE
	return TRUE

/datum/symptom/proc/Activate(datum/disease/advance/advanced_disease)
	if(neutered)
		return FALSE
	if(required_organ)
		if(!advanced_disease.has_required_infectious_organ(advanced_disease.affected_mob, required_organ))
			return FALSE

	if(world.time < next_activation)
		return FALSE
	else
		next_activation = world.time + rand(symptom_delay_min * 10, symptom_delay_max * 10)
		return TRUE

/datum/symptom/proc/on_stage_change(datum/disease/advance/A)
	if(neutered)
		return FALSE
	return TRUE

/datum/symptom/proc/Copy()
	var/datum/symptom/new_symp = new type
	new_symp.name = name
	new_symp.id = id
	new_symp.neutered = neutered
	return new_symp

/datum/symptom/proc/generate_threshold_desc()
	return

///Overload when a symptom needs to be active before processing, like changing biotypes.
/datum/symptom/proc/OnAdd(datum/disease/advance/A)
	return

///Overload for running after processing.
/datum/symptom/proc/OnRemove(datum/disease/advance/A)
	return

/**
 * Returns a list for all of the traits of this symptom.
 *
 *
 * @returns {list} symptom - The desired symptoms as a list.
 */
/datum/symptom/proc/get_symptom_data()
	var/list/data = list()
	data["name"] = name
	data["desc"] = desc
	data["stealth"] = stealth
	data["resistance"] = resistance
	data["stage_speed"] = stage_speed
	data["transmission"] = transmittable
	data["level"] = level
	data["neutered"] = neutered
	data["threshold_desc"] = threshold_descs
	return data

/// Check if we can generate randomly
/datum/symptom/proc/can_generate_randomly()
	return naturally_occuring
