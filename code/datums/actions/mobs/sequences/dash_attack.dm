/datum/action/cooldown/mob_cooldown/dash_attack
	name = "Рывок и Атака"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Позволяет совершить рывок и атаковать цель одновременно."
	cooldown_time = 3 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_2
	sequence_actions = list(
		/datum/action/cooldown/mob_cooldown/dash = 0.1 SECONDS,
		/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator = 0,
	)
