SUBSYSTEM_DEF(dynamic)
	name = "Dynamic"
	flags = SS_NO_INIT
	wait = 5 MINUTES

	// These vars just exist for admins interfacing with dynamic
	/// Cooldown between "we're going to spawn a midround" and "we're actually spawning a midround", to give admins a chance to cancel
	COOLDOWN_DECLARE(midround_admin_cancel_period)
	/// Set to TRUE by hrefs if admins cancel a midround
	var/tmp/midround_admin_cancel = FALSE
	/// Set to TRUE by hrefs if admins reroll a midround
	var/tmp/midround_admin_reroll = FALSE
	/// Set to TRUE by admin panels if they want to max out the chance of a light ruleset spawning
	var/tmp/admin_forcing_next_light = FALSE
	/// Set to TRUE by admin panels if they want to max out the chance of a heavy ruleset spawning
	var/tmp/admin_forcing_next_heavy = FALSE
	/// Set to TRUE by admin panels if they want to max out the chance of a latejoin ruleset spawning
	var/tmp/admin_forcing_next_latejoin = FALSE
	/// List of ruleset typepaths that admins have explicitly disabled
	var/tmp/list/admin_disabled_rulesets = list()

	// Dynamic vars
	/// Reference to a dynamic tier datum, the tier picked for this round
	var/datum/dynamic_tier/current_tier
	/// The config for dynamic loaded from the toml file
	var/list/dynamic_config = list()
	/// Tracks how many of each ruleset category is yet to be spawned
	var/list/rulesets_to_spawn = list(
		ROUNDSTART = -1,
		LIGHT_MIDROUND = -1,
		HEAVY_MIDROUND = -1,
		LATEJOIN = -1,
	)
	/// Tracks the number of rulesets to spawn at game start (for admin reference)
	var/list/base_rulesets_to_spawn = list(
		ROUNDSTART = 0,
		LIGHT_MIDROUND = 0,
		HEAVY_MIDROUND = 0,
		LATEJOIN = 0,
	)
	/// Cooldown for when we are allowed to spawn light rulesets
	COOLDOWN_DECLARE(light_ruleset_start)
	/// Cooldown for when we are allowed to spawn heavy rulesets
	COOLDOWN_DECLARE(heavy_ruleset_start)
	/// Cooldown for when we are allowed to spawn latejoin rulesets
	COOLDOWN_DECLARE(latejoin_ruleset_start)
	/// Tracks how many time we fail to spawn a latejoin (to up the odds next time)
	var/failed_latejoins = 0
	/// Cooldown between midround ruleset executions
	COOLDOWN_DECLARE(midround_cooldown)
	/// Cooldown between latejoin ruleset executions
	COOLDOWN_DECLARE(latejoin_cooldown)
	/// List of rulesets that have been executed this round
	var/list/datum/dynamic_ruleset/executed_rulesets = list()
	/// List of rulesets that have been set up to run, but not yet executed
	var/list/datum/dynamic_ruleset/queued_rulesets = list()
	/// Rulesets in this list will be excluded from the roundend report
	var/list/datum/dynamic_ruleset/unreported_rulesets = list()
	/// Whether random events that spawn antagonists or modify dynamic are enabled
	var/antag_events_enabled = TRUE

