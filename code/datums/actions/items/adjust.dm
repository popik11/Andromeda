/datum/action/item_action/adjust
	name = "Настроить предмет"

/datum/action/item_action/adjust/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Настроить [item_target.name]"

/datum/action/item_action/adjust/do_effect(trigger_flags)
	if(!isclothing(target))
		CRASH("Действие adjust_visor вызвано для неодежды [target] ([target?.type]) принадлежащей [owner] ([owner?.type]!")
	var/obj/item/clothing/as_clothing = target
	as_clothing.adjust_visor(owner)
	return TRUE

/datum/action/item_action/adjust_style
	name = "Настроить стиль предмета"

/datum/action/item_action/adjust_style/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Настроить стиль [item_target.name]"
