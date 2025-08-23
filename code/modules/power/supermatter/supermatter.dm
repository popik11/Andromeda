//Портировано из /vg/station13, которая в свою очередь была форкнута из baystation12;
//Пожалуйста, не беспокойте их багами из этого порта, так как он был значительно изменён.
//Изменения включают удаление уничтожающей мир полной версии суперматерии и оставление только осколка.

//Константы разряда, ускоряющие наведение.

#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (OBJECT + 1)
#define OBJECT (LOWEST + 1)
#define LOWEST (1)

GLOBAL_DATUM(main_supermatter_engine, /obj/machinery/power/supermatter_crystal)

/obj/machinery/power/supermatter_crystal
	name = "supermatter crystal"
	desc = "Странно прозрачный и переливающийся кристалл."
	icon = 'icons/obj/machines/engine/supermatter.dmi'
	density = TRUE
	anchored = TRUE
	layer = MOB_LAYER
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	critical_machine = TRUE
	base_icon_state = "sm"
	icon_state = "sm"
	light_on = FALSE

	///ID нашей суперматерии
	var/uid = 1
	///Количество суперматерий, созданных в этом раунде
	var/static/gl_uid = 1
	///Отслеживает цвет используемого разряда
	var/zap_icon = DEFAULT_ZAP_ICON_STATE

	///Доля газовой смеси, которую мы должны удалить
	var/absorption_ratio = 0.15
	/// Газовая смесь, которую мы недавно поглотили. Воздух тайла умноженный на absorption_ratio
	var/datum/gas_mixture/absorbed_gasmix
	/// Текущие газовые поведения для этого конкретного кристалла
	var/list/current_gas_behavior

	///Обозначается как EER на мониторе. Это значение влияет на выход газа, урон и генерацию энергии.
	var/internal_energy = 0
	var/list/internal_energy_factors

	///Текущее количество урона.
	var/damage = 0
	/// Урон, который был у нас до этого цикла.
	/// Используется для проверки, получаем ли мы сейчас урон или восстанавливаемся.
	var/damage_archived = 0
	var/list/damage_factors

	/// Передача мощности разряда относительно внутренней энергии. Вт/МэВ.
	var/zap_transmission_rate = BASE_POWER_TRANSMISSION_RATE
	var/list/zap_factors

	/// Температура, при которой мы начинаем получать урон
	var/temp_limit = T0C + HEAT_PENALTY_THRESHOLD
	var/list/temp_limit_factors

	/// Умножает количество отходов и температуру.
	var/waste_multiplier = 0
	var/list/waste_multiplier_factors

	///Точка, при которой мы считаем суперматерию в состоянии [SUPERMATTER_STATUS_WARNING]
	var/warning_point = 5
	var/warning_channel = RADIO_CHANNEL_ENGINEERING
	///Точка, при которой мы считаем суперматерию в состоянии [SUPERMATTER_STATUS_DANGER]
	///Также спавнит аномалии при большем уроне.
	var/danger_point = 60
	///Точка, при которой мы считаем суперматерию в состоянии [SUPERMATTER_STATUS_EMERGENCY]
	var/emergency_point = 75
	var/emergency_channel = null // Нужен null для фактической трансляции, лол.
	///Точка, при которой мы делимитируем [SUPERMATTER_STATUS_DELAMINATING].
	var/explosion_point = 100
	///Мы взрываемся?
	var/final_countdown = FALSE
	///Масштабируемое значение, влияющее на силу взрывов.
	var/explosion_power = 35
	///Время в 1/10 секунды с последнего предупреждения
	var/lastwarning = 0

	/// Список газов, сопоставленных с их текущим составом.
	/// Мы используем это для расчёта различных значений, используемых суперматерией, таких как мощность или термостойкость.
	/// Диапазон от 0 до 1
	var/list/gas_percentage

	/// Влияет на тепло, производимое нашей СМ.
	var/gas_heat_modifier = 0
	/// Влияет на минимальную точку, при которой СМ получает тепловой урон
	var/gas_heat_resistance = 0
	/// Насколько подавляется потеря энергии. Полное подавление потерь энергии при 1.
	var/gas_powerloss_inhibition = 0
	/// Влияет на количество энергии, создаваемое основным разрядом СМ.
	var/gas_power_transmission_rate = 0
	/// Влияет на прирост энергии СМ от тепла.
	var/gas_heat_power_generation = 0

	/// Внешняя энергия, которая добавляется постепенно, а не мгновенно.
	var/external_power_trickle = 0
	/// Внешняя энергия, которая добавляется к СМ при следующем вызове [/obj/machinery/power/supermatter_crystal/process_atmos].
	var/external_power_immediate = 0

	/// Внешний урон, который добавляется к СМ при следующем вызове [/obj/machinery/power/supermatter_crystal/process_atmos].
	/// СМ не будет получать урон, если её здоровье ниже аварийной точки.
	var/external_damage_immediate = 0

	/// Порог для прыжка разряда, растёт с температурой, снижается с увеличением количества молей,
	var/zap_cutoff = 1.2 MEGA JOULES
	/// Во сколько следует умножать урон от пуль при добавлении к внутренним переменным
	var/bullet_energy = SUPERMATTER_DEFAULT_BULLET_ENERGY
	/// Сколько галлюцинаций мы должны производить на единицу мощности?
	var/hallucination_power = 0.1

	/// Наше внутреннее радио
	var/obj/item/radio/radio
	/// Ключ, используемый нашим внутренним радио
	var/radio_key = /obj/item/encryptionkey/headset_eng

	/// Логическая переменная для записи первой активации СМ.
	var/activation_logged = FALSE

	/// Эффект, который мы показываем администраторам и призракам, процент делимитации
	var/obj/effect/countdown/supermatter/countdown

	/// Только главные двигатели могут иметь украденные осколки, вызывать каскады и порождать общестанционные аномалии.
	var/is_main_engine = FALSE
	/// Наш звуковой цикл
	var/datum/looping_sound/supermatter/soundloop
	/// Может ли быть перемещён?
	var/moveable = FALSE

	///Отслеживание кулдауна для акцентных звуков
	var/last_accent_sound = 0
	///Переменная, которая увеличивается от 0 до 1, когда рядом психолог, и уменьшается аналогичным образом
	var/psy_coeff = 0

	/// Отключает все методы получения урона.
	var/disable_damage = FALSE
	/// Отключает расчёт эффектов газов и производство отходов.
	/// СМ всё ещё "дышит", принимает и выдыхает газы. Но ничего с ними не делает.
	/// Так код чище. Убрать, если слишком расточительно.
	var/disable_gas = FALSE
	/// Отключает изменения мощности.
	var/disable_power_change = FALSE
	/// Полностью отключает обработку СМ при установке в SM_PROCESS_DISABLED.
	/// Временно отключает обработку при установке в SM_PROCESS_TIMESTOP.
	/// Убедитесь, что absorbed_gasmix и gas_percentage не null, если это SM_PROCESS_DISABLED.
	var/disable_process = SM_PROCESS_ENABLED

	///Хранит время последнего разряда
	var/last_power_zap = 0
	///Хранит тик подсистемы машин, когда произошло последнее накопление энергии разряда. Даёт отсчёт времени в перспективе SSmachines.
	var/last_energy_accumulation_perspective_machines = 0
	///То же, что и [last_energy_accumulation_perspective_machines], но для высокоэнергетических разрядов из handle_high_power().
	var/last_high_energy_accumulation_perspective_machines = 0
	/// Накопленная энергия для передачи от разрядов суперматерии.
	var/list/zap_energy_accumulation = list()
	///Показывать ли этот кристалл в модульной программе CIMS
	var/include_in_cims = TRUE

	///Сдвиг оттенка цвета разрядов в зависимости от мощности кристалла
	var/hue_angle_shift = 0
	///Ссылка на эффект искажения
	var/atom/movable/warp_effect/warp
	///Порог мощности, необходимый для преобразования функции потерь мощности из кубической в линейную.
	var/powerloss_linear_threshold = 0
	///Смещение линейной функции потерь мощности, установленное так, чтобы переход был дифференцируемым.
	var/powerloss_linear_offset = 0

	/// Как мы делимитируем.
	var/datum/sm_delam/delamination_strategy
	/// Принудительно ли установлена конкретная стратегия делимитации или нет. Все truthy-значения означают принудительную установку.
	/// Только значения больше или равные текущему могут изменить стратегию.
	var/delam_priority = SM_DELAM_PRIO_NONE

	/// Ленивый список безумных инженеров, которым удалось обратить вспять каскад двигателя.
	var/list/datum/weakref/saviors = null

	/// Если осколок суперматерии был удалён. Почти наверняка предателем. Сокращает время отсчёта до делимитации.
	var/supermatter_sliver_removed = FALSE

	/// Если СМ украшена праздничными огнями
	var/holiday_lights = FALSE

	/// Кулдаун для отправки аварийных оповещений на общий радиочастотный канал
	COOLDOWN_DECLARE(common_radio_cooldown)

