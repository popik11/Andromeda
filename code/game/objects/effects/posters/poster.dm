// This is synced up to the poster placing animation.
#define PLACE_SPEED 37

// The poster item

/**
 * The rolled up item form of a poster
 *
 * In order to create one of these for a specific poster, you must pass the structure form of the poster as an argument to /new().
 * This structure then gets moved into the contents of the item where it will stay until the poster is placed by a player.
 * The structure form is [obj/structure/sign/poster] and that's where all the specific posters are defined.
 * If you just want a random poster, see [/obj/item/poster/random_official] or [/obj/item/poster/random_contraband]
 */
/obj/item/poster
	name = "плохо закодированный постер"
	desc = "Вам, наверное, не стоит держать это в руках."
	icon = 'icons/obj/poster.dmi'
	force = 0
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	var/poster_type
	var/obj/structure/sign/poster/poster_structure

/obj/item/poster/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете установить ловушку на постер, использовав осколок стекла на нём перед размещением.")

/obj/item/poster/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()

	var/static/list/hovering_item_typechecks = list(
		/obj/item/shard = list(
			SCREENTIP_CONTEXT_LMB = "Установить ловушку на постер",
		),
	)
	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)

	if(new_poster_structure && (new_poster_structure.loc != src))
		new_poster_structure.forceMove(src) //The poster structure *must* be in the item's contents for the exited() proc to properly clean up when placing the poster
	poster_structure = new_poster_structure
	if(!new_poster_structure && poster_type)
		poster_structure = new poster_type(src)

	// posters store what name and description they would like their
	// rolled up form to take.
	if(poster_structure)
		if(QDELETED(poster_structure))
			stack_trace("Постер был инициализирован с удалённой poster_structure, что-то пошло не так")
			return INITIALIZE_HINT_QDEL
		name = poster_structure.poster_item_name
		desc = poster_structure.poster_item_desc
		icon_state = poster_structure.poster_item_icon_state

		name = "[name] - [poster_structure.original_name]"

/obj/item/poster/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(I, /obj/item/shard))
		return ..()

	if (poster_structure.trap?.resolve())
		balloon_alert(user, "уже с ловушкой!")
		return

	if(!user.transferItemToLoc(I, poster_structure))
		return

	poster_structure.trap = WEAKREF(I)
	to_chat(user, span_notice("Вы прячете [I.declent_ru(NOMINATIVE)] внутри свёрнутого постера."))

/obj/item/poster/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == poster_structure)
		poster_structure = null
		if(!QDELING(src))
			qdel(src) //we're now a poster, huzzah!

/obj/item/poster/Destroy(force)
	QDEL_NULL(poster_structure)
	return ..()

// The poster sign/structure

/**
 * The structure form of a poster.
 *
 * These are what get placed on maps as posters. They are also what gets created when a player places a poster on a wall.
 * For the item form that can be spawned for players, see [/obj/item/poster]
 */
/obj/structure/sign/poster
	name = "постер"
	var/original_name
	desc = "Большой кусок космоустойчивой печатной бумаги."
	icon = 'icons/obj/poster.dmi'
	anchored = TRUE
	buildable_sign = FALSE //Cannot be unwrenched from a wall.
	var/ruined = FALSE
	var/random_basetype
	var/never_random = FALSE // used for the 'random' subclasses.
	///Exclude posters of these types from being added to the random pool
	var/list/blacklisted_types = list()
	///Whether the poster should be printable from library management computer. Mostly exists to keep directionals from being printed.
	var/printable = FALSE

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "Этого гипотетического предмета постера не должно существовать, давайте будем честны."
	var/poster_item_icon_state = "rolled_poster"
	var/poster_item_type = /obj/item/poster
	///A sharp shard of material can be hidden inside of a poster, attempts to embed when it is torn down.
	var/datum/weakref/trap

