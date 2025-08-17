/// Pretend to be dead
/datum/ai_behavior/play_dead

/datum/ai_behavior/play_dead/setup(datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/basic_pawn = controller.pawn
	if(!istype(basic_pawn) || basic_pawn.stat) // Can't act dead if you're dead
		return
	basic_pawn.emote("deathgasp", intentional=FALSE)
	ADD_TRAIT(basic_pawn, TRAIT_FAKEDEATH, BASIC_MOB_DEATH_TRAIT)
	basic_pawn.look_dead()

/datum/ai_behavior/play_dead/perform(seconds_per_tick, datum/ai_controller/controller)
	if(SPT_PROB(10, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/play_dead/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/basic_pawn = controller.pawn
	if(QDELETED(basic_pawn) || basic_pawn.stat) // представьте, что умерли, притворяясь мёртвыми. или представьте ребёнка, ждущего, когда его щенок "оживёт" :(
		return
	basic_pawn.visible_message(span_notice("[basic_pawn] чудесным образом возвращается к жизни!"))
	REMOVE_TRAIT(basic_pawn, TRAIT_FAKEDEATH, BASIC_MOB_DEATH_TRAIT)
	basic_pawn.look_alive()
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
