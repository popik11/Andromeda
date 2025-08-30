#define PULSE_DISTANCE_RANGE 2

/obj/machinery/vending/runic_vendor
	name = "Рунический ТоргоМат"
	desc = "Этот торговый автомат был создан для войны! Идеальная приманка для жажды консьюмеризма экипажа Нанотрейзен."
	icon_state = "RunicVendor"
	panel_type = "panel10"
	product_slogans = "Получи бесплатную магию!;50% скидка на Мьёльниры сегодня!;Купи свист варп и получи второй бесплатно!"
	vend_reply = "Пожалуйста, оставайтесь рядом с торговым автоматом для получения специального пакета!"
	resistance_flags = FIRE_PROOF
	light_mask = "RunicVendor-light-mask"
	obj_flags = parent_type::obj_flags | NO_DEBRIS_AFTER_DECONSTRUCTION
	/// Как долго вендор стоит перед распадом.
	var/time_to_decay = 30 SECONDS
	/// Область вокруг вендора, которая будет отталкивать ближайших мобов.
	var/pulse_distance = PULSE_DISTANCE_RANGE


/obj/machinery/vending/runic_vendor/Initialize(mapload)
	if(mapload)
		log_mapping("[type] не предназначен для маппинга, он распадается через установленное время")
		stack_trace("Кто-то замапил мемный торговый автомат, который создаёт скипетр волшебника, пожалуйста, удалите его")

	addtimer(CALLBACK(src, PROC_REF(decay)), time_to_decay, TIMER_STOPPABLE)
	INVOKE_ASYNC(src, PROC_REF(runic_pulse))

	switch(pick(1,3))
		if(1)
			products = list(
			/obj/item/clothing/head/wizard = 1,
			/obj/item/clothing/suit/wizrobe = 1,
			/obj/item/clothing/shoes/sandal/magic = 1,
			/obj/item/toy/foam_runic_scepter = 1,
			)
		if(2)
			products = list(
			/obj/item/clothing/head/wizard/red = 1,
			/obj/item/clothing/suit/wizrobe/red = 1,
			/obj/item/clothing/shoes/sandal/magic = 1,
			/obj/item/toy/foam_runic_scepter = 1,
			)
		if(3)
			products = list(
			/obj/item/clothing/head/wizard/yellow = 1,
			/obj/item/clothing/suit/wizrobe/yellow = 1,
			/obj/item/clothing/shoes/sandal/magic = 1,
			/obj/item/toy/foam_runic_scepter = 1,
			)

	return ..()

/obj/machinery/vending/runic_vendor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(held_item)
		if(istype(held_item, /obj/item/runic_vendor_scepter))
			context[SCREENTIP_CONTEXT_LMB] = "Детонировать"
			context[SCREENTIP_CONTEXT_RMB] = "Силовой толчок"

		return CONTEXTUAL_SCREENTIP_SET

	return .

/obj/machinery/vending/runic_vendor/handle_deconstruct(disassembled)
	SHOULD_NOT_OVERRIDE(TRUE)

	visible_message(span_warning("[src] мерцает и исчезает!"))
	playsound(src,'sound/items/weapons/resonator_blast.ogg',25,TRUE)
	return ..()

/obj/machinery/vending/runic_vendor/proc/runic_explosion()
	explosion(src, light_impact_range = 2)
	deconstruct(FALSE)

/obj/machinery/vending/runic_vendor/proc/runic_pulse()
	var/pulse_locs = spiral_range_turfs(pulse_distance, get_turf(src))
	var/list/hit_things = list()
	for(var/turf/pulsing_turf in pulse_locs)
		for(var/mob/living/mob_to_be_pulsed_back in pulsing_turf.contents)
			hit_things += mob_to_be_pulsed_back
			var/atom/target = get_edge_target_turf(mob_to_be_pulsed_back, get_dir(src, get_step_away(mob_to_be_pulsed_back, src)))
			to_chat(mob_to_be_pulsed_back, span_userdanger("Поле отталкивает вас с огромной силой!"))
			playsound(src, 'sound/effects/gravhit.ogg', 50, TRUE)
			mob_to_be_pulsed_back.throw_at(target, 4, 4)

/obj/machinery/vending/runic_vendor/screwdriver_act(mob/living/user, obj/item/I)
	runic_explosion()

/obj/machinery/vending/runic_vendor/proc/decay()
	deconstruct(FALSE)

#undef PULSE_DISTANCE_RANGE
