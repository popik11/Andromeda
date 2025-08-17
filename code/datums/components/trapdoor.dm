
///makes this file more legible
#define IS_OPEN(parent) isgroundlessturf(parent)
///distance a trapdoor will accept a link request.
#define TRAPDOOR_LINKING_SEARCH_RANGE 4

/**
 * ## trapdoor component!
 *
 * component attached to floors to turn them into trapdoors, a constructable trap that when signalled drops people to the level below.
 * assembly code at the bottom of this file
 */
/datum/component/trapdoor
	///assembly tied to this trapdoor
	var/obj/item/assembly/trapdoor/assembly
	///path of the turf this should change into when the assembly is pulsed. needed for openspace trapdoors knowing what to turn back into
	var/trapdoor_turf_path
	/// is this trapdoor "conspicuous" (ie. it gets examine text and overlay added)
	var/conspicuous
	/// overlay that makes trapdoors more obvious
	var/static/trapdoor_overlay
	/**
	* list of lists that are arguments for readding decals when the linked trapdoor comes back. pain.
	*
	* we are storing this data FOR the trapdoor component we are linked to. kinda like a multitool.
	* format: list(list(element's description, element's cleanable, element's directional, element's pic))
	* the list will be filled with all the data of the deleting elements (when ChangeTurf is called) only when the trapdoor begins to open.
	* so any other case the elements will be changed but not recorded.
	*/
	var/list/stored_decals = list()
	/// Trapdoor shuts close automatically
	var/autoclose = TRUE
	/// Delay before trapdoor shuts close
	var/autoclose_delay = 5 SECONDS

/datum/component/trapdoor/Initialize(starts_open, trapdoor_turf_path, assembly, conspicuous = TRUE, list/carried_decals = null, autoclose = TRUE)
	if(!isopenturf(parent))
		return COMPONENT_INCOMPATIBLE

	src.conspicuous = conspicuous
	src.assembly = assembly
	src.autoclose = autoclose
	if(carried_decals)
		stored_decals = carried_decals.Copy()

	if(!trapdoor_overlay)
		trapdoor_overlay = mutable_appearance('icons/turf/overlays.dmi', "border_black", ABOVE_NORMAL_TURF_LAYER)

	if(IS_OPEN(parent))
		openspace_trapdoor_setup(trapdoor_turf_path, assembly)
		if(autoclose)
			addtimer(CALLBACK(src, PROC_REF(try_closing)), autoclose_delay)
	else
		tile_trapdoor_setup(trapdoor_turf_path, assembly)

	if(starts_open)
		try_opening()

///initializing as an opened trapdoor, we need to trust that we were given the data by a closed trapdoor
/datum/component/trapdoor/proc/openspace_trapdoor_setup(trapdoor_turf_path)
	src.trapdoor_turf_path = trapdoor_turf_path

///initializing as a closed trapdoor, we need to take data from the tile we're on to give it to the open state to store
/datum/component/trapdoor/proc/tile_trapdoor_setup(trapdoor_turf_path)
	src.trapdoor_turf_path = parent.type
	if(stored_decals.len)
		reapply_all_decals()
	if(conspicuous)
		var/turf/parent_turf = parent
		parent_turf.add_overlay(trapdoor_overlay)

/datum/component/trapdoor/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_TURF_CHANGE, PROC_REF(turf_changed_pre))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	if(!src.assembly)
		RegisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK, PROC_REF(on_link_requested))
	else
		RegisterSignal(assembly, COMSIG_ASSEMBLY_PULSED, PROC_REF(toggle_trapdoor))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(try_unlink))
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(try_link))

/datum/component/trapdoor/UnregisterFromParent()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK)
	if(assembly)
		UnregisterSignal(assembly, COMSIG_ASSEMBLY_PULSED)
	UnregisterSignal(parent, COMSIG_TURF_CHANGE)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL))
	UnregisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION)

/datum/component/trapdoor/proc/try_unlink(turf/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!assembly)
		return
	if(IS_OPEN(parent))
		source.balloon_alert(user, "нельзя отсоединять шлюз в открытом состоянии")
		return
	source.balloon_alert(user, "отсоединяем шлюз")
	INVOKE_ASYNC(src, PROC_REF(async_try_unlink), source, user, tool)
	return

/datum/component/trapdoor/proc/try_link(turf/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!istype(tool, /obj/item/trapdoor_remote))
		return
	var/obj/item/trapdoor_remote/remote = tool
	if(!remote.internals)
		source.balloon_alert(user, "отсутствуют компоненты")
		return
	if(IS_OPEN(parent))
		source.balloon_alert(user, "нельзя подключить шлюз в открытом состоянии")
		return
	if(assembly)
		source.balloon_alert(user, "уже подключен")
		return
	source.balloon_alert(user, "подключаем шлюз")
	INVOKE_ASYNC(src, PROC_REF(async_try_link), source, user, tool)

