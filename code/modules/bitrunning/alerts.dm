/atom/movable/screen/alert/bitrunning
	name = "Общее оповещение битраннинга"
	icon_state = "template"
	timeout = 10 SECONDS

/atom/movable/screen/alert/bitrunning/qserver_domain_complete
	name = "Домен завершён"
	desc = "Домен завершён. Активируйте для выхода."
	timeout = 20 SECONDS
	clickable_glow = TRUE

/atom/movable/screen/alert/bitrunning/qserver_domain_complete/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/mob/living/living_owner = owner
	if(!isliving(living_owner))
		return

	if(tgui_alert(living_owner, "Безопасно отключиться?", "Сообщение сервера", list("Выйти", "Остаться"), 10 SECONDS) == "Выйти")
		SEND_SIGNAL(living_owner, COMSIG_BITRUNNER_ALERT_SEVER)

