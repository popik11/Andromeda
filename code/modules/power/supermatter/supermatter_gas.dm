/proc/init_sm_gas()
	var/list/gas_list = list()
	for (var/sm_gas_path in subtypesof(/datum/sm_gas))
		var/datum/sm_gas/sm_gas = new sm_gas_path
		gas_list[sm_gas.gas_path] = sm_gas
	return gas_list

/// Возвращает список информации о газах СМ.
/// Может работать только после init_sm_gas
/proc/sm_gas_data()
	var/list/data = list()
	for (var/gas_path in GLOB.sm_gas_behavior)
		var/datum/sm_gas/sm_gas = GLOB.sm_gas_behavior[gas_path]
		var/list/singular_gas_data = list()
		singular_gas_data["desc"] = sm_gas.desc

		// Positive равен true, если большее количество газа является положительным эффектом.
		var/list/numeric_data = list()
		if(sm_gas.power_transmission)
			var/list/si_derived_data = siunit_isolated(sm_gas.power_transmission * BASE_POWER_TRANSMISSION_RATE, "Вт/МэВ", 2)
			numeric_data += list(list(
				"name" = "Бонус передачи энергии",
				"amount" = si_derived_data["coefficient"],
				"unit" = si_derived_data["unit"],
				"positive" = TRUE,
			))
		if(sm_gas.heat_modifier)
			numeric_data += list(list(
				"name" = "Множитель отходов",
				"amount" = 100 * sm_gas.heat_modifier,
				"unit" = "%",
				"positive" = FALSE,
			))
		if(sm_gas.heat_resistance)
			numeric_data += list(list(
				"name" = "Термостойкость",
				"amount" = 100 * sm_gas.heat_resistance,
				"unit" = "%",
				"positive" = TRUE,
			))
		if(sm_gas.heat_power_generation)
			var/list/si_derived_data = siunit_isolated(sm_gas.heat_power_generation * GAS_HEAT_POWER_SCALING_COEFFICIENT MEGA SECONDS / SSair.wait, "эВ/К/с", 2)
			numeric_data += list(list(
				"name" = "Прирост энергии от тепла",
				"amount" = si_derived_data["coefficient"],
				"unit" = si_derived_data["unit"],
				"positive" = TRUE,
			))
		if(sm_gas.powerloss_inhibition)
			numeric_data += list(list(
				"name" = "Подавление потерь энергии",
				"amount" = 100 * sm_gas.powerloss_inhibition,
				"unit" = "%",
				"positive" = TRUE,
			))
		singular_gas_data["numeric_data"] = numeric_data
		data[gas_path] = singular_gas_data
	return data

/// Ассоциативный массив sm_gas_behavior[/datum/gas (путь)] = datum/sm_gas (экземпляр)
GLOBAL_LIST_INIT(sm_gas_behavior, init_sm_gas())

/// Содержит эффекты газов при поглощении СМ.
/// Если газ не имеет эффектов, вам не нужно добавлять другой подтип sm_gas,
/// Мы уже проверяем на null в [/obj/machinery/power/supermatter_crystal/proc/calculate_gases]
/datum/sm_gas
	/// Путь [/datum/gas], участвующего в этом взаимодействии.
	var/gas_path
	/// Влияет на мощность разряда, не вмешиваясь в собственную энергию кристалла. Масштабируется через [BASE_POWER_TRANSMISSION_RATE].
	var/power_transmission = 0
	/// Насколько больше побочного тепла и газа генерирует СМ.
	var/heat_modifier = 0
	/// Насколько горячее может работать СМ до получения урона.
	var/heat_resistance = 0
	/// Позволяет СМ генерировать дополнительную энергию из тепла. Да...
	var/heat_power_generation = 0
	/// Насколько снижаются потери энергии.
	var/powerloss_inhibition = 0
	/// Дайте краткое описание газа, если нужно. Если газ имеет дополнительные эффекты, опишите их здесь.
	var/desc

/datum/sm_gas/proc/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	return

/datum/sm_gas/oxygen
	gas_path = /datum/gas/oxygen
	power_transmission = 0.15
	heat_power_generation = 1

/datum/sm_gas/nitrogen
	gas_path = /datum/gas/nitrogen
	heat_modifier = -2.5
	heat_power_generation = -1

/datum/sm_gas/carbon_dioxide
	gas_path = /datum/gas/carbon_dioxide
	heat_modifier = 1
	heat_power_generation = 1
	powerloss_inhibition = 1
	desc = "При поглощении Суперматерией и контакте с кислородом, будет генерироваться Плюоксиум."

