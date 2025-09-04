/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/resist
	hotkey_keys = list("R")
	name = "resist"
	full_name = "Сопротивляться"
	description = "Освободиться от текущего состояния. В наручниках? Вы горите? Сопротивляйтесь!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/owner = user.mob
	owner.resist()
	if (owner.hud_used?.resist_icon)
		owner.hud_used.resist_icon.icon_state = "[owner.hud_used.resist_icon.base_icon_state]_on"
	return TRUE

/datum/keybinding/living/resist/up(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/owner = user.mob
	if (owner.hud_used?.resist_icon)
		owner.hud_used.resist_icon.icon_state = owner.hud_used.resist_icon.base_icon_state

/datum/keybinding/living/look_up
	hotkey_keys = list("L")
	name = "look up"
	full_name = "Посмотреть вверх"
	description = "Посмотреть на нижний Z-уровень. Возможно только если над вами свободное пространство."
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_up()
	return TRUE

/datum/keybinding/living/look_up/up(client/user, turf/target)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look()
	return TRUE

/datum/keybinding/living/look_down
	hotkey_keys = list(";")
	name = "look down"
	full_name = "Посмотреть вниз"
	description = "Посмотреть на нижний Z-уровень. Возможно только если под вами его видно."
	keybind_signal = COMSIG_KB_LIVING_LOOKDOWN_DOWN

/datum/keybinding/living/look_down/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_down()
	return TRUE

/datum/keybinding/living/look_down/up(client/user, turf/target)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look()
	return TRUE

/datum/keybinding/living/rest
	hotkey_keys = list("B")
	name = "rest"
	full_name = "Лечь/встать"
	description = "Нажмите, чтобы лечь или встать."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/toggle_combat_mode
	hotkey_keys = list("F")
	name = "toggle_combat_mode"
	full_name = "Переключить Combat Mode"
	description = "Переключает боевой режим. Это как Помощь/Вред, но круче."
	keybind_signal = COMSIG_KB_LIVING_TOGGLE_COMBAT_DOWN


/datum/keybinding/living/toggle_combat_mode/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(!user_mob.combat_mode, FALSE)

/datum/keybinding/living/enable_combat_mode
	hotkey_keys = list("2")
	name = "enable_combat_mode"
	full_name = "Включить Combat Mode"
	description = "Включает боевой режим."
	keybind_signal = COMSIG_KB_LIVING_ENABLE_COMBAT_DOWN

/datum/keybinding/living/enable_combat_mode/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(TRUE, silent = FALSE)

/datum/keybinding/living/disable_combat_mode
	hotkey_keys = list("1")
	name = "disable_combat_mode"
	full_name = "Отключить Combat Mode"
	description = "Отключает боевой режим."
	keybind_signal = COMSIG_KB_LIVING_DISABLE_COMBAT_DOWN

/datum/keybinding/living/disable_combat_mode/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(FALSE, silent = FALSE)

/datum/keybinding/living/toggle_move_intent
	hotkey_keys = list("ctrl")
	name = "toggle_move_intent"
	full_name = "Удерживайте, чтобы переключить намерение перемещения"
	description = "Удерживайте нажатой кнопку, чтобы перейти к другому намерению движения, отпустите, чтобы вернуться назад."
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/living/toggle_move_intent/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_move_intent/up(client/user, turf/target)
	. = ..()
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_move_intent_alternative
	hotkey_keys = list("Unbound")
	name = "toggle_move_intent_alt"
	full_name = "Нажмите, чтобы запустить цикл перемещения намерения"
	description = "При нажатии на эту кнопку цикл переходит к противоположному намерению движения, но не возвращается назад."
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENTALT_DOWN

/datum/keybinding/living/toggle_move_intent_alternative/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_throw_mode
	hotkey_keys = list("`") // END
	name = "toggle_throw_mode"
	full_name = "Режим броска"
	description = "Переключить бросок текущего предмета."
	keybind_signal = COMSIG_KB_LIVING_TOGGLETHROWMODE_DOWN

/datum/keybinding/living/toggle_throw_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	living_user.toggle_throw_mode()
	return TRUE

/datum/keybinding/living/hold_throw_mode
	hotkey_keys = list("Space")
	name = "hold_throw_mode"
	full_name = "Удержание режима броска"
	description = "Удерживайте для включения режима броска, отпустите для выключения"
	keybind_signal = COMSIG_KB_LIVING_HOLDTHROWMODE_DOWN

/datum/keybinding/living/hold_throw_mode/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	living_user.throw_mode_on(THROW_MODE_HOLD)

/datum/keybinding/living/hold_throw_mode/up(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	living_user.throw_mode_off(THROW_MODE_HOLD)

/datum/keybinding/living/give
	hotkey_keys = list("G")
	name = "Give_Item"
	full_name = "Передать предмет"
	description = "Передать предмет, который вы сейчас держите"
	keybind_signal = COMSIG_KB_LIVING_GIVEITEM_DOWN

/datum/keybinding/living/give/can_use(client/user)
	. = ..()
	if (!.)
		return FALSE
	if(!user.mob)
		return FALSE
	if(!HAS_TRAIT(user.mob, TRAIT_CAN_HOLD_ITEMS))
		return FALSE
	return TRUE

/datum/keybinding/living/give/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	if(!HAS_TRAIT(living_user, TRAIT_CAN_HOLD_ITEMS))
		return
	living_user.give()