/obj/machinery/power/supermatter_crystal/Initialize(mapload)
	. = ..()
	current_gas_behavior = init_sm_gas()
	gas_percentage = list()
	absorbed_gasmix = new()
	uid = gl_uid++
	set_delam(SM_DELAM_PRIO_NONE, /datum/sm_delam/explosive)
	SSair.start_processing_machine(src)
	countdown = new(src)
	countdown.start()
	SSpoints_of_interest.make_point_of_interest(src)
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	investigate_log("был создан.", INVESTIGATE_ENGINE)
	if(is_main_engine)
		GLOB.main_supermatter_engine = src

	AddElement(/datum/element/bsa_blocker)
	RegisterSignal(src, COMSIG_ATOM_BSA_BEAM, PROC_REF(force_delam))
	RegisterSignal(src, COMSIG_ATOM_TIMESTOP_FREEZE, PROC_REF(time_frozen))
	RegisterSignal(src, COMSIG_ATOM_TIMESTOP_UNFREEZE, PROC_REF(time_unfrozen))
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(eat_bullets))
	var/static/list/loc_connections = list(
		COMSIG_TURF_INDUSTRIAL_LIFT_ENTER = PROC_REF(tram_contents_consume),
	)
	AddElement(/datum/element/connect_loc, loc_connections)	//Специально для трамвая, костыльно.

	AddComponent(/datum/component/supermatter_crystal, CALLBACK(src, PROC_REF(wrench_act_callback)), CALLBACK(src, PROC_REF(consume_callback)))
	soundloop = new(src, TRUE)

	if(!isnull(check_holidays(FESTIVE_SEASON)))
		holiday_lights()

	if (!moveable)
		move_resist = MOVE_FORCE_OVERPOWERING // Избегаем перемещения статуями или другими мемами

	// Чёртовы математики-зануды
	powerloss_linear_threshold = sqrt(POWERLOSS_LINEAR_RATE / 3 * POWERLOSS_CUBIC_DIVISOR ** 3)
	powerloss_linear_offset = -1 * powerloss_linear_threshold * POWERLOSS_LINEAR_RATE + (powerloss_linear_threshold / POWERLOSS_CUBIC_DIVISOR) ** 3

/obj/machinery/power/supermatter_crystal/Destroy()
	if(warp)
		vis_contents -= warp
		QDEL_NULL(warp)
	investigate_log("был уничтожен.", INVESTIGATE_ENGINE)
	SSair.stop_processing_machine(src)
	absorbed_gasmix = null
	QDEL_NULL(radio)
	QDEL_NULL(countdown)
	if(is_main_engine && GLOB.main_supermatter_engine == src)
		GLOB.main_supermatter_engine = null
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/supermatter_crystal/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	if(warp)
		SET_PLANE_EXPLICIT(warp, PLANE_TO_TRUE(warp.plane), src)

/obj/machinery/power/supermatter_crystal/examine(mob/user)
	. = ..()
	var/immune = HAS_MIND_TRAIT(user, TRAIT_MADNESS_IMMUNE)
	if(isliving(user))
		if (!immune && (get_dist(user, src) < SM_HALLUCINATION_RANGE(internal_energy)))
			. += span_danger("У вас начинает болеть голова от одного взгляда на это.")
		var/mob/living/living_user = user
		if (HAS_TRAIT(user, TRAIT_REMOTE_TASTING))
			to_chat(user, span_warning("Вкус подавляющий и неописуемый!"))
			living_user.electrocute_act(shock_damage = 15, source = src, flags = SHOCK_KNOCKDOWN | SHOCK_NOGLOVES)
			. += span_notice("Можно было бы добавить немного хлорида натрия...")

	if(holiday_lights)
		. += span_notice("Излучая как праздничное настроение, так и настоящую радиацию, он имеет ослепительные огни, с любовью обернутые вокруг основания, превращая его из потенциального устройства судного дня в космическую рождественскую центральную часть.")

	. += delamination_strategy.examine(src)
	return .