/datum/controller/subsystem/dynamic/fire(resumed)
	if(!COOLDOWN_FINISHED(src, midround_cooldown) || EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return

	if(COOLDOWN_FINISHED(src, light_ruleset_start))
		if(try_spawn_midround(LIGHT_MIDROUND))
			return

	if(COOLDOWN_FINISHED(src, heavy_ruleset_start))
		if(try_spawn_midround(HEAVY_MIDROUND))
			return

/datum/controller/subsystem/dynamic/proc/get_config()
	if(!length(dynamic_config))
		load_config()
	return dynamic_config

/// Used to get a config entry for some variable on some typepath
/// Can be passed a default value.
/datum/controller/subsystem/dynamic/proc/get_config_value(datum/some_typepath, var_name, default_value)
	var/config_tag
	if(ispath(some_typepath, /datum/dynamic_ruleset))
		var/datum/dynamic_ruleset/ruleset_type = some_typepath
		config_tag = ruleset_type::config_tag
	else if(ispath(some_typepath, /datum/dynamic_tier))
		var/datum/dynamic_tier/tier_type = some_typepath
		config_tag = tier_type::config_tag
	else
		stack_trace("Dynamic get_config_value called with invalid typepath: [some_typepath]")
		return default_value

	if(isnull(config_tag)) // Technically valid
		return default_value

	if(!length(dynamic_config))
		load_config()

	var/config_value = dynamic_config?[config_tag]?[var_name]
	return isnull(config_value) ? default_value : config_value

/**
 * Selects which rulesets are to run at roundstart, and sets them up
 *
 * Note: This proc can sleep (due to lazyloading of templates)!
 */
/datum/controller/subsystem/dynamic/proc/select_roundstart_antagonists()
	load_config()
	SEND_SIGNAL(src, COMSIG_DYNAMIC_PRE_ROUNDSTART, dynamic_config)
	// we start by doing a dry run of the job selection process to detect antag rollers
	SSjob.divide_occupations(pure = TRUE, allow_all = TRUE)

	var/list/antag_candidates = list()
	// anyone who was readied up and NOT unassigned is a potential candidate (even those who have no antag preferences)
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list - SSjob.unassigned)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			antag_candidates += player

	// anyone unassigned are potential antag rollers, so we need to warn them
	for(var/mob/dead/new_player/player as anything in SSjob.unassigned)
		var/list/job_data = list()
		var/job_prefs = player.client?.prefs.job_preferences
		for(var/job in job_prefs)
			var/priority = job_prefs[job]
			job_data += "[job]: [SSjob.job_priority_level_to_string(priority)]"
		to_chat(player, span_danger("Вы не смогли получить роль антагониста в начале раунда, \
			так как ваши предпочтения по профессиям с высокой вероятностью делают все выбранные вами профессии недоступными, \
			а также включена опция 'возвращаться в лобби, если профессия недоступна'. \
			Увеличьте количество профессий со средним или низким приоритетом, чтобы уменьшить вероятность этого."))
		log_admin("[player.ckey] не смог получить роль антагониста в начале раунда \
			из-за настроек профессий, делающих все выбранные профессии потенциально недоступными, \
			а также включенной опции 'возвращаться в лобби'. \
			У игрока [player.client.prefs.be_special.len] включенных предпочтений антагонистов. \
			Его настройки профессий: [job_data.Join(" | ")]")

	var/num_real_players = length(antag_candidates)
	// now select a tier (if admins didn't)
	// this also calculates the number of rulesets to spawn
	if(!current_tier)
		pick_tier(num_real_players)
	// put rulesets in the queue (if admins didn't)
	// this will even handle the case in which the tier wants 0 roundstart rulesets
	if(!length(queued_rulesets))
		queued_rulesets += pick_roundstart_rulesets(antag_candidates)
	// we got what we needed, reset so we can do real job selection later
	// reset only happens AFTER roundstart selection so we can verify stuff like "can we get 3 heads of staff for revs?"
	SSjob.reset_occupations()
	// finally, run through the queue and prepare rulesets for execution
	// (actual execution, ie assigning antags, will happen after job assignment)
	for(var/datum/dynamic_ruleset/roundstart/ruleset in queued_rulesets)
		// NOTE: !! THIS CAN SLEEP !!
		if(!ruleset.prepare_execution( num_real_players, antag_candidates ))
			log_dynamic("РаундСтарт: Выбранное правило [ruleset.config_tag] не смогло подготовиться к выполнению!")
			queued_rulesets -= ruleset
			qdel(ruleset)
			continue

		// Логирование выбранных игроков в начале раунда
		for(var/datum/mind/selected as anything in ruleset.selected_minds)
			log_dynamic("РаундСтарт: [key_name(selected)] был выбран для [ruleset.config_tag].")

		rulesets_to_spawn[ROUNDSTART] -= 1
	// and start ticking
	COOLDOWN_START(src, light_ruleset_start, current_tier.ruleset_type_settings[LIGHT_MIDROUND][TIME_THRESHOLD])
	COOLDOWN_START(src, heavy_ruleset_start, current_tier.ruleset_type_settings[HEAVY_MIDROUND][TIME_THRESHOLD])
	COOLDOWN_START(src, latejoin_ruleset_start, current_tier.ruleset_type_settings[LATEJOIN][TIME_THRESHOLD])

	return TRUE

/datum/controller/subsystem/dynamic/proc/load_config()
	PRIVATE_PROC(TRUE)

	if(!CONFIG_GET(flag/dynamic_config_enabled))
		return

	var/config_file = "[global.config.directory]/dynamic.toml"
	var/list/result = rustg_raw_read_toml_file(config_file)
	if(!result["success"])
		log_dynamic("Не удалось загрузить файл конфигурации! ([config_file] - [result["content"]])")
		return

	dynamic_config = json_decode(result["content"])

/// Sets the tier to the typepath passed in
/datum/controller/subsystem/dynamic/proc/set_tier(picked_tier, population = length(GLOB.player_list))
	current_tier = new picked_tier(dynamic_config)

	for(var/category in current_tier.ruleset_type_settings)
		var/list/range = current_tier.ruleset_type_settings[category] || list()
		var/low_end = range[LOW_END] || 0
		var/high_end = range[HIGH_END] || 0

		if(population <= (range[HALF_RANGE_POP_THRESHOLD] || 0))
			high_end = max(low_end, ceil(high_end * 0.25))
		else if(population <= (range[FULL_RANGE_POP_THRESHOLD] || 0))
			high_end = max(low_end, ceil(high_end * 0.5))

		rulesets_to_spawn[category] = rand(low_end, high_end)
		base_rulesets_to_spawn[category] = rulesets_to_spawn[category]

