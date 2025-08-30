/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "Старый автомат по продаже сладкой воды."
	icon_state = "sovietsoda"
	panel_type = "panel8"
	light_mask = "soviet-light-mask"
	product_ads = "За Царя и Отечество.;Вы выполнили сегодня свою норму питания?;Очень хорошо!;Мы простые люди, ибо это всё, что мы едим.;Если есть человек - есть проблема. Если нет человека - нет проблемы.;Пей пей комрадес!"
	products = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/soda = 30,
	)
	contraband = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/cola = 20,
	)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/sovietsoda
	default_price = 1
	extra_price = PAYCHECK_CREW //One credit for every state of FREEDOM
	payment_department = NO_FREEBIES
	light_color = COLOR_PALE_ORANGE
	initial_language_holder = /datum/language_holder/spinwarder
	allow_custom = TRUE

/obj/item/vending_refill/sovietsoda
	machine_name = "BODA"
	icon_state = "refill_cola"
