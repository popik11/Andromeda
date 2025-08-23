/// Приоритет сверху вниз.
GLOBAL_LIST_INIT(sm_delam_list, list(
	/datum/sm_delam/cascade = new /datum/sm_delam/cascade,
	/datum/sm_delam/singularity = new /datum/sm_delam/singularity,
	/datum/sm_delam/tesla = new /datum/sm_delam/tesla,
	/datum/sm_delam/explosive = new /datum/sm_delam/explosive,
))

/// Держатель логики для делимитации суперматерии, использует стратегический шаблон проектирования.
/// Выбирается через [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam

/// Подходим ли мы для этой делимитации или нет. TRUE если valid, FALSE если нет.
/// [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam/proc/can_select(obj/machinery/power/supermatter_crystal/sm)
	return FALSE

#define ROUNDCOUNT_ENGINE_JUST_EXPLODED -1

/// Вызывается, когда отсчёт завершён, выполняет грязную работу.
/// [/obj/machinery/power/supermatter_crystal/proc/count_down]
/datum/sm_delam/proc/delaminate(obj/machinery/power/supermatter_crystal/sm)
	if (sm.is_main_engine)
		SSpersistence.delam_highscore = SSpersistence.rounds_since_engine_exploded
		SSpersistence.rounds_since_engine_exploded = ROUNDCOUNT_ENGINE_JUST_EXPLODED
		for (var/obj/machinery/incident_display/sign as anything in GLOB.map_incident_displays)
			sign.update_delam_count(ROUNDCOUNT_ENGINE_JUST_EXPLODED)
	qdel(sm)

#undef ROUNDCOUNT_ENGINE_JUST_EXPLODED

