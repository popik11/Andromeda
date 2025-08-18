/**Spontaneous Combustion
 * Slightly hidden.
 * Lowers resistance tremendously.
 * Decreases stage speed tremendously.
 * Decreases transmittability tremendously.
 * Fatal level
 * Bonus: Ignites infected mob.
 */

/datum/symptom/fire
	name = "Самовозгорание"
	desc = "Вирус преобразует жир в легковоспламеняющееся соединение и повышает температуру тела, заставляя носителя самовоспламеняться."
	illness = "Самовозгорание"
	stealth = -1
	resistance = -4
	stage_speed = -3
	transmittable = -4
	level = 6
	severity = 5
	base_message_chance = 20
	symptom_delay_min = 20
	symptom_delay_max = 75
	var/infective = FALSE
	threshold_descs = list(
		"Скорость 4" = "Усиливает интенсивность пламени.",
		"Скорость 8" = "Дальнейшее усиление пламени.",
		"Заразность 8" = "Носитель будет распространять вирус через частицы кожи при возгорании.",
		"Скрытность 4" = "Симптом остаётся скрытым до активации.",
	)

/datum/symptom/fire/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 4)
		power = 1.5
	if(A.totalStageSpeed() >= 8)
		power = 2
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalTransmittable() >= 8) //burning skin spreads the virus through smoke
		infective = TRUE

/datum/symptom/fire/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/living_mob = A.affected_mob
	switch(A.stage)
		if(1 to 2)
			return
		if(3)
			if(prob(base_message_chance) && !suppress_warning)
				warn_mob(living_mob)
		else
			var/advanced_stage = A.stage > 4
			living_mob.adjust_fire_stacks((advanced_stage ? 3 : 1) * power)
			living_mob.take_overall_damage(burn = ((advanced_stage ? 5 : 3) * power), required_bodytype = BODYTYPE_ORGANIC)
			living_mob.ignite_mob(silent = TRUE)
			if(living_mob.on_fire) // Проверяем действительно ли они загорелись или этого не произошло из-за влажности
				living_mob.visible_message(span_warning("[living_mob] вспыхивает!"), ignored_mobs = living_mob)
				to_chat(living_mob, span_userdanger((advanced_stage ? "Ваша кожа вспыхивает адским пламенем!" : "Ваша кожа внезапно загорается!")))
				living_mob.emote("scream")
			else if(!suppress_warning)
				warn_mob(living_mob)

			if(infective)
				A.airborne_spread(advanced_stage ? 4 : 2)

/datum/symptom/fire/proc/warn_mob(mob/living/living_mob)
	if(prob(33.33))
		living_mob.show_message(span_hear("Вы слышите потрескивание."), type = MSG_AUDIBLE)
	else
		if(HAS_TRAIT(living_mob, TRAIT_ANOSMIA)) // Обладатели особенности "Аносмия" не чувствуют запахов
			to_chat(living_mob, span_warning("Вам жарко."))
		else
			to_chat(living_mob, span_warning("[pick("Вам жарко.", "Вы чувствуете запах дыма.")]"))

/*
Alkali perspiration
	Hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmissibility.
	Fatal Level.
Bonus
	Ignites infected mob.
	Explodes mob on contact with water.
*/

/datum/symptom/alkali
	name = "Щелочная потливость"
	desc = "Вирус поражает потовые железы, синтезируя химическое вещество, которое воспламеняется при реакции с водой, приводя к самовозгоранию."
	illness = "Хрустящая кожа"
	stealth = 2
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 7
	severity = 6
	base_message_chance = 100
	symptom_delay_min = 30
	symptom_delay_max = 90
	var/chems = FALSE
	var/explosion_power = 1
	threshold_descs = list(
		"Устойчивость 9" = "Удваивает силу эффекта самовозгорания, но уменьшает частоту всех проявлений симптома.",
		"Скорость 8" = "Увеличивает радиус взрыва и урон от взрыва для носителя при контакте с водой.",
		"Заразность 8" = "Дополнительно синтезирует трифторид хлора и напалм в организме носителя. При выполнении порога устойчивости 9 синтезируется больше химикатов."
	)

/datum/symptom/alkali/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 9) //intense but sporadic effect
		power = 2
		symptom_delay_min = 50
		symptom_delay_max = 140
	if(A.totalStageSpeed() >= 8) //serious boom when wet
		explosion_power = 2
	if(A.totalTransmittable() >= 8) //extra chemicals
		chems = TRUE

/datum/symptom/alkali/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(3)
			if(prob(base_message_chance))
				to_chat(M, span_warning("[pick("Кровь в жилах кипит.", "Вам жарко.", "Пахнет жареным мясом.")]"))
		if(4)
			if(M.fire_stacks < 0)
				M.visible_message(span_warning("Пот [M] шипит и взрывается при контакте с водой!"))
				explosion(M, devastation_range = -1, heavy_impact_range = (-1 + explosion_power), light_impact_range = (2 * explosion_power), explosion_cause = src)
			Alkali_fire_stage_4(M, A)
			M.ignite_mob()
			to_chat(M, span_userdanger("Ваш пот вспыхивает пламенем!"))
			M.emote("scream")
		if(5)
			if(M.fire_stacks < 0)
				M.visible_message(span_warning("Пот [M] шипит и взрывается при контакте с водой!"))
				explosion(M, devastation_range = -1, heavy_impact_range = (-1 + explosion_power), light_impact_range = (2 * explosion_power), explosion_cause = src)
			Alkali_fire_stage_5(M, A)
			M.ignite_mob()
			to_chat(M, span_userdanger("Ваша кожа вспыхивает адским пламенем!"))
			M.emote("scream")

/datum/symptom/alkali/proc/Alkali_fire_stage_4(mob/living/M, datum/disease/advance/A)
	var/get_stacks = 6 * power
	M.adjust_fire_stacks(get_stacks)
	M.take_overall_damage(burn = get_stacks / 2, required_bodytype = BODYTYPE_ORGANIC)
	if(chems)
		M.reagents.add_reagent(/datum/reagent/clf3, 2 * power)
	return 1

/datum/symptom/alkali/proc/Alkali_fire_stage_5(mob/living/M, datum/disease/advance/A)
	var/get_stacks = 8 * power
	M.adjust_fire_stacks(get_stacks)
	M.take_overall_damage(burn = get_stacks, required_bodytype = BODYTYPE_ORGANIC)
	if(chems)
		M.reagents.add_reagent_list(list(/datum/reagent/napalm = 4 * power, /datum/reagent/clf3 = 4 * power))
	return 1
