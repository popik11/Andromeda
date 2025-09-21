/*

Passive gate is similar to the regular pump except:
* It doesn't require power
* Can not transfer low pressure to higher pressure (so it's more like a valve where you can control the flow)
* Passes gas when output pressure lower than target pressure

*/

/obj/machinery/atmospherics/components/binary/passive_gate
	icon_state = "passgate_map-3"
	name = "passive gate"
	desc = "Односторонний воздушный клапан, не требующий питания. Пропускает газ, когда выходное давление ниже целевого давления."
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	construction_type = /obj/item/pipe/directional
	pipe_state = "passivegate"
	use_power = NO_POWER_USE
	///Set the target pressure the component should arrive to
	var/target_pressure = ONE_ATMOSPHERE

/obj/machinery/atmospherics/components/binary/passive_gate/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/atmospherics/components/binary/passive_gate/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Включить [on ? "выкл" : "вкл"]"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Максимизировать целевое давление"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/binary/passive_gate/click_ctrl(mob/user)
	if(is_operational)
		set_on(!on)
		balloon_alert(user, "переключён [on ? "вкл" : "выкл"]")
		investigate_log("был переключён [on ? "вкл" : "выкл"] пользователем [key_name(user)]", INVESTIGATE_ATMOS)
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/machinery/atmospherics/components/binary/passive_gate/click_alt(mob/user)
	if(target_pressure == MAX_OUTPUT_PRESSURE)
		return CLICK_ACTION_BLOCKING

	target_pressure = MAX_OUTPUT_PRESSURE
	investigate_log("был установлен на [target_pressure] кПа пользователем [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "выходное давление установлено на [target_pressure] кПа")
	update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/binary/passive_gate/update_icon_nopipes()
	cut_overlays()
	icon_state = "passgate_off-[set_overlay_offset(piping_layer)]"
	if(on)
		add_overlay(get_pipe_image(icon, "passgate_on-[set_overlay_offset(piping_layer)]"))

/obj/machinery/atmospherics/components/binary/passive_gate/process_atmos()
	if(!on)
		return

	var/datum/gas_mixture/input_air = airs[1]
	var/datum/gas_mixture/output_air = airs[2]
	var/datum/gas_mixture/output_pipenet_air = parents[2].air

	if(input_air.release_gas_to(output_air, target_pressure, output_pipenet_air = output_pipenet_air))
		update_parents()

/obj/machinery/atmospherics/components/binary/passive_gate/relaymove(mob/living/user, direction)
	if(!on || direction != dir)
		return
	. = ..()

/obj/machinery/atmospherics/components/binary/passive_gate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/passive_gate/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)
	return data

/obj/machinery/atmospherics/components/binary/passive_gate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("был переключён [on ? "вкл" : "выкл"] пользователем [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = MAX_OUTPUT_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(pressure, 0, ONE_ATMOSPHERE*100)
				investigate_log("был установлен на [target_pressure] кПа пользователем [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/binary/passive_gate/can_unwrench(mob/user)
	. = ..()
	if(. && on)
		to_chat(user, span_warning("Вы не можете открутить [declent_ru(NOMINATIVE)], сначала выключите его!"))
		return FALSE


/obj/machinery/atmospherics/components/binary/passive_gate/layer2
	piping_layer = 2
	icon_state = "passgate_map-2"

/obj/machinery/atmospherics/components/binary/passive_gate/layer4
	piping_layer = 4
	icon_state = "passgate_map-4"