/datum/component/trapdoor/proc/async_try_link(turf/source, mob/user, obj/item/trapdoor_remote/remote)
	if(!do_after(user, 2 SECONDS, target=source))
		return
	if(IS_OPEN(parent))
		source.balloon_alert(user, "нельзя подключить шлюз в открытом состоянии")
		return
	src.assembly = remote.internals
	++assembly.linked
	source.balloon_alert(user, "шлюз подключен")
	UnregisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK)
	RegisterSignal(assembly, COMSIG_ASSEMBLY_PULSED, PROC_REF(toggle_trapdoor))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(try_unlink))

/datum/component/trapdoor/proc/async_try_unlink(turf/source, mob/user, obj/item/tool)
	if(!do_after(user, 5 SECONDS, target=source))
		return
	if(IS_OPEN(parent))
		source.balloon_alert(user, "нельзя отсоединять шлюз в открытом состоянии")
		return
	assembly.linked = max(assembly.linked - 1, 0)
	stored_decals = list()
	UnregisterSignal(assembly, COMSIG_ASSEMBLY_PULSED)
	UnregisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL))
	RegisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK, PROC_REF(on_link_requested))
	assembly = null
	source.balloon_alert(user, "шлюз отсоединён")

/datum/component/trapdoor/proc/decal_detached(datum/source, description, cleanable, directional, pic)
	SIGNAL_HANDLER
	///so it adds the list to the list, not appending it to the end. thank you byond, very cool.
	stored_decals += list(list(description, cleanable, directional, pic))

/**
 * ## reapply_all_decals
 *
 * changing turfs does not bring over decals, so we must perform a little bit of element reapplication.
 */
/datum/component/trapdoor/proc/reapply_all_decals()
	for(var/list/element_data as anything in stored_decals)
		apply_decal(element_data[1], element_data[2], element_data[3], element_data[4])
	stored_decals = list()

/// small proc that takes passed arguments and drops it into a new element
/datum/component/trapdoor/proc/apply_decal(description, cleanable, directional, pic)
	parent.AddElement(/datum/element/decal, _description = description, _cleanable = cleanable, _dir = directional, _pic = pic)

///called by linking remotes to tie an assembly to the trapdoor
/datum/component/trapdoor/proc/on_link_requested(datum/source, obj/item/assembly/trapdoor/assembly)
	SIGNAL_HANDLER
	if(get_dist(parent, assembly) > TRAPDOOR_LINKING_SEARCH_RANGE)
		return
	. = LINKED_UP
	src.assembly = assembly
	++assembly.linked
	UnregisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK)
	RegisterSignal(assembly, COMSIG_ASSEMBLY_PULSED, PROC_REF(toggle_trapdoor))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(try_unlink))

///signal called by our assembly being pulsed
/datum/component/trapdoor/proc/toggle_trapdoor(datum/source)
	SIGNAL_HANDLER
	if(assembly)
		autoclose = assembly.autoclose
	if(!IS_OPEN(parent))
		try_opening()
	else
		try_closing()

///signal called by turf changing
/datum/component/trapdoor/proc/turf_changed_pre(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER
	var/turf/open/dying_trapdoor = parent
	if((flags & CHANGETURF_TRAPDOOR_INDUCED) == 0) //not a process of the trapdoor
		if(!IS_OPEN(parent) && !ispath(path, /turf/closed) && !ispath(path, /turf/open/openspace)) // allow people to place tiles on plating / change tiles without breaking the trapdoor
			post_change_callbacks += CALLBACK(src, TYPE_PROC_REF(/datum/component/trapdoor, carry_over_trapdoor), path, conspicuous, assembly)
			return
		// otherwise, break trapdoor
		dying_trapdoor.visible_message(span_warning("Механизм шлюза в [dying_trapdoor] сломан!"))
		if(assembly)
			assembly.linked = max(assembly.linked - 1, 0)
			stored_decals.Cut()
			assembly = null
		return
	post_change_callbacks += CALLBACK(src, TYPE_PROC_REF(/datum/component/trapdoor, carry_over_trapdoor), trapdoor_turf_path, conspicuous, assembly)

/**
 * ## carry_over_trapdoor
 *
 * applies the trapdoor to the new turf (created by the last trapdoor)
 * apparently callbacks with arguments on invoke and the callback itself have the callback args go first. interesting!
 */
/datum/component/trapdoor/proc/carry_over_trapdoor(trapdoor_turf_path, conspicuous, assembly, turf/new_turf)
	new_turf.AddComponent(/datum/component/trapdoor, FALSE, trapdoor_turf_path, assembly, conspicuous, stored_decals, autoclose)

/**
 * ## on_examine
 *
 * examine message for conspicuous trapdoors that makes it obvious
 */
/datum/component/trapdoor/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(conspicuous)
		examine_text += "Вокруг этой плитки виден небольшой зазор с проводами, которые можно активировать <b>мультитулом</b>."

/**
 * ## try_opening
 *
 * small proc for opening the turf into openspace
 * there are no checks for opening a trapdoor, but closed has some
 */
/datum/component/trapdoor/proc/try_opening()
	var/turf/open/trapdoor_turf = parent
	///we want to save this turf's decals as they were right before deletion, so this is the point where we begin listening
	if(assembly)
		RegisterSignal(parent, COMSIG_TURF_DECAL_DETACHED, PROC_REF(decal_detached))
	playsound(trapdoor_turf, 'sound/machines/trapdoor/trapdoor_open.ogg', 50)
	trapdoor_turf.visible_message(span_warning("[trapdoor_turf] распахивается!"))
	trapdoor_turf.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR | CHANGETURF_TRAPDOOR_INDUCED)