/obj/machinery/power/supermatter_crystal/process_atmos()
	// ЧАСТЬ 1: ПОДГОТОВКА
	if(disable_process != SM_PROCESS_ENABLED)
		return

	var/turf/local_turf = loc
	if(!istype(local_turf))//Мы в ящике или где-то не на тайле, если вернёмся на тайл - продолжим обработку, но пока.
		return  //Да, просто останавливаемся.
	if(isclosedturf(local_turf))
		var/turf/did_it_melt = local_turf.Melt()
		if(!isclosedturf(did_it_melt)) //На случай, если шутник найдёт способ разместить их на несокрушимых стенах
			visible_message(span_warning("[src] проплавляет [local_turf]!"))
		return

	// ЧАСТЬ 2: ОБРАБОТКА ГАЗОВ
	var/datum/gas_mixture/env = local_turf.return_air()
	absorbed_gasmix = env?.remove_ratio(absorption_ratio) || new()
	absorbed_gasmix.volume = (env?.volume || CELL_VOLUME) * absorption_ratio // Чтобы соответствовать давлению.
	calculate_gases()
	// Дополнительные эффекты должны всегда срабатывать после завершения расчёта состава
	// Некоторые дополнительные эффекты, такие как [/datum/sm_gas/carbon_dioxide/extra_effects]
	// требуют более одного газа и зависят от полностью рассчитанного gas_percentage.
	for (var/gas_path in absorbed_gasmix.gases)
		var/datum/sm_gas/sm_gas = current_gas_behavior[gas_path]
		sm_gas?.extra_effects(src)

	// ЧАСТЬ 3: ОБРАБОТКА ЭНЕРГИИ
	internal_energy_factors = calculate_internal_energy()
	zap_factors = calculate_zap_transmission_rate()
	var/delta_time = (SSmachines.times_fired - last_energy_accumulation_perspective_machines) * SSmachines.wait / (1 SECONDS)
	var/accumulated_energy = accumulate_energy(ZAP_ENERGY_ACCUMULATION_NORMAL, energy = internal_energy * zap_transmission_rate * delta_time)
	if(accumulated_energy && (last_power_zap + (4 - internal_energy * 0.001) SECONDS) < world.time)
		var/discharged_energy = discharge_energy(ZAP_ENERGY_ACCUMULATION_NORMAL)
		playsound(src, 'sound/items/weapons/emitter2.ogg', 70, TRUE)
		hue_angle_shift = clamp(903 * log(10, (internal_energy + 8000)) - 3590, -50, 240)
		var/zap_color = color_matrix_rotate_hue(hue_angle_shift)
		supermatter_zap(
			zapstart = src,
			range = 3,
			zap_str = discharged_energy,
			zap_flags = ZAP_SUPERMATTER_FLAGS,
			zap_cutoff = 240 KILO JOULES,
			power_level = internal_energy,
			color = zap_color,
		)

		last_power_zap = world.time
	last_energy_accumulation_perspective_machines = SSmachines.times_fired

	// ЧАСТЬ 4: ОБРАБОТКА УРОНА
	temp_limit_factors = calculate_temp_limit()
	damage_archived = damage
	damage_factors = calculate_damage()
	if(damage == 0) // Очищаем любые принудительные делимитации в игре при полном здоровье.
		set_delam(SM_DELAM_PRIO_IN_GAME, SM_DELAM_STRATEGY_PURGE)
	else if(!final_countdown)
		set_delam(SM_DELAM_PRIO_NONE, SM_DELAM_STRATEGY_PURGE) // Этот не может очистить любые принудительные делимитации.
	delamination_strategy.delam_progress(src)
	if(damage > explosion_point && !final_countdown)
		count_down()

	// ЧАСТЬ 5: ОБРАБОТКА ОТХОДНЫХ ГАЗОВ
	waste_multiplier_factors = calculate_waste_multiplier()
	var/device_energy = internal_energy * REACTION_POWER_MODIFIER

	/// Производим отходы в другом газмиксе, чтобы сохранить копию газмикса, используемого для обработки.
	var/datum/gas_mixture/merged_gasmix = absorbed_gasmix.copy()
	merged_gasmix.temperature += device_energy * waste_multiplier / THERMAL_RELEASE_MODIFIER
	merged_gasmix.temperature = clamp(merged_gasmix.temperature, TCMB, 2500 * waste_multiplier)
	merged_gasmix.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)
	merged_gasmix.gases[/datum/gas/plasma][MOLES] += max(device_energy * waste_multiplier / PLASMA_RELEASE_MODIFIER, 0)
	merged_gasmix.gases[/datum/gas/oxygen][MOLES] += max(((device_energy + merged_gasmix.temperature * waste_multiplier) - T0C) / OXYGEN_RELEASE_MODIFIER, 0)
	merged_gasmix.garbage_collect()
	env.merge(merged_gasmix)
	air_update_turf(FALSE, FALSE)

	// ЧАСТЬ 6: ДОПОЛНИТЕЛЬНОЕ ПОВЕДЕНИЕ
	emit_radiation()
	processing_sound()
	handle_high_power()
	psychological_examination()

	// обрабатываем инженеров, спасших двигатель от каскада, если такие были
	if(get_status() < SUPERMATTER_EMERGENCY && !isnull(saviors))
		for(var/datum/weakref/savior_ref as anything in saviors)
			var/mob/living/savior = savior_ref.resolve()
			if(!istype(savior)) // не дожили, чтобы рассказать историю, увы.
				continue
			savior.client?.give_award(/datum/award/achievement/jobs/theoretical_limits, savior)
		LAZYNULL(saviors)

	if(prob(15))
		supermatter_pull(loc, min(internal_energy/850, 3))//850, 1700, 2550
	update_appearance()
	delamination_strategy.lights(src)
	delamination_strategy.filters(src)
	absorption_ratio = clamp(absorption_ratio - 0.05, 0.15, 1)
	return TRUE

// Интерфейс SupermatterMonitor только для призраков. Унаследованный attack_ghost вызовет это.
/obj/machinery/power/supermatter_crystal/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user))
		return FALSE
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Supermatter")
		ui.open()

/obj/machinery/power/supermatter_crystal/ui_static_data(mob/user)
	var/list/data = list()
	data["gas_metadata"] = sm_gas_data()
	return data

