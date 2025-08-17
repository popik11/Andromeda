/datum/brain_trauma/mild/phobia
	name = "Фобия"
	desc = "Пациент испытывает необоснованный страх перед чем-либо."
	scan_desc = "фобия"
	gain_text = span_warning("Вы начинаете находить стандартные значения очень тревожными...")
	lose_text = span_notice("Вы больше не боитесь стандартных значений.")
	var/phobia_type
	/// Кулдаун проверки близости, чтобы не спамить проверкой радиуса 7 каждые две секунды
	COOLDOWN_DECLARE(check_cooldown)
	/// Кулдаун приступов страха, чтобы не пермастанить игрока
	COOLDOWN_DECLARE(scare_cooldown)

	/// Какое событие настроения применять при виде объекта страха
	var/datum/mood_event/mood_event_type = /datum/mood_event/phobia

	var/regex/trigger_regex
	// Вместо перебора всех атомов, проверяем только релевантные типы
	var/list/trigger_mobs
	var/list/trigger_objs // также проверяется экипировка мобов
	var/list/trigger_turfs
	var/list/trigger_species

/datum/brain_trauma/mild/phobia/New(new_phobia_type)
	if(new_phobia_type)
		phobia_type = new_phobia_type

	if(!phobia_type)
		phobia_type = pick(GLOB.phobia_types)

	gain_text = span_warning("Вы начинаете находить [phobia_type] очень тревожными...")
	lose_text = span_notice("Вы больше не боитесь [phobia_type].")
	scan_desc += " к [phobia_type]"
	trigger_regex = GLOB.phobia_regexes[phobia_type]
	trigger_mobs = GLOB.phobia_mobs[phobia_type]
	trigger_objs = GLOB.phobia_objs[phobia_type]
	trigger_turfs = GLOB.phobia_turfs[phobia_type]
	trigger_species = GLOB.phobia_species[phobia_type]
	..()

/datum/brain_trauma/mild/phobia/on_lose(silent)
	owner.clear_mood_event("phobia_[phobia_type]")
	return ..()

/datum/brain_trauma/mild/phobia/on_life(seconds_per_tick, times_fired)
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(owner.is_blind())
		return

	if(!COOLDOWN_FINISHED(src, check_cooldown) || !COOLDOWN_FINISHED(src, scare_cooldown))
		return

	COOLDOWN_START(src, check_cooldown, 5 SECONDS)
	var/list/seen_atoms = view(7, owner)
	if(LAZYLEN(trigger_objs))
		for(var/obj/seen_item in seen_atoms)
			if(is_scary_item(seen_item))
				freak_out(seen_item)
				return

	if(LAZYLEN(trigger_turfs))
		for(var/turf/checked in seen_atoms)
			if(is_type_in_typecache(checked, trigger_turfs))
				freak_out(checked)
				return

	seen_atoms -= owner //make sure they aren't afraid of themselves.
	if(LAZYLEN(trigger_mobs) || LAZYLEN(trigger_species) || LAZYLEN(trigger_objs))
		for(var/mob/living/checked in seen_atoms)
			if (is_scary_mob(checked))
				freak_out(checked)
				return

/// Returns true if this item should be scary to us
/datum/brain_trauma/mild/phobia/proc/is_scary_item(obj/checked)
	if (QDELETED(checked) || !is_type_in_typecache(checked, trigger_objs) || checked.invisibility > owner.see_invisible)
		return FALSE
	if (!isitem(checked))
		return TRUE
	var/obj/item/checked_item = checked
	return !HAS_TRAIT(checked_item, TRAIT_EXAMINE_SKIP)

/datum/brain_trauma/mild/phobia/proc/is_scary_mob(mob/living/checked)
	if(is_type_in_typecache(checked, trigger_mobs))
		return TRUE

	if (!ishuman(checked))
		return FALSE

	var/mob/living/carbon/human/as_human = checked
	if (LAZYLEN(trigger_species))
		if (is_type_in_typecache(as_human.dna?.species, trigger_species))
			return TRUE

	if (!LAZYLEN(trigger_objs))
		return FALSE

	for(var/obj/item/equipped as anything in as_human.get_visible_items())
		if(is_scary_item(equipped))
			return TRUE

	return FALSE