/**
 * ## try_closing
 *
 * small proc for closing the turf back into what it should be
 * trapdoor can be blocked by building things on the openspace turf
 */
/datum/component/trapdoor/proc/try_closing()
	var/turf/open/trapdoor_turf = parent
	var/obj/structure/lattice/blocking = locate() in trapdoor_turf.contents
	if(blocking)
		trapdoor_turf.visible_message(span_warning("Механизм шлюза в [trapdoor_turf] пытается закрыться, но застрял на [blocking]!"))
		return
	playsound(trapdoor_turf, 'sound/machines/trapdoor/trapdoor_shut.ogg', 50)
	trapdoor_turf.visible_message(span_warning("Механизм шлюза в [trapdoor_turf] захлопывается!"))
	trapdoor_turf.ChangeTurf(trapdoor_turf_path, flags = CHANGETURF_INHERIT_AIR | CHANGETURF_TRAPDOOR_INDUCED)

#undef IS_OPEN

/obj/item/assembly/trapdoor
	name = "trapdoor controller"
	desc = "Зловещего вида пульт управления шлюзом."
	icon_state = "trapdoor"
	///if the trapdoor isn't linked it will try to link on pulse, this shouldn't be spammable
	COOLDOWN_DECLARE(search_cooldown)
	///trapdoor link cooldown time here!
	var/search_cooldown_time = 10 SECONDS
	///if true, a trapdoor in the world has a reference to this assembly and is listening for when it is pulsed.
	var/linked = FALSE
	/// Linked trapdoors will automatically close
	var/autoclose = TRUE

/obj/item/assembly/trapdoor/pulsed(mob/pulser)
	. = ..()
	if(linked > 0)
		return
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		if(loc && pulser)
			loc.balloon_alert(pulser, "перезарядка подключения!")
		return
	attempt_link_up()
	COOLDOWN_START(src, search_cooldown, search_cooldown_time)

/obj/item/assembly/trapdoor/proc/attempt_link_up()
	var/turf/assembly_turf = get_turf(src)
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		var/timeleft = DisplayTimeText(COOLDOWN_TIMELEFT(src, search_cooldown))
		assembly_turf.visible_message(span_warning("[src] на перезарядке! Подождите [timeleft]."), vision_distance = SAMETILE_MESSAGE_RANGE)
		return
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_TRAPDOOR_LINK, src) & LINKED_UP)
		playsound(assembly_turf, 'sound/machines/chime.ogg', 50, TRUE)
		assembly_turf.visible_message(span_notice("[src] подключился к ближайшему шлюзу! \
		Теперь можно проверить его местоположение... будьте осторожны!"), vision_distance = SAMETILE_MESSAGE_RANGE)
	else
		playsound(assembly_turf, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
		assembly_turf.visible_message(span_warning("[src] не нашёл поблизости шлюза для подключения."), vision_distance = SAMETILE_MESSAGE_RANGE)

/**
 * ## trapdoor remotes!
 *
 * Item that accepts the assembly for the internals and helps link/activate it.
 * This base type is an empty shell that needs the assembly added to it first to work.
 */
/obj/item/trapdoor_remote
	name = "trapdoor remote"
	desc = "Небольшое устройство для удобного управления контроллером шлюза."
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "trapdoor_remote"
	COOLDOWN_DECLARE(trapdoor_cooldown)
	var/trapdoor_cooldown_time = 2 SECONDS
	var/obj/item/assembly/trapdoor/internals

/obj/item/trapdoor_remote/examine(mob/user)
	. = ..()
	if(!internals)
		. += span_warning("В [src] отсутствуют компоненты! Для работы нужен контроллер шлюза.")
		return
	. += span_notice("Компоненты можно извлечь отвёрткой.")
	if(!internals.linked)
		. += span_warning("[src] не подключен к шлюзу.")
		. += span_notice("[src] подключится к ближайшему шлюзу при использовании.")
		return
	. += span_notice("[src] подключен к [internals.linked] шлюзу(ам).")
	. += span_notice("Можно подключить к дополнительным шлюзам, используя на них.")
	. += span_notice("Шлюз можно отключить мультитулом.")
	. += span_notice("Автозакрытие [internals.autoclose ? "включено" : "выключено"], ctrl+клик для переключения.")
	if(!COOLDOWN_FINISHED(src, trapdoor_cooldown))
		. += span_warning("Сейчас на перезарядке.")

/obj/item/trapdoor_remote/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!internals)
		to_chat(user, span_warning("В [src] нет компонентов!"))
		return
	to_chat(user, span_notice("Вы извлекаете [internals] из [src]."))
	internals.forceMove(get_turf(src))
	internals = null