/// Picks what tier we are going to use for this round and sets up all the corresponding variables and ranges
/datum/controller/subsystem/dynamic/proc/pick_tier(roundstart_population = 0)
	PRIVATE_PROC(TRUE)

	var/list/tier_weighted = list()
	for(var/datum/dynamic_tier/tier_datum as anything in subtypesof(/datum/dynamic_tier))
		var/tier_pop = GET_DYNAMIC_CONFIG(tier_datum, min_pop)
		if(roundstart_population < tier_pop)
			continue

		var/tier_weight = GET_DYNAMIC_CONFIG(tier_datum, weight)
		if(tier_weight <= 0)
			continue

		tier_weighted[tier_datum] = tier_weight

	set_tier(pick_weight(tier_weighted), roundstart_population)

	var/roundstart_spawn = rulesets_to_spawn[ROUNDSTART]
	var/light_midround_spawn = rulesets_to_spawn[LIGHT_MIDROUND]
	var/heavy_midround_spawn = rulesets_to_spawn[HEAVY_MIDROUND]
	var/latejoin_spawn = rulesets_to_spawn[LATEJOIN]

	log_dynamic("Выбранный уровень сложности: [current_tier.tier]")
	log_dynamic("- Население в начале раунда: [roundstart_population]")
	log_dynamic("- Количество начальных правил: [roundstart_spawn]")
	log_dynamic("- Количество легких мидроунд-правил: [light_midround_spawn]")
	log_dynamic("- Количество тяжелых мидроунд-правил: [heavy_midround_spawn]")
	log_dynamic("- Количество поздних правил: [latejoin_spawn]")
	SSblackbox.record_feedback(
		"associative",
		"dynamic_tier",
		1,
		list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"tier" = current_tier.tier,
			"player_count" = roundstart_population,
			"roundstart_ruleset_count" = roundstart_spawn,
			"light_midround_ruleset_count" = light_midround_spawn,
			"heavy_midround_ruleset_count" = heavy_midround_spawn,
			"latejoin_ruleset_count" = latejoin_spawn,
		),
	)

/// Gets a weighted list of roundstart rulesets
/datum/controller/subsystem/dynamic/proc/get_roundstart_rulesets(list/antag_candidates)
	PRIVATE_PROC(TRUE)

	var/list/datum/dynamic_ruleset/roundstart/rulesets = list()
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset/roundstart))
		var/datum/dynamic_ruleset/roundstart/ruleset = new ruleset_type(dynamic_config)
		rulesets[ruleset] = ruleset.get_weight(length(antag_candidates), current_tier.tier)

	return rulesets

/// Picks as many roundstart rulesets as we are allowed to spawn, returns them
/datum/controller/subsystem/dynamic/proc/pick_roundstart_rulesets(list/antag_candidates)
	PRIVATE_PROC(TRUE)

	if(rulesets_to_spawn[ROUNDSTART] <= 0)
		return list()

	var/list/rulesets_weighted = get_roundstart_rulesets(antag_candidates)
	var/total_weight = 0
	for(var/ruleset in rulesets_weighted)
		total_weight += rulesets_weighted[ruleset]
	if(total_weight <= 0)
		log_dynamic("РаундСтарт: Нет доступных правил для выбора!")
		return list()

	var/list/picked_rulesets = list()
	while(rulesets_to_spawn[ROUNDSTART] > 0)
		if(!length(rulesets_weighted) || total_weight <= 0)
			log_dynamic("РаундСтарт: Больше нет доступных правил, осталось [rulesets_to_spawn[ROUNDSTART]]!")
			break
		rulesets_to_spawn[ROUNDSTART] -= 1
		var/datum/dynamic_ruleset/roundstart/picked_ruleset = pick_weight(rulesets_weighted)
		log_dynamic("РаундСтарт: Выбрано правило [picked_ruleset.config_tag] (Шанс: [round(rulesets_weighted[picked_ruleset] / total_weight * 100, 0.01)]%)")
		if(picked_ruleset.solo)
			log_dynamic("РаундСтарт: Правило является одиночным. Отмена других выборов.")
			QDEL_LIST(picked_rulesets)
			rulesets_weighted -= picked_ruleset
			picked_rulesets += picked_ruleset
			break
		if(current_tier.tier != DYNAMIC_TIER_HIGH && (picked_ruleset.ruleset_flags & RULESET_HIGH_IMPACT))
			for(var/datum/dynamic_ruleset/roundstart/high_impact_ruleset as anything in rulesets_weighted)
				if(!(high_impact_ruleset.ruleset_flags & RULESET_HIGH_IMPACT))
					continue
				total_weight -= rulesets_weighted[high_impact_ruleset]
				rulesets_weighted -= high_impact_ruleset
		if(!picked_ruleset.repeatable)
			rulesets_weighted -= picked_ruleset
			picked_rulesets += picked_ruleset
			continue

		rulesets_weighted[picked_ruleset] -= picked_ruleset.repeatable_weight_decrease
		total_weight -= picked_ruleset.repeatable_weight_decrease
		// Rulesets are not singletons. We need to to make a new one
		picked_rulesets += new picked_ruleset.type(dynamic_config)

	// clean up unused rulesets
	QDEL_LIST(rulesets_weighted)
	return picked_rulesets

