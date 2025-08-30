/datum/station_goal
	var/name = "Общая Цель"
	var/weight = 1 //На случай нескольких целей в будущем.
	var/required_crew = 10
	var/requires_space = FALSE
	var/completed = FALSE
	var/report_message = "Выполните эту цель."

/datum/station_goal/proc/send_report()
	priority_announce("Получена приоритетная директива Нанотрейзен. Поступают детали проекта \"[name]\".", "Входящее Приоритетное Сообщение", SSstation.announcer.get_rand_report_sound())
	print_command_report(get_report(),"Директива Нанотрейзен [pick(GLOB.phonetic_alphabet)] \Roman[rand(1,50)]", announce=FALSE)
	on_report()

/datum/station_goal/proc/on_report()
	//Дополнительные разблокировки/изменения здесь
	return

/datum/station_goal/proc/get_report()
	return report_message

/datum/station_goal/proc/check_completion()
	return completed

/datum/station_goal/proc/get_result()
	if(check_completion())
		return "<li>[name] : [span_greentext("Выполнено!")]</li>"
	else
		return "<li>[name] : [span_redtext("Провалено!")]</li>"

/datum/station_goal/Topic(href, href_list)
	..()
	if(!check_rights(R_ADMIN) || !usr.client.holder.CheckAdminHref(href, href_list))
		return

	if(href_list["announce"])
		on_report()
		send_report()
	else if(href_list["remove"])
		qdel(src)

/datum/station_goal/New()
	if(type in SSstation.goals_by_type)
		stack_trace("Создание новой station_goal типа [type], когда она уже существует в SSstation.goals_by_type, нигде не поддерживается. Но я доверяю тебе")
	else
		SSstation.goals_by_type[type] = src
	return ..()

/datum/station_goal/Destroy(force)
	if(SSstation.goals_by_type[type] == src)
		SSstation.goals_by_type -= type
	return ..()
