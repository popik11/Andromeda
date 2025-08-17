/**
 * Deadchat Plays Things - The Componenting
 *
 * Allows deadchat to control stuff and things by typing commands into chat.
 * These commands will then trigger callbacks to execute procs!
 */
/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The id for the DEMOCRACY_MODE looping vote timer.
	var/timerid
	/// Assoc list of key-chat command string, value-callback pairs. list("right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, EAST))
	var/list/datum/callback/inputs = list()
	/// Assoc list of ckey:value pairings. In DEMOCRACY_MODE, value is the player's vote. In ANARCHY_MODE, value is world.time when their cooldown expires.
	var/list/ckey_to_cooldown = list()
	/// List of everything orbitting this component's parent.
	var/orbiters = list()
	/// A bitfield containing the mode which this component uses (DEMOCRACY_MODE or ANARCHY_MODE) and other settings)
	var/deadchat_mode
	/// In DEMOCRACY_MODE, this is how long players have to vote on an input. In ANARCHY_MODE, this is how long between inputs for each unique player.
	var/input_cooldown
	///Set to true if a point of interest was created for an object, and needs to be removed if deadchat control is removed. Needed for preventing objects from having two points of interest.
	var/generated_point_of_interest = FALSE
	/// Callback invoked when this component is Destroy()ed to allow the parent to return to a non-deadchat controlled state.
	var/datum/callback/on_removal

/datum/component/deadchat_control/Initialize(_deadchat_mode, _inputs, _input_cooldown = 12 SECONDS, _on_removal)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(orbit_begin))
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, PROC_REF(orbit_stop))
	RegisterSignal(parent, COMSIG_VV_TOPIC, PROC_REF(handle_vv_topic))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	deadchat_mode = _deadchat_mode
	inputs = _inputs
	input_cooldown = _input_cooldown
	on_removal = _on_removal
	if(deadchat_mode & DEMOCRACY_MODE)
		if(deadchat_mode & ANARCHY_MODE) // Выберите что-то одно.
			stack_trace("Компонент deadchat_control добавлен к [parent.type] с одновременно включенными режимами демократии и анархии.")
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	if(!ismob(parent) && !SSpoints_of_interest.is_valid_poi(parent))
		SSpoints_of_interest.make_point_of_interest(parent)
		generated_point_of_interest = TRUE

	var/parent_name = "[parent]"
	if(ismob(parent))
		var/mob/mob_parent = parent
		parent_name = "[mob_parent.real_name]"
	notify_ghosts(
		"[parent_name] теперь под контролем мертвого чата!",
		source = parent,
		header = "Контроль призраков!",
	)

/datum/component/deadchat_control/Destroy(force)
	on_removal?.Invoke()
	inputs = null
	orbiters = null
	ckey_to_cooldown = null
	if(generated_point_of_interest)
		SSpoints_of_interest.remove_point_of_interest(parent)
	on_removal = null
	return ..()

/datum/component/deadchat_control/proc/deadchat_react(mob/source, message)
	SIGNAL_HANDLER

	message = LOWER_TEXT(message)

	if(!inputs[message])
		return

	if(deadchat_mode & ANARCHY_MODE)
		if(!source || !source.ckey)
			return
		var/cooldown = ckey_to_cooldown[source.ckey] - world.time
		if(cooldown > 0)
			to_chat(source, span_warning("Твои команды в мертвый чат ещё на кулдауне ещё [CEILING(cooldown * 0.1, 1)] секунд."))
			return MOB_DEADSAY_SIGNAL_INTERCEPT
		ckey_to_cooldown[source.ckey] = world.time + input_cooldown
		addtimer(CALLBACK(src, PROC_REF(end_cooldown), source.ckey), input_cooldown)
		inputs[message].Invoke()
		to_chat(source, span_notice("Команда \"[message]\" принята. Теперь ты на кулдауне [input_cooldown * 0.1] секунд."))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

	if(deadchat_mode & DEMOCRACY_MODE)
		ckey_to_cooldown[source.ckey] = message
		to_chat(source, span_notice("Ты проголосовал за \"[message]\"."))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/deadchat_control/proc/democracy_loop()
	if(QDELETED(parent) || !(deadchat_mode & DEMOCRACY_MODE))
		deltimer(timerid)
		return
	var/result = count_democracy_votes()
	if(!isnull(result))
		inputs[result].Invoke()
		if(!(deadchat_mode & MUTE_DEMOCRACY_MESSAGES))
			var/message = "<span class='deadsay italics bold'>[parent] выполнил действие [result]!<br>Начато новое голосование. Результат через [input_cooldown * 0.1] секунд.</span>"
			for(var/M in orbiters)
				to_chat(M, message)
	else if(!(deadchat_mode & MUTE_DEMOCRACY_MESSAGES))
		var/message = "<span class='deadsay italics bold'>В этом цикле голосов не было.</span>"
		for(var/M in orbiters)
			to_chat(M, message)