/datum/controller/subsystem/dynamic/proc/get_advisory_report()
	var/shown_tier = current_tier.tier
	if(prob(10))
		shown_tier = pick(list(DYNAMIC_TIER_LOW, DYNAMIC_TIER_LOWMEDIUM, DYNAMIC_TIER_MEDIUMHIGH, DYNAMIC_TIER_HIGH) - current_tier.tier)

	else if(prob(15))
		shown_tier = clamp(current_tier.tier + pick(-1, 1), DYNAMIC_TIER_LOW, DYNAMIC_TIER_HIGH)

	for(var/datum/dynamic_tier/tier_datum as anything in subtypesof(/datum/dynamic_tier))
		if(tier_datum::tier == shown_tier)
			return GET_DYNAMIC_CONFIG(tier_datum, advisory_report)

	return null

/**
 * Invoked by SSdynamic to try to spawn a random midround ruleset
 * Respects ranges and thresholds
 *
 * Prioritizes light midround rulesets first, then heavy midround rulesets
 *
 * Returns TRUE if a ruleset was spawned, FALSE otherwise
 */
/datum/controller/subsystem/dynamic/proc/try_spawn_midround(range)
	if(rulesets_to_spawn[range] <= 0)
		return FALSE
	var/midround_chance = get_midround_chance(range)
	if(!prob(midround_chance))
		log_dynamic("СерединаРаунда ([range]): Шанс события не сработал ([midround_chance]% вероятность)")
		return FALSE

	midround_admin_cancel = FALSE
	midround_admin_reroll = FALSE
	COOLDOWN_RESET(src, midround_admin_cancel_period)

	var/player_count = get_active_player_count(afk_check = TRUE)
	var/list/rulesets_weighted = get_midround_rulesets(player_count, range)
	var/datum/dynamic_ruleset/midround/picked_ruleset = pick_weight(rulesets_weighted)
	if(isnull(picked_ruleset))
		log_dynamic("СерединаРаунда ([range]): Нет доступных правил для выбора!")
		return FALSE
	message_admins("СерединаРаунда ([range]): Запускается [picked_ruleset.config_tag] \
		[MIDROUND_CANCEL_HREF()] [MIDROUND_REROLL_HREF(rulesets_weighted)]")
	// если есть онлайн-админы, даем время на отмену или перевыбор
	if(length(GLOB.admins))
		COOLDOWN_START(src, midround_admin_cancel_period, 15 SECONDS)
		while(!COOLDOWN_FINISHED(src, midround_admin_cancel_period))
			if(midround_admin_cancel)
				QDEL_LIST(rulesets_weighted)
				COOLDOWN_START(src, midround_cooldown, get_ruleset_cooldown(range))
				return FALSE
			if(midround_admin_reroll && length(rulesets_weighted) >= 2)
				midround_admin_reroll = FALSE
				COOLDOWN_START(src, midround_admin_cancel_period, 15 SECONDS)
				rulesets_weighted -= picked_ruleset
				qdel(picked_ruleset)
				picked_ruleset = pick_weight(rulesets_weighted)
				if(isnull(picked_ruleset))
					log_dynamic("СерединаРаунда ([range]): Нет доступных правил для выбора!")
					message_admins("Перевыбор СерединаРаунда ([range]): Не удалось выбрать новое правило, отмена!")
					midround_admin_cancel = TRUE
					continue
				message_admins("Перевыбор СерединаРаунда ([range]): Запускается [picked_ruleset.config_tag] - \
					[length(rulesets_weighted) - 1] правил осталось в пуле. [MIDROUND_CANCEL_HREF()] [MIDROUND_REROLL_HREF(rulesets_weighted)]")
			stoplag()

	// ВНИМАНИЕ: !! ЭТОТ КОД МОЖЕТ БЫТЬ БЛОКИРУЮЩИМ !!
	if(!picked_ruleset.prepare_execution(player_count, picked_ruleset.collect_candidates()))
		log_dynamic("СерединаРаунда ([range]): Выбрано правило [picked_ruleset.config_tag], но подготовка не удалась!")
		QDEL_LIST(rulesets_weighted)
		return FALSE
	// Запускаем правило
	executed_rulesets += picked_ruleset
	rulesets_weighted -= picked_ruleset
	picked_ruleset.execute()
	// Логирование после выполнения
	for(var/datum/mind/selected as anything in picked_ruleset.selected_minds)
		message_admins("СерединаРаунда ([range]): [ADMIN_LOOKUPFLW(selected.current)] был выбран для [picked_ruleset.config_tag].")
		log_dynamic("СерединаРаунда ([range]): [key_name(selected.current)] был выбран для [picked_ruleset.config_tag].")
		notify_ghosts("[selected.name] был выбран для [picked_ruleset.config_tag]!", source = selected.current)
	// Очистка неиспользованных правил
	QDEL_LIST(rulesets_weighted)
	rulesets_to_spawn[range] -= 1
	if(range == LIGHT_MIDROUND)
		admin_forcing_next_light = FALSE
	if(range == HEAVY_MIDROUND)
		admin_forcing_next_heavy = FALSE
	COOLDOWN_START(src, midround_cooldown, get_ruleset_cooldown(range))
	return TRUE

