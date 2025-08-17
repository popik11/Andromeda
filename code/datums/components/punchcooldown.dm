///Твоя любимая Jojo-шутка. Используется для перчаток северной звезды.
/datum/component/wearertargeting/punchcooldown
	signals = list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_LIVING_HAND_ITEM_ATTACK)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(reducecooldown)
	valid_slots = ITEM_SLOT_GLOVES
	///Боевой клич, который издаётся
	var/warcry = "АТА"

/datum/component/wearertargeting/punchcooldown/Initialize()
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(changewarcry))

///Вызывается по COMSIG_LIVING_UNARMED_ATTACK. Кричит боевой клич и уменьшает кулдаун ударов.
/datum/component/wearertargeting/punchcooldown/proc/reducecooldown(mob/living/carbon/M, atom/target)
	var/obj/item/used_item = M.get_active_held_item()
	if((M.combat_mode && isliving(target)) || (used_item & HAND_ITEM))
		M.changeNext_move(CLICK_CD_RAPID)
		if(warcry)
			M.say(warcry, ignore_spam = TRUE, forced = "боевой клич северной звезды")

///Вызывается по COMSIG_ITEM_ATTACK_SELF. Позволяет изменить боевой клич.
/datum/component/wearertargeting/punchcooldown/proc/changewarcry(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_changewarcry), user)

/datum/component/wearertargeting/punchcooldown/proc/do_changewarcry(mob/user)
	var/input = tgui_input_text(user, "Каким будет твой боевой клич?", "Боевой Клич", max_length = 6)
	if(!QDELETED(src) && !QDELETED(user) && !user.Adjacent(parent))
		return
	if(input)
		warcry = input
