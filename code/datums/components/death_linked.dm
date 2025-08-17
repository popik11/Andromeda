/**
 * ## Компонент смертельной связи
 *
 * При смерти носителя этого компонента также уничтожает связанного моба
 */
/datum/component/death_linked
	///Моб, который тоже умрёт при смерти владельца
	var/datum/weakref/linked_mob

/datum/component/death_linked/Initialize(mob/living/target_mob)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(isnull(target_mob))
		stack_trace("[type] добавлен к [parent] без связанного моба.")
	src.linked_mob = WEAKREF(target_mob)

/datum/component/death_linked/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/component/death_linked/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)

///Сигнал при изменении состояния цели
/datum/component/death_linked/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/mob/living/linked_mob_resolved = linked_mob?.resolve()
	linked_mob_resolved?.gib(DROP_ALL_REMAINS)
