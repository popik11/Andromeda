// Возможно, в будущем это можно будет изменить на использование mind linker
/datum/action/personality_commune
	name = "Общение с Личностью"
	desc = "Отправляет мысли вашему альтернативному сознанию."
	background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "telepathy"
	overlay_icon_state = "bg_spell_border"

	/// Текст, отображаемый при отправке сообщения паре
	var/fluff_text = span_boldnotice("Вы слышите эхо голоса в глубине своего сознания...")

/datum/action/personality_commune/New(Target)
	. = ..()
	if(!istype(target, /datum/brain_trauma/severe/split_personality))
		stack_trace("[type] был создан для цели, не являющейся /datum/brain_trauma/severe/split_personality, это не работает.")
		qdel(src)

/datum/action/personality_commune/Grant(mob/grant_to)
	if(!istype(grant_to, /mob/living/split_personality))
		return

	return ..()

/datum/action/personality_commune/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/datum/brain_trauma/severe/split_personality/trauma = target
	var/mob/living/split_personality/non_controller = usr
	var/client/non_controller_client = non_controller.client

	var/to_send = tgui_input_text(non_controller, "Что вы хотите сказать своему второму я?", "Общение", max_length = MAX_MESSAGE_LEN)
	if(QDELETED(src) || QDELETED(trauma) || !to_send)
		return FALSE

	var/mob/living/carbon/human/personality_body = trauma.owner
	if(personality_body.client == non_controller_client) // Мы взяли контроль
		return FALSE

	var/user_message = span_boldnotice("Вы концентрируетесь и отправляете мысли своему второму я:")
	var/user_message_body = span_notice("[to_send]")

	to_chat(non_controller, "[user_message] [user_message_body]")

	personality_body.balloon_alert(personality_body, "вы слышите голос")
	to_chat(personality_body, "[fluff_text] [user_message_body]")

	log_directed_talk(non_controller, personality_body, to_send, LOG_SAY, "[name]")
	for(var/dead_mob in GLOB.dead_mob_list)
		if(!isobserver(dead_mob))
			continue
		to_chat(dead_mob, "[FOLLOW_LINK(dead_mob, non_controller)] [span_boldnotice("[non_controller] [name]:")] [span_notice("\"[to_send]\" для")] [span_name("[trauma]")]")

	return TRUE