/// Gets a weighted list of midround rulesets
/datum/controller/subsystem/dynamic/proc/get_midround_rulesets(player_count, midround_type)
	PRIVATE_PROC(TRUE)

	var/list/datum/dynamic_ruleset/midround/rulesets = list()
	for(var/datum/dynamic_ruleset/midround/ruleset_type as anything in subtypesof(/datum/dynamic_ruleset/midround))
		if(initial(ruleset_type.midround_type) != midround_type)
			continue
		var/datum/dynamic_ruleset/midround/ruleset = new ruleset_type(dynamic_config)
		rulesets[ruleset] = ruleset.get_weight(player_count, current_tier.tier)

	return rulesets

/**
 * Attempt to run a midround ruleset of the given type
 *
 * * midround_type - The type of midround ruleset to force
 * * forced_max_cap - Rather than using the ruleset's max antag cap, use this value
 * As an example, this allows you to only spawn 1 traitor rather than the ruleset's default of 3
 * Can't be set to 0 (why are you forcing a ruleset that spawns 0 antags?)
 * * alert_admins_on_fail - If TRUE, alert admins if the ruleset fails to prepare/execute
 * * mob/admin - The admin who is forcing the ruleset, used for configuring the ruleset if possible
 */
/datum/controller/subsystem/dynamic/proc/force_run_midround(midround_typepath, forced_max_cap, alert_admins_on_fail = FALSE, mob/admin)
	if(!ispath(midround_typepath, /datum/dynamic_ruleset/midround))
		CRASH("force_run_midround() вызвана с неверным типом мидраунда: [midround_typepath]")

	var/datum/dynamic_ruleset/midround/running = new midround_typepath(dynamic_config)
	if(isnum(forced_max_cap) && forced_max_cap > 0)
		running.min_antag_cap = min(forced_max_cap, running.min_antag_cap)
		running.max_antag_cap = forced_max_cap

	if(admin && (running.ruleset_flags & RULESET_ADMIN_CONFIGURABLE))
		if(running.configure_ruleset(admin) == RULESET_CONFIG_CANCEL)
			qdel(running)
			return FALSE

	// ВНИМАНИЕ: !! ЭТОТ КОД МОЖЕТ БЫТЬ БЛОКИРУЮЩИМ !!
	if(!running.prepare_execution(get_active_player_count(afk_check = TRUE), running.collect_candidates()))
		if(alert_admins_on_fail)
			message_admins("СерединаРаунда (принудительно): Принудительное правило [running.config_tag] не смогло подготовиться!")
		log_dynamic("СерединаРаунда (принудительно): Принудительное правило [running.config_tag] не смогло подготовиться!")
		qdel(running)
		return FALSE

	executed_rulesets += running
	running.execute()
	// Логирование после выполнения
	for(var/datum/mind/selected as anything in running.selected_minds)
		message_admins("СерединаРаунда (принудительно): [ADMIN_LOOKUPFLW(selected.current)] был выбран для [running.config_tag].")
		log_dynamic("СерединаРаунда (принудительно): [key_name(selected.current)] был выбран для [running.config_tag].")
		notify_ghosts("[selected.name] был выбран для [running.config_tag]!", source = selected.current)
	return TRUE

/**
 * Called when someone latejoins
 * (This could be a signal in the future)
 */
