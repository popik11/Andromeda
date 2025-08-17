/// This component allows you to judge someone's level of criminal activity by examining them
/datum/component/security_vision
	/// Bitfield containing what things we want to judge based upon
	var/judgement_criteria
	/// Optional callback which will modify the value of `judgement_criteria` before we make the check
	var/datum/callback/update_judgement_criteria

/datum/component/security_vision/Initialize(judgement_criteria, datum/callback/update_judgement_criteria)
	. = ..()
	if (!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.judgement_criteria = judgement_criteria
	src.update_judgement_criteria = update_judgement_criteria

/datum/component/security_vision/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_EXAMINING, PROC_REF(on_examining))

/datum/component/security_vision/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_EXAMINING)

/// When we examine something, check if we have any extra data to add
/datum/component/security_vision/proc/on_examining(mob/source, atom/target, list/examine_strings)
	SIGNAL_HANDLER
	if (!isliving(target))
		return
	var/mob/living/perp = target
	judgement_criteria = update_judgement_criteria?.Invoke() || judgement_criteria

	var/threat_level = perp.assess_threat(judgement_criteria)
	switch(threat_level)
		if (THREAT_ASSESS_MAXIMUM to INFINITY)
			examine_strings += span_boldwarning("Уровень угрозы: [threat_level]! Чрезвычайно опасен!")
		if (THREAT_ASSESS_DANGEROUS to THREAT_ASSESS_MAXIMUM)
			examine_strings += span_warning("Уровень угрозы: [threat_level]. Обнаружен криминальный элемент!")
		if (1 to THREAT_ASSESS_DANGEROUS)
			examine_strings += span_notice("Уровень угрозы: [threat_level]. Вероятно не опасен... пока что.")
		else
			examine_strings += span_notice("Похоже на законопослушного гражданина.")
