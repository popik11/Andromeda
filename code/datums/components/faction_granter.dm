/**
 * ## Компонент передачи фракции!
 *
 * Компонент для предметов, позволяющий использовать их в руке для вступления в определённую фракцию
 * Пример - плюшевый капеллан, добавляющий вас в фракцию карпов.
 */
/datum/component/faction_granter
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Фракция, в которую добавляет предмет
	var/faction_to_grant
	/// Требуется ли святость для получения фракции
	var/holy_role_required
	/// Сообщение при получении фракции
	var/grant_message
	/// Был ли предмет уже использован
	var/used = FALSE

/datum/component/faction_granter/Initialize(faction_to_grant, holy_role_required = NONE, grant_message)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!grant_message)
		grant_message = "Вы подружились с [faction_to_grant]"
	src.faction_to_grant = faction_to_grant
	src.holy_role_required = holy_role_required
	src.grant_message = grant_message

/datum/component/faction_granter/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_self_attack))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/faction_granter/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ATOM_EXAMINE))

/// Сигнал при осмотре предмета
/datum/component/faction_granter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(used)
		examine_list += span_notice("Сила [parent] уже была использована.")
	else
		examine_list += span_notice("Использование [parent] в руке даст вам расположение [faction_to_grant]")

/// Сигнал при использовании в руке
/datum/component/faction_granter/proc/on_self_attack(atom/source, mob/user)
	SIGNAL_HANDLER
	if(used)
		to_chat(user, span_warning("Сила [parent] уже была использована!"))
		return
	if(user.mind?.holy_role < holy_role_required)
		to_chat(user, span_warning("Вы недостаточно святы, чтобы использовать силу [parent]!"))
		return

	to_chat(user, grant_message)
	user.faction |= faction_to_grant
	used = TRUE