/datum/controller/subsystem/dynamic/proc/on_latejoin(mob/living/carbon/human/latejoiner)
	// Сначала проверяем правила в очереди - они игнорируют кулдауны и проверки вероятности,
	// так как обычно вызываются событиями или админами (и имеют высший приоритет)
	for(var/datum/dynamic_ruleset/latejoin/queued in queued_rulesets)
		// ВНИМАНИЕ: !! ЭТОТ КОД МОЖЕТ БЫТЬ БЛОКИРУЮЩИМ !!
		if(!queued.prepare_execution(get_active_player_count(afk_check = TRUE), list(latejoiner)))
			message_admins("ПозднееПрисоединение (принудительно): Правило [queued.config_tag] в очереди не смогло подготовиться! Остается в очереди для следующего позднего присоединения. (<a href='byond://?src=[REF(src)];admin_dequeue=[REF(queued)]'>УДАЛИТЬ ИЗ ОЧЕРЕДИ</a>)")
			log_dynamic("ПозднееПрисоединение (принудительно): Правило [queued.config_tag] в очереди не смогло подготовиться! Остается в очереди для следующего позднего присоединения.")
			continue
		message_admins("ПозднееПрисоединение (принудительно): [ADMIN_LOOKUPFLW(latejoiner)] был выбран для [queued.config_tag].")
		log_dynamic("ПозднееПрисоединение (принудительно): [key_name(latejoiner)] был выбран для [queued.config_tag].")
		queued_rulesets -= queued
		executed_rulesets += queued
		queued.execute()
		return

	if(COOLDOWN_FINISHED(src, latejoin_ruleset_start) && COOLDOWN_FINISHED(src, latejoin_cooldown))
		if(try_spawn_latejoin(latejoiner))
			return

/**
 * Invoked by SSdynamic to try to spawn a latejoin ruleset
 * Respects ranges and thresholds
 *
 * Returns TRUE if a ruleset was spawned, FALSE otherwise
 */
/datum/controller/subsystem/dynamic/proc/try_spawn_latejoin(mob/living/carbon/human/latejoiner)
	if(rulesets_to_spawn[LATEJOIN] <= 0)
		return FALSE
	var/latejoin_chance = get_latejoin_chance()
	if(!prob(latejoin_chance))
		log_dynamic("ПозднееПрисоединение: Шанс события не сработал ([latejoin_chance]% вероятность)")
		return FALSE

	var/player_count = get_active_player_count(afk_check = TRUE)
	var/list/rulesets_weighted = get_latejoin_rulesets(player_count)
	// Примечание: мы не проверяем доступность правил для игрока здесь
	// Мы выбираем правило, и у игрока может не быть этого антага в настройках. И это нормально
	var/datum/dynamic_ruleset/latejoin/picked_ruleset = pick_weight(rulesets_weighted)
	if(isnull(picked_ruleset))
		log_dynamic("ПозднееПрисоединение: Нет доступных правил для выбора!")
		return FALSE
	// ВНИМАНИЕ: !! ЭТОТ КОД МОЖЕТ БЫТЬ БЛОКИРУЮЩИМ !!
	if(!picked_ruleset.prepare_execution(player_count, list(latejoiner)))
		log_dynamic("ПозднееПрисоединение: Выбрано правило [picked_ruleset.name] для [key_name(latejoiner)], но подготовка не удалась! Шанс позднего присоединения увеличен.")
		QDEL_LIST(rulesets_weighted)
		failed_latejoins++
		return FALSE
	// Запускаем правило
	executed_rulesets += picked_ruleset
	rulesets_weighted -= picked_ruleset
	picked_ruleset.execute()
	// Логирование после выполнения
	if(!(latejoiner.mind in picked_ruleset.selected_minds))
		stack_trace("Динамичный: ПозднееПрисоединение [picked_ruleset.type] выполнен, но игрок не попал в список выбранных!")
	message_admins("ПозднееПрисоединение: [ADMIN_LOOKUPFLW(latejoiner)] был выбран для [picked_ruleset.config_tag].")
	log_dynamic("ПозднееПрисоединение: [key_name(latejoiner)] был выбран для [picked_ruleset.config_tag].")
	// Очистка неиспользованных правил
	QDEL_LIST(rulesets_weighted)
	rulesets_to_spawn[LATEJOIN] -= 1
	failed_latejoins = 0
	admin_forcing_next_latejoin = FALSE
	COOLDOWN_START(src, latejoin_cooldown, get_ruleset_cooldown(LATEJOIN))
	return TRUE

/// Gets a weighted list of latejoin rulesets
/datum/controller/subsystem/dynamic/proc/get_latejoin_rulesets(player_count)
	PRIVATE_PROC(TRUE)

	var/list/datum/dynamic_ruleset/latejoin/rulesets = list()
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset/latejoin))
		var/datum/dynamic_ruleset/latejoin/ruleset = new ruleset_type(dynamic_config)
		rulesets[ruleset] = ruleset.get_weight(player_count, current_tier.tier)

	return rulesets

/**
 * Queues a ruleset to run on roundstart or next latejoin which fulfills all requirements
 *
 * For example, if you queue a latejoin revolutionary, it'll only run when population gets large enough and there are enough heads of staff
 * For all latejoins until then, it will simply do nothing
 *
 * * latejoin_type - The type of latejoin ruleset to force
 */
/datum/controller/subsystem/dynamic/proc/queue_ruleset(ruleset_typepath)
	if(!ispath(ruleset_typepath, /datum/dynamic_ruleset/latejoin) && !ispath(ruleset_typepath, /datum/dynamic_ruleset/roundstart))
		CRASH("queue_ruleset() вызвана с неверным типом правила: [ruleset_typepath]")

	queued_rulesets += new ruleset_typepath(dynamic_config)