/// Возвращает данные, относящиеся исключительно к этой СМ.
/obj/machinery/power/supermatter_crystal/proc/sm_ui_data()
	var/list/data = list()
	data["uid"] = uid
	data["area_name"] = get_area_name(src)

	data["integrity"] = get_integrity_percent()
	data["integrity_factors"] = list()
	for (var/factor in damage_factors)
		var/amount = round(damage_factors[factor], 0.01)
		if(!amount)
			continue
		data["integrity_factors"] += list(list(
			"name" = factor,
			"amount" = amount * -1
		))
	var/list/internal_energy_si_derived_data = siunit_isolated(internal_energy * 1e6, "eV", 3)
	data["internal_energy"] = internal_energy
	data["internal_energy_coefficient"] = internal_energy_si_derived_data[SI_COEFFICIENT]
	data["internal_energy_unit"] = internal_energy_si_derived_data[SI_UNIT]
	data["internal_energy_factors"] = list()
	for (var/factor in internal_energy_factors)
		var/list/internal_energy_factor_si_derived_data = siunit_isolated(internal_energy_factors[factor] * 1e6, "eV", 3)
		var/amount = round(internal_energy_factors[factor], 0.01)
		if(!amount)
			continue
		data["internal_energy_factors"] += list(list(
			"name" = factor,
			"amount" = internal_energy_factor_si_derived_data[SI_COEFFICIENT],
			"unit" = internal_energy_factor_si_derived_data[SI_UNIT],
		))
	data["temp_limit"] = temp_limit
	data["temp_limit_factors"] = list()
	for (var/factor in temp_limit_factors)
		var/amount = round(temp_limit_factors[factor], 0.01)
		if(!amount)
			continue
		data["temp_limit_factors"] += list(list(
			"name" = factor,
			"amount" = amount,
		))
	data["waste_multiplier"] = waste_multiplier
	data["waste_multiplier_factors"] = list()
	for (var/factor in waste_multiplier_factors)
		var/amount = round(waste_multiplier_factors[factor], 0.01)
		if(!amount)
			continue
		data["waste_multiplier_factors"] += list(list(
			"name" = factor,
			"amount" = amount,
		))

	data["zap_transmission_factors"] = list()
	for (var/factor in zap_factors)
		var/list/zap_factor_si_derived_data = siunit_isolated(zap_factors[factor] * internal_energy, "W", 2)
		if(!zap_factor_si_derived_data[SI_COEFFICIENT])
			continue
		data["zap_transmission_factors"] += list(list(
			"name" = factor,
			"amount" = zap_factor_si_derived_data[SI_COEFFICIENT],
			"unit" = zap_factor_si_derived_data[SI_UNIT],
		))

	///Добавляем бонус высокой энергии к данным передачи разряда для точного измерения генерации энергии от разрядов.
	var/high_energy_bonus = 0
	var/zap_transmission = zap_transmission_rate * internal_energy
	var/zap_power_multiplier = 1
	if(internal_energy > POWER_PENALTY_THRESHOLD) //Разряды суперматерии почему-то умножают мощность внутри при некоторых условиях, так что пока сделаем костыль.
		///Бонусный множитель мощности, применяемый ко всем разрядам. Генерация энергии от разрядов удваивается при достижении 7ГэВ и 9ГэВ.
		zap_power_multiplier *= 2 ** clamp(round((internal_energy - POWER_PENALTY_THRESHOLD) / 2000), 0, 2)
		///Суперматерия выпускает дополнительные разряды после 5ГэВ, с увеличением при 7ГэВ и 9ГэВ.
		var/additional_zap_bonus = clamp(internal_energy * 3200, 6.4e6, 3.2e7) * clamp(round(INVERSE_LERP(1000, 3000, internal_energy)), 1, 4)
		high_energy_bonus = (zap_transmission + additional_zap_bonus) * zap_power_multiplier - zap_transmission
		var/list/zap_factor_si_derived_data = siunit_isolated(high_energy_bonus, "W", 2)
		data["zap_transmission_factors"] += list(list(
			"name" = "High Energy Bonus",
			"amount" = zap_factor_si_derived_data[SI_COEFFICIENT],
			"unit" = zap_factor_si_derived_data[SI_UNIT],
		))

	var/list/zap_transmission_si_derived_data = siunit_isolated(zap_transmission + high_energy_bonus, "W", 2)
	data["zap_transmission"] = zap_transmission + high_energy_bonus
	data["zap_transmission_coefficient"] = zap_transmission_si_derived_data[SI_COEFFICIENT]
	data["zap_transmission_unit"] = zap_transmission_si_derived_data[SI_UNIT]

	data["absorbed_ratio"] = absorption_ratio
	var/list/formatted_gas_percentage = list()
	for (var/datum/gas/gas_path as anything in subtypesof(/datum/gas))
		formatted_gas_percentage[gas_path] = gas_percentage?[gas_path] || 0
	data["gas_composition"] = formatted_gas_percentage
	data["gas_temperature"] = absorbed_gasmix.temperature
	data["gas_total_moles"] = absorbed_gasmix.total_moles()
	return data

/obj/machinery/power/supermatter_crystal/ui_data(mob/user)
	var/list/data = list()
	data["sm_data"] = list(sm_ui_data())
	return data

/// Кодирует текущее состояние суперматерии.
/obj/machinery/power/supermatter_crystal/proc/get_status()
	if(!absorbed_gasmix)
		return SUPERMATTER_ERROR
	if(final_countdown)
		return SUPERMATTER_DELAMINATING
	if(damage >= emergency_point)
		return SUPERMATTER_EMERGENCY
	if(damage >= danger_point)
		return SUPERMATTER_DANGER
	if(damage >= warning_point)
		return SUPERMATTER_WARNING
	if(absorbed_gasmix.temperature > temp_limit * 0.8)
		return SUPERMATTER_NOTIFY
	if(internal_energy)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/// Возвращает процент целостности Суперматерии. Округление не производится, округлите самостоятельно.
/obj/machinery/power/supermatter_crystal/proc/get_integrity_percent()
	var/integrity = damage / explosion_point
	integrity = 100 - integrity * 100
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/power/supermatter_crystal/update_overlays()
	. = ..()
	if(psy_coeff > 0)
		. += mutable_appearance(icon = icon, icon_state = "[base_icon_state]-psy", layer = FLOAT_LAYER - 1, alpha = psy_coeff * 255)
	if(delamination_strategy)
		. += delamination_strategy.overlays(src)
	if(holiday_lights)
		if(istype(src, /obj/machinery/power/supermatter_crystal/shard))
			. += mutable_appearance(icon, "holiday_lights_shard")
			. += emissive_appearance(icon, "holiday_lights_shard_e", src, alpha = src.alpha)
		else
			. += mutable_appearance(icon, "holiday_lights")
			. += emissive_appearance(icon, "holiday_lights_e", src, alpha = src.alpha)
	return .

/obj/machinery/power/supermatter_crystal/update_icon(updates)
	. = ..()
	if(gas_heat_power_generation > 0.8)
		icon_state = "[base_icon_state]-glow"
	else
		icon_state = base_icon_state

/obj/machinery/power/supermatter_crystal/proc/time_frozen()
	SIGNAL_HANDLER
	if(disable_process != SM_PROCESS_ENABLED)
		return

	disable_process = SM_PROCESS_TIMESTOP

