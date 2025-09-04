#define OWNER 0
#define STRANGER 1

/datum/brain_trauma/severe/split_personality
	name = "Раздвоение личности"
	desc = "Мозг пациента разделён на две личности, которые случайным образом сменяют контроль над телом."
	scan_desc = "полное разделение долей"
	gain_text = span_warning("Ты чувствуешь, как твой разум разделился надвое.")
	lose_text = span_notice("Ты снова чувствуешь себя одиноким.")
	var/current_controller = OWNER
	var/initialized = FALSE //чтобы предотвратить удаление личностей, пока мы ждём призраков
	var/mob/living/split_personality/stranger_backseat //их двое, чтобы они могли меняться без перезаписи
	var/mob/living/split_personality/owner_backseat
	///Роль для отображения при опросе призраков
	var/poll_role = "раздвоение личности"
	///Сколько времени даём призракам на ответ?
	var/poll_time = 20 SECONDS
	///The stranger_backseat does not have temp body component so we will ghostize() on_lose
	var/temp_component = FALSE

/datum/brain_trauma/severe/split_personality/on_gain()
	var/mob/living/brain_owner = owner
	if(brain_owner.stat == DEAD || !GET_CLIENT(brain_owner) || istype(get_area(brain_owner), /area/deathmatch)) //No use assigning people to a corpse or braindead
		return FALSE
	. = ..()
	make_backseats()

#ifdef UNIT_TESTS
	return // There's no ghosts in the unit test
#endif

	get_ghost()

/datum/brain_trauma/severe/split_personality/proc/make_backseats()
	stranger_backseat = new(owner, src)
	var/datum/action/personality_commune/stranger_spell = new(src)
	stranger_spell.Grant(stranger_backseat)

	owner_backseat = new(owner, src)
	var/datum/action/personality_commune/owner_spell = new(src)
	owner_spell.Grant(owner_backseat)

/// Attempts to get a ghost to play the personality
/datum/brain_trauma/severe/split_personality/proc/get_ghost()
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		question = "Хотите играть за [span_danger("[owner.real_name]")] [span_notice(poll_role)]?. You will be able to return to your original body after.",
		check_jobban = ROLE_PAI,
		poll_time = poll_time,
		checked_target = owner,
		ignore_category = POLL_IGNORE_SPLITPERSONALITY,
		alert_pic = owner,
		role_name_text = poll_role,
	)
	schism(chosen_one)

/// Ghost poll has concluded
/datum/brain_trauma/severe/split_personality/proc/schism(mob/dead/observer/ghost)
	if(isnull(ghost))
		qdel(src)
		return
	if(ghost.mind.current)// if they previous had a body preserve them else that means they never had one or it was destroyed so assign ckey like normal
		stranger_backseat.AddComponent( \
		/datum/component/temporary_body, \
		old_mind = ghost.mind, \
		old_body = ghost.mind.current, \
		)
		temp_component = TRUE


	stranger_backseat.PossessByPlayer(ghost.ckey)
	stranger_backseat.log_message("стал раздвоением личности [key_name(owner)].", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(stranger_backseat)] стал раздвоением личности [ADMIN_LOOKUPFLW(owner)].")

	owner_backseat.AddComponent( \
		/datum/component/temporary_body, \
		old_mind = owner.mind, \
		old_body = owner, \
		perma_body_attached = TRUE, \
	)

	owner_backseat.AddComponent( \
		/datum/component/temporary_body, \
		old_mind = owner.mind, \
		old_body = owner, \
		perma_body_attached = TRUE, \
	)


/datum/brain_trauma/severe/split_personality/on_life(seconds_per_tick, times_fired)
	if(owner.stat == DEAD)
		if(current_controller != OWNER)
			switch_personalities(TRUE)
		qdel(src)
	else if(SPT_PROB(1.5, seconds_per_tick))
		switch_personalities()
	..()

/datum/brain_trauma/severe/split_personality/on_lose()
	// qdel the mob with the temporary component will ensure the original mind will go back into the body and vice versa for the stranger mind
	if(!temp_component)
		stranger_backseat?.ghostize()
	QDEL_NULL(stranger_backseat)
	QDEL_NULL(owner_backseat)
	..()

// Changes who controls the body
/datum/brain_trauma/severe/split_personality/proc/switch_personalities(reset_to_owner = FALSE)
	if(QDELETED(owner) || QDELETED(stranger_backseat) || QDELETED(owner_backseat))
		return

	if(current_controller == STRANGER || reset_to_owner)
		//переход с заднего сиденья к телу и наоборот
		stranger_backseat.PossessByPlayer(owner.ckey)
		//логирование
		owner_backseat.log_message("принял контроль над [key_name(owner)] из-за [src]. (Оригинальный владелец: [stranger_backseat.key])", LOG_GAME)
		owner.PossessByPlayer(owner_backseat.ckey)
		to_chat(stranger_backseat, span_userdanger("Вы чувствуете, что контроль уходит... ваша другая личность теперь у руля!"))

	else
		owner_backseat.PossessByPlayer(owner.ckey)
		stranger_backseat.log_message("принял контроль над [key_name(owner)] из-за [src]. (Оригинальный владелец: [owner_backseat.key])", LOG_GAME)
		owner.PossessByPlayer(stranger_backseat.ckey)
		to_chat(owner_backseat, span_userdanger("Вы чувствуете, что контроль уходит... ваша другая личность теперь у руля!"))

	to_chat(owner, span_userdanger("Вам удаётся вернуть контроль над своим телом!"))
	current_controller = !current_controller