/**
 * Получить кулдаун между попытками запустить правило указанного типа
 */
/datum/controller/subsystem/dynamic/proc/get_ruleset_cooldown(range)
	if(range == ROUNDSTART)
		stack_trace("Попытка получить кулдаун для roundstart правил - это избыточно и вероятно ошибка")
		return 0

	var/low = current_tier.ruleset_type_settings[range][EXECUTION_COOLDOWN_LOW] || 0
	var/high = current_tier.ruleset_type_settings[range][EXECUTION_COOLDOWN_HIGH] || 0
	return rand(low, high)

/**
 * Gets the chance of a midround ruleset being selected
 */
/datum/controller/subsystem/dynamic/proc/get_midround_chance(range)
	if(admin_forcing_next_light && range == LIGHT_MIDROUND)
		return 100
	if(admin_forcing_next_heavy && range == HEAVY_MIDROUND)
		return 100

	var/chance = 0
	var/num_antags = length(GLOB.current_living_antags)
	var/num_dead = length(GLOB.dead_player_list)
	var/num_alive = get_active_player_count(afk_check = TRUE)
	if(num_dead + num_alive <= 0)
		return 0

	chance += 100 - (200 * (num_dead / (num_alive + num_dead)))
	if(num_antags < 0)
		chance += 50

	return chance

/**
 * Gets the chance of a latejoin ruleset being selected
 */
/datum/controller/subsystem/dynamic/proc/get_latejoin_chance()
	if(admin_forcing_next_latejoin)
		return 100

	var/chance = 0
	var/num_antags = length(GLOB.current_living_antags)
	var/num_dead = length(GLOB.dead_player_list)
	var/num_alive = get_active_player_count(afk_check = TRUE)
	if(num_dead + num_alive <= 0)
		return 0

	chance += 100 - (200 * (num_dead / (num_alive + num_dead)))
	if(num_antags < 0)
		chance += 50
	chance += (failed_latejoins * 15)
	// Reduced chance before lights start
	if(!COOLDOWN_FINISHED(src, light_ruleset_start))
		chance *= 0.2

	return chance

/datum/controller/subsystem/dynamic/proc/set_round_result()
	// Если дошло до этой части, просто выбираем одно высокоэффективное правило, если оно существует
	for(var/datum/dynamic_ruleset/rule as anything in executed_rulesets)
		if(rule.round_result())
			return

	SSticker.mode_result = "неопределён"

	switch(GLOB.revolution_handler?.result)
		if(STATION_VICTORY)
			SSticker.mode_result = "поражение - главы революции убиты"
			SSticker.news_report = REVS_LOSE
		if(REVOLUTION_VICTORY)
			SSticker.mode_result = "победа - главы убиты"
			SSticker.news_report = REVS_WIN

	// Something nuked the station - it wasn't nuke ops (they set their own via their rulset)
	if(GLOB.station_was_nuked)
		SSticker.news_report = STATION_NUKED

	if(SSsupermatter_cascade.cascade_initiated)
		SSticker.news_report = SUPERMATTER_CASCADE

	// Only show this one if we have nothing better to show
	if(EMERGENCY_ESCAPED_OR_ENDGAMED && !SSticker.news_report)
		SSticker.news_report = SSshuttle.emergency?.is_hijacked() ? SHUTTLE_HIJACK : STATION_EVACUATED

/// Helper to clear all queued rulesets and stop any other rulesets from naturally spawning
/datum/controller/subsystem/dynamic/proc/force_extended()
	for(var/category in rulesets_to_spawn)
		rulesets_to_spawn[category] = 0
	QDEL_LIST(queued_rulesets)

