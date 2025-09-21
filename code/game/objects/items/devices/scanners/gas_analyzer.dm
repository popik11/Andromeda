/obj/item/analyzer
	desc = "Портативный сканер окружающей среды, который показывает текущие уровни газов."
	name = "gas analyzer"
	custom_price = PAYCHECK_LOWER * 0.9
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "analyzer"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	tool_behaviour = TOOL_ANALYZER
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 0.2)
	grind_results = list(/datum/reagent/mercury = 5, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	interaction_flags_click = NEED_LITERACY|NEED_LIGHT|ALLOW_RESTING
	pickup_sound = 'sound/items/handling/gas_analyzer/gas_analyzer_pickup.ogg'
	drop_sound = 'sound/items/handling/gas_analyzer/gas_analyzer_drop.ogg'
	/// Boolean whether this has a CD
	var/cooldown = FALSE
	/// The time in deciseconds
	var/cooldown_time = 25 SECONDS
	/// 0 is best accuracy
	var/barometer_accuracy
	/// Cached gasmix data from ui_interact
	var/list/last_gasmix_data
	/// Max scan distance
	var/ranged_scan_distance = 1

/obj/item/analyzer/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TOOL_ATOM_ACTED_PRIMARY(tool_behaviour), PROC_REF(on_analyze))

	if(type != /obj/item/analyzer)
		return
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/material_sniffer)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/analyzer/equipped(mob/user, slot, initial)
	. = ..()
	ADD_TRAIT(user, TRAIT_DETECT_STORM, CLOTHING_TRAIT)

/obj/item/analyzer/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_DETECT_STORM, CLOTHING_TRAIT)

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += span_notice("Правый клик по [src], чтобы открыть справочник по газам.")
	. += span_notice("Alt+ЛКМ по [src], чтобы активировать функцию барометра.")

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] начинает анализировать [user.p_them()] себя с помощью [src]! Дисплей показывает, что [user.p_theyre()] мёртв!"))
	return BRUTELOSS

/obj/item/analyzer/click_alt(mob/user) //Показания барометра для измерения времени следующего шторма
	if(cooldown)
		to_chat(user, span_warning("Функция барометра [src] готовится к работе."))
		return CLICK_ACTION_BLOCKING

	var/turf/T = get_turf(user)
	if(!T)
		return CLICK_ACTION_BLOCKING

	playsound(src, 'sound/effects/pop.ogg', 100)
	var/area/user_area = T.loc
	var/datum/weather/ongoing_weather = null

	if(!user_area.outdoors)
		to_chat(user, span_warning("Функция барометра [src] не работает в помещении!"))
		return CLICK_ACTION_BLOCKING

	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if((W.weather_flags & WEATHER_BAROMETER) && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
			ongoing_weather = W
			break

	if(ongoing_weather)
		if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
			to_chat(user, span_warning("Функция барометра [src] не может ничего отследить, пока шторм [ongoing_weather.stage == MAIN_STAGE ? "уже здесь!" : "затихает."]"))
			return CLICK_ACTION_BLOCKING

		to_chat(user, span_notice("Следующий [ongoing_weather] начнётся через [butchertime(ongoing_weather.next_hit_time - world.time)]."))
		if(!(ongoing_weather.weather_flags & FUNCTIONAL_WEATHER))
			to_chat(user, span_warning("Функция барометра [src] сообщает, что следующий шторм пройдёт стороной."))
	else
		var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
		var/fixed = next_hit ? timeleft(next_hit) : -1
		if(fixed < 0)
			to_chat(user, span_warning("Функция барометра [src] не смогла обнаружить какие-либо погодные явления."))
		else
			to_chat(user, span_warning("Функция барометра [src] сообщает, что шторм начнётся приблизительно через [butchertime(fixed)]."))
	cooldown = TRUE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/analyzer, ping)), cooldown_time)
	return CLICK_ACTION_SUCCESS

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_notice("Функция барометра [src] готова к работе!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/// Applies the barometer inaccuracy to the gas reading.
/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(barometer_accuracy)
		var/inaccurate = round(barometer_accuracy*(1/3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1,amount))

/obj/item/analyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasAnalyzer", "Gas Analyzer")
		ui.open()

/obj/item/analyzer/ui_static_data(mob/user)
	return return_atmos_handbooks()

/obj/item/analyzer/ui_data(mob/user)
	LAZYINITLIST(last_gasmix_data)
	return list("gasmixes" = last_gasmix_data)

/obj/item/analyzer/attack_self(mob/user, modifiers)
	if(user.stat != CONSCIOUS || !user.can_read(src) || user.is_blind())
		return
	atmos_scan(user=user, target=get_turf(src), silent=FALSE)
	on_analyze(source=src, target=get_turf(src))

/obj/item/analyzer/attack_self_secondary(mob/user, modifiers)
	if(user.stat != CONSCIOUS || !user.can_read(src) || user.is_blind())
		return

	ui_interact(user)

/obj/item/analyzer/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/effect/anomaly) && can_see(user, interacting_with, ranged_scan_distance))
		var/obj/effect/anomaly/ranged_anomaly = interacting_with
		ranged_anomaly.analyzer_act(user, src)
		return ITEM_INTERACT_SUCCESS
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/analyzer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION) && can_see(user, interacting_with, ranged_scan_distance))
		atmos_scan(user, (interacting_with.return_analyzable_air() ? interacting_with : get_turf(interacting_with)))
	return NONE // Non-blocking