/obj/structure/sign/poster/Initialize(mapload)
	. = ..()
	if(random_basetype)
		randomise(random_basetype)
	if(!ruined)
		original_name = name // can't use initial because of random posters
		name = "постер - [name]"
		desc = "Большой кусок космоустойчивой печатной бумаги. [desc]"

	AddElement(/datum/element/beauty, 300)

/// Adds contextual screentips
/obj/structure/sign/poster/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if (!held_item)
		if (ruined)
			return .
		context[SCREENTIP_CONTEXT_LMB] = "Сорвать постер"
		return CONTEXTUAL_SCREENTIP_SET

	if (held_item.tool_behaviour == TOOL_WIRECUTTER)
		if (ruined)
			context[SCREENTIP_CONTEXT_LMB] = "Убрать остатки"
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Снять постер"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/structure/sign/poster/proc/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	if(length(blacklisted_types))
		for(var/iterated_type in blacklisted_types)
			poster_types -= typesof(iterated_type)
	var/list/approved_types = list()
	for(var/obj/structure/sign/poster/type_of_poster as anything in poster_types)
		if(initial(type_of_poster.icon_state) && !initial(type_of_poster.never_random))
			approved_types |= type_of_poster

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon_state = initial(selected.icon_state)
	icon = initial(selected.icon)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)
	if(length(GLOB.holidays) && prob(30)) // its the holidays! lets get festive
		apply_holiday()
	update_appearance()

/// allows for posters to become festive posters during holidays
/obj/structure/sign/poster/proc/apply_holiday()
	if(!length(GLOB.holidays))
		return
	var/active_holiday = pick(GLOB.holidays)
	var/datum/holiday/holi_data = GLOB.holidays[active_holiday]

	if(holi_data.poster_name == "generic celebration poster")
		return
	name = holi_data.poster_name
	desc = holi_data.poster_desc
	icon_state = holi_data.poster_icon

/obj/structure/sign/poster/attackby(obj/item/tool, mob/user, list/modifiers, list/attack_modifiers)
	if(tool.tool_behaviour == TOOL_WIRECUTTER)
		tool.play_tool_sound(src, 100)
		if(ruined)
			to_chat(user, span_notice("Вы убираете остатки постера."))
			qdel(src)
		else
			to_chat(user, span_notice("Вы аккуратно снимаете постер со стены."))
			roll_and_drop(Adjacent(user) ? get_turf(user) : loc, user)

/obj/structure/sign/poster/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !check_tearability())
		return
	tear_poster(user)

/// Check to see if this poster is tearable and gives the user feedback if it is not.
/obj/structure/sign/poster/proc/check_tearability(mob/user)
	if(ruined)
		balloon_alert(user, "уже испорчен!")
		return FALSE
	return TRUE

// HO-HO-HOHOHO HU HU-HU HU-HU
/obj/structure/sign/poster/proc/spring_trap(mob/user)
	var/obj/item/shard/payload = trap?.resolve()
	if (!payload)
		return

	to_chat(user, span_warning("За этим что-то острое! Какого чёрта?"))
	if(!can_embed_trap(user) || !payload.force_embed(user, user.get_active_hand()))
		visible_message(span_notice("Из-за постера падает [payload.declent_ru(NOMINATIVE)]!") )
		payload.forceMove(user.drop_location())

