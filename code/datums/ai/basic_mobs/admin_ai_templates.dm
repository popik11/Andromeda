/// Используется для настройки базового контроллера ИИ на мобе для удобства админов
/datum/admin_ai_template
	/// Что видят админы при выборе этого варианта?
	var/name = ""
	/// Какой контроллер ИИ применяем?
	var/controller_type
	/// Должен ли контроллер оставаться активным при наличии клиента?
	var/override_client
	/// Применять враждебную фракцию?
	var/make_hostile
	/// Вероятность случайного перемещения при бездействии
	var/idle_chance
	/// При каком состоянии прекращать атаковать мобов?
	var/minimum_stat

/// Фактическое применение шаблона
/datum/admin_ai_template/proc/apply(mob/living/target, client/user)
	if (QDELETED(target) || !isliving(target))
		to_chat(user, span_warning("Недопустимая цель для контроллера ИИ."))
		return
	if (gather_information(target, user))
		apply_controller(target, user)

/// Настроить хранимые переменные перед применением контроллера
/datum/admin_ai_template/proc/gather_information(mob/living/target, client/user)
	override_client = tgui_alert(user, "Должен ли контроллер оставаться активным, даже если мобом управляет клиент?", "Переопределить клиент?", list("Да", "Нет"))
	if (isnull(override_client))
		return FALSE
	override_client = override_client == "Да"

	idle_chance = tgui_input_number(user, "Какова вероятность (% в секунду) случайного перемещения моба, когда он бездействует?", "Шанс перемещения", max_value = 100, min_value = 0)
	if (isnull(idle_chance))
		return FALSE

	if (isnull(make_hostile))
		make_hostile = tgui_alert(user, "Заменить фракцию моба на враждебную?", "Изменить фракцию?", list("Да", "Нет"))
		if (isnull(make_hostile))
			return FALSE
		make_hostile = make_hostile == "Да"

	if (isnull(minimum_stat))
		var/static/list/stat_types = list(
			"В сознании" = CONSCIOUS,
			"Лёгкий крит" = SOFT_CRIT,
			"Без сознания" = UNCONSCIOUS,
			"Тяжёлый крит" = HARD_CRIT,
			"Мёртв (вероятно, будет вечно бить труп)" = DEAD,
		)
		var/selected_stat = tgui_input_list(user, "Атаковать цели с максимальным уровнем здоровья...?", "Уровень настойчивости", stat_types, "Лёгкий крит")
		if (isnull(selected_stat))
			return FALSE
		minimum_stat = stat_types[selected_stat]

	return TRUE

/datum/admin_ai_template/proc/apply_controller(mob/living/target, client/user)
	if (QDELETED(target))
		to_chat(user, span_warning("Target stopped existing while you were answering prompts :("))
		return

	QDEL_NULL(target.ai_controller)
	target.ai_controller = new controller_type(target)

	if (make_hostile)
		target.faction = list(FACTION_HOSTILE, REF(target))

	var/datum/ai_controller/controller = target.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_IDLE_WALK_CHANCE, idle_chance)
	controller.set_blackboard_key(BB_TARGET_MINIMUM_STAT, minimum_stat)
	if (override_client)
		controller.continue_processing_when_client = TRUE
		controller.reset_ai_status()

/// Идёт к цели и атакует
/datum/admin_ai_template/hostile
	name = "Враждебный ближний бой"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

/// Отходит от цели и атакует
/datum/admin_ai_template/hostile_ranged
	name = "Враждебная дальняя атака"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_ranged
	/// На каком расстоянии отступать?
	var/min_range
	/// На каком расстоянии приближаться?
	var/max_range
	/// Какой снаряд выпускать?
	var/projectile_type
	/// Задержка между выстрелами?
	var/fire_cooldown
	/// Сколько снарядов за очередь?
	var/burst_shots
	/// Задержка между снарядами в очереди?
	var/burst_interval
	/// Звук выстрела?
	var/projectile_sound

/datum/admin_ai_template/hostile_ranged/gather_information(mob/living/target, client/user)
	. = ..()
	if (!.)
		return FALSE

	if (!setup_ranged_attacks(target, user))
		return FALSE

	return decide_min_max_range(target, user)

