// Любая мощность сверх этого числа будет ограничена
#define MAX_ACCEPTED_POWER_OUTPUT 5000

// При максимальной выходной мощности, при условии отсутствия изменений целостности, порог будет равен 0.
#define THRESHOLD_EQUATION_SLOPE (-1 / MAX_ACCEPTED_POWER_OUTPUT)

// Чем выше это число, тем быстрее низкая целостность будет снижать порог
// Я бы назвал это "мощностью", но, знаете ли. :P
#define INTEGRITY_EXPONENTIAL_DEGREE 2

// При INTEGRITY_MIN_NUDGABLE_AMOUNT, мощность будет рассматриваться как максимум INTEGRITY_MAX_POWER_NUDGE.
// Любая более низкая целостность приведет к INTEGRITY_MAX_POWER_NUDGE.
#define INTEGRITY_MAX_POWER_NUDGE 1500
#define INTEGRITY_MIN_NUDGABLE_AMOUNT 0.7

#define RADIATION_CHANCE_AT_FULL_INTEGRITY 0.03
#define RADIATION_CHANCE_AT_ZERO_INTEGRITY 0.4
#define CHANCE_EQUATION_SLOPE (RADIATION_CHANCE_AT_ZERO_INTEGRITY - RADIATION_CHANCE_AT_FULL_INTEGRITY)

/obj/machinery/power/supermatter_crystal/proc/emit_radiation()
	// С ростом мощности растёт и радиация.
	// Стандартный СМ на N2, кажется, выдаёт значение около 1500.
	var/power_factor = min(internal_energy, MAX_ACCEPTED_POWER_OUTPUT)

	var/integrity = 1 - CLAMP01(damage / explosion_point)

	// При снижении целостности порог (с точки зрения наблюдателя, радиация) повышается.
	// Однако коэффициент мощности также должен расти, иначе отключение эмиттеров
	// на делимитирующем СМ остановило бы утечку радиации.
	// Чтобы это исправить, низкая целостность повышает коэффициент мощности до минимума.
	var/integrity_power_nudge = LERP(INTEGRITY_MAX_POWER_NUDGE, 0, CLAMP01((integrity - INTEGRITY_MIN_NUDGABLE_AMOUNT) / (1 - INTEGRITY_MIN_NUDGABLE_AMOUNT)))

	power_factor = max(power_factor, integrity_power_nudge)

	// При "нормальной" выходной мощности N2 (с максимальной целостностью) это 0.7, что достаточно для остановки
	// стенами или радиационными ставнями.
	// При снижении целостности радиация растёт.
	var/threshold
	switch(integrity)
		if(0)
			threshold = power_factor ? 0 : 1
		if(1)
			threshold = (THRESHOLD_EQUATION_SLOPE * power_factor + 1)
		else
			threshold = (THRESHOLD_EQUATION_SLOPE * power_factor + 1) ** ((1 / integrity) ** INTEGRITY_EXPONENTIAL_DEGREE)

	// Расчёт шанса полностью зависит от целостности, чтобы активно делимитирующие СМ ощущались опаснее.
	var/chance = (CHANCE_EQUATION_SLOPE * (1 - integrity)) + RADIATION_CHANCE_AT_FULL_INTEGRITY

	radiation_pulse(
		src,
		max_range = 8,
		threshold = threshold,
		chance = chance * 100,
	)

