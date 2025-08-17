/datum/action/item_action/zipper
	name = "Расстегнуть Дафл"
	desc = "Расстегните ваш экипированный дафл, чтобы получить доступ к его содержимому."

/datum/action/item_action/zipper/New(Target)
	. = ..()
	RegisterSignal(target, COMSIG_DUFFEL_ZIP_CHANGE, PROC_REF(on_zip_change))
	var/obj/item/storage/backpack/duffelbag/duffle_target = target
	on_zip_change(target, duffle_target.zipped_up)

/datum/action/item_action/zipper/proc/on_zip_change(datum/source, new_zip)
	SIGNAL_HANDLER
	if(new_zip)
		name = "Расстегнуть"
		desc = "Расстегните ваш экипированный дафл, чтобы получить доступ к его содержимому."
	else
		name = "Застегнуть"
		desc = "Застегните ваш экипированный дафл, чтобы передвигаться быстрее."
	build_all_button_icons(UPDATE_BUTTON_NAME)