/obj/machinery/power/supermatter_crystal/proc/time_unfrozen()
	SIGNAL_HANDLER
	if(disable_process != SM_PROCESS_TIMESTOP)
		return

	disable_process = SM_PROCESS_ENABLED

/obj/machinery/power/supermatter_crystal/proc/force_delam()
	SIGNAL_HANDLER
	investigate_log("was forcefully delaminated", INVESTIGATE_ENGINE)
	INVOKE_ASYNC(delamination_strategy, TYPE_PROC_REF(/datum/sm_delam, delaminate), src)

/**
 * Отсчитывает, выдаёт сообщения и затем выполняет саму делимитацию.
 * Здесь мы защищаемся от последних изменений стратегии делимитации, в основном потому что у некоторых разные сообщения.
 *
 * Под последними изменениями мы подразумеваем, что возможно, например, тесла-делимитация
 * может просто взорваться обычным образом, если в последнюю секунду потеряет мощность и переключится на стандартную.
 * Даже после того, как отсчёт уже начался.
 */
/obj/machinery/power/supermatter_crystal/proc/count_down()
	set waitfor = FALSE

	if(final_countdown) // Уже идет, отвали
		stack_trace("[src] попытался начать делимитацию, когда она уже идет.")
		return

	final_countdown = TRUE

	notify_ghosts(
		"[src] начал процесс делимитации!",
		source = src,
		header = "Надвигается делимитация",
	)

	var/list/count_down_messages = delamination_strategy.count_down_messages()

	radio.talk_into(
		src,
		count_down_messages[1],
		emergency_channel,
		list(SPAN_COMMAND)
	)

	var/delamination_countdown_time = SUPERMATTER_COUNTDOWN_TIME
	// Если осколок был удалён из суперматерии, время отсчёта значительно сокращается
	if (supermatter_sliver_removed == TRUE)
		delamination_countdown_time = SUPERMATTER_SLIVER_REMOVED_COUNTDOWN_TIME
		radio.talk_into(
			src,
			"ВНИМАНИЕ: Прогнозируемое время до полного расслоения кристалла значительно ниже ожидаемого. \
			Пожалуйста, проверьте кристалл на структурные аномалии или признаки саботажа!",
			emergency_channel,
			list(SPAN_COMMAND)
			)

	for(var/i in delamination_countdown_time to 0 step -10)
		var/message
		var/healed = FALSE

		if(damage < explosion_point) // Инженеры, это было опасно близко
			message = count_down_messages[2]
			healed = TRUE
		else if((i % 50) != 0 && i > 50) // Сообщение каждые 5 секунд до последних 5 секунд, которые отсчитываются индивидуально
			sleep(1 SECONDS)
			continue
		else if(i > 50)
			message = "[DisplayTimeText(i, TRUE)] [count_down_messages[3]]"
		else
			message = "[i*0.1]..."

		radio.talk_into(src, message, emergency_channel, list(SPAN_COMMAND))

		if(healed)
			final_countdown = FALSE

			if(!istype(delamination_strategy, /datum/sm_delam/cascade))
				return

			for(var/mob/living/lucky_engi as anything in mobs_in_area_type(list(/area/station/engineering/supermatter)))
				if(isnull(lucky_engi.client))
					continue
				if(isanimal_or_basicmob(lucky_engi))
					continue
				LAZYADD(saviors, WEAKREF(lucky_engi))

			return // делимитация предотвращена
		sleep(1 SECONDS)

	delamination_strategy.delaminate(src)

// Все процедуры calculate должны только обновлять переменные.
// Перенесите реальные эффекты в [/obj/machinery/power/supermatter_crystal/process_atmos].

/**
 * Выполняет расчёт переменных, зависящих от газов.
 * Описание каждого фактора можно найти в дефайнах.
 *
 * Обновляет:
 * [/obj/machinery/power/supermatter_crystal/var/list/gas_percentage]
 * [/obj/machinery/power/supermatter_crystal/var/gas_power_transmission_rate]
 * [/obj/machinery/power/supermatter_crystal/var/gas_heat_modifier]
 * [/obj/machinery/power/supermatter_crystal/var/gas_heat_resistance]
 * [/obj/machinery/power/supermatter_crystal/var/gas_heat_power_generation]
 * [/obj/machinery/power/supermatter_crystal/var/gas_powerloss_inhibition]
 *
 * Возвращает: null
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_gases()
	if(disable_gas)
		return

	gas_percentage = list()
	gas_power_transmission_rate = 0
	gas_heat_modifier = 0
	gas_heat_resistance = 0
	gas_heat_power_generation = 0
	gas_powerloss_inhibition = 0

	var/total_moles = absorbed_gasmix.total_moles()
	if(total_moles < MINIMUM_MOLE_COUNT) //не стоит обрабатывать такие маленькие значения, total_moles также может быть 0 в вакууме
		return
	for (var/gas_path in absorbed_gasmix.gases)
		var/mole_count = absorbed_gasmix.gases[gas_path][MOLES]
		if(mole_count < MINIMUM_MOLE_COUNT) //экономим вычислительную мощность на таких маленьких значениях
			continue
		gas_percentage[gas_path] = mole_count / total_moles
		var/datum/sm_gas/sm_gas = current_gas_behavior[gas_path]
		if(!sm_gas)
			continue
		gas_power_transmission_rate += sm_gas.power_transmission * gas_percentage[gas_path]
		gas_heat_modifier += sm_gas.heat_modifier * gas_percentage[gas_path]
		gas_heat_resistance += sm_gas.heat_resistance * gas_percentage[gas_path]
		gas_heat_power_generation += sm_gas.heat_power_generation * gas_percentage[gas_path]
		gas_powerloss_inhibition += sm_gas.powerloss_inhibition * gas_percentage[gas_path]

	gas_heat_power_generation = clamp(gas_heat_power_generation, 0, 1)
	gas_powerloss_inhibition = clamp(gas_powerloss_inhibition, 0, 1)

/**
 * Выполняет расчёт потерь и прироста энергии за этот тик.
 * Описание каждого фактора можно найти в дефайнах.
 *
 * Обновляет:
 * [/obj/machinery/power/supermatter_crystal/var/internal_energy]
 * [/obj/machinery/power/supermatter_crystal/var/external_power_trickle]
 * [/obj/machinery/power/supermatter_crystal/var/external_power_immediate]
 *
 * Возвращает: Факторы, повлиявшие на расчёт. list[FACTOR_DEFINE] = число
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_internal_energy()
	if(disable_power_change)
		return
	var/list/additive_power = list()

	/// Если у нас небольшое количество external_power_trickle, мы просто округляем его до 40.
	additive_power[SM_POWER_EXTERNAL_TRICKLE] = external_power_trickle ? max(external_power_trickle/MATTER_POWER_CONVERSION, 40) : 0
	external_power_trickle -= min(additive_power[SM_POWER_EXTERNAL_TRICKLE], external_power_trickle)
	additive_power[SM_POWER_EXTERNAL_IMMEDIATE] = external_power_immediate
	external_power_immediate = 0
	additive_power[SM_POWER_HEAT] = gas_heat_power_generation * absorbed_gasmix.temperature * GAS_HEAT_POWER_SCALING_COEFFICIENT
	additive_power[SM_POWER_HEAT] && log_activation(who = "environmental factors")

	// Извините за это, но нам нужно рассчитывать потери энергии сразу после прироста.
	// Помогает предотвратить случаи, когда кто-то закачивает сверхгорячий газ в СМ и взвинчивает мощность до небес на один тик.
	/// Мощность без затухания. Используется для расчёта потерь.
	var/momentary_power = internal_energy
	for(var/powergain_type in additive_power)
		momentary_power += additive_power[powergain_type]
	if(momentary_power < powerloss_linear_threshold) // Отрицательные числа
		additive_power[SM_POWER_POWERLOSS] = -1 * (momentary_power / POWERLOSS_CUBIC_DIVISOR) ** 3
	else
		additive_power[SM_POWER_POWERLOSS] = -1 * (momentary_power * POWERLOSS_LINEAR_RATE + powerloss_linear_offset)
	// Положительные числа
	additive_power[SM_POWER_POWERLOSS_GAS] = -1 * gas_powerloss_inhibition *  additive_power[SM_POWER_POWERLOSS]
	additive_power[SM_POWER_POWERLOSS_SOOTHED] = -1 * min(1-gas_powerloss_inhibition , 0.2 * psy_coeff) *  additive_power[SM_POWER_POWERLOSS]

	for(var/powergain_types in additive_power)
		internal_energy += additive_power[powergain_types]
	internal_energy = max(internal_energy, 0)
	if(internal_energy && !activation_logged)
		stack_trace("Supermatter powered for the first time without being logged. Internal energy factors: [json_encode(internal_energy_factors)]")
		activation_logged = TRUE // чтобы не спамить лог.
	else if(!internal_energy)
		last_power_zap = world.time
		last_energy_accumulation_perspective_machines = SSmachines.times_fired
	return additive_power

/** Логирует первую активацию суперматерии.
 * Всё, что может увеличить [/obj/machinery/power/supermatter_crystal/var/internal_energy]
 * прямо или косвенно, ДОЛЖНО вызывать это.
 *
 * Аргументы:
 * * who - Строка или datum. То, что дало энергию СМ. Обязательно.
 * * how - Datum. Как они её зарядили. Опционально.
 */