/obj/machinery/power/supermatter_crystal/proc/processing_sound()
	if(internal_energy)
		soundloop.volume = clamp((50 + (internal_energy / 50)), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	//Мы проигрываем звуки делимитации/нейтральные с частотой, определяемой мощностью и уроном.
	if(last_accent_sound >= world.time || !prob(20))
		return
	var/aggression = min(((damage / 800) * (internal_energy / 2500)), 1.0) * 100
	if(damage >= 300)
		playsound(src, SFX_SM_DELAM, max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
	else
		playsound(src, SFX_SM_CALM, max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
	var/next_sound = round((100 - aggression) * 5)
	last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

/obj/machinery/power/supermatter_crystal/proc/psychological_examination()
	// По умолчанию значение меньше 1. Со временем psy_coeff стремится к 0, если
	// поблизости нет суперматериальных успокоителей.
	var/psy_coeff_diff = -0.05
	for(var/mob/living/carbon/human/seen_by_sm in view(src, SM_HALLUCINATION_RANGE(internal_energy)))
		// Кто-то (обычно психолог), смотрящий на СМ в пределах радиуса галлюцинаций, облегчает управление им.
		if(HAS_MIND_TRAIT(seen_by_sm, TRAIT_SUPERMATTER_SOOTHER))
			psy_coeff_diff = 0.05
	visible_hallucination_pulse(
		center = src,
		radius = SM_HALLUCINATION_RANGE(internal_energy),
		hallucination_duration = internal_energy * hallucination_power,
		hallucination_max_duration = 400 SECONDS,
	)
	psy_coeff = clamp(psy_coeff + psy_coeff_diff, 0, 1)

/obj/machinery/power/supermatter_crystal/proc/handle_high_power()
	if(internal_energy <= POWER_PENALTY_THRESHOLD && damage <= danger_point) //Если мощность выше 5000 или урон выше 550
		last_high_energy_accumulation_perspective_machines = SSmachines.times_fired //Предотвращаем аномально высокий начальный разряд из-за того, что высокоэнергетические разряды не срабатывают при слишком низкой энергии.
		return
	var/range = 4
	zap_cutoff = 1500
	var/total_moles = absorbed_gasmix.total_moles()
	var/pressure = absorbed_gasmix.return_pressure()
	var/temp = absorbed_gasmix.temperature
	if(pressure > 0 && temp > 0)
		//Возможно, хорошим планированием можно заморозить состояние разряда двигателя, посмотрим
		zap_cutoff = clamp(1.2e6 - (internal_energy * total_moles * 40) / temp, 1.4e5, 1.2e6)//Если ядро холодное, прыжок проще, то же самое, если много молей
		//Мы всегда должны иметь возможность вырваться из стандартного корпуса
		//Подробнее см. supermatter_zap()
		range = clamp(internal_energy / pressure * 10, 2, 7)
	var/flags = ZAP_SUPERMATTER_FLAGS
	var/zap_count = 0
	//Разбираемся с силовыми разрядами
	switch(internal_energy)
		if(POWER_PENALTY_THRESHOLD to SEVERE_POWER_PENALTY_THRESHOLD)
			zap_icon = DEFAULT_ZAP_ICON_STATE
			zap_count = 2
		if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
			zap_icon = SLIGHTLY_CHARGED_ZAP_ICON_STATE
			//Снимает ограничение с урона от разряда, он ограничен входной мощностью
			//Объекты теперь получают урон
			flags |= (ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
			zap_count = 3
		if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
			zap_icon = OVER_9000_ZAP_ICON_STATE
			//Теперь оглушает сильнее, и урон будет выше, перчатки не гарантия.
			//Машины взрываются
			flags |= (ZAP_MOB_STUN | ZAP_MACHINE_EXPLOSIVE | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
			zap_count = 4
	//Теперь разбираемся с уроном
	if (damage > danger_point && prob(20))
		zap_count += 1

	if(zap_count >= 1)
		playsound(loc, 'sound/items/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
		var/delta_time = (SSmachines.times_fired - last_high_energy_accumulation_perspective_machines) * SSmachines.wait / (1 SECONDS)
		var/accumulated_energy = accumulate_energy(ZAP_ENERGY_ACCUMULATION_HIGH_ENERGY, energy = clamp(internal_energy * 3200, 6.4e6, 3.2e7) * delta_time)
		if(accumulated_energy)
			for(var/i in 1 to zap_count)
				var/discharged_energy = discharge_energy(ZAP_ENERGY_ACCUMULATION_HIGH_ENERGY, portion = 1 - (1 - ZAP_ENERGY_DISCHARGE_PORTION) ** INVERSE(zap_count))
				supermatter_zap(src, range = range, zap_str = discharged_energy, zap_flags = flags, zap_cutoff = src.zap_cutoff, power_level = internal_energy, zap_icon = src.zap_icon)
		last_high_energy_accumulation_perspective_machines = SSmachines.times_fired
	if(prob(5))
		supermatter_anomaly_gen(get_ranged_target_turf(src, pick(GLOB.cardinals), rand(5, 10)), FLUX_ANOMALY, 3)
	if(prob(5))
		supermatter_anomaly_gen(get_ranged_target_turf(src, pick(GLOB.cardinals), rand(5, 10)), HALLUCINATION_ANOMALY, 3)
	if(internal_energy > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
		supermatter_anomaly_gen(get_ranged_target_turf(src, pick(GLOB.cardinals), rand(5, 10)), GRAVITATIONAL_ANOMALY, 3)
	if((internal_energy > SEVERE_POWER_PENALTY_THRESHOLD && prob(2)) || (prob(0.3) && internal_energy > POWER_PENALTY_THRESHOLD))
		supermatter_anomaly_gen(get_ranged_target_turf(src, pick(GLOB.cardinals), rand(5, 10)), PYRO_ANOMALY, 3)

/obj/machinery/power/supermatter_crystal/proc/supermatter_pull(turf/center, pull_range = 3)
	playsound(center, 'sound/items/weapons/marauder.ogg', 100, TRUE, extrarange = pull_range - world.view)
	for(var/atom/movable/movable_atom in orange(pull_range,center))
		if((movable_atom.anchored || movable_atom.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)) //мемы сопротивления движению.
			if(istype(movable_atom, /obj/structure/closet))
				var/obj/structure/closet/closet = movable_atom
				closet.open(force = TRUE)
			continue
		if(ismob(movable_atom))
			var/mob/pulled_mob = movable_atom
			if(pulled_mob.mob_negates_gravity())
				continue //Нельзя тянуть того, кто прибит к палубе.
		step_towards(movable_atom,center)

/proc/supermatter_anomaly_gen(turf/anomalycenter, type = FLUX_ANOMALY, anomalyrange = 5, has_changed_lifespan = TRUE)
	var/turf/local_turf = pick(RANGE_TURFS(anomalyrange, anomalycenter))
	if(!local_turf)
		return
	switch(type)
		if(FLUX_ANOMALY)
			var/explosive = has_changed_lifespan ? FLUX_NO_EMP : FLUX_LIGHT_EMP
			new /obj/effect/anomaly/flux(local_turf, has_changed_lifespan ? rand(25 SECONDS, 35 SECONDS) : null, FALSE, explosive)
		if(GRAVITATIONAL_ANOMALY)
			new /obj/effect/anomaly/grav(local_turf, has_changed_lifespan ? rand(20 SECONDS, 30 SECONDS) : null, FALSE)
		if(PYRO_ANOMALY)
			new /obj/effect/anomaly/pyro(local_turf, has_changed_lifespan ? rand(15 SECONDS, 25 SECONDS) : null, FALSE)
		if(HALLUCINATION_ANOMALY)
			new /obj/effect/anomaly/hallucination/supermatter(local_turf, has_changed_lifespan ? rand(15 SECONDS, 25 SECONDS) : null, FALSE)
		if(VORTEX_ANOMALY)
			new /obj/effect/anomaly/bhole(local_turf, 2 SECONDS, FALSE)
		if(BIOSCRAMBLER_ANOMALY)
			new /obj/effect/anomaly/bioscrambler/docile(local_turf, null, FALSE)
		if(DIMENSIONAL_ANOMALY)
			new /obj/effect/anomaly/dimensional(local_turf, null, FALSE)

#undef CHANCE_EQUATION_SLOPE
#undef INTEGRITY_EXPONENTIAL_DEGREE
#undef INTEGRITY_MAX_POWER_NUDGE
#undef INTEGRITY_MIN_NUDGABLE_AMOUNT
#undef MAX_ACCEPTED_POWER_OUTPUT
#undef RADIATION_CHANCE_AT_FULL_INTEGRITY
#undef RADIATION_CHANCE_AT_ZERO_INTEGRITY
#undef THRESHOLD_EQUATION_SLOPE
