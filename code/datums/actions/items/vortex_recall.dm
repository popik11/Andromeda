/datum/action/item_action/vortex_recall
	name = "Вихревой Возврат"
	desc = "Возвратите себя и всех nearby к настроенному маяку иерофанта в любое время.<br>Если маяк всё ещё прикреплён, он будет отсоединён."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable(feedback = FALSE)
	if(!istype(target, /obj/item/hierophant_club))
		return
	var/obj/item/hierophant_club/teleport_stick = target
	if(teleport_stick.teleporting)
		return FALSE
	if(teleport_stick.beacon && !check_teleport_valid(owner, get_turf(teleport_stick.beacon), TELEPORT_CHANNEL_FREE))
		return FALSE
	return ..()
