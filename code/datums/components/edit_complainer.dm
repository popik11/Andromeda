// Просто забавный компонент для примера работы с глобальными сигналами
/datum/component/edit_complainer
	var/list/say_lines

/datum/component/edit_complainer/Initialize(list/text)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/static/list/default_lines = list(
		"Расточительство ЦентКома рвёт ещё одну нить.",
		"Ещё один рывок за ткань реальности.",
		"Кто знает, когда напряжение окончательно разорвёт форму?",
		"Даже сейчас свет пробивается сквозь трещины.",
		"ЦентКом вновь искажает знание за пределами своих полномочий.",
		"В Мансусе витает неопределённость.",
		)
	say_lines = text || default_lines

	RegisterSignal(SSdcs, COMSIG_GLOB_VAR_EDIT, PROC_REF(var_edit_react))

/datum/component/edit_complainer/proc/var_edit_react(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/atom/movable/master = parent
	master.say(pick(say_lines))
