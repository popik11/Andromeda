// If an item has the dunkable element, it's able to be dunked into reagent containers like beakers and glasses.
// Dunking the item into a container will transfer reagents from the container to the item.
/datum/element/dunkable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/dunk_amount // the amount of reagents that will be transferred from the container to the item on each click

/datum/element/dunkable/Attach(datum/target, amount_per_dunk)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	dunk_amount = amount_per_dunk
	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(get_dunked))

/datum/element/dunkable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM)

/datum/element/dunkable/proc/get_dunked(datum/source, mob/user, atom/target, params)
	SIGNAL_HANDLER

	var/obj/item/reagent_containers/container = target // контейнер, в который пытаемся макнуть
	if(istype(container) && (container.reagent_flags & DUNKABLE)) // контейнер подходит для макания
		if(!container.is_drainable())
			to_chat(user, span_warning("[container] нельзя макнуть!"))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/I = source // предмет с элементом dunkable
		if(container.reagents.trans_to(I, dunk_amount, transferred_by = user)) // если реагенты были перенесены, покажем сообщение
			to_chat(user, span_notice("Ты макаешь [I] в [container]."))
			return ITEM_INTERACT_SUCCESS
		if(!container.reagents.total_volume)
			to_chat(user, span_warning("[container] пуст!"))
		else
			to_chat(user, span_warning("[I] заполнен!"))
		return ITEM_INTERACT_BLOCKING
	return NONE
