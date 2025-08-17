/**
 * Реагирует на определённые сигналы и "взрывает" использующего предмет.
 * Отличается от `interaction_booby_trap` тем, что не создаёт реальный взрыв, а напрямую вызывает ex_act на цели.
 */
/datum/component/direct_explosive_trap
	/// Опциональный моб, которого нужно уведомлять о взрывах
	var/mob/living/saboteur
	/// Сила взрыва
	var/explosive_force
	/// Цвет подсветки при осмотре
	var/glow_colour
	/// Дополнительные проверки перед срабатыванием
	var/datum/callback/explosive_checks
	/// Сигналы, которые активируют ловушку (первый аргумент после source должен быть mob)
	var/list/triggering_signals

/datum/component/direct_explosive_trap/Initialize(
	mob/living/saboteur,
	explosive_force = EXPLODE_HEAVY,
	expire_time = 1 MINUTES,
	glow_colour = COLOR_RED,
	datum/callback/explosive_checks,
	list/triggering_signals = list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BUMPED)
)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.saboteur = saboteur
	src.explosive_force = explosive_force
	src.glow_colour = glow_colour
	src.explosive_checks = explosive_checks
	src.triggering_signals = triggering_signals

	if (expire_time > 0)
		addtimer(CALLBACK(src, PROC_REF(bomb_expired)), expire_time, TIMER_DELETE_ME)

/datum/component/direct_explosive_trap/RegisterWithParent()
	if (!(COMSIG_ATOM_EXAMINE in triggering_signals)) // Для особо коварных ловушек
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignals(parent, triggering_signals, PROC_REF(explode))
	if (!isnull(saboteur))
		RegisterSignal(saboteur, COMSIG_QDELETING, PROC_REF(on_bomber_deleted))

/datum/component/direct_explosive_trap/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE) + triggering_signals)
	if (!isnull(saboteur))
		UnregisterSignal(saboteur, COMSIG_QDELETING)

/datum/component/direct_explosive_trap/Destroy(force)
	if (isnull(saboteur))
		return ..()
	UnregisterSignal(saboteur, COMSIG_QDELETING)
	saboteur = null
	return ..()

/// Срабатывает при истечении времени без активации
/datum/component/direct_explosive_trap/proc/bomb_expired()
	if (!isnull(saboteur))
		to_chat(saboteur, span_bolddanger("Провал! Ваша ловушка никого не поймала..."))
	qdel(src)

/// Предупреждение при осмотре
/datum/component/direct_explosive_trap/proc/on_examined(datum/source, mob/user, text)
	SIGNAL_HANDLER
	text += span_holoparasite("Мерцает <font color=\"[glow_colour]\">странным светом</font>...")

/// Взрыв
/datum/component/direct_explosive_trap/proc/explode(atom/source, mob/living/victim)
	SIGNAL_HANDLER
	if (!isliving(victim))
		return
	if (!isnull(explosive_checks) && !explosive_checks.Invoke(victim))
		return
	to_chat(victim, span_bolddanger("[source] оказался ловушкой!"))
	if (!isnull(saboteur))
		to_chat(saboteur, span_bolddanger("Успех! Ваша ловушка на [source] сработала на [victim.name]!"))
	playsound(source, 'sound/effects/explosion/explosion2.ogg', 200, TRUE)
	new /obj/effect/temp_visual/explosion(get_turf(source))
	EX_ACT(victim, explosive_force)
	qdel(src)

/// Удаление ссылки на установившего бомбу
/datum/component/direct_explosive_trap/proc/on_bomber_deleted()
	SIGNAL_HANDLER
	saboteur = null
