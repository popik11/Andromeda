/datum/security_level
	/// Задержка перед установкой этого уровня безопасности
	var/set_delay = 0

/// Вызывается перед установкой или планированием установки уровня безопасности
/datum/security_level/proc/pre_set_security_level(mob/user)
	return

/// Вызывается после установки уровня безопасности, прямо перед отправкой `COMSIG_SECURITY_LEVEL_CHANGED`
/datum/security_level/proc/post_set_security_level(mob/user)
	return


/**
 * ГАММА
 *
 * Пора решать проблемы большим дядям
 */
/datum/security_level/gamma
	name = "гамма"
	name_shortform = "GAM"
	announcement_color = "orange"
	sound = 'modular_andromeda/sound/announcer/security_levels/gamma.ogg'
	number_level = SEC_LEVEL_GAMMA
	status_display_icon_state = "gammaalert"
	fire_alarm_light_color = LIGHT_COLOR_ORANGE
	lowering_to_configuration_key = /datum/config_entry/string/alert_gamma
	elevating_to_configuration_key = /datum/config_entry/string/alert_gamma
	shuttle_call_time_mod = ALERT_COEFF_RED

/datum/config_entry/string/alert_gamma
	default = "Центральным Командованием был установлен Код ГАММА. Служба безопасности должна быть полностью вооружена. Гражданский персонал обязан немедленно обратиться к главам отделов для получения дальнейших указаний."


/**
 * ЭПСИЛОН
 *
 * Эскодрон опиздюливания
 */
/datum/security_level/epsilon
	name = "эпсилон"
	name_shortform = "EPS"
	announcement_color = "purple"
	sound = 'modular_andromeda/sound/announcer/security_levels/epsilon.ogg'
	number_level = SEC_LEVEL_EPSILON
	status_display_icon_state = "epsilonalert"
	fire_alarm_light_color = LIGHT_COLOR_PURPLE
	lowering_to_configuration_key = /datum/config_entry/string/alert_epsilon
	elevating_to_configuration_key = /datum/config_entry/string/alert_epsilon
	shuttle_call_time_mod = 10
	set_delay = 15 SECONDS

/datum/config_entry/string/alert_epsilon
	default = "Центральным Командованием был установлен код ЭПСИЛОН. Все контракты расторгнуты."

/datum/security_level/epsilon/pre_set_security_level()
	// Небольшое вступление, которое проигрывается перед фактическим показом кода
	sound_to_playing_players('modular_andromeda/sound/announcer/event/powerloss.ogg', 70)
	power_fail(set_delay, set_delay)

/datum/security_level/epsilon/post_set_security_level()
	for(var/obj/machinery/light/light_to_update as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
		if(is_station_level(light_to_update.z))
			light_to_update.set_major_emergency_light()
		CHECK_TICK

	for(var/obj/machinery/power/apc/current_apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(!current_apc.cell || !SSmapping.level_trait(current_apc.z, ZTRAIT_STATION))
			continue

		var/area/apc_area = current_apc.area
		if(is_type_in_typecache(apc_area, GLOB.typecache_powerfailure_safe_areas))
			continue

		current_apc.reboot()
		CHECK_TICK