/obj/structure/sign/poster/proc/can_embed_trap(mob/living/carbon/human/user)
	if (!istype(user) || HAS_TRAIT(user, TRAIT_PIERCEIMMUNE))
		return FALSE
	return !user.gloves || !(user.gloves.body_parts_covered & HANDS) || HAS_TRAIT(user, TRAIT_FINGERPRINT_PASSTHROUGH) || HAS_TRAIT(user.gloves, TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/structure/sign/poster/proc/roll_and_drop(atom/location, mob/user)
	pixel_x = 0
	pixel_y = 0
	var/obj/item/poster/rolled_poster = return_to_poster_item(location, src)
	if(!user?.put_in_hands(rolled_poster))
		forceMove(rolled_poster)
	return rolled_poster


/// Re-creates the poster item from the poster structure
/obj/structure/sign/poster/proc/return_to_poster_item(atom/location)
	return new poster_item_type(location, src)

//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/closed/proc/place_poster(obj/item/poster/rolled_poster, mob/user)
	if(!rolled_poster.poster_structure)
		to_chat(user, span_warning("[rolled_poster] не имеет постера... внутри? Сообщите кодерам!"))
		return

	// Deny placing posters on currently-diagonal walls, although the wall may change in the future.
	if (smoothing_flags & SMOOTH_DIAGONAL_CORNERS)
		for (var/overlay in overlays)
			var/image/new_image = overlay
			if(copytext(new_image.icon_state, 1, 3) == "d-") //3 == length("d-") + 1
				return

	var/stuff_on_wall = 0
	for(var/obj/contained_object in contents) //Посмотрим, есть ли уже постер на стене или слишком много объектов
		if(istype(contained_object, /obj/structure/sign/poster))
			balloon_alert(user, "нет места!")
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			balloon_alert(user, "нет места!")
			return

	balloon_alert(user, "вешаем постер...")
	var/obj/structure/sign/poster/placed_poster = rolled_poster.poster_structure

	flick("poster_being_set", placed_poster)
	placed_poster.forceMove(src) //deletion of the poster is handled in poster/Exited(), so don't have to worry about P anymore.
	playsound(src, 'sound/items/poster/poster_being_created.ogg', 100, TRUE)

	var/turf/user_drop_location = get_turf(user) //cache this so it just falls to the ground if they move. also no tk memes allowed.
	if(!do_after(user, PLACE_SPEED, placed_poster, extra_checks = CALLBACK(placed_poster, TYPE_PROC_REF(/obj/structure/sign/poster, snowflake_closed_turf_check), src)))
		placed_poster.roll_and_drop(user_drop_location, user)
		return

	placed_poster.on_placed_poster(user)
	return TRUE

/obj/structure/sign/poster/proc/snowflake_closed_turf_check(atom/hopefully_still_a_closed_turf) //since turfs never get deleted but instead change type, make sure we're still being placed on a wall.
	return isclosedturf(hopefully_still_a_closed_turf)

/obj/structure/sign/poster/proc/on_placed_poster(mob/user)
	to_chat(user, span_notice("Вы размещаете постер!"))

/obj/structure/sign/poster/proc/tear_poster(mob/user)
	visible_message(span_notice("[user] срывает [capitalize(declent_ru(NOMINATIVE))] одним решительным движением!") )
	playsound(src.loc, 'sound/items/poster/poster_ripped.ogg', 100, TRUE)
	spring_trap(user)

	var/obj/structure/sign/poster/ripped/torn_poster = new(loc)
	torn_poster.pixel_y = pixel_y
	torn_poster.pixel_x = pixel_x
	torn_poster.add_fingerprint(user)
	qdel(src)

// Various possible posters follow

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "разорванный постер"
	desc = "Вы не можете разобрать что-либо из оригинального изображения постера. Он испорчен.. \
	Вы можете <b>откусить</b> остатки. "

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/ripped, 32)

/obj/structure/sign/poster/random
	name = "случайный постер" // could even be ripped
	icon_state = "random_anything"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster
	blacklisted_types = list(
		/obj/structure/sign/poster/traitor,
		/obj/structure/sign/poster/abductor,
	)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/random, 32)

/obj/structure/sign/poster/greenscreen
	name = "хромакей"
	desc = "Используется для создания убедительной иллюзии другого фона."
	icon_state = "greenscreen"
	poster_item_name = "хромакей"
	poster_item_desc = "Используется для создания убедительной иллюзии другого фона."
	never_random = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/greenscreen, 32)

#undef PLACE_SPEED