/obj/item/trapdoor_remote/item_interaction(mob/living/user, obj/item/assembly/trapdoor/assembly, list/modifiers)
	if(!istype(assembly))
		return NONE
	if(internals)
		balloon_alert(user, "не помещается!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "добавлен")
	internals = assembly
	user.transferItemToLoc(assembly, src)
	return ITEM_INTERACT_SUCCESS

/obj/item/trapdoor_remote/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return TRUE

	if(!internals)
		user.balloon_alert(user, "нет устройства!")
		return TRUE

	if(!internals.linked)
		internals.pulsed(user)
		// Успешное подключение
		if(internals.linked)
			user.balloon_alert(user, "подключено [internals.linked] шлюзов")
		// Не удалось подключиться
		else
			user.balloon_alert(user, "не удалось подключиться!")
		return TRUE

	if(!COOLDOWN_FINISHED(src, trapdoor_cooldown))
		user.balloon_alert(user, "на перезарядке!")
		return TRUE

	user.balloon_alert(user, "шлюз активирован")
	playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 50, FALSE)
	icon_state = "trapdoor_pressed"
	addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), trapdoor_cooldown_time)
	COOLDOWN_START(src, trapdoor_cooldown, trapdoor_cooldown_time)
	internals.pulsed(user)
	return TRUE

/obj/item/trapdoor_remote/item_ctrl_click(mob/user)
	if (!user.is_holding(src))
		return CLICK_ACTION_BLOCKING
	if(!internals)
		user.balloon_alert(user, "нет устройства!")
		return CLICK_ACTION_BLOCKING

	internals.autoclose = !internals.autoclose
	user.balloon_alert(user, "автозакрытие [internals.autoclose ? "включено" : "выключено"]")
	return CLICK_ACTION_SUCCESS

#undef TRAPDOOR_LINKING_SEARCH_RANGE

///subtype with internals already included. If you're giving a department a roundstart trapdoor, this is what you want
/obj/item/trapdoor_remote/preloaded

/obj/item/trapdoor_remote/preloaded/Initialize(mapload)
	. = ..()
	internals = new(src)

/// trapdoor parts kit, allows trapdoors to be made by players
/obj/item/trapdoor_kit
	name = "trapdoor parts kit"
	desc = "Набор со всеми деталями для постройки шлюза. Можно использовать только в открытом космосе."
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "kitsuitcase"
	var/in_use = FALSE

/obj/item/trapdoor_kit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/trapdoor_kit/handle_openspace_click(turf/target, mob/user, list/modifiers)
	interact_with_atom(target, user, modifiers)

/obj/item/trapdoor_kit/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/target_turf = get_turf(interacting_with)
	if(!isopenspaceturf(target_turf))
		return NONE
	in_use = TRUE
	balloon_alert(user, "устанавливает шлюз")
	if(!do_after(user, 5 SECONDS, interacting_with))
		in_use = FALSE
		return ITEM_INTERACT_BLOCKING
	in_use = FALSE
	if(!isopenspaceturf(target_turf)) // second check to make sure nothing changed during constructions
		return ITEM_INTERACT_BLOCKING
	var/turf/new_turf = target_turf.place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	new_turf.AddComponent(/datum/component/trapdoor, starts_open = FALSE, conspicuous = TRUE)
	balloon_alert(user, "шлюз установлен")
	qdel(src)
	return ITEM_INTERACT_SUCCESS