/// Called when our analyzer is used on something
/obj/item/analyzer/proc/on_analyze(datum/source, atom/target)
	SIGNAL_HANDLER
	var/mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE
	var/list/airs = islist(mixture) ? mixture : list(mixture)
	var/list/new_gasmix_data = list()
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(LOWER_TEXT(target.name))
		if(airs.len != 1) //not a unary gas mixture
			mix_name += " - Узел [airs.Find(air)]"
		new_gasmix_data += list(gas_mixture_parser(air, mix_name))
	last_gasmix_data = new_gasmix_data

/**
 * Outputs a message to the user describing the target's gasmixes.
 *
 * Gets called by analyzer_act, which in turn is called by tool_act.
 * Also used in other chat-based gas scans.
 */
/proc/atmos_scan(mob/user, atom/target, silent=FALSE)
	var/mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/icon = target
	var/message = list()
	if(!silent && isliving(user))
		playsound(user, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		user.visible_message(span_notice("[user] использует анализатор на [icon2html(icon, viewers(user))] [target]."), span_notice("Вы используете анализатор на [icon2html(icon, user)] [target]."))
	message += span_boldnotice("Результаты анализа [icon2html(icon, user)] [target].")

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(LOWER_TEXT(target.name))
		if(airs.len > 1) //not a unary gas mixture
			var/mix_number = airs.Find(air)
			message += span_boldnotice("Узел [mix_number]")
			mix_name += " - Узел [mix_number]"

		var/total_moles = air.total_moles()
		var/pressure = air.return_pressure()
		var/volume = air.return_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air.return_temperature()
		var/heat_capacity = air.heat_capacity()
		var/thermal_energy = air.thermal_energy()

		if(total_moles > 0)
			message += span_notice("Моли: [round(total_moles, 0.01)] моль")

			var/list/cached_gases = air.gases
			for(var/id in cached_gases)
				var/gas_concentration = cached_gases[id][MOLES]/total_moles
				message += span_notice("[cached_gases[id][GAS_META][META_GAS_NAME]]: [round(cached_gases[id][MOLES], 0.01)] моль ([round(gas_concentration*100, 0.01)] %)")
			message += span_notice("Температура: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)")
			message += span_notice("Объём: [volume] л")
			message += span_notice("Давление: [round(pressure, 0.01)] кПа")
			message += span_notice("Теплоёмкость: [display_energy(heat_capacity)] / K")
			message += span_notice("Тепловая энергия: [display_energy(thermal_energy)]")
		else
			message += airs.len > 1 ? span_notice("Этот узел пуст!") : span_notice("[target] пуст!")
			message += span_notice("Объём: [volume] л") // не хочу менять порядок отображения объёма, смирись

	// we let the join apply newlines so we do need handholding
	to_chat(user, boxed_message(jointext(message, "\n")), type = MESSAGE_TYPE_INFO)
	return TRUE

/obj/item/analyzer/ranged
	desc = "Портативный сканер окружающей среды дальнего действия, который показывает текущие уровни газов."
	name = "long-range gas analyzer"
	icon_state = "analyzerranged"
	worn_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.2, /datum/material/gold = SMALL_MATERIAL_AMOUNT*3, /datum/material/bluespace=SMALL_MATERIAL_AMOUNT*2)
	grind_results = list(/datum/reagent/mercury = 5, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	ranged_scan_distance = 15