/datum/component/deadchat_control/proc/count_democracy_votes()
	if(!length(ckey_to_cooldown))
		return
	var/list/votes = list()
	for(var/command in inputs)
		votes["[command]"] = 0
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		ckey_to_cooldown.Remove(vote)

	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote

	if(result in inputs)
		return result

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	else
		deltimer(timerid)

/datum/component/deadchat_control/proc/orbit_begin(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	RegisterSignal(orbiter, COMSIG_MOB_DEADSAY, PROC_REF(deadchat_react))
	RegisterSignal(orbiter, COMSIG_MOB_AUTOMUTE_CHECK, PROC_REF(waive_automute))
	orbiters |= orbiter


/datum/component/deadchat_control/proc/orbit_stop(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	if(orbiter in orbiters)
		UnregisterSignal(orbiter, list(
			COMSIG_MOB_DEADSAY,
			COMSIG_MOB_AUTOMUTE_CHECK,
		))
		orbiters -= orbiter

/**
 * Prevents messages used to control the parent from counting towards the automute threshold for repeated identical messages.
 *
 * Arguments:
 * - [speaker][/client]: The mob that is trying to speak.
 * - [client][/client]: The client that is trying to speak.
 * - message: The message that the speaker is trying to say.
 * - mute_type: Which type of mute the message counts towards.
 */
/datum/component/deadchat_control/proc/waive_automute(mob/speaker, client/client, message, mute_type)
	SIGNAL_HANDLER
	if(mute_type == MUTE_DEADCHAT && inputs[LOWER_TEXT(message)])
		return WAIVE_AUTOMUTE_CHECK
	return NONE


/// Allows for this component to be removed via a dedicated VV dropdown entry.
/datum/component/deadchat_control/proc/handle_vv_topic(datum/source, mob/user, list/href_list)
	SIGNAL_HANDLER
	if(!href_list[VV_HK_DEADCHAT_PLAYS] || !check_rights(R_FUN))
		return
	. = COMPONENT_VV_HANDLED
	INVOKE_ASYNC(src, PROC_REF(async_handle_vv_topic), user, href_list)

/// Асинхронная процедура обработки ввода админа при удалении этого компонента через VV меню.
/datum/component/deadchat_control/proc/async_handle_vv_topic(mob/user, list/href_list)
	if(tgui_alert(user, "Убрать контроль мертвого чата с [parent]?", "Мертвый чат играет [parent]", list("Убрать", "Отмена")) == "Убрать")
		// Быстрая проверка, так как это асинхронный вызов.
		if(QDELETED(src))
			return

		to_chat(user, span_notice("Мертвый чат больше не может контролировать [parent]."))
		log_admin("[key_name(user)] убрал контроль мертвого чата с [parent]")
		message_admins(span_notice("[key_name(user)] убрал контроль мертвого чата с [parent]"))

		qdel(src)

/// Сообщает осматривающим о доступных командах мертвого чата, текущем режиме работы и кулдаунах.
/datum/component/deadchat_control/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!isobserver(user))
		return

	examine_list += span_notice("[A.p_Theyre()] сейчас под контролем мертвого чата в режиме [(deadchat_mode & DEMOCRACY_MODE) ? "демократии" : "анархии"]!")

	if(deadchat_mode & DEMOCRACY_MODE)
		examine_list += span_notice("Введите команду в чат для голосования. Голосование происходит каждые [input_cooldown * 0.1] секунд.")
	else if(deadchat_mode & ANARCHY_MODE)
		examine_list += span_notice("Введите команду в чат для выполнения. Можно делать это каждые [input_cooldown * 0.1] секунд.")

	var/extended_examine = "<span class='notice'>Список команд:"

	for(var/possible_input in inputs)
		extended_examine += " [possible_input]"

	extended_examine += ".</span>"

	examine_list += extended_examine

/// Удаляет призрака из списка ckey_to_cooldown и сообщает ему, что он снова может отправлять команды.
/datum/component/deadchat_control/proc/end_cooldown(ghost_ckey)
	ckey_to_cooldown -= ghost_ckey
	var/mob/ghost = get_mob_by_ckey(ghost_ckey)
	if(!ghost || isliving(ghost))
		return
	to_chat(ghost, "[FOLLOW_LINK(ghost, parent)] <span class='nicegreen'>Кулдаун на управление [parent] через мертвый чат закончился.</span>")

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for a spicy
 * singularity or vomit goose.
 */
/datum/component/deadchat_control/cardinal_movement/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, NORTH)
	inputs["down"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, SOUTH)
	inputs["left"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, WEST)
	inputs["right"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, EAST)

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for spicy
 * immovable rod.
 */
/datum/component/deadchat_control/immovable_rod/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!istype(parent, /obj/effect/immovablerod))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), NORTH)
	inputs["down"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), SOUTH)
	inputs["left"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), WEST)
	inputs["right"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), EAST)