/obj/machinery/power/supermatter_crystal/proc/log_activation(who, how)
	if(activation_logged || disable_power_change)
		return
	if(!who)
		CRASH("Суперматерия активирована неизвестным источником")

	if(istext(who))
		investigate_log("был впервые запущен [who][how ? " при помощи [how]" : ""].", INVESTIGATE_ENGINE)
		message_admins("[src] [ADMIN_JMP(src)] был впервые запущен [who][how ? " при помощи [how]" : ""].")
	else
		investigate_log("был впервые запущен [key_name(who)][how ? " при помощи [how]" : ""].", INVESTIGATE_ENGINE)
		message_admins("[src] [ADMIN_JMP(src)] был впервые запущен [ADMIN_FULLMONTY(who)][how ? " при помощи [how]" : ""].")
	activation_logged = TRUE

/**
 * Выполняет расчёт основной скорости передачи мощности разряда в Вт/МэВ.
 * Описание каждого фактора можно найти в дефайнах.
 *
 * Обновляет:
 * [/obj/machinery/power/supermatter_crystal/var/zap_transmission_rate]
 *
 * Возвращает: Факторы, повлиявшие на расчёт. list[FACTOR_DEFINE] = число
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_zap_transmission_rate()
	var/list/additive_transmission_rate = list()
	additive_transmission_rate[SM_ZAP_BASE] = BASE_POWER_TRANSMISSION_RATE
	additive_transmission_rate[SM_ZAP_GAS] = BASE_POWER_TRANSMISSION_RATE * gas_power_transmission_rate

	zap_transmission_rate = 0
	for (var/transmission_types in additive_transmission_rate)
		zap_transmission_rate += additive_transmission_rate[transmission_types]
	zap_transmission_rate = max(zap_transmission_rate, 0)
	return additive_transmission_rate

/**
 * Выполняет расчёт множителя отходов.
 * Это число влияет на температуру, плазму и кислород в отходящем газе.
 * Множитель применяется к энергии для плазмы и температуры, но к температуре для кислорода.
 *
 * Описание каждого фактора можно найти в дефайнах.
 *
 * Обновляет:
 * [/obj/machinery/power/supermatter_crystal/var/waste_multiplier]
 *
 * Возвращает: Факторы, повлиявшие на расчёт. list[FACTOR_DEFINE] = число
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_waste_multiplier()
	waste_multiplier = 0
	if(disable_gas)
		return
	/// Сообщаем людям о тепловыделении в энергии. Более информативно, чем сообщать множитель тепла.
	var/additive_waste_multiplier = list()
	additive_waste_multiplier[SM_WASTE_BASE] = 1
	additive_waste_multiplier[SM_WASTE_GAS] = gas_heat_modifier
	additive_waste_multiplier[SM_WASTE_SOOTHED] = -0.2 * psy_coeff

	for (var/waste_type in additive_waste_multiplier)
		waste_multiplier += additive_waste_multiplier[waste_type]
	waste_multiplier = clamp(waste_multiplier, 0.5, INFINITY)
	return additive_waste_multiplier

/**
 * Вычисляет температуру, при которой СМ начинает получать урон.
 * тепловой лимит задаётся: (T0C+40) * (1 + термостойкость газа + psy_coeff)
 *
 * Описание каждого фактора можно найти в дефайнах.
 *
 * Обновляет:
 * [/obj/machinery/power/supermatter_crystal/var/temp_limit]
 *
 * Возвращает: Факторы, повлиявшие на расчёт. list[FACTOR_DEFINE] = число
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_temp_limit()
	var/list/additive_temp_limit = list()
	additive_temp_limit[SM_TEMP_LIMIT_BASE] = T0C + HEAT_PENALTY_THRESHOLD
	additive_temp_limit[SM_TEMP_LIMIT_GAS] = gas_heat_resistance *  (T0C + HEAT_PENALTY_THRESHOLD)
	additive_temp_limit[SM_TEMP_LIMIT_SOOTHED] = psy_coeff * 45
	additive_temp_limit[SM_TEMP_LIMIT_LOW_MOLES] =  clamp(2 - absorbed_gasmix.total_moles() / 100, 0, 1) * (T0C + HEAT_PENALTY_THRESHOLD)

	temp_limit = 0
	for (var/resistance_type in additive_temp_limit)
		temp_limit += additive_temp_limit[resistance_type]
	temp_limit = max(temp_limit, TCMB)

	return additive_temp_limit

/**
 * Выполняет расчёт полученного или восстановленного урона.
 * Описание каждого фактора можно найти в дефайнах.
 *
 * Обновляет:
 * [/obj/machinery/power/supermatter_crystal/var/damage]
 *
 * Возвращает: Факторы, повлиявшие на расчёт. list[FACTOR_DEFINE] = число
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_damage()
	if(disable_damage)
		return

	var/list/additive_damage = list()
	var/total_moles = absorbed_gasmix.total_moles()

	// Мы не позволяем внешним факторам наносить урон сверх аварийной точки.
	// Учитывается только урон до выполнения этой процедуры. Мы игнорируем скоро применяемый урон.
	additive_damage[SM_DAMAGE_EXTERNAL] = external_damage_immediate * clamp((emergency_point - damage) / emergency_point, 0, 1)
	external_damage_immediate = 0

	additive_damage[SM_DAMAGE_HEAT] = clamp((absorbed_gasmix.temperature - temp_limit) / 24000, 0, 0.15)
	additive_damage[SM_DAMAGE_POWER] = clamp((internal_energy - POWER_PENALTY_THRESHOLD) / 40000, 0, 0.1)
	additive_damage[SM_DAMAGE_MOLES] = clamp((total_moles - MOLE_PENALTY_THRESHOLD) / 3200, 0, 0.1)

	var/is_spaced = FALSE
	if(isturf(src.loc))
		var/turf/local_turf = src.loc
		for (var/turf/open/space/turf in ((local_turf.atmos_adjacent_turfs || list()) + local_turf))
			additive_damage[SM_DAMAGE_SPACED] = clamp(internal_energy * 0.000125, 0, 1)
			is_spaced = TRUE
			break

	if(total_moles > 0 && !is_spaced)
		additive_damage[SM_DAMAGE_HEAL_HEAT] = clamp((absorbed_gasmix.temperature - temp_limit) / 6000, -0.1, 0)

	var/total_damage = 0
	for (var/damage_type in additive_damage)
		total_damage += additive_damage[damage_type]

	damage += total_damage
	damage = max(damage, 0)
	return additive_damage

/**
 * Устанавливает делимитацию нашей СМ.
 *
 * Аргументы:
 * * priority: Truthy-значения означают принудительную делимитацию. Если текущий forced_delam выше priority - не выполняем.
 * Установите число выше [SM_DELAM_PRIO_IN_GAME] для полного принуждения админской делимитации.
 * * delam_path: Путь типа [/datum/sm_delam]. [SM_DELAM_STRATEGY_PURGE] означает сброс и возврат приоритета к нулю.
 *
 * Возвращает: Ни для чего не используется, просто возвращает true при успешной установке, ручной и автоматической. Помогает админам проверять.
 */
