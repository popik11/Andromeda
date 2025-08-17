/// Fearful component: provides optional handling of fears and phobias for mob's mood
/// Can be applied from multiple sources, and essentially serves as a central controller for fear datums described below

/datum/component/fearful
	dupe_mode = COMPONENT_DUPE_SOURCES

	/// How terrified is the source?
	var/terror_buildup = 0
	/// List of terror handlers we currently have -> sources they're added by
	var/list/terror_handlers = list()
	/// List of overriden handler types, for ease of access
	var/list/list/overriden_handlers = list()
	/// How much buildup we had last tick? Used for non-ticking terror source tracking
	var/last_tick_buildup = 0

/*
 * handler_types - terror_handler(s) to add to the mob
 * initial_buildup - amount of fear to add to mob from getting scared shitless by whatever added the component
 * add_defaults - should terror handlers marked as "default" be added to the mob?
 */
/datum/component/fearful/Initialize(list/handler_types, initial_buildup, add_defaults = TRUE)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSdcs, src)
	terror_buildup = initial_buildup

	if (!add_defaults)
		return

	for (var/datum/terror_handler/handler as anything in subtypesof(/datum/terror_handler))
		if (!initial(handler.default))
			continue
		add_handler(handler, "default")

/datum/component/fearful/Destroy(force)
	STOP_PROCESSING(SSdcs, src)
	QDEL_LIST(terror_handlers)
	return ..()

/datum/component/fearful/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(comfort_owner))
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_FEARLESS), PROC_REF(fearless_added))
	RegisterSignal(parent, COMSIG_CARBON_MOOD_CHECK, PROC_REF(on_mood_check))

/datum/component/fearful/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_CARBON_PRE_MISC_HELP, SIGNAL_ADDTRAIT(TRAIT_FEARLESS), COMSIG_CARBON_MOOD_CHECK))

/datum/component/fearful/on_source_add(source, list/handler_types, initial_buildup, add_defaults = TRUE)
	. = ..()
	terror_buildup = clamp(terror_buildup + initial_buildup, 0, TERROR_BUILDUP_MAXIMUM)
	for (var/handler_type in handler_types)
		add_handler(handler_type, source)

/datum/component/fearful/on_source_remove(source)
	for (var/datum/terror_handler/handler as anything in terror_handlers)
		terror_handlers[handler] -= source
		if (length(terror_handlers[handler]))
			continue
		terror_handlers -= handler
		for (var/override_type in handler.overrides)
			if (!overriden_handlers[override_type])
				continue
			overriden_handlers[override_type] -= handler.type
			if (!length(overriden_handlers[override_type]))
				overriden_handlers -= override_type
		qdel(handler)
	return ..()

/datum/component/fearful/proc/add_handler(handler_type, source)
	for (var/datum/terror_handler/existing as anything in terror_handlers)
		if (existing.type == handler_type)
			terror_handlers[existing] += source
			return

	var/datum/terror_handler/handler = new handler_type(parent, src)
	terror_handlers[handler] = list(source)
	for (var/override_type in handler.overrides)
		if (!overriden_handlers[override_type])
			overriden_handlers[override_type] = list()
		overriden_handlers[override_type][handler_type] = TRUE

/datum/component/fearful/process(seconds_per_tick)
	var/terror_adjustment = 0
	var/list/tick_later = list()
	for (var/datum/terror_handler/handler as anything in terror_handlers)
		if (overriden_handlers[handler.type])
			continue
		if (handler.handler_type == TERROR_HANDLER_EFFECT)
			tick_later += handler
			continue
		var/adjustment = handler.tick(seconds_per_tick, terror_buildup)
		terror_buildup = clamp(terror_buildup + adjustment, 0, TERROR_BUILDUP_MAXIMUM)
		terror_adjustment += adjustment

	for (var/datum/terror_handler/handler as anything in tick_later)
		var/adjustment = handler.tick(seconds_per_tick, terror_buildup)
		terror_buildup = clamp(terror_buildup + adjustment, 0, TERROR_BUILDUP_MAXIMUM)
		terror_adjustment += adjustment

	// If we gained terror in any way, don't tick it down
	if (terror_adjustment > 0 || terror_buildup > last_tick_buildup)
		last_tick_buildup = terror_buildup
		return

	// Tick terror down while we're not being actively spooked
	if (terror_buildup > 0)
		terror_buildup = max(terror_buildup - TERROR_BUILDUP_PASSIVE_DECREASE, 0)
	last_tick_buildup = terror_buildup

