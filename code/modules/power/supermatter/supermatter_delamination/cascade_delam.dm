/datum/sm_delam/cascade

/datum/sm_delam/cascade/can_select(obj/machinery/power/supermatter_crystal/sm)
	if(!sm.is_main_engine)
		return FALSE
	var/total_moles = sm.absorbed_gasmix.total_moles()
	if(total_moles < MOLE_PENALTY_THRESHOLD * sm.absorption_ratio)
		return FALSE
	for (var/gas_path in list(/datum/gas/antinoblium, /datum/gas/hypernoblium))
		var/percent = sm.gas_percentage[gas_path]
		if(!percent || percent < 0.4)
			return FALSE
	return TRUE

/datum/sm_delam/cascade/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(!..())
		return FALSE

	sm.radio.talk_into(
		sm,
		"ОПАСНОСТЬ: ЧАСТОТА КОЛЕБАНИЙ ГИПЕРСТРУКТУРЫ ВЫШЛА ЗА ПРЕДЕЛЫ.",
		sm.damage >= sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)
	var/list/messages = list(
		"Пространство вокруг вас, кажется, смещается...",
		"Вы слышите высокий звенящий звук.",
		"Вы чувствуете покалывание вдоль позвоночника.",
		"Что-то ощущается очень неправильным.",
		"Вас накрывает давящее чувство ужаса.",
	)
	dispatch_announcement_to_players(span_danger(pick(messages)), should_play_sound = FALSE)

	return TRUE

/datum/sm_delam/cascade/on_select(obj/machinery/power/supermatter_crystal/sm)
	message_admins("[sm] движется к каскаду. [ADMIN_VERBOSEJMP(sm)]")
	sm.investigate_log("движется к каскаду.", INVESTIGATE_ENGINE)

	sm.warp = new(sm)
	sm.vis_contents += sm.warp
	animate(sm.warp, time = 1, transform = matrix().Scale(0.5,0.5))
	animate(time = 9, transform = matrix())

	addtimer(CALLBACK(src, PROC_REF(announce_cascade), sm), 2 MINUTES)

/datum/sm_delam/cascade/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	message_admins("[sm] больше не будет каскадировать. [ADMIN_VERBOSEJMP(sm)]")
	sm.investigate_log("больше не будет каскадировать.", INVESTIGATE_ENGINE)

	sm.vis_contents -= sm.warp
	QDEL_NULL(sm.warp)

/datum/sm_delam/cascade/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Суперматерия [sm] в [ADMIN_VERBOSEJMP(sm)] вызвала каскадную делимитацию.")
	sm.investigate_log("вызвала каскадную делимитацию.", INVESTIGATE_ENGINE)

	effect_explosion(sm)
	effect_emergency_state()
	effect_cascade_demoralize()
	priority_announce("В вашем секторе произошло событие резонансного сдвига типа C. Сканирование указывает на локальный колебательный поток, влияющий на пространственную и гравитационную подструктуру. \
		Образовалось несколько резонансных горячих точек. Пожалуйста, ожидайте.", "Ассоциация Звёздного Наблюдения Nanotrasen", ANNOUNCER_SPANOMALIES)
	sleep(2 SECONDS)
	effect_strand_shuttle()
	sleep(5 SECONDS)
	var/obj/cascade_portal/rift = effect_evac_rift_start()
	RegisterSignal(rift, COMSIG_QDELETING, PROC_REF(end_round_holder))
	SSsupermatter_cascade.can_fire = TRUE
	SSsupermatter_cascade.cascade_initiated = TRUE
	effect_crystal_mass(sm, rift)
	return ..()

/datum/sm_delam/cascade/examine(obj/machinery/power/supermatter_crystal/sm)
	return list(span_bolddanger("Кристалл вибрирует с огромной скоростью, искривляя пространство вокруг!"))

/datum/sm_delam/cascade/overlays(obj/machinery/power/supermatter_crystal/sm)
	return list()

/datum/sm_delam/cascade/count_down_messages(obj/machinery/power/supermatter_crystal/sm)
	var/list/messages = list()
	messages += "ДЕЛИМИТАЦИЯ КРИСТАЛЛА НЕИЗБЕЖНА. Суперматерия достигла критического разрушения целостности. Пределы гармонической частоты превышены. Поле дестабилизации причинности не может быть задействовано."
	messages += "Кристаллическая гиперструктура возвращается к безопасным рабочим параметрам. Гармоническая частота восстановлена в аварийных пределах. Инициирован антирезонансный фильтр."
	messages += "осталось до стабилизации, вызванной резонансом."
	return messages

/datum/sm_delam/cascade/proc/announce_cascade(obj/machinery/power/supermatter_crystal/sm)
	if(QDELETED(sm))
		return FALSE
	if(!can_select(sm))
		return FALSE
	priority_announce("Внимание: сканирование аномалий дальнего действия обнаружило аномальное количество гармонического потока, исходящего \
	от объекта на [station_name()], может произойти резонансный коллапс.",
	"Ассоциация Звёздного Наблюдения Nanotrasen", 'sound/announcer/alarm/airraid.ogg')
	return TRUE

/// Обработчики сигналов не могут спать, нам придётся сделать так.
/datum/sm_delam/cascade/proc/end_round_holder()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(effect_evac_rift_end))
