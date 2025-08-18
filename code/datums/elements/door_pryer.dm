/**
 * Attached to a basic mob.
 * Causes attacks on doors to attempt to open them.
 */
/datum/element/door_pryer
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Time it takes to open a door with force
	var/pry_time
	/// Interaction key for if we force a door open
	var/interaction_key

/datum/element/door_pryer/Attach(datum/target, pry_time = 10 SECONDS, interaction_key = null)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.pry_time = pry_time
	src.interaction_key = interaction_key
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_attack))

/datum/element/door_pryer/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)

/// If we're targeting an airlock, open it
/datum/element/door_pryer/proc/on_attack(mob/living/basic/attacker, atom/target, proximity_flag)
	SIGNAL_HANDLER
	if(!proximity_flag || !istype(target, /obj/machinery/door/airlock))
		return NONE
	var/obj/machinery/door/airlock/airlock_target = target
	if (!airlock_target.density)
		return NONE // Уже открыто, болван

	if(DOING_INTERACTION_WITH_TARGET(attacker, target) || (!isnull(interaction_key) && DOING_INTERACTION(attacker, interaction_key)))
		attacker.balloon_alert(attacker, "занят!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (attacker.combat_mode)
		return // Атаковать дверь

	if (airlock_target.locked || airlock_target.welded || airlock_target.seal)
		airlock_target.balloon_alert(attacker, "запечатано!")
		attacker.log_message("Пытался вскрыть [src] в [loc_name(src)], но не смог из-за того, что шлюз запечатан.", LOG_GAME)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(open_door), attacker, airlock_target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Попытка открыть дверь, при неудаче - взломать
/datum/element/door_pryer/proc/open_door(mob/living/basic/attacker, obj/machinery/door/airlock/airlock_target)
	if (!airlock_target.hasPower())
		attacker.visible_message(span_warning("[attacker] взламывает [airlock_target]."))
		attacker.log_message("Вскрыл [src] в [loc_name(src)].", LOG_GAME)
		airlock_target.open(FORCING_DOOR_CHECKS)
		return

	if (airlock_target.allowed(attacker))
		airlock_target.open(DEFAULT_DOOR_CHECKS)
		return

	attacker.visible_message(\
		message = span_warning("[attacker] начинает взламывать [airlock_target]!"),
		blind_message = span_hear("Слышен скрежет металла."),
	)
	attacker.log_message("Начал вскрывать [src] в [loc_name(src)].", LOG_GAME)

	playsound(airlock_target, 'sound/machines/airlock/airlock_alien_prying.ogg', 100, TRUE)
	airlock_target.balloon_alert(attacker, "взлом...")
	if(!do_after(attacker, pry_time, airlock_target))
		airlock_target.balloon_alert(attacker, "прервано!")
		attacker.log_message("Попытка вскрыть [src] в [loc_name(src)] прервана.", LOG_GAME)
		return
	if(airlock_target.locked)
		attacker.log_message("Не удалось вскрыть [src] в [loc_name(src)] - шлюз заблокирован во время взлома.", LOG_GAME)
		return
	attacker.visible_message(span_warning("[attacker] взламывает [airlock_target]."))
	attacker.log_message("Успешно вскрыл [src] в [loc_name(src)].", LOG_GAME)
	airlock_target.open(BYPASS_DOOR_CHECKS)
	airlock_target.take_damage(AIRLOCK_PRY_DAMAGE, BRUTE, sound_effect = FALSE)