/datum/component/fearful/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if (source.stat >= UNCONSCIOUS)
		return

	if(terror_buildup >= TERROR_BUILDUP_HEART_ATTACK)
		examine_list += span_danger("[source.p_They()] [source.p_are()] вот-вот рухнет от страха!")
	else if(terror_buildup > TERROR_BUILDUP_PANIC)
		examine_list += span_boldwarning("[source.p_They()] [source.p_are()] дрожат и едва стоят на ногах!")
	else if(terror_buildup >= TERROR_BUILDUP_TERROR)
		examine_list += span_boldwarning("[source] заметно дрожит и дергается. [source.p_They()] [source.p_are()] явно в бедственном положении!")
	else if(terror_buildup >= TERROR_BUILDUP_FEAR)
		examine_list += span_warning("[source] выглядит очень встревоженным. [capitalize(source.p_are())] с [source.p_them()] всё в порядке?")
	else if (terror_buildup)
		examine_list += span_smallnotice("[source] выглядит довольно тревожным. [source.p_They()] наверняка не отказались бы от объятий...")

/datum/component/fearful/proc/comfort_owner(mob/living/carbon/source, mob/living/hugger)
	SIGNAL_HANDLER

	if(hugger == parent)
		return

	if(isnightmare(hugger))
		var/lit_tiles = 0
		var/unlit_tiles = 0

		for(var/turf/open/turf_to_check in range(1, source))
			var/light_amount = turf_to_check.get_lumcount()
			if(light_amount > LIGHTING_TILE_IS_DARK)
				lit_tiles++
			else
				unlit_tiles++

		if(lit_tiles < unlit_tiles)
			source.Knockdown(0.5 SECONDS)
			terror_buildup += HUG_TERROR_AMOUNT
			source.visible_message(
				span_warning("[source] отшатывается в страхе, когда [hugger] размахивает [hugger.p_their()] руками и кричит на [source.p_them()]!"),
				span_boldwarning("Тени бьют по вам, и вы падаете на землю от страха!"),
				span_hear("Вы слышите чей-то испуганный крик. Как неловко!"),
				)
			return COMPONENT_BLOCK_MISC_HELP

	for (var/datum/brain_trauma/mild/phobia/phobia in source.get_traumas())
		if (!phobia.is_scary_mob(hugger))
			continue

		terror_buildup += HUG_TERROR_AMOUNT
		source.visible_message(
			span_warning("[source] отшатывается в страхе, когда [hugger] пытается обнять [source.p_them()]!"),
			span_boldwarning("Вы отшатываетесь в ужасе, когда [hugger] пытается обнять вас!"),
			span_hear("Вы слышите чей-то испуганный крик. Как неловко!"),
			)
		return COMPONENT_BLOCK_MISC_HELP

	terror_buildup -= HUG_TERROR_AMOUNT
	source.visible_message(
		span_notice("[source] кажется, расслабляется, когда [hugger] обнимает [source.p_them()]."),
		span_nicegreen("Вы чувствуете, как успокаиваетесь, когда [hugger] обнимает вас."),
		span_hear("Слышно шуршание и вздох облегчения."),
	)

/// Remove all terror buildup when we become fearless
/datum/component/fearful/proc/fearless_added(datum/source)
	SIGNAL_HANDLER
	terror_buildup = 0

/datum/component/fearful/proc/on_mood_check(mob/living/source, list/mood_list)
	SIGNAL_HANDLER

	if(terror_buildup >= TERROR_BUILDUP_HEART_ATTACK)
		mood_list += span_boldwarning("Вы вот-вот рухните от страха!")
	else if(terror_buildup > TERROR_BUILDUP_PANIC)
		mood_list += span_boldwarning("Вы дрожите от страха!")
	else if(terror_buildup >= TERROR_BUILDUP_TERROR)
		mood_list += span_warning("Вы дрожите в ужасе.")
	else if(terror_buildup >= TERROR_BUILDUP_FEAR)
		mood_list += span_warning("Вам страшно.")
	else if (terror_buildup)
		mood_list += span_notice("Вы чувствуете себя на грани.")