/// Дать цель огнестрельное оружие
/datum/admin_ai_template/hostile_ranged/proc/setup_ranged_attacks(mob/living/target, client/user)
	if (target.GetComponent(/datum/component/ranged_attacks))
		return TRUE

	var/static/list/all_projectiles = subtypesof(/obj/projectile)
	// Названия не очень удобные для пользователя, но вариантов много, извините админы
	projectile_type = tgui_input_list(user, "Какой снаряд выпускать?", "Выбор боеприпаса", all_projectiles)
	if (isnull(projectile_type))
		return FALSE

	fire_cooldown = tgui_input_number(user, "Сколько секунд между выстрелами?", "Скорострельность", round_value = FALSE, max_value = 10, min_value = 0.2, default = 1)
	if (isnull(fire_cooldown))
		return FALSE
	fire_cooldown = fire_cooldown SECONDS

	burst_shots = tgui_input_number(user, "Сколько выстрелов за очередь?", "Количество в очереди", max_value = 100, min_value = 1, default = 1)
	if (isnull(burst_shots))
		return FALSE
	if (burst_shots > 1)
		burst_interval = tgui_input_number(user, "Задержка между выстрелами в очереди (сек)?", "Скорость очереди", round_value = FALSE, max_value = 2, min_value = 0.1, default = 0.2)
		if (isnull(burst_interval))
			return FALSE
		burst_interval = burst_interval SECONDS

	var/pick_sound = tgui_alert(user, "Выбрать звук выстрела?", "Выбор звука", list("Да", "Нет"))
	if (isnull(pick_sound))
		return FALSE
	if (pick_sound == "Да")
		projectile_sound = input("", "Выберите звук выстрела",) as null|sound

	return TRUE

/// Определение параметров движения
/datum/admin_ai_template/hostile_ranged/proc/decide_min_max_range(mob/living/target, client/user)
	min_range = tgui_input_number(user, "На каком минимальном расстоянии держаться от цели?", "Минимальная дистанция", max_value = 9, min_value = 0, default = 2)
	if (isnull(min_range))
		return FALSE

	max_range = tgui_input_number(user, "На каком максимальном расстоянии держаться от цели?", "Максимальная дистанция", max_value = 9, min_value = 1, default = 6)
	if (isnull(max_range))
		return FALSE

	return TRUE

/datum/admin_ai_template/hostile_ranged/apply_controller(mob/living/target, client/user)
	. = ..()

	var/datum/ai_controller/controller = target.ai_controller
	controller.set_blackboard_key(BB_RANGED_SKIRMISH_MIN_DISTANCE, min_range)
	controller.set_blackboard_key(BB_RANGED_SKIRMISH_MAX_DISTANCE, max_range)

	if (!projectile_type)
		return

	target.AddComponent(\
		/datum/component/ranged_attacks,\
		cooldown_time = fire_cooldown,\
		projectile_type = projectile_type,\
		projectile_sound = projectile_sound,\
		burst_shots = burst_shots,\
		burst_intervals = burst_interval,\
	)

	if (fire_cooldown <= 1 SECONDS)
		target.AddComponent(/datum/component/ranged_mob_full_auto)

/// Идёт к цели, стреляя и атакуя в ближнем бою
/datum/admin_ai_template/hostile_ranged/and_melee
	name = "Враждебная комбинированная атака"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_skirmisher

/datum/admin_ai_template/hostile_ranged/and_melee/decide_min_max_range(mob/living/target, client/user)
	return TRUE

/// Держит дистанцию и использует способности по перезарядке
/datum/admin_ai_template/ability
	name = "Враждебный использующий способности"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_ability
	/// Тип используемой способности
	var/ability_type
	/// Минимальная дистанция отступления
	var/min_range
	/// Максимальная дистанция приближения
	var/max_range

/datum/admin_ai_template/ability/gather_information(mob/living/target, client/user)
	. = ..()
	if (!.)
		return FALSE

	// Ограничимся действиями мобов, так как они уже настроены для случайных мобов, а заклинания требуют дополнительной настройки (одежда волшебника и т.д.)
	var/static/list/all_mob_actions = sort_list(subtypesof(/datum/action/cooldown/mob_cooldown), GLOBAL_PROC_REF(cmp_typepaths_asc))
	var/static/list/actions_by_name = list()
	if (!length(actions_by_name))
		for (var/datum/action/cooldown/mob_cooldown as anything in all_mob_actions)
			actions_by_name["[initial(mob_cooldown.name)] ([mob_cooldown])"] = mob_cooldown

	ability_type = tgui_input_list(user, "Какую способность использовать?", "Выбор способности", actions_by_name)
	if (isnull(ability_type))
		return FALSE

	ability_type = actions_by_name[ability_type]
	return decide_min_max_range(target, user)

/// Определение параметров движения (к сожалению, частично дублируется)
/datum/admin_ai_template/ability/proc/decide_min_max_range(mob/living/target, client/user)
	min_range = tgui_input_number(user, "На каком минимальном расстоянии держаться от цели?", "Минимальная дистанция", max_value = 9, min_value = 0, default = 2)
	if (isnull(min_range))
		return FALSE

	max_range = tgui_input_number(user, "На каком максимальном расстоянии держаться от цели?", "Максимальная дистанция", max_value = 9, min_value = 1, default = 6)
	if (isnull(max_range))
		return FALSE

	return TRUE

