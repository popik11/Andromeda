/atom/movable
	// Звуки текстовых баркков
	// да. все атомы могут "высказаться".
	var/sound/blooper
	var/blooper_id
	var/blooper_pitch = 1
	var/blooper_pitch_range = 0.2 //Фактическая высота тона от (pitch - (blooper_pitch_range*0.5)) до (pitch + (blooper_pitch_range*0.5))
	var/blooper_volume = 50
	var/blooper_speed = 4 //Меньшие значения быстрее, большие значения медленнее
	var/blooper_current_blooper //Когда баркки ставятся в очередь, это передается в процедуру барка. Если blooper_current_blooper не совпадает с аргументами, переданными в процедуру барка (если они вообще передаются), то барк просто не проигрывается. Базовое ограничение спама

/atom/movable/proc/set_blooper(id)
	if(!id)
		return FALSE
	var/datum/blooper/B = GLOB.blooper_list[id]
	if(!B)
		return FALSE
	blooper = sound(initial(B.soundpath))
	blooper_id = id
	return blooper

/atom/movable/proc/blooper(list/listeners, distance, volume, pitch, queue_time)
	if(!GLOB.blooper_allowed)
		return
	if(queue_time && blooper_current_blooper != queue_time)
		return
	if(!blooper)
		if(!blooper_id || !set_blooper(blooper_id)) //just-in-time генерация барков
			return
	volume = min(volume, 100)
	var/turf/T = get_turf(src)
	for(var/mob/M in listeners)
		M.playsound_local(T, vol = volume, vary = TRUE, frequency = pitch, max_distance = distance, falloff_distance = 0, falloff_exponent = BLOOPER_SOUND_FALLOFF_EXPONENT, sound_to_use = blooper, distance_multiplier = 1)

/atom/movable/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language, list/message_mods = list(), forced = FALSE, tts_message, list/tts_filter)
	. = ..()
	var/list/listeners = get_hearers_in_view(range, source)
	if(blooper || blooper_id)
		for(var/mob/M in listeners)
			if(!M.client)
				continue
			if(!(M.client.prefs?.read_preference(/datum/preference/toggle/hear_sound_blooper)))
				listeners -= M
		var/bloopers = min(round((LAZYLEN(message) / blooper_speed)) + 1, BLOOPER_MAX_BLOOPERS)
		var/total_delay
		blooper_current_blooper = world.time //это нааааастолько случайно, чтобы быть уникальным каждый раз при вызове send_speech() в большинстве сценариев
		for(var/i in 1 to bloopers)
			if(total_delay > BLOOPER_MAX_TIME)
				break
			addtimer(CALLBACK(src, PROC_REF(blooper), listeners, range, blooper_volume, BLOOPER_DO_VARY(blooper_pitch, blooper_pitch_range), blooper_current_blooper), total_delay)
			total_delay += rand(DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE), DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE) + DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE)) TICKS

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	// Это дает случайный вокальный барк случайно созданному человеку
	if(!client)
		set_blooper(pick(GLOB.blooper_list))
		blooper_pitch = BLOOPER_PITCH_RAND(gender)
		blooper_pitch_range = BLOOPER_VARIANCE_RAND
		blooper_speed = rand(BLOOPER_DEFAULT_MINSPEED, BLOOPER_DEFAULT_MAXSPEED)

/randomize_human(mob/living/carbon/human/human, randomize_mutations = FALSE)
	. = ..()
	human.set_blooper(pick(GLOB.blooper_list))
	human.blooper_pitch = BLOOPER_PITCH_RAND(human.gender)
	human.blooper_pitch_range = BLOOPER_VARIANCE_RAND
	human.blooper_speed = rand(BLOOPER_DEFAULT_MINSPEED, BLOOPER_DEFAULT_MAXSPEED)

/mob/living/send_speech(message_raw, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language = null, list/message_mods = list(), forced = null, tts_message, list/tts_filter)
	. = ..()
	if(client)
		if(!(client.prefs.read_preference(/datum/preference/toggle/send_sound_blooper)))
			return
	blooper_volume = client?.prefs.read_preference(/datum/preference/numeric/sound_blooper_volume) //громкость масштабируется с ползунком громкости в настройках игры.
	if(HAS_TRAIT(src, TRAIT_SIGN_LANG) && !HAS_TRAIT(src, TRAIT_MUTE)) //если вы можете говорить и используете язык жестов, ваши руки не издают барка. Если вы полностью немой, вы можете иметь некоторый ручной лай.
		return
	if(message_mods[WHISPER_MODE])
		blooper_volume = (client?.prefs.read_preference(/datum/preference/numeric/sound_blooper_volume)*0.5) //Шепотные лаи в два раза тише.
		message_range++
	var/list/listening = get_hearers_in_view(message_range, source)
	var/is_yell = (say_test(message_raw) == "2")
	//Listening обрезается здесь, если присутствует блипер. Если кто-то заставит эту процедуру возвращать listening, убедитесь, что вместо этого инициализируется копия listening здесь, чтобы избежать странностей
	if(blooper || blooper_id)
		for(var/mob/M in listening)
			if(!M.client)
				continue
			if(!(M.client.prefs?.read_preference(/datum/preference/toggle/hear_sound_blooper)))
				listening -= M
		var/bloopers = min(round((LAZYLEN(message_raw) / blooper_speed)) + 1, BLOOPER_MAX_BLOOPERS)
		var/total_delay
		blooper_current_blooper = world.time
		for(var/i in 1 to bloopers)
			if(total_delay > BLOOPER_MAX_TIME)
				break
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, blooper), listening, message_range + 1, (blooper_volume * (is_yell ? 2 : 1)), BLOOPER_DO_VARY(blooper_pitch, blooper_pitch_range), blooper_current_blooper), total_delay) //Функция равна нулю на седьмой плитке. Это делает ее максимум на 1 больше.
			total_delay += rand(DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE), DS2TICKS(blooper_speed / BLOOPER_SPEED_BASELINE) + DS2TICKS((blooper_speed / BLOOPER_SPEED_BASELINE) * (is_yell ? 0.5 : 1))) TICKS