/obj/machinery/power/supermatter_crystal/proc/set_delam(priority = SM_DELAM_PRIO_NONE, manual_delam_path = SM_DELAM_STRATEGY_PURGE)
	if(priority < delam_priority)
		return FALSE
	var/datum/sm_delam/new_delam = null

	if(manual_delam_path == SM_DELAM_STRATEGY_PURGE)
		for (var/delam_path in GLOB.sm_delam_list)
			var/datum/sm_delam/delam = GLOB.sm_delam_list[delam_path]
			if(!delam.can_select(src))
				continue
			if(delam == delamination_strategy)
				return FALSE
			new_delam = delam
			break
		delam_priority = SM_DELAM_PRIO_NONE
	else
		new_delam = GLOB.sm_delam_list[manual_delam_path]
		delam_priority = priority

	if(!new_delam)
		return FALSE
	delamination_strategy?.on_deselect(src)
	delamination_strategy = new_delam
	delamination_strategy.on_select(src)
	return TRUE

/**
 * Накопливает энергию для ключа zap_energy_accumulation.
 * Аргументы:
 * * key: Ключ накопления энергии разряда для использования.
 * * energy: Количество энергии для накопления.
 * Возвращает: Накопленную энергию для этого ключа.
 */
/obj/machinery/power/supermatter_crystal/proc/accumulate_energy(key, energy)
	. = (zap_energy_accumulation[key] ? zap_energy_accumulation[key] : 0) + energy
	zap_energy_accumulation[key] = .

/**
 * Расходует часть накопленной энергии для данного ключа и возвращает её. Используется для разрядки энергии из суперматерии.
 * Аргументы:
 * * key: Ключ накопления энергии разряда для использования.
 * * portion: Часть накопленной энергии, которая разряжается.
 * Возвращает: Разряженную энергию для этого ключа.
 */
/obj/machinery/power/supermatter_crystal/proc/discharge_energy(key, portion = ZAP_ENERGY_DISCHARGE_PORTION)
	. = portion * zap_energy_accumulation[key]
	zap_energy_accumulation[key] -= .