/datum/admin_ai_template/ability/apply_controller(mob/living/target, client/user)
	. = ..()

	var/datum/action/cooldown/ability = locate(ability_type) in target.actions
	if (isnull(ability))
		ability = new ability_type(target)
		ability.Grant(target)

	var/datum/ai_controller/controller = target.ai_controller
	controller.set_blackboard_key(BB_TARGETED_ACTION, ability)
	controller.set_blackboard_key(BB_RANGED_SKIRMISH_MIN_DISTANCE, min_range)
	controller.set_blackboard_key(BB_RANGED_SKIRMISH_MAX_DISTANCE, max_range)

/// Идёт к цели и использует способность в ближнем бою
/datum/admin_ai_template/ability/melee
	name = "Враждебный использующий способности (ближние атаки)"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_ability_melee

/datum/admin_ai_template/ability/melee/decide_min_max_range(mob/living/target, client/user)
	return TRUE

/// Держится на расстоянии и использует способности
/datum/admin_ai_template/hostile_ranged/ability
	name = "Враждебный использующий способности (дальние атаки)"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_ability_ranged
	/// Тип используемой способности
	var/ability_type

/datum/admin_ai_template/hostile_ranged/ability/gather_information(mob/living/target, client/user)
	. = ..()
	if (!.)
		return FALSE

// К сожалению, приходится дублировать и здесь
	var/static/list/all_mob_actions = sort_list(subtypesof(/datum/action/cooldown/mob_cooldown), GLOBAL_PROC_REF(cmp_typepaths_asc))
	var/static/list/actions_by_name = list()
	if (!length(actions_by_name))
		for (var/datum/action/cooldown/mob_cooldown as anything in all_mob_actions)
			actions_by_name["[initial(mob_cooldown.name)] ([mob_cooldown])"] = mob_cooldown

	ability_type = tgui_input_list(user, "Какую способность использовать?", "Выбор способности", actions_by_name)
	if (isnull(ability_type))
		return FALSE
	ability_type = actions_by_name[ability_type]
	return TRUE

/datum/admin_ai_template/hostile_ranged/ability/apply_controller(mob/living/target, client/user)
	. = ..()

	var/datum/action/cooldown/ability = locate(ability_type) in target.actions
	if (isnull(ability))
		ability = new ability_type(target)
		ability.Grant(target)

	var/datum/ai_controller/controller = target.ai_controller
	controller.set_blackboard_key(BB_TARGETED_ACTION, ability)

/// Спокойный, но даёт сдачи
/datum/admin_ai_template/retaliate
	name = "Пассивный, но отвечает (ближний бой)"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_retaliate
	make_hostile = FALSE

/datum/admin_ai_template/retaliate/apply_controller(mob/living/target, client/user)
	. = ..()
	if (!HAS_TRAIT_FROM(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, /datum/element/ai_retaliate)) // Не совсем для этого предназначено, но должно работать
		target.AddElement(/datum/element/ai_retaliate)

/// Стреляет в ответ на атаки
/datum/admin_ai_template/hostile_ranged/ability/retaliate
	name = "Пассивный, но отвечает (дальние атаки)"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_ranged_retaliate
	make_hostile = FALSE

/datum/admin_ai_template/hostile_ranged/ability/retaliate/apply_controller(mob/living/target, client/user)
	. = ..()
	if (!HAS_TRAIT_FROM(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, /datum/element/ai_retaliate)) // Не совсем для этого предназначено, но должно работать
		target.AddElement(/datum/element/ai_retaliate)

/// Использует свою фирменную способность в ответ на атаки
/datum/admin_ai_template/ability/retaliate
	name = "Пассивный, но отвечает (способности)"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_ability_retaliate
	make_hostile = FALSE

/datum/admin_ai_template/ability/retaliate/apply_controller(mob/living/target, client/user)
	. = ..()
	if (!HAS_TRAIT_FROM(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, /datum/element/ai_retaliate)) // Не совсем для этого предназначено, но должно работать
		target.AddElement(/datum/element/ai_retaliate)

/// Кто знает, что сделает этот тип - он непредсказуем
/datum/admin_ai_template/grumpy
	name = "Злится непредсказуемо"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_capricious
	make_hostile = FALSE
	/// Шанс в секунду разозлиться
	var/flipout_chance
	/// Шанс в секунду успокоиться
	var/calm_down_chance

/datum/admin_ai_template/grumpy/gather_information(mob/living/target, client/user)
	. = ..()
	if (!.)
		return FALSE

	flipout_chance = tgui_input_number(user, "Какой % шанс в секунду беспричинно злиться?", "Шанс ярости", round_value = FALSE, max_value = 100, min_value = 0, default = 0.5)
	if (isnull(flipout_chance))
		return FALSE

	calm_down_chance = tgui_input_number(user, "Какой % шанс в секунду успокоиться?", "Шанс успокоения", round_value = FALSE, max_value = 100, min_value = 0, default = 10)
	if (isnull(calm_down_chance))
		return FALSE

	return TRUE

