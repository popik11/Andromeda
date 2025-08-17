///Хранитель данных для дикторов, которые могут быть использованы в игре. Позволяет создавать альтернативные объявления помимо стандартных, например, для интерна
/datum/centcom_announcer
	///Аудио при начале смены
	var/welcome_sounds = list()
	///Звуки при получении объявления
	var/alert_sounds = list()
	///Звуки при получении командного отчета
	var/command_report_sounds = list()
	///Аудио для событий (ассоциативный список ключ-звук). Если звук не найден, используется стандартный
	var/event_sounds = list()
	///Переопределите это для кастомного сообщения вместо стандартного приоритетного объявления
	var/custom_alert_message


/datum/centcom_announcer/proc/get_rand_welcome_sound()
	return pick(welcome_sounds)


/datum/centcom_announcer/proc/get_rand_alert_sound()
	return pick(alert_sounds)

/datum/centcom_announcer/proc/get_rand_report_sound()
	return pick(command_report_sounds)
