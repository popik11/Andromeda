/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Переключить [item_target.name]"

/datum/action/item_action/toggle_light
	name = "Переключить свет"

/datum/action/item_action/toggle_computer_light
	name = "Переключить фонарик"

/datum/action/item_action/toggle_hood
	name = "Надеть/снять капюшон"

/datum/action/item_action/toggle_firemode
	name = "Переключить режим огня"

/datum/action/item_action/toggle_gunlight
	name = "Переключить тактический фонарь"

/datum/action/item_action/toggle_mode
	name = "Переключить режим"

/datum/action/item_action/toggle_barrier_spread
	name = "Переключить барьер"

/datum/action/item_action/toggle_paddles
	name = "Переключить электроды"

/datum/action/item_action/toggle_mister
	name = "Переключить распылитель"

/datum/action/item_action/toggle_helmet_light
	name = "Переключить свет шлема"

/datum/action/item_action/toggle_welding_screen
	name = "Откинуть/закрыть сварочный щиток"

/datum/action/item_action/toggle_spacesuit
	name = "Переключить терморегулятор скафандра"
	button_icon = 'icons/mob/actions/actions_spacesuit.dmi'
	button_icon_state = "thermal_off"

/datum/action/item_action/toggle_spacesuit/apply_button_icon(atom/movable/screen/movable/action_button/button, force)
	var/obj/item/clothing/suit/space/suit = target
	if(istype(suit))
		button_icon_state = "thermal_[suit.thermal_on ? "on" : "off"]"
	return ..()

/datum/action/item_action/toggle_helmet_flashlight
	name = "Переключить фонарь шлема"

/datum/action/item_action/toggle_helmet_mode
	name = "Переключить режим шлема"

/datum/action/item_action/toggle_voice_box
	name = "Переключить голосовой модуль"

/datum/action/item_action/toggle_helmet
	name = "Надеть/снять шлем"

/datum/action/item_action/toggle_seclight
	name = "Переключить фонарь охраны"

/datum/action/item_action/toggle_jetpack
	name = "Переключить джетпак"

/datum/action/item_action/jetpack_stabilization
	name = "Переключить стабилизацию джетпака"

/datum/action/item_action/jetpack_stabilization/IsAvailable(feedback = FALSE)
	var/obj/item/tank/jetpack/linked_jetpack = target
	if(!istype(linked_jetpack) || !linked_jetpack.on)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle_hud
	name = "Переключить имплант HUD"
	desc = "Отключает визуальную часть HUD импланта. Вы по-прежнему можете получать информацию при осмотре."

/datum/action/item_action/organ_action/toggle_hud/do_effect(trigger_flags)
	var/obj/item/organ/cyberimp/eyes/hud/hud_implant = target
	hud_implant.toggle_hud(owner)
	return TRUE

/datum/action/item_action/wheelys
	name = "Выдвинуть/убрать колеса"
	desc = "Выдвигает или убирает колеса на вашей обуви."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"

/datum/action/item_action/kindle_kicks
	name = "Активировать Kindle Kicks"
	desc = "Щелкните каблуками, чтобы активировать подсветку на обуви."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

/datum/action/item_action/storage_gather_mode
	name = "Сменить режим сбора"
	desc = "Изменяет режим сбора предметов в контейнере."
	background_icon = 'icons/mob/actions/actions_items.dmi'
	background_icon_state = "storage_gather_switch"
	overlay_icon_state = "bg_tech_border"

/datum/action/item_action/flip
	name = "Перевернуть"

/datum/action/item_action/call_link
	name = "Вызов МОДлинк"

/datum/action/item_action/toggle_wearable_hud
	name = "Переключить носимый HUD"
	desc = "Включает/выключает носимый HUD. Вы по-прежнему можете получать информацию при осмотре."

/datum/action/item_action/toggle_wearable_hud/do_effect(trigger_flags)
	var/obj/item/clothing/glasses/hud/hud_display = target
	hud_display.toggle_hud_display(owner)
	return TRUE

/datum/action/item_action/toggle_nv
	name = "Переключить ночное видение"
	var/stored_cutoffs
	var/stored_colour

/datum/action/item_action/toggle_nv/New(obj/item/clothing/glasses/target)
	. = ..()
	target.AddElement(/datum/element/update_icon_updates_onmob)

/datum/action/item_action/toggle_nv/do_effect(trigger_flags)
	if(!istype(target, /obj/item/clothing/glasses))
		return ..()
	var/obj/item/clothing/glasses/goggles = target
	var/mob/holder = goggles.loc
	if(!istype(holder) || holder.get_slot_by_item(goggles) != ITEM_SLOT_EYES)
		holder = null
	if(stored_cutoffs)
		goggles.color_cutoffs = stored_cutoffs
		goggles.flash_protect = FLASH_PROTECTION_SENSITIVE
		stored_cutoffs = null
		if(stored_colour)
			goggles.change_glass_color(stored_colour)
		playsound(goggles, 'sound/items/night_vision_on.ogg', 30, TRUE, -3)
	else
		stored_cutoffs = goggles.color_cutoffs
		stored_colour = goggles.glass_colour_type
		goggles.color_cutoffs = list()
		goggles.flash_protect = FLASH_PROTECTION_NONE
		if(stored_colour)
			goggles.change_glass_color(null)
		playsound(goggles, 'sound/machines/click.ogg', 30, TRUE, -3)
	holder?.update_sight()
	goggles.update_appearance()
	return TRUE