/datum/admin_ai_template/grumpy/apply_controller(mob/living/target, client/user)
	. = ..()
	var/datum/ai_controller/controller = target.ai_controller
	controller.set_blackboard_key(BB_RANDOM_AGGRO_CHANCE, flipout_chance)
	controller.set_blackboard_key(BB_RANDOM_DEAGGRO_CHANCE, calm_down_chance)

	if (!HAS_TRAIT_FROM(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, /datum/element/ai_retaliate)) // Не совсем для этого предназначено, но должно работать
		target.AddElement(/datum/element/ai_retaliate)

/// Трус
/datum/admin_ai_template/fearful
	name = "Беглец"
	minimum_stat = CONSCIOUS
	make_hostile = FALSE
	controller_type = /datum/ai_controller/basic_controller/simple/simple_fearful

/// Не любит насилие
/datum/admin_ai_template/skittish
	name = "Убегает от атакующих"
	minimum_stat = CONSCIOUS
	make_hostile = FALSE
	controller_type = /datum/ai_controller/basic_controller/simple/simple_skittish

/datum/admin_ai_template/skittish/apply_controller(mob/living/target, client/user)
	. = ..()
	if (!HAS_TRAIT_FROM(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, /datum/element/ai_retaliate)) // Не совсем для этого предназначено, но должно работать
		target.AddElement(/datum/element/ai_retaliate)

/// Слушается команд
/datum/admin_ai_template/goon
	name = "Послушный подручный"
	controller_type = /datum/ai_controller/basic_controller/simple/simple_goon
	/// Кто здесь главный?
	var/mob/living/da_boss

/datum/admin_ai_template/goon/gather_information(mob/living/target, client/user)
	. = ..()
	if (!.)
		return FALSE

	var/find_a_mob = tgui_alert(user, "Сделать этого моба подручным другого моба на вашей клетке? (Если отказаться, нужно будет использовать proc befriend)", "Назначить хозяина?", list("Да", "Нет"))
	if (isnull(override_client))
		return FALSE
	find_a_mob = find_a_mob == "Да"
	if (!find_a_mob)
		return TRUE

	return grab_mob(target, user)

/// Найти моба, который станет боссом
/datum/admin_ai_template/goon/proc/grab_mob(mob/living/target, client/user)
	var/list/mobs_in_my_tile = list()
	for (var/mob/living/dude in (range(0, user.mob) - target))
		mobs_in_my_tile[dude.real_name] = dude

	if (length(mobs_in_my_tile))
		var/picked = tgui_input_list(user, "Выберите нового хозяина.", "Назначить хозяина", mobs_in_my_tile + "Попробовать снова", "Попробовать снова")
		if (isnull(picked))
			return FALSE
		if (picked == "Попробовать снова")
			return grab_mob(target, user)

		da_boss = mobs_in_my_tile[picked]
		return TRUE

	var/find_a_mob = tgui_alert(user, "Подходящих мобов не найдено. Попробовать снова?", "Повторить?", list("Да", "Нет"))
	if (isnull(find_a_mob))
		return FALSE
	find_a_mob = find_a_mob == "Да"
	if (!find_a_mob)
		return TRUE
	return grab_mob(target, user)

/datum/admin_ai_template/goon/apply_controller(mob/living/target, client/user)
	. = ..()
	// Пока нет особого смысла делать это настраиваемым
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/move,
		/datum/pet_command/attack,
		/datum/pet_command/follow/start_active,
		/datum/pet_command/protect_owner,
	)
	target.AddComponent(/datum/component/obeys_commands, pet_commands)

	if (isnull(da_boss))
		return

	target.befriend(da_boss)

/// Возврат к предыдущему состоянию до вмешательства (не всегда возможно полностью восстановить)
/datum/admin_ai_template/reset
	name = "Сбросить"

/datum/admin_ai_template/reset/gather_information(mob/living/target, client/user)
	return TRUE

/datum/admin_ai_template/reset/apply_controller(mob/living/target, client/user)
	QDEL_NULL(target.ai_controller)
	var/controller_type = initial(target.ai_controller)
	target.ai_controller = new controller_type(src)

/// Как будто я вообще ничего не делаю, ничего
/datum/admin_ai_template/clear
	name = "Отсутствует"

/datum/admin_ai_template/clear/gather_information(mob/living/target, client/user)
	return TRUE

/datum/admin_ai_template/clear/apply_controller(mob/living/target, client/user)
	QDEL_NULL(target.ai_controller)