/// Может быть на Кислороде или CO2, но лучше объединить здесь, так как CO2 встречается реже.
/datum/sm_gas/carbon_dioxide/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(!sm.gas_percentage[/datum/gas/carbon_dioxide] || !sm.gas_percentage[/datum/gas/oxygen])
		return
	var/co2_pp = sm.absorbed_gasmix.return_pressure() * sm.gas_percentage[/datum/gas/carbon_dioxide]
	var/co2_ratio = clamp((1/2 * (co2_pp - CO2_CONSUMPTION_PP) / (co2_pp + CO2_PRESSURE_SCALING)), 0, 1)
	var/consumed_co2 = sm.absorbed_gasmix.gases[/datum/gas/carbon_dioxide][MOLES] * co2_ratio
	consumed_co2 = min(
		consumed_co2,
		sm.absorbed_gasmix.gases[/datum/gas/carbon_dioxide][MOLES],
		sm.absorbed_gasmix.gases[/datum/gas/oxygen][MOLES]
	)
	if(!consumed_co2)
		return
	sm.absorbed_gasmix.gases[/datum/gas/carbon_dioxide][MOLES] -= consumed_co2
	sm.absorbed_gasmix.gases[/datum/gas/oxygen][MOLES] -= consumed_co2
	ASSERT_GAS(/datum/gas/pluoxium, sm.absorbed_gasmix)
	sm.absorbed_gasmix.gases[/datum/gas/pluoxium][MOLES] += consumed_co2

/datum/sm_gas/plasma
	gas_path = /datum/gas/plasma
	heat_modifier = 14
	power_transmission = 0.4
	heat_power_generation = 1

/datum/sm_gas/water_vapor
	gas_path = /datum/gas/water_vapor
	heat_modifier = 11
	power_transmission = -0.25
	heat_power_generation = 1

/datum/sm_gas/hypernoblium
	gas_path = /datum/gas/hypernoblium
	heat_modifier = -14
	power_transmission = 0.3
	heat_power_generation = -1

/datum/sm_gas/nitrous_oxide
	gas_path = /datum/gas/nitrous_oxide
	heat_resistance = 5

/datum/sm_gas/tritium
	gas_path = /datum/gas/tritium
	heat_modifier = 9
	power_transmission = 3
	heat_power_generation = 1

/datum/sm_gas/bz
	gas_path = /datum/gas/bz
	heat_modifier = 4
	power_transmission = -0.2
	heat_power_generation = 1
	desc = "Будет испускать ядерные частицы (излуччение) при составе выше 40%"

/// Начинает испускать радиационные шары с максимальным шансом 30% за тик.
/datum/sm_gas/bz/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(sm.gas_percentage[/datum/gas/bz] > 0.4 && prob(30 * sm.gas_percentage[/datum/gas/bz]))
		sm.fire_nuclear_particle()

/datum/sm_gas/pluoxium
	gas_path = /datum/gas/pluoxium
	heat_modifier = -1.5
	power_transmission = -0.5
	heat_power_generation = -1

/datum/sm_gas/miasma
	gas_path = /datum/gas/miasma
	heat_power_generation = 0.5
	desc = "Будет поглощаться Суперматерией для генерации энергии."

///Миазма - это действительно просто микроскопические частицы. Она поглощается, как и всё остальное, что касается кристалла.
/datum/sm_gas/miasma/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(!sm.gas_percentage[/datum/gas/miasma])
		return
	var/miasma_pp = sm.absorbed_gasmix.return_pressure() * sm.gas_percentage[/datum/gas/miasma]
	var/miasma_ratio = clamp(((miasma_pp - MIASMA_CONSUMPTION_PP) / (miasma_pp + MIASMA_PRESSURE_SCALING)) * (1 + (sm.gas_heat_power_generation * MIASMA_GASMIX_SCALING)), 0, 1)
	var/consumed_miasma = sm.absorbed_gasmix.gases[/datum/gas/miasma][MOLES] * miasma_ratio
	if(!consumed_miasma)
		return
	sm.absorbed_gasmix.gases[/datum/gas/miasma][MOLES] -= consumed_miasma
	sm.external_power_trickle += consumed_miasma * MIASMA_POWER_GAIN
	sm.log_activation("miasma absorption")

/datum/sm_gas/freon
	gas_path = /datum/gas/freon
	heat_modifier = -9
	power_transmission = -3
	heat_power_generation = -1

/datum/sm_gas/hydrogen
	gas_path = /datum/gas/hydrogen
	heat_modifier = 9
	power_transmission = 2.5
	heat_resistance = 1
	heat_power_generation = 1

/datum/sm_gas/healium
	gas_path = /datum/gas/healium
	heat_modifier = 3
	power_transmission = 0.24
	heat_power_generation = 1

/datum/sm_gas/proto_nitrate
	gas_path = /datum/gas/proto_nitrate
	heat_modifier = -4
	power_transmission = 1.5
	heat_resistance = 4
	heat_power_generation = 1

/datum/sm_gas/zauker
	gas_path = /datum/gas/zauker
	heat_modifier = 7
	power_transmission = 2
	heat_power_generation = 1
	desc = "Будет генерировать электрические разряды."

/datum/sm_gas/zauker/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(!prob(sm.gas_percentage[/datum/gas/zauker] * 100))
		return
	playsound(sm.loc, 'sound/items/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
	sm.supermatter_zap(
		sm,
		range = 6,
		zap_str = clamp(sm.internal_energy * 1.6 KILO JOULES, 3.2 MEGA JOULES, 16 MEGA JOULES),
		zap_flags = ZAP_MOB_STUN,
		zap_cutoff = sm.zap_cutoff,
		power_level = sm.internal_energy,
		zap_icon = sm.zap_icon
	)

/datum/sm_gas/antinoblium
	gas_path = /datum/gas/antinoblium
	heat_modifier = 14
	power_transmission = -0.5
	heat_power_generation = 1
