/obj/machinery/vending/coffee
	name = "Горячие Напитки"
	desc = "Торговый автомат, выдающий горячие напитки."
	product_ads = "Выпей чего-нибудь!;Пейте на здоровье!;Это полезно для вас!;Хочешь горячего кофе?;Убью за кофе!;Лучшие зёрна в галактике.;Только самый лучший напиток для вас.;Мммм. Нет ничего лучше кофе.;Я люблю кофе, а ты?;Кофе помогает работать!;Попробуй чай.;Надеемся, вам понравится лучшее!;Попробуйте наш новый шоколад!;Заговоры админов"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	panel_type = "panel9"
	products = list(
		/obj/item/reagent_containers/cup/glass/coffee = 6,
		/obj/item/reagent_containers/cup/glass/mug/tea = 6,
		/obj/item/reagent_containers/cup/glass/mug/coco = 3,
	)
	contraband = list(
		/obj/item/reagent_containers/cup/glass/ice = 12,
	)
	refill_canister = /obj/item/vending_refill/coffee
	default_price = PAYCHECK_LOWER
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SRV
	light_mask = "coffee-light-mask"
	light_color = COLOR_DARK_MODERATE_ORANGE
	allow_custom = TRUE

/obj/item/vending_refill/coffee
	machine_name = "Горячие Напитки"
	icon_state = "refill_joe"
