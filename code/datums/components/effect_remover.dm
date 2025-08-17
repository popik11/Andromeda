/*
 * Простой компонент для предметов, способных уничтожать
 * определённые эффекты (например, руны культа) за одно использование.
 */
/datum/component/effect_remover
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Сообщение пользователю при успешном удалении
	var/success_feedback
	/// Форс-сообщение пользователя при успешном удалении
	var/success_forcesay
	/// Текст подсказки при наведении на удаляемый эффект (например "Уничтожить руну")
	var/tip_text
	/// Колбэк, вызываемый после удаления
	var/datum/callback/on_clear_callback
	/// Типы эффектов, которые можно удалить этим предметом
	var/list/obj/effect/effects_we_clear
	/// Если больше 0 - время, необходимое для удаления эффекта
	var/time_to_remove = 0 SECONDS

/datum/component/effect_remover/Initialize(
	success_forcesay,
	success_feedback,
	tip_text,
	on_clear_callback,
	effects_we_clear,
	time_to_remove,
	)

	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!effects_we_clear)
		stack_trace("[type] создан без указания удаляемых эффектов!")
		return COMPONENT_INCOMPATIBLE

	src.success_feedback = success_feedback
	src.success_forcesay = success_forcesay
	src.tip_text = tip_text
	src.on_clear_callback = on_clear_callback
	src.effects_we_clear = typecacheof(effects_we_clear)
	src.time_to_remove = time_to_remove

/datum/component/effect_remover/Destroy(force)
	on_clear_callback = null
	return ..()

/datum/component/effect_remover/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(try_remove_effect))

	if(tip_text)
		var/obj/item/item_parent = parent
		item_parent.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS
		RegisterSignal(parent, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))

/datum/component/effect_remover/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_INTERACTING_WITH_ATOM, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET))

/*
 * Обработчик сигнала COMSIG_ITEM_INTERACTING_WITH_ATOM.
 */

/datum/component/effect_remover/proc/try_remove_effect(datum/source, mob/living/user, atom/target, params)
	SIGNAL_HANDLER

	if(!isliving(user))
		return NONE

	if(HAS_TRAIT(target, TRAIT_ILLUSORY_EFFECT))
		to_chat(user, span_notice("Вы проводите [parent] сквозь [target], но ничего не происходит. Он вообще реальный?"))
		return NONE

	if(is_type_in_typecache(target, effects_we_clear))
		INVOKE_ASYNC(src, PROC_REF(do_remove_effect), target, user)
		return ITEM_INTERACT_SUCCESS

/*
 * Непосредственно удаляет эффект, вызывая колбэк перед удалением.
 */
/datum/component/effect_remover/proc/do_remove_effect(obj/effect/target, mob/living/user)
	if(time_to_remove && !do_after(user, time_to_remove, target))
		return

	var/obj/item/item_parent = parent
	if(success_forcesay)
		user.say(success_forcesay, forced = item_parent.name)
	if(success_feedback)
		var/real_feedback = replacetext(success_feedback, "%THEEFFECT", "[target]")
		real_feedback = replacetext(real_feedback, "%THEWEAPON", "[item_parent]")
		to_chat(user, span_notice(real_feedback))
	on_clear_callback?.Invoke(target, user)

	if(!QDELETED(target))
		qdel(target)

/*
 * Обработчик сигнала COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET.
 *
 * Добавляет контекстную подсказку для подходящих целей.
 */
/datum/component/effect_remover/proc/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if(effects_we_clear[target.type])
		context[SCREENTIP_CONTEXT_LMB] = tip_text
		return CONTEXTUAL_SCREENTIP_SET

	return NONE
