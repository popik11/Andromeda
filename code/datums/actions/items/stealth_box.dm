///КОРОБКА MGS!
/datum/action/item_action/agent_box
	name = "Развернуть коробку"
	desc = "Обрести покой здесь, в коробке."
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	background_icon_state = "bg_agent"
	overlay_icon_state = "bg_agent_border"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "deploy_box"
	///Тип разворачиваемого шкафа
	var/boxtype = /obj/structure/closet/cardboard/agent
	COOLDOWN_DECLARE(box_cooldown)

///Обрабатывает открытие и закрытие коробки
/datum/action/item_action/agent_box/do_effect(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(istype(owner.loc, /obj/structure/closet/cardboard/agent))
		var/obj/structure/closet/cardboard/agent/box = owner.loc
		if(box.open())
			owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
		return FALSE
	//Закрытие в коробку
	if(!isturf(owner.loc)) //Не позволяем игрокам использовать это для побега из мехов/закрытых шкафов
		to_chat(owner, span_warning("Нужно больше места для активации!"))
		return FALSE
	if(!COOLDOWN_FINISHED(src, box_cooldown))
		return FALSE
	COOLDOWN_START(src, box_cooldown, 10 SECONDS)
	var/box = new boxtype(owner.drop_location())
	owner.forceMove(box)
	owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)

/datum/action/item_action/agent_box/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_HUMAN_SUICIDE_ACT, PROC_REF(suicide_act))

/datum/action/item_action/agent_box/Remove(mob/M)
	if(owner)
		UnregisterSignal(owner, COMSIG_HUMAN_SUICIDE_ACT)
	return ..()

/datum/action/item_action/agent_box/proc/suicide_act(datum/source)
	SIGNAL_HANDLER

	if(!istype(owner.loc, /obj/structure/closet/cardboard/agent))
		return

	var/obj/structure/closet/cardboard/agent/box = owner.loc
	owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
	box.open()
	owner.visible_message(span_suicide("[owner] выпадает из [box]! Похоже на самоубийство!"))
	owner.throw_at(get_turf(owner))
	if(isliving(owner))
		var/mob/living/suicider = owner
		suicider.suicide_log()
	return OXYLOSS