/mob/living/split_personality
	name = "раздвоение личности"
	real_name = "неизвестное сознание"
	var/mob/living/carbon/body
	var/datum/brain_trauma/severe/split_personality/trauma

/mob/living/split_personality/Initialize(mapload, _trauma)
	if(iscarbon(loc))
		body = loc
		name = body.real_name
		real_name = body.real_name
		trauma = _trauma
	return ..()

/mob/living/split_personality/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(QDELETED(body))
		qdel(src) //in case trauma deletion doesn't already do it

	if((body.stat == DEAD && trauma.owner_backseat == src))
		trauma.switch_personalities()
		qdel(trauma)

	..()

/mob/living/split_personality/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_notice("Как раздвоение личности, ты не можешь ничего делать, кроме как наблюдать. Однако со временем ты получишь контроль над телом, поменявшись местами с текущей личностью."))
	to_chat(src, span_warning("<b>Не совершай суицид и не ставь тело в смертельно опасные ситуации. Веди себя так, будто тебе небезразлична его судьба, как и основному сознанию.</b>"))

/mob/living/split_personality/try_speak(message, ignore_spam, forced, filterproof)
	SHOULD_CALL_PARENT(FALSE)
	to_chat(src, span_warning("Ты не можешь говорить, твоё второе я сейчас контролирует тело!"))
	return FALSE

/mob/living/split_personality/emote(act, m_type = null, message = null, intentional = FALSE, force_silence = FALSE, forced = FALSE)
	return FALSE

///////////////BRAINWASHING////////////////////

/datum/brain_trauma/severe/split_personality/brainwashing
	name = "Раздвоение личности"
	desc = "Мозг пациента разделён на две личности, которые случайным образом сменяют контроль над телом."
	scan_desc = "полное разделение долей"
	gain_text = ""
	lose_text = span_notice("Вы свободны от промывки мозгов.")
	can_gain = FALSE
	var/codeword
	var/objective

/datum/brain_trauma/severe/split_personality/brainwashing/New(obj/item/organ/brain/B, _permanent, _codeword, _objective)
	..()
	if(_codeword)
		codeword = _codeword
	else
		codeword = pick(strings("ion_laws.json", "ionabstract")\
			| strings("ion_laws.json", "ionobjects")\
			| strings("ion_laws.json", "ionadjectives")\
			| strings("ion_laws.json", "ionthreats")\
			| strings("ion_laws.json", "ionfood")\
			| strings("ion_laws.json", "iondrinks"))

/datum/brain_trauma/severe/split_personality/brainwashing/on_gain()
	. = ..()
	var/mob/living/split_personality/traitor/traitor_backseat = stranger_backseat
	traitor_backseat.codeword = codeword
	traitor_backseat.objective = objective

/datum/brain_trauma/severe/split_personality/brainwashing/make_backseats()
	stranger_backseat = new /mob/living/split_personality/traitor(owner, src, codeword, objective)
	owner_backseat = new(owner, src)

/datum/brain_trauma/severe/split_personality/brainwashing/get_ghost()
	set waitfor = FALSE
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target("Хотите играть за [span_danger("[owner.real_name]")] с промытыми мозгами? You will be able to return to your original body after.", poll_time = 7.5 SECONDS, checked_target = stranger_backseat, alert_pic = owner, role_name_text = "промытая личность")
	if(chosen_one)
		stranger_backseat.PossessByPlayer(chosen_one.ckey)
	else
		qdel(src)

/datum/brain_trauma/severe/split_personality/brainwashing/on_life(seconds_per_tick, times_fired)
	return //no random switching

/datum/brain_trauma/severe/split_personality/brainwashing/handle_hearing(datum/source, list/hearing_args)
	if(!owner.can_hear() || owner == hearing_args[HEARING_SPEAKER] || !owner.has_language(hearing_args[HEARING_LANGUAGE]))
		return

	var/message = hearing_args[HEARING_RAW_MESSAGE]
	if(findtext(message, codeword))
		hearing_args[HEARING_RAW_MESSAGE] = replacetext(message, codeword, span_warning("[codeword]"))
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/brain_trauma/severe/split_personality, switch_personalities)), 1 SECONDS)

/datum/brain_trauma/severe/split_personality/brainwashing/handle_speech(datum/source, list/speech_args)
	if(findtext(speech_args[SPEECH_MESSAGE], codeword))
		speech_args[SPEECH_MESSAGE] = "" //oh hey did you want to tell people about the secret word to bring you back?

