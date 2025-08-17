/datum/action/item_action/organ_action
	name = "Действие органа"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable(feedback = FALSE)
	var/obj/item/organ/attached_organ = target
	if(!attached_organ.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle
	name = "Переключить орган"

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Переключить [organ_target.name]"

/datum/action/item_action/organ_action/use
	name = "Использовать орган"

/datum/action/item_action/organ_action/use/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Использовать [organ_target.name]"

/datum/action/item_action/organ_action/go_feral
	name = "Одичать"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "feral_mode_off"
	var/list/ability_name = list("Одичать", "Укусить кормящую руку", "Выпустить Ид", "Активировать кошачий мозг", "Режим гремлина", "Режим нямки", "Дегуманизироваться", "Шалить")

/datum/action/item_action/organ_action/go_feral/New(Target)
	..()
	name = pick(ability_name)

/datum/action/item_action/organ_action/go_feral/do_effect(trigger_flags)
	var/obj/item/organ/tongue/cat/cat_tongue = target
	cat_tongue.toggle_feral()
	if(!cat_tongue.feral_mode)
		background_icon_state = "bg_default"
		button_icon_state = "feral_mode_off"
		to_chat(cat_tongue.owner, span_notice("Вы будете атаковать в рукопашной как обычно."))
	else
		background_icon_state = "bg_default_on"
		button_icon_state = "feral_mode_on"
		to_chat(cat_tongue.owner, span_notice("Вы будете кусаться при рукопашной атаке."))
	build_all_button_icons()
	return TRUE
