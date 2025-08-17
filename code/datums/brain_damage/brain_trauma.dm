// Травмы мозга теперь представляют собой реальное повреждение мозга. Само повреждение мозга выступает способом получения травм: при каждом нанесении урона мозгу есть шанс получить травму.
// Этот шанс увеличивается с ростом повреждения мозга (brainloss). Удаление травм - отдельный процесс от лечения повреждений: можно восстановить полную функциональность мозга,
// но сохранить особенности поведения, пока травма не будет вылечена нейрином, операцией, лоботомией или магией - в зависимости от устойчивости травмы.

/datum/brain_trauma
	var/name = "Травма мозга"
	var/desc = "Травма, вызванная повреждением мозга, которая вызывает проблемы у пациента."
	var/scan_desc = "общая травма мозга" // описание при обнаружении сканером здоровья
	var/mob/living/carbon/owner // несчастный
	var/obj/item/organ/brain/brain // мозг несчастного
	var/gain_text = span_notice("Вы чувствуете себя травмированным.")
	var/lose_text = span_notice("Вы больше не чувствуете себя травмированным.")
	var/can_gain = TRUE
	var/random_gain = TRUE // может ли быть получена случайным образом?
	var/resilience = TRAUMA_RESILIENCE_BASIC // насколько сложно вылечить?

	/// Отслеживает абстрактные типы травм мозга, полезно для определения травм, которых не должно существовать
	var/abstract_type = /datum/brain_trauma

/datum/brain_trauma/Destroy()
	// Обрабатываем ссылки на мозг
	brain?.remove_trauma_from_traumas(src)
	if(owner)
		log_game("[key_name_and_tag(owner)] потерял следующую травму мозга: [type]")
		on_lose()
		owner = null
	return ..()

//Called on life ticks
/datum/brain_trauma/proc/on_life(seconds_per_tick, times_fired)
	return

//Called on death
/datum/brain_trauma/proc/on_death()
	return

//Called when given to a mob
/datum/brain_trauma/proc/on_gain()
	SHOULD_CALL_PARENT(TRUE)
	if(gain_text)
		to_chat(owner, gain_text)
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(owner, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))
	return TRUE

//Called when removed from a mob
/datum/brain_trauma/proc/on_lose(silent)
	SHOULD_CALL_PARENT(TRUE)
	if(!silent && lose_text)
		to_chat(owner, lose_text)
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

//Called when hearing a spoken message
/datum/brain_trauma/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

//Called when speaking
/datum/brain_trauma/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	UnregisterSignal(owner, COMSIG_MOB_SAY)
