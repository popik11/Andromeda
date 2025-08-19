/area/station/command
	name = "Командование"
	icon_state = "command"
	ambientsounds = list(
		'sound/ambience/misc/signal.ogg',
		)
	airlock_wires = /datum/wires/airlock/command
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/command/bridge
	name = "\improper Мостик"
	icon_state = "bridge"

/area/station/command/meeting_room
	name = "\improper Комната совещаний руководства"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/meeting_room/council
	name = "\improper Зал совета"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_showroom
	name = "\improper Корпоративный шоурум"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_suite
	name = "\improper Гостевые апартаменты корпорации"
	icon_state = "command"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/emergency_closet
	name = "\improper Аварийный шкаф корпорации"
	icon_state = "command"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/*
* Кабинеты глав
*/

/area/station/command/heads_quarters
	icon_state = "heads_quarters"

/area/station/command/heads_quarters/captain
	name = "\improper Кабинет капитана"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/captain/private
	name = "\improper Каюта капитана"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/ce
	name = "\improper Кабинет старшего инженера"
	icon_state = "ce_office"

/area/station/command/heads_quarters/cmo
	name = "\improper Кабинет главного врача"
	icon_state = "cmo_office"

/area/station/command/heads_quarters/hop
	name = "\improper Кабинет главы персонала"
	icon_state = "hop_office"

/area/station/command/heads_quarters/hos
	name = "\improper Кабинет главы службы безопасности"
	icon_state = "hos_office"

/area/station/command/heads_quarters/rd
	name = "\improper Кабинет научного руководителя"
	icon_state = "rd_office"

/area/station/command/heads_quarters/qm
	name = "\improper Кабинет квартирмейстера"
	icon_state = "qm_office"

/*
* Командование - Телепортация
*/

/area/station/command/teleporter
	name = "\improper Телепортационная"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/station/command/gateway
	name = "\improper Гейтвей"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI

/*
* Командование - Разное
*/

/area/station/command/corporate_dock
	name = "\improper Корпоративный док"
	icon_state = "command"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