/datum/brain_trauma/mild/phobia/handle_hearing(datum/source, list/hearing_args)
	if(!owner.can_hear() || owner == hearing_args[HEARING_SPEAKER] || !owner.has_language(hearing_args[HEARING_LANGUAGE])) 	//words can't trigger you if you can't hear them *taps head*
		return

	if(HAS_TRAIT(owner, TRAIT_FEARLESS) || !COOLDOWN_FINISHED(src, scare_cooldown))
		return

	if(trigger_regex.Find(hearing_args[HEARING_RAW_MESSAGE]) != 0)
		addtimer(CALLBACK(src, PROC_REF(freak_out), null, trigger_regex.group[2]), 1 SECONDS) //to react AFTER the chat message
		hearing_args[HEARING_RAW_MESSAGE] = trigger_regex.Replace(hearing_args[HEARING_RAW_MESSAGE], "[span_phobia("$2")]$3")

/datum/brain_trauma/mild/phobia/handle_speech(datum/source, list/speech_args)
	if (HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if (trigger_regex.Find(speech_args[SPEECH_MESSAGE]) == 0)
		return

	var/stutter = prob(50)
	var/whisper = prob(30)

	if (!stutter && !whisper)
		return

	if (whisper)
		speech_args[SPEECH_SPANS] |= SPAN_SMALL_VOICE
	if (stutter)
		owner.set_stutter_if_lower(4 SECONDS)
	to_chat(owner, span_warning("Вы с трудом произносите слово \"[span_phobia("[trigger_regex.group[2]]")]\"!"))

/datum/brain_trauma/mild/phobia/proc/freak_out(atom/reason, trigger_word)
	if(owner.stat == DEAD)
		return

	var/message = pick("начинаете паниковать", "ощущаете страх", "ощущаете дрожь своего тела", "ощущаете холодок, что прошол по вашей спине")
	if(trigger_word)
		if (owner.has_status_effect(/datum/status_effect/minor_phobia_reaction))
			return
		to_chat(owner, span_userdanger("Услышав [span_phobia(trigger_word)], вы [message]!"))
		owner.apply_status_effect(/datum/status_effect/minor_phobia_reaction)
		return

	COOLDOWN_START(src, scare_cooldown, 12 SECONDS)
	if(mood_event_type)
		owner.add_mood_event("phobia_[phobia_type]", mood_event_type)

	if(reason)
		to_chat(owner, span_userdanger("Увидев [span_phobia(reason.name)] [message]!"))
//	else
//		to_chat(owner, span_userdanger("Что-то [message]!"))  /// Rewokin: под Русскую локализацию так себе идёт. Если кто-то сможет найти вариант лучше, с использованием этих строчек, то будет круто :)

	if(reason)
		owner.face_atom(reason)
		owner._pointed(reason)
	owner.apply_status_effect(/datum/status_effect/stacking/phobia_reaction, 1, mood_event_type)

// Defined phobia types for badminry, not included in the RNG trauma pool to avoid diluting.

/datum/brain_trauma/mild/phobia/aliens
	phobia_type = "aliens"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/anime
	phobia_type = "anime"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/authority
	phobia_type = "authority"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/birds
	phobia_type = "birds"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/blood
	phobia_type = "blood"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/blood/is_scary_item(obj/checked)
	if (GET_ATOM_BLOOD_DNA_LENGTH(checked))
		return TRUE
	return ..()

/datum/brain_trauma/mild/phobia/clowns
	phobia_type = "clowns"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/conspiracies
	phobia_type = "conspiracies"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/doctors
	phobia_type = "doctors"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/falling
	phobia_type = "falling"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/fish
	phobia_type = "fish"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/greytide
	phobia_type = "greytide"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/guns
	phobia_type = "guns"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/insects
	phobia_type = "insects"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/lizards
	phobia_type = "lizards"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/ocky_icky
	phobia_type = "ocky icky"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/robots
	phobia_type = "robots"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/security
	phobia_type = "security"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/skeletons
	phobia_type = "skeletons"
	mood_event_type = /datum/mood_event/spooked
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/snakes
	phobia_type = "snakes"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/space
	phobia_type = "space"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/spiders
	phobia_type = "spiders"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/strangers
	phobia_type = "strangers"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/supernatural
	phobia_type = "the supernatural"
	random_gain = FALSE
