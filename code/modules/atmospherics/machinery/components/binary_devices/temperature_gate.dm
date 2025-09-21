/obj/machinery/atmospherics/components/binary/temperature_gate
	icon_state = "tgate_map-3"
	name = "temperature gate"
	desc = "Активируемый клапан, который сравнивает входную температуру с температурой, установленной в интерфейсе, чтобы определить, может ли газ протекать от входной стороны к выходной или нет."
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	construction_type = /obj/item/pipe/directional
	pipe_state = "tgate"
	///If the temperature of the mix before the gate is lower than this, the gas will flow (if inverted, if the temperature of the mix before the gate is higher than this)
	var/target_temperature = T0C
	///Minimum allowed temperature
	var/minimum_temperature = TCMB
	///Maximum allowed temperature to be set
	var/max_temperature = 4500
	///Check if the sensor should let gas pass if temperature in the mix is less/higher than the target one
	var/inverted = FALSE
	///Check if the gas is moving from one pipenet to the other
	var/is_gas_flowing = FALSE

/obj/machinery/atmospherics/components/binary/temperature_gate/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/atmospherics/components/binary/temperature_gate/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Включить [on ? "выкл" : "вкл"]"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Максимизировать целевую температуру"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/binary/temperature_gate/click_ctrl(mob/user)
	if(is_operational)
		set_on(!on)
		balloon_alert(user, "переключён [on ? "вкл" : "выкл"]")
		investigate_log("был переключён [on ? "вкл" : "выкл"] пользователем [key_name(user)]", INVESTIGATE_ATMOS)
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/machinery/atmospherics/components/binary/temperature_gate/click_alt(mob/user)
	if(target_temperature == max_temperature)
		return CLICK_ACTION_BLOCKING

	target_temperature = max_temperature
	investigate_log("был установлен на [target_temperature] K пользователем [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "целевая температура установлена на [target_temperature] K")
	update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS


/obj/machinery/atmospherics/components/binary/temperature_gate/examine(mob/user)
	. = ..()
	. += "Это устройство будет пропускать газ, если температура газа на входе [inverted ? "выше" : "ниже"], чем температура, установленная в интерфейсе."
	if(inverted)
		. += "Настройки устройства можно восстановить, используя мультитул на нём."
	else
		. += "Настройки датчика можно изменить, используя мультитул на устройстве."

/obj/machinery/atmospherics/components/binary/temperature_gate/update_icon_nopipes()
	if(on && is_operational && is_gas_flowing)
		icon_state = "tgate_flow-[set_overlay_offset(piping_layer)]"
	else if(on && is_operational && !is_gas_flowing)
		icon_state = "tgate_on-[set_overlay_offset(piping_layer)]"
	else
		icon_state = "tgate_off-[set_overlay_offset(piping_layer)]"


/obj/machinery/atmospherics/components/binary/temperature_gate/process_atmos()
	if(!on || !is_operational)
		return

	var/datum/gas_mixture/input_air = airs[1]
	var/datum/gas_mixture/output_air = airs[2]
	var/datum/gas_mixture/output_pipenet_air = parents[2].air

	if(!inverted)
		if(input_air.temperature < target_temperature)
			if(input_air.release_gas_to(output_air, input_air.return_pressure(), output_pipenet_air = output_pipenet_air))
				update_parents()
				is_gas_flowing = TRUE
		else
			is_gas_flowing = FALSE
	else
		if(input_air.temperature > target_temperature)
			if(input_air.release_gas_to(output_air, input_air.return_pressure(), output_pipenet_air = output_pipenet_air))
				update_parents()
				is_gas_flowing = TRUE
		else
			is_gas_flowing = FALSE
	update_icon_nopipes()

/obj/machinery/atmospherics/components/binary/temperature_gate/relaymove(mob/living/user, direction)
	if(!on || direction != dir)
		return
	. = ..()

/obj/machinery/atmospherics/components/binary/temperature_gate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosTempGate", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/temperature_gate/ui_data()
	var/data = list()
	data["on"] = on
	data["temperature"] = round(target_temperature)
	data["min_temperature"] = round(minimum_temperature)
	data["max_temperature"] = round(max_temperature)
	return data

/obj/machinery/atmospherics/components/binary/temperature_gate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			set_on(!on)
			investigate_log("был переключён [on ? "вкл" : "выкл"] пользователем [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("temperature")
			var/temperature = params["temperature"]
			if(temperature == "max")
				temperature = max_temperature
				. = TRUE
			else if(text2num(temperature) != null)
				temperature = text2num(temperature)
				. = TRUE
			if(.)
				target_temperature = clamp(minimum_temperature, temperature, max_temperature)
				investigate_log("был установлен на [target_temperature] K пользователем [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/binary/temperature_gate/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, span_warning("Вы не можете открутить [declent_ru(NOMINATIVE)], сначала выключите его!"))
		return FALSE

/obj/machinery/atmospherics/components/binary/temperature_gate/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if (istype(I))
		inverted = !inverted
		if(inverted)
			to_chat(user, span_notice("Вы настраиваете датчики [declent_ru(NOMINATIVE)] на выпуск газов при температуре выше установленной."))
		else
			to_chat(user, span_notice("Вы сбрасываете датчики [declent_ru(NOMINATIVE)] к настройкам по умолчанию."))
	return TRUE

//mapping

/obj/machinery/atmospherics/components/binary/temperature_gate/layer2
	piping_layer = 2
	icon_state = "tgate_map-2"

/obj/machinery/atmospherics/components/binary/temperature_gate/layer4
	piping_layer = 4
	icon_state = "tgate_map-4"