/// Что мы должны делать, когда делимитация в процессе.
/// В основном просто сообщаем людям о бесполезности инженеров и проигрываем тревожные звуки.
/// Возвращает TRUE, если мы только что сообщили о делимитации. FALSE, если происходит восстановление или мы ничего не сказали.
/// [/obj/machinery/power/supermatter_crystal/proc/process_atmos]
/datum/sm_delam/proc/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(sm.damage <= sm.warning_point) // Урон слишком низкий, давайте не будем
		return FALSE

	if (sm.damage >= sm.emergency_point && sm.damage_archived < sm.emergency_point)
		sm.investigate_log("достиг аварийной точки.", INVESTIGATE_ENGINE)
		message_admins("[sm] достиг аварийной точки [ADMIN_VERBOSEJMP(sm)].")

	if((REALTIMEOFDAY - sm.lastwarning) < SUPERMATTER_WARNING_DELAY)
		return FALSE
	sm.lastwarning = REALTIMEOFDAY

	if(sm.damage_archived - sm.damage > SUPERMATTER_FAST_HEALING_RATE && sm.damage_archived >= sm.emergency_point) // Быстрое восстановление, инженеры скорее всего всё починили
		if(sm.should_alert_common()) // Оповещаем общий канал раз за период кулдауна, иначе инженерный
			sm.radio.talk_into(sm,"Кристаллическая гиперструктура возвращается к безопасным рабочим параметрам. Целостность: [round(sm.get_integrity_percent(), 0.01)]%", sm.emergency_channel)
		else
			sm.radio.talk_into(sm,"Кристаллическая гиперструктура возвращается к безопасным рабочим параметрам. Целостность: [round(sm.get_integrity_percent(), 0.01)]%", sm.warning_channel)
		playsound(sm, 'sound/machines/terminal/terminal_alert.ogg', 75)
		return FALSE

	switch(sm.get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(sm, 'sound/announcer/alarm/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(SUPERMATTER_EMERGENCY)
			playsound(sm, 'sound/machines/engine_alert/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_DANGER)
			playsound(sm, 'sound/machines/engine_alert/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_WARNING)
			playsound(sm, 'sound/machines/terminal/terminal_alert.ogg', 75)

	if(sm.damage >= sm.emergency_point) // В аварийном режиме
		sm.radio.talk_into(sm, "ДЕЛИМИТАЦИЯ КРИСТАЛЛА НЕИЗБЕЖНА! Целостность: [round(sm.get_integrity_percent(), 0.01)]%", sm.emergency_channel)
		sm.lastwarning = REALTIMEOFDAY - (SUPERMATTER_WARNING_DELAY / 2) // Уменьшаем время до следующего объявления вдвое.
	else if(sm.damage_archived > sm.damage) // Восстановление, в режиме предупреждения
		sm.radio.talk_into(sm,"Кристаллическая гиперструктура возвращается к безопасным рабочим параметрам. Целостность: [round(sm.get_integrity_percent(), 0.01)]%", sm.warning_channel)
		return FALSE
	else // Получение урона, в режиме предупреждения
		sm.radio.talk_into(sm, "Опасность! Целостность кристаллической гиперструктуры нарушена! Целостность: [round(sm.get_integrity_percent(), 0.01)]%", sm.warning_channel)

	SEND_SIGNAL(sm, COMSIG_SUPERMATTER_DELAM_ALARM)
	return TRUE

/// Вызывается, когда суперматерия переключает свою стратегию с другой на нас.
/// [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam/proc/on_select(obj/machinery/power/supermatter_crystal/sm)
	return

/// Вызывается, когда суперматерия переключает свою стратегию с нас на другую.
/// [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam/proc/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	return

/// Добавлено к возвращаемому значению examine.
/// [/obj/machinery/power/supermatter_crystal/examine]
/datum/sm_delam/proc/examine(obj/machinery/power/supermatter_crystal/sm)
	return list()

/// Добавляет любой оверлей к СМ.
/// [/obj/machinery/power/supermatter_crystal/update_overlays]
/datum/sm_delam/proc/overlays(obj/machinery/power/supermatter_crystal/sm)
	if(sm.final_countdown)
		return list(mutable_appearance(icon = sm.icon, icon_state = "causality_field", layer = FLOAT_LAYER))
	return list()

/// Применяет фильтры к СМ.
/// [/obj/machinery/power/supermatter_crystal/process_atmos]
/datum/sm_delam/proc/filters(obj/machinery/power/supermatter_crystal/sm)
	var/new_filter = isnull(sm.get_filter("ray"))

	sm.add_filter(name = "ray", priority = 1, params = list(
		type = "rays",
		size = clamp(sm.internal_energy / 50, 1, 100),
		color = (sm.gas_heat_power_generation > 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR),
		factor = clamp(sm.damage / 10, 1, 10),
		density = clamp(sm.damage, 12, 100)
	))

	// Анимация фильтра сохраняется, даже если сам фильтр изменён извне.
	// Вероятно, склонно к поломкам. Относитесь с подозрением.
	if(new_filter)
		animate(sm.get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)

// Изменяет яркость камня.
/// [/obj/machinery/power/supermatter_crystal/process_atmos]
/datum/sm_delam/proc/lights(obj/machinery/power/supermatter_crystal/sm)
	sm.set_light(
		l_range = ROUND_UP(clamp(sm.internal_energy / 500, 4, 10)),
		l_power = ROUND_UP(clamp(sm.internal_energy / 1000, 1, 5)),
		l_color = sm.gas_heat_power_generation > 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR,
		l_on = !!sm.internal_energy,
	)

/// Возвращает набор сообщений для озвучивания во время делимитации
/// Первое сообщение - начало отсчета, второе - отмена отсчета (если СМ восстановлен), третье - 5-секундные интервалы
/datum/sm_delam/proc/count_down_messages(obj/machinery/power/supermatter_crystal/sm)
	var/list/messages = list()
	messages += "ДЕЛИМИТАЦИЯ КРИСТАЛЛА НЕИЗБЕЖНА! Суперматерия достигла критического уровня целостности!"
	messages += "Кристаллическая гиперструктура возвращается к безопасным рабочим параметрам."
	messages += "до полной делимитации."
	return messages