/datum/controller/subsystem/dynamic/Topic(href, list/href_list)
	. = ..()
	if(href_list["admin_dequeue"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/dynamic_ruleset/to_remove = locate(href_list["admin_dequeue"]) in queued_rulesets
		if(!istype(to_remove))
			return
		queued_rulesets -= to_remove
		qdel(to_remove)
		message_admins(span_adminnotice("[key_name_admin(usr)] удалил [to_remove.config_tag] из очереди поздних присоединений."))
		log_admin("[key_name(usr)] удалил [to_remove.config_tag] из очереди поздних присоединений.")
		return

	if(href_list["admin_reroll"])
		if(!check_rights(R_ADMIN) || midround_admin_reroll)
			return
		if(COOLDOWN_FINISHED(src, midround_admin_cancel_period))
			to_chat(usr, span_alert("Слишком поздно!"))
			return
		midround_admin_reroll = TRUE
		message_admins(span_adminnotice("[key_name_admin(usr)] перевыбрал правило мидраунда."))
		log_admin("[key_name(usr)] перевыбрал правило мидраунда.")
		return

	if(href_list["admin_cancel_midround"])
		if(!check_rights(R_ADMIN) || midround_admin_cancel)
			return
		if(COOLDOWN_FINISHED(src, midround_admin_cancel_period))
			to_chat(usr, span_alert("Слишком поздно!"))
			return
		midround_admin_cancel = TRUE
		message_admins(span_adminnotice("[key_name_admin(usr)] отменил правило мидраунда."))
		log_admin("[key_name(usr)] отменил правило мидраунда.")
		return

#ifdef TESTING
/// Puts all repo defaults into a dynamic.toml file
/datum/controller/subsystem/dynamic/proc/build_dynamic_toml()
	var/data = ""
	for(var/tier_type in subtypesof(/datum/dynamic_tier))
		var/datum/dynamic_tier/tier = new tier_type()
		if(!tier.config_tag)
			qdel(tier)
			continue

		data += "\[\"[tier.config_tag]\"\]\n"
		data += "name = \"[tier.name]\"\n"
		data += "min_pop = [tier.min_pop]\n"
		data += "weight = [tier.weight]\n"
		data += "advisory_report = \"[tier.advisory_report]\"\n"
		for(var/range in tier.ruleset_type_settings)
			data += "ruleset_type_settings.[range].[LOW_END] = [tier.ruleset_type_settings[range]?[LOW_END] || 0]\n"
			data += "ruleset_type_settings.[range].[HIGH_END] = [tier.ruleset_type_settings[range]?[HIGH_END] || 0]\n"
			data += "ruleset_type_settings.[range].[HALF_RANGE_POP_THRESHOLD] = [tier.ruleset_type_settings[range]?[HALF_RANGE_POP_THRESHOLD] || 0]\n"
			data += "ruleset_type_settings.[range].[FULL_RANGE_POP_THRESHOLD] = [tier.ruleset_type_settings[range]?[FULL_RANGE_POP_THRESHOLD] || 0]\n"
			if(range != ROUNDSTART)
				data += "ruleset_type_settings.[range].[TIME_THRESHOLD] = [(tier.ruleset_type_settings[range]?[TIME_THRESHOLD] || 0) / 60 / 10]\n"
				data += "ruleset_type_settings.[range].[EXECUTION_COOLDOWN_LOW] = [(tier.ruleset_type_settings[range]?[EXECUTION_COOLDOWN_LOW] || 0) / 60 / 10]\n"
				data += "ruleset_type_settings.[range].[EXECUTION_COOLDOWN_HIGH] = [(tier.ruleset_type_settings[range]?[EXECUTION_COOLDOWN_HIGH] || 0) / 60 / 10]\n"

		data += "\n"
		qdel(tier)

	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset))
		var/datum/dynamic_ruleset/ruleset = new ruleset_type()
		if(!ruleset.config_tag)
			qdel(ruleset)
			continue

		data += "\[\"[ruleset.config_tag]\"\]\n"
		if(islist(ruleset.weight))
			for(var/i in 1 to length(ruleset.weight))
				data += "weight.[i] = [ruleset.weight[i]]\n"
		else
			data += "weight = [ruleset.weight || 0]\n"
		if(islist(ruleset.min_pop))
			for(var/i in 1 to length(ruleset.min_pop))
				data += "min_pop.[i] = [ruleset.min_pop[i]]\n"
		else
			data += "min_pop = [ruleset.min_pop || 0]\n"
		if(length(ruleset.blacklisted_roles))
			data += "blacklisted_roles = \[\n"
			for(var/i in ruleset.blacklisted_roles)
				data += "\t\"[i]\",\n"
			data += "\]\n"
		else
			data += "blacklisted_roles = \[\]\n"
		if(!istype(ruleset, /datum/dynamic_ruleset/latejoin) && !istype(ruleset, /datum/dynamic_ruleset/midround/from_living))
			if(islist(ruleset.min_antag_cap))
				for(var/ruleset_min_antag_cap in ruleset.min_antag_cap)
					data += "min_antag_cap.[ruleset_min_antag_cap] = [ruleset.min_antag_cap[ruleset_min_antag_cap]]\n"
			else
				data += "min_antag_cap = [ruleset.min_antag_cap || 0]\n"
			if(islist(ruleset.max_antag_cap))
				for(var/ruleset_max_antag_cap in ruleset.max_antag_cap)
					data += "max_antag_cap.[ruleset_max_antag_cap] = [ruleset.max_antag_cap[ruleset_max_antag_cap]]\n"
			else if(!isnull(ruleset.max_antag_cap))
				data += "max_antag_cap = [ruleset.max_antag_cap]\n"
			else
				data += "# max_antag_cap = min_antag_cap\n"
		data += "repeatable_weight_decrease = [ruleset.repeatable_weight_decrease]\n"
		data += "repeatable = [ruleset.repeatable]\n"
		data += "minimum_required_age = [ruleset.minimum_required_age]\n"
		data += "\n"
		qdel(ruleset)

	var/filepath = "[global.config.directory]/dynamic.toml"
	fdel(file(filepath))
	text2file(data, filepath)
	return TRUE
#endif
