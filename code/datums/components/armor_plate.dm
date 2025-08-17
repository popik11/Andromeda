/datum/component/armor_plate
	/// Текущее количество улучшений, применённых к родителю через этот компонент.
	var/amount = 0
	/// Максимальное количество улучшений, которые можно применить. Когда var/amount достигает этого значения, больше улучшений применить нельзя.
	var/maxamount = 3
	/// Путь для предмета улучшения. Каждый расходуется для улучшения показателей брони родителя.
	var/upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide
	/// Путь датума брони для значений улучшения. Это значение добавляется за каждое применённое улучшение.
	var/datum/armor/armor_mod = /datum/armor/armor_plate
	/// Название предмета улучшения.
	var/upgrade_name
	/// Добавляет префикс к предмету, показывая что он улучшен.
	var/upgrade_prefix = "улучшенный"
	/// Отслеживает, было ли применено улучшение.
	var/have_upgraded = FALSE
	/// Абстрактное броневое оборудование, используемое для занятия слота и отображения в интерфейсе меха.
	var/obj/item/mecha_parts/mecha_equipment/armor/armor_plate/plate_component = null

/datum/armor/armor_plate
	melee = 10

/datum/component/armor_plate/Initialize(maxamount, obj/item/upgrade_item, datum/armor/armor_mod, upgrade_prefix = "улучшенный")
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(applyplate))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(dropplates))
	if(istype(parent, /obj/vehicle/sealed/mecha/ripley))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_mech_overlays))

	if(maxamount)
		src.maxamount = maxamount
	if(upgrade_item)
		src.upgrade_item = upgrade_item
	if(armor_mod)
		src.armor_mod = armor_mod
	if(upgrade_prefix)
		src.upgrade_prefix = upgrade_prefix
	var/obj/item/typecast = src.upgrade_item
	src.upgrade_name = initial(typecast.name)

/datum/component/armor_plate/Destroy(force)
	QDEL_NULL(plate_component)
	return ..()

/datum/component/armor_plate/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	// Здесь также можно было бы использовать typecast для upgrade_item
	if(ismecha(parent))
		if(amount)
			if(amount < maxamount)
				examine_list += span_notice("Его броня усилена [amount] [upgrade_name].")
			else
				examine_list += span_notice("Он покрыт грозным панцирем, полностью состоящим из [upgrade_name] - пилот явно опытный охотник на монстров.")
		else
			examine_list += span_notice("На нём есть крепления для дополнительной защиты из шкур монстров.")
	else
		if(amount)
			examine_list += span_notice("Усилено [amount]/[maxamount] [upgrade_name].")
		else
			examine_list += span_notice("Может быть усилено до [maxamount] [upgrade_name].")

/datum/component/armor_plate/proc/applyplate(datum/source, obj/item/our_upgrade_item, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(our_upgrade_item, upgrade_item))
		return

	if(amount >= maxamount)
		to_chat(user, span_warning("Вы не можете улучшить [parent] дальше!"))
		return

	if(ismecha(parent) && !plate_component)
		var/obj/vehicle/sealed/mecha/as_mecha = parent
		if (LAZYLEN(as_mecha.equip_by_category[MECHA_ARMOR]) >= as_mecha.max_equip_by_category[MECHA_ARMOR])
			to_chat(user, span_warning("[as_mecha] не имеет свободных слотов для брони!"))
			return

	if(isstack(our_upgrade_item))
		our_upgrade_item.use(1)
	else
		if(length(our_upgrade_item.contents))
			to_chat(user, span_warning("[our_upgrade_item] нельзя использовать для бронирования, пока внутри что-то есть!"))
			return
		qdel(our_upgrade_item)

	var/obj/target_for_upgrading = parent
	amount++
	target_for_upgrading.set_armor(target_for_upgrading.get_armor().add_other_armor(armor_mod))
	SEND_SIGNAL(target_for_upgrading, COMSIG_ARMOR_PLATED, amount, maxamount)

	if(!ismecha(target_for_upgrading))
		if(upgrade_prefix && !have_upgraded)
			target_for_upgrading.name = "[upgrade_prefix] [target_for_upgrading.name]"
			have_upgraded = TRUE
		to_chat(user, span_info("Вы укрепляете [target_for_upgrading], повышая его устойчивость к атакам."))
		return

	var/obj/vehicle/sealed/mecha/mecha_for_upgrading = target_for_upgrading
	mecha_for_upgrading.update_appearance()
	to_chat(user, span_info("Вы укрепляете [mecha_for_upgrading], повышая его устойчивость к атакам."))
	if (plate_component)
		return
	plate_component = new(mecha_for_upgrading)
	plate_component.name = our_upgrade_item.name
	plate_component.desc = our_upgrade_item.desc
	plate_component.icon = our_upgrade_item.icon
	plate_component.icon_state = our_upgrade_item.icon_state
	plate_component.attach(mecha_for_upgrading)

/datum/component/armor_plate/proc/dropplates(datum/source, force)
	SIGNAL_HANDLER

	if(ismecha(parent)) //items didn't drop the plates before and it causes erroneous behavior for the time being with collapsible helmets
		for(var/i in 1 to amount)
			new upgrade_item(get_turf(parent))

/datum/component/armor_plate/proc/apply_mech_overlays(obj/vehicle/sealed/mecha/mech, list/overlays)
	SIGNAL_HANDLER

	if(amount)
		var/overlay_string = "ripley-g"
		if(amount >= 3)
			overlay_string += "-full"
		if(!LAZYLEN(mech.occupants))
			overlay_string += "-open"
		overlays += overlay_string

/// Abstract armor module used just to occupy a slot and show up in the UI
/obj/item/mecha_parts/mecha_equipment/armor/armor_plate
	name = "abstract armor"
	desc = "Сообщите кодерам, если вы видите это!"
	detachable = FALSE
