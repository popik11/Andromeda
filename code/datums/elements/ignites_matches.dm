/// Ignites matches swiped over it.
/datum/element/ignites_matches

/datum/element/ignites_matches/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_interact))

/datum/element/ignites_matches/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ATOM_ITEM_INTERACTION)
	return ..()

/datum/element/ignites_matches/proc/on_interact(atom/source, mob/living/user, obj/item/match/match, ...)
	SIGNAL_HANDLER
	if(!istype(match) || match.lit || match.burnt || match.broken)
		return NONE
	if(SHOULD_SKIP_INTERACTION(source, match, user))
		return NONE
	var/over_what_tp = source.loc == user ? "[user.p_their()] [source.name]" : source
	var/over_what_fp = source.loc == user ? "ваш [source.name]" : source
	if(prob(10))
		user.visible_message(
			span_warning("[user] проводит [match] по [over_what_tp], но ничего не происходит."),
			span_warning("Ты проводишь [match] по [over_what_fp], но он не загорается."),
		)
		return ITEM_INTERACT_SUCCESS
	if(prob((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_HULK)) ? 33 : 2))
		user.visible_message(
			span_warning("[user] проводит [match] по [over_what_tp], случайно ломая его."),
			span_warning("Ты слишком быстро проводишь [match] по [over_what_fp], ломая его пополам."),
		)
		match.snap()
		return ITEM_INTERACT_SUCCESS

	user.visible_message(
		span_rose("[user] проводит [match] по [over_what_tp], зажигая его."),
		span_rose("Ты проводишь [match] по [over_what_fp], зажигая его."),
	)
	match.matchignite()
	return ITEM_INTERACT_SUCCESS