/obj/machinery/proc/supermatter_zap(atom/zapstart = src, range = 5, zap_str = 3.2 MEGA JOULES, zap_flags = ZAP_SUPERMATTER_FLAGS, list/targets_hit = list(), zap_cutoff = 1.2 MEGA JOULES, power_level = 0, zap_icon = DEFAULT_ZAP_ICON_STATE, color = null)
	if(QDELETED(zapstart))
		return
	if(zap_cutoff <= 0)
		stack_trace("/obj/machinery/supermatter_zap() was called with a non-positive value")
		return
	if(zap_str <= 0) // На случай, если что-то масштабирует zap_str и zap_cutoff до 0.
		return
	. = zapstart.dir
	//Если сила разряда падает ниже порога, останавливаемся
	if(zap_str < zap_cutoff)
		return
	var/atom/target
	var/target_type = LOWEST
	var/list/arc_targets = list()
	//Создаём новую копию, чтобы последующие добавления по рекурсии не мешали другим дугам
	//Добавим себя в список непопаданий, чтобы не вернуться и не ударить ту же цель дважды одной дугой
	for(var/atom/test as anything in oview(zapstart, range))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(targets_hit, test))
			continue

		if(istype(test, /obj/vehicle/ridden/bicycle/))
			var/obj/vehicle/ridden/bicycle/bike = test
			if(!HAS_TRAIT(bike, TRAIT_BEING_SHOCKED) && bike.can_buckle)//Бог не на нашей стороне, потому что он ненавидит идиотов.
				if(target_type != BIKE)
					arc_targets = list()
				arc_targets += test
				target_type = BIKE

		if(target_type > COIL)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/tesla_coil/))
			var/obj/machinery/power/energy_accumulator/tesla_coil/coil = test
			if(!HAS_TRAIT(coil, TRAIT_BEING_SHOCKED) && coil.anchored && !coil.panel_open && prob(70))//Разнообразие смерти
				if(target_type != COIL)
					arc_targets = list()
				arc_targets += test
				target_type = COIL

		if(target_type > ROD)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/grounding_rod/))
			var/obj/machinery/power/energy_accumulator/grounding_rod/rod = test
			//Добавляем эффекты повреждения машин, стержни должны быть надёжными
			if(rod.anchored && !rod.panel_open)
				if(target_type != ROD)
					arc_targets = list()
				arc_targets += test
				target_type = ROD

		if(target_type > LIVING)
			continue

		if(isliving(test))
			var/mob/living/alive = test
			if(!HAS_TRAIT(alive, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(alive, TRAIT_BEING_SHOCKED) && alive.stat != DEAD && prob(20))//Давайте не бить всех инженеров каждым лучом и/или сегментом дуги
				if(target_type != LIVING)
					arc_targets = list()
				arc_targets += test
				target_type = LIVING

		if(target_type > MACHINERY)
			continue

		if(ismachinery(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED) && prob(40))
				if(target_type != MACHINERY)
					arc_targets = list()
				arc_targets += test
				target_type = MACHINERY

		if(target_type > OBJECT)
			continue

		if(isobj(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED))
				if(target_type != OBJECT)
					arc_targets = list()
				arc_targets += test
				target_type = OBJECT

	if(arc_targets.len)//Выбираем из нашего пула
		target = pick(arc_targets)

	if(QDELETED(target))//Если ничего не нашли
		return

	//Анимируем разряд от сюда к цели
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(targets_hit, target, TRUE)
	zapstart.Beam(target, icon_state=zap_icon, time = 0.5 SECONDS, beam_color = color)
	var/zapdir = get_dir(zapstart, target)
	if(zapdir)
		. = zapdir

	//Взрывы должны быть редкими
	if(prob(80))
		zap_flags &= ~ZAP_MACHINE_EXPLOSIVE
	if(target_type == COIL || target_type == ROD)
		var/multi = 1
		switch(power_level)//Между 7к и 9к это 2, выше этого - 4
			if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
				multi = 2
			if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
				multi = 4
		if(zap_flags & ZAP_SUPERMATTER_FLAGS)
			var/remaining_power = target.zap_act(zap_str * multi, zap_flags)
			zap_str = remaining_power / multi //Катушки должны поглощать много энергии разряда
		else
			zap_str /= 3

	else if(isliving(target))//Если у нас в руках мешок с плотью
		var/mob/living/creature = target
		ADD_TRAIT(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
		addtimer(TRAIT_CALLBACK_REMOVE(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
		//3 разряда чтобы убить человека без сопротивления. 2 до крита, один до смерти. Это при мощности от 10000.
		//Увеличения после этого нет, потому что входная мощность эффективно ограничена 10к
		//Наносит минимум 1.5 урона
		var/shock_damage = ((zap_flags & ZAP_MOB_DAMAGE) ? (power_level / 200) - 10 : rand(5,10))
		creature.electrocute_act(shock_damage, "Supermatter Discharge Bolt", 1,  ((zap_flags & ZAP_MOB_STUN) ? SHOCK_TESLA : SHOCK_NOSTUN))
		zap_str /= 1.5 //Мясные мешки проводят ток, что делает работу в парах более разрушительной

	else
		zap_str = target.zap_act(zap_str, zap_flags)

	//Эта чёртова переменная - бумер и постоянно доставляет проблемы
	var/turf/target_turf = get_turf(target)
	var/pressure = 1
	// Рассчитываем давление и проводим электролиз.
	if(target_turf?.return_air())
		var/datum/gas_mixture/air_mixture = target_turf.return_air()
		pressure = max(1, air_mixture.return_pressure())
		air_mixture.electrolyze(working_power = zap_str / 200, electrolyzer_args = list(ELECTROLYSIS_ARGUMENT_SUPERMATTER_POWER = power_level))
		target_turf.air_update_turf()
	//Получаем наш диапазон с силой разряда и давлением, чем выше первое и ниже второе - тем лучше
	var/new_range = clamp(zap_str / pressure * 10, 2, 7)
	var/zap_count = 1
	if(prob(5))
		zap_str -= (zap_str/10)
		zap_count += 1
	for(var/j in 1 to zap_count)
		var/child_targets_hit = targets_hit
		if(zap_count > 1)
			child_targets_hit = targets_hit.Copy() //Прощай, передача по ссылке
		supermatter_zap(target, new_range, zap_str, zap_flags, child_targets_hit, zap_cutoff, power_level, zap_icon, color)

// Для /datum/sm_delam проверить, нужно ли отправлять оповещение на общий радиочастотный канал
/obj/machinery/power/supermatter_crystal/proc/should_alert_common()
	if(!COOLDOWN_FINISHED(src, common_radio_cooldown))
		return FALSE

	COOLDOWN_START(src, common_radio_cooldown, SUPERMATTER_COMMON_RADIO_DELAY)
	return TRUE

/obj/machinery/power/supermatter_crystal/proc/holiday_lights()
	holiday_lights = TRUE
	RegisterSignal(src, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(holiday_item_interaction))
	update_appearance()

/// Поглощает шапку Санты и добавляет её как оверлей
/obj/machinery/power/supermatter_crystal/proc/holiday_item_interaction(source, mob/living/user, obj/item/item, list/modifiers)
	SIGNAL_HANDLER
	if(istype(item, /obj/item/clothing/head/costume/santa))
		QDEL_NULL(item)
		RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(holiday_hat_examine))
		if(istype(src, /obj/machinery/power/supermatter_crystal/shard))
			add_overlay(mutable_appearance(icon, "santa_hat_shard"))
		else
			add_overlay(mutable_appearance(icon, "santa_hat"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/// Добавляет описательный текст о шапке при осмотре
/obj/machinery/power/supermatter_crystal/proc/holiday_hat_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_info("На нём красуется шапка Санты. Загадка, как она туда попала и не испарилась.")

#undef BIKE
#undef COIL
#undef ROD
#undef LIVING
#undef MACHINERY
#undef OBJECT
#undef LOWEST
