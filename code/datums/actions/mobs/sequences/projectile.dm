/datum/action/cooldown/mob_cooldown/direct_and_aoe
	name = "Прямая и Радиальная Атака"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Позволяет стрелять напрямую по цели, одновременно атакуя окружающее пространство."
	cooldown_time = 12 SECONDS
	sequence_actions = list(
		/datum/action/cooldown/mob_cooldown/dash = 0.1 SECONDS,
		/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator = 0,
	)