/mob/living/split_personality/traitor
	name = "раздвоение личности"
	real_name = "неизвестное сознание"
	var/objective
	var/codeword

/mob/living/split_personality/traitor/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_notice("Как промытая личность, вы пока можете только наблюдать. Однако вы можете получить контроль над телом, услышав кодовое слово, поменявшись местами с текущей личностью."))
	to_chat(src, span_notice("Ваше кодовое слово для активации: <b>[codeword]</b>"))
	if(objective)
		to_chat(src, span_notice("Ваш хозяин оставил вам задание: <b>[objective]</b>. Выполняйте его любой ценой, когда получите контроль."))

/datum/brain_trauma/severe/split_personality/blackout
	name = "Нарушение ЦНС"
	desc = "ЦНС пациента временно нарушена из-за употребления алкоголя, что блокирует формирование воспоминаний и вызывает снижение когнитивных функций и оглушение."
	scan_desc = "алкогольное нарушение ЦНС"
	gain_text = span_warning("Чёрт, это была последняя капля. Вы отключаетесь...")
	lose_text = "Вы приходите в себя в крайней степени растерянности и с жуткого похмелья. Всё, что вы помните — это что выпили очень много алкоголя... что произошло?"
	poll_role = "отключившийся пьяница"
	random_gain = FALSE
	poll_time = 10 SECONDS
	/// Длительность эффекта в секундах (не в децисекундах). Удаляется при достижении 0.
	var/duration_in_seconds = 180

/datum/brain_trauma/severe/split_personality/blackout/on_gain()
	. = ..()

	if(QDELETED(src))
		return

	RegisterSignal(owner, COMSIG_ATOM_SPLASHED, PROC_REF(on_splashed))
	notify_ghosts(
		"[owner.real_name] отключается!",
		source = owner,
		header = "Чувак, я даже не пьян",
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
	)
	var/datum/status_effect/inebriated/inebriation = owner.has_status_effect(/datum/status_effect/inebriated)
	inebriation?.iron_liver = TRUE

/datum/brain_trauma/severe/split_personality/blackout/on_lose()
	. = ..()
	owner.add_mood_event("hang_over", /datum/mood_event/hang_over)
	UnregisterSignal(owner, COMSIG_ATOM_SPLASHED)
	var/datum/status_effect/inebriated/inebriation = owner.has_status_effect(/datum/status_effect/inebriated)
	inebriation?.iron_liver = FALSE

/datum/brain_trauma/severe/split_personality/blackout/proc/on_splashed()
	SIGNAL_HANDLER
	if(prob(20))//we don't want every single splash to wake them up now do we
		qdel(src)

/datum/brain_trauma/severe/split_personality/blackout/on_life(seconds_per_tick, times_fired)
	if(current_controller == OWNER && stranger_backseat)//we should only start transitioning after the other personality has entered
		owner.overlay_fullscreen("fade_to_black", /atom/movable/screen/fullscreen/blind)
		owner.clear_fullscreen("fade_to_black", animated = 4 SECONDS)
		switch_personalities()
	if(owner.stat == DEAD)
		if(current_controller != OWNER)
			switch_personalities(TRUE)
		qdel(src)
		return
	if(duration_in_seconds <= 0)
		qdel(src)
		return
	else if(duration_in_seconds <= 60 && !(duration_in_seconds % 20))
		to_chat(owner, span_warning("До протрезвления осталось [duration_in_seconds] секунд!"))
	if(prob(10) && !HAS_TRAIT(owner, TRAIT_DISCOORDINATED_TOOL_USER))
		ADD_TRAIT(owner, TRAIT_DISCOORDINATED_TOOL_USER, TRAUMA_TRAIT)
		owner.balloon_alert(owner, "временно снижена координация движений!")
		//We then send a callback to automatically re-add the trait
		addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_DISCOORDINATED_TOOL_USER, TRAUMA_TRAIT), 10 SECONDS)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, balloon_alert), owner, "координация восстановлена!"), 10 SECONDS)
	if(prob(15))
		playsound(owner,'sound/mobs/humanoids/human/hiccup/sf_hiccup_male_01.ogg', 50)
		owner.emote("hiccup")
	//too drunk to feel anything
	//if they're to this point, they're likely dying of liver damage
	//and not accounting for that, the split personality is temporary
	owner.adjustStaminaLoss(-25)
	duration_in_seconds -= seconds_per_tick

/mob/living/split_personality/blackout
	name = "отключившийся пьяница"
	real_name = "пьяное сознание"

/mob/living/split_personality/blackout/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_notice("Вы - невероятно пьяные остатки сознания вашего хозяина! Сыграйте свою роль и оставьте после себя следы хаоса и неразберихи."))
	to_chat(src, span_boldwarning("Хоть вы и пьяны, вы не суицидальны. Не совершайте самоубийство и не подвергайте тело опасности. У вас есть некоторая свобода действий, как у клоуна, но не убивайте никого и не создавайте ситуаций, ведущих к опасности для тела."))

#undef OWNER
#undef STRANGER
