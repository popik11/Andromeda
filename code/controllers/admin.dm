// Кликабельная кнопка stat().
/obj/effect/statclick
	name = "Инициализация..."
	blocks_emissive = EMISSIVE_BLOCK_NONE
	var/target

INITIALIZE_IMMEDIATE(/obj/effect/statclick)

/obj/effect/statclick/Initialize(mapload, text, target)
	. = ..()
	name = text
	src.target = target
	if(isdatum(target)) // Защита от хардделов
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(cleanup))

/obj/effect/statclick/Destroy()
	target = null
	return ..()

/obj/effect/statclick/proc/cleanup()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/statclick/proc/update(text)
	name = text
	return src

/obj/effect/statclick/debug
	var/class

/obj/effect/statclick/debug/Click()
	if(!usr.client.holder || !target)
		return
	if(!class)
		if(istype(target, /datum/controller/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else if(isdatum(target))
			class = "datum"
		else
			class = "unknown"

	usr.client.debug_variables(target)
	message_admins("Администратор [key_name_admin(usr)] отлаживает [target] ([class]).")

ADMIN_VERB(restart_controller, R_DEBUG, "Перезапустить Контроллер", "Перезапускает один из периодических контроллеров игры (будьте осторожны!)", ADMIN_CATEGORY_DEBUG, controller in list("Master", "Failsafe"))
	switch(controller)
		if("Master")
			Recreate_MC()
			BLACKBOX_LOG_ADMIN_VERB("Перезапуск Master Controller")
		if("Failsafe")
			new /datum/controller/failsafe()
			BLACKBOX_LOG_ADMIN_VERB("Перезапуск Failsafe Controller")

	message_admins("Администратор [key_name_admin(user)] перезапустил контроллер [controller].")

ADMIN_VERB(debug_controller, R_DEBUG, "Отладить Контроллер", "Отлаживает различные периодические контроллеры игры (будьте осторожны!)", ADMIN_CATEGORY_DEBUG)
	var/list/controllers = list()
	var/list/controller_choices = list()

	for (var/var_key in global.vars)
		var/datum/controller/controller = global.vars[var_key]
		if(!istype(controller) || istype(controller, /datum/controller/subsystem))
			continue
		controllers[controller.name] = controller // Используем ассоциативный список для предотвращения утечек ссылок
		controller_choices += controller.name

	var/datum/controller/controller_string = input("Выберите контроллер для отладки", "Отладка Контроллера") as null|anything in controller_choices
	var/datum/controller/controller = controllers[controller_string]

	if (!istype(controller))
		return

	user.debug_variables(controller)

	BLACKBOX_LOG_ADMIN_VERB("Отладка Контроллера")
	message_admins("Администратор [key_name_admin(user)] отлаживает контроллер [controller].")
