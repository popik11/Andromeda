/// Обычный СМ с отключенной обработкой.
/obj/machinery/power/supermatter_crystal/hugbox
	disable_damage = TRUE
	disable_gas =  TRUE
	disable_power_change = TRUE
	disable_process = SM_PROCESS_DISABLED

/// Обычный СМ, назначенный главным двигателем.
/obj/machinery/power/supermatter_crystal/engine
	is_main_engine = TRUE

/// Осколок СМ.
/obj/machinery/power/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "Странно прозрачный и переливающийся кристалл, похожий на часть большего сооружения."
	base_icon_state = "sm_shard"
	icon_state = "sm_shard"
	anchored = FALSE
	absorption_ratio = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	moveable = TRUE


/obj/machinery/power/supermatter_crystal/shard/Initialize(mapload)
	. = ..()

	register_context()


/obj/machinery/power/supermatter_crystal/shard/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Открепить" : "Закрепить"
		return CONTEXTUAL_SCREENTIP_SET


/// Осколок СМ с отключенной обработкой.
/obj/machinery/power/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	disable_damage = TRUE
	disable_gas =  TRUE
	disable_power_change = TRUE
	disable_process = SM_PROCESS_DISABLED
	moveable = FALSE
	anchored = TRUE

/// Осколок СМ, назначенный главным двигателем.
/obj/machinery/power/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	is_main_engine = TRUE
	anchored = TRUE
	moveable = FALSE

/// Обычный СМ, но маленький (элемент рецепта меча СМ) (только для визардов) и адамантиновый постамент для него
/obj/machinery/power/supermatter_crystal/small
	name = "strangely small supermatter crystal"
	desc = "Странно прозрачный и переливающийся кристалл на адамантиновом постаменте. Выглядит так, будто должен быть немного больше..."
	base_icon_state = "sm_small"
	icon_state = "sm_small"
	moveable = TRUE
	anchored = FALSE

/obj/machinery/power/supermatter_crystal/small/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Adamantium Signal")
	priority_announce("На борту обнаружен аномальный кристалл. Местоположение отмечено на каждом GPS устройстве.", "Объявление Отдела Аномалий Nanotrasen")

/obj/item/adamantine_pedestal
	name = "adamantine pedestal"
	desc = "Адамантиновый постамент. Похоже, на нём должно что-то стоять — маленькое, но массивное."
	icon = 'icons/obj/machines/engine/supermatter.dmi'
	icon_state = "pedestal"
	w_class = WEIGHT_CLASS_HUGE
	throw_speed = 1
	throw_range = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
