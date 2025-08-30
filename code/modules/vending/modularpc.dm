/obj/machinery/vending/modularpc
	name = "Делюкс Силикат Селекшнс"
	desc = "Все детали, необходимые для сборки собственного кастомного ПК."
	icon_state = "modularpc"
	icon_deny = "modularpc-deny"
	panel_type = "panel21"
	light_mask = "modular-light-mask"
	product_ads = "Получи свой геймерский набор!;Лучшие видеокарты для всех ваших космо-крипто нужд!;Самое робмастное охлаждение!;Лучший RGB в космосе!"
	vend_reply = "Игра началась!"
	products = list(
		/obj/item/computer_disk = 8,
		/obj/item/modular_computer/laptop = 4,
		/obj/item/modular_computer/pda = 4,
	)
	premium = list(
		/obj/item/pai_card = 2,
	)
	refill_canister = /obj/item/vending_refill/modularpc
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SCI
	allow_custom = TRUE

/obj/item/vending_refill/modularpc
	machine_name = "Делюкс Силикат Селекшнс"
	icon_state = "refill_engi"
