/**
 * Развертываемое - Возьмите с собой тяжёлое вооружение и установите его где нужно.
 *
 * Позволяет предметам создавать другие предметы (обычно объекты) перед пользователем после небольшой задержки.
 * При добавлении этого компонента:
 * Установите deploy_time в число (секунды) для задержки развертывания
 * Установите thing_to_be_deployed в путь объекта, который будет создан
 * Если multiple_deployments = TRUE, deployments определяет сколько раз можно развернуть объект
 * direction_setting = TRUE означает что объект будет повёрнут в сторону пользователя
 */

/datum/component/deployable
	/// Время развертывания объекта
	var/deploy_time
	/// Объект, который создаётся при успешном развертывании
	var/obj/thing_to_be_deployed
	/// Можно ли развернуть объект несколько раз
	var/multiple_deployments
	/// Сколько раз можно развернуть объект (при multiple_deployments = TRUE)
	var/deployments
	/// Добавлять ли подсказку в описание предмета
	var/add_description_hint
	/// Менять ли направление развернутого объекта
	var/direction_setting

	/// Имя развернутого объекта (для описания)
	var/deployed_name

/datum/component/deployable/Initialize(deploy_time = 5 SECONDS, thing_to_be_deployed, multiple_deployments = FALSE, deployments = 1, add_description_hint = TRUE, direction_setting = TRUE)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.deploy_time = deploy_time
	src.thing_to_be_deployed = thing_to_be_deployed
	src.add_description_hint = add_description_hint
	src.direction_setting = direction_setting
	src.deployments = deployments
	src.multiple_deployments = multiple_deployments

	if(add_description_hint)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_hand))

	var/obj/item/typecast = thing_to_be_deployed
	deployed_name = initial(typecast.name)

/datum/component/deployable/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Можно использовать <b>в руках</b> для развертывания в [((deployments > 1) && multiple_deployments) ? "[deployments]" : ""] [deployed_name].")

/datum/component/deployable/proc/on_attack_hand(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(deploy), source, user, location, direction)

/datum/component/deployable/proc/deploy(obj/source, mob/user, location, direction) // Если нет пользователя, используются location и direction
	// Создаваемый объект
	var/atom/deployed_object
	// Позиция развертывания
	var/turf/deploy_location
	// Направление объекта
	var/new_direction

	if(user)
		deploy_location = get_step(user, user.dir) // Позиция перед пользователем
		if(deploy_location.is_blocked_turf(TRUE, parent))
			source.balloon_alert(user, "недостаточно места!")
			return
		new_direction = user.dir // Направление пользователя
		source.balloon_alert(user, "развертывание...")
		playsound(source, 'sound/items/tools/ratchet.ogg', 50, TRUE)
		if(!do_after(user, deploy_time))
			return
	else // Если нет пользователя
		deploy_location = location
		new_direction = direction

	deployed_object = new thing_to_be_deployed(deploy_location)
	if(direction_setting)
		deployed_object.setDir(new_direction)
		deployed_object.update_icon_state()

	deployments -= 1

	if(!multiple_deployments || deployments < 1)
		qdel(source)
