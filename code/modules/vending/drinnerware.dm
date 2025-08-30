/obj/machinery/vending/dinnerware
	name = "КухаркаМат"
	desc = "Торговый автомат с кухонным и ресторанным оборудованием."
	product_ads = "Мм, продукты питания!;Еда и аксессуары для еды.;Возьмите свои тарелки!;Вам нравятся вилки?;Мне нравятся вилки.;Ура, столовые приборы.;Вам не особо нужно это..."
	icon_state = "dinnerware"
	panel_type = "panel4"
	product_categories = list(
		list(
			"name" = "Кухонные принадлежности",
			"icon" = FA_ICON_KITCHEN_SET,
			"products" = list(
				/obj/item/storage/bag/tray = 8,
				/obj/item/reagent_containers/cup/soup_pot = 3,
				/obj/item/kitchen/spoon/soup_ladle = 3,
				/obj/item/clothing/suit/apron/chef = 2,
				/obj/item/kitchen/rollingpin = 2,
				/obj/item/kitchen/tongs = 2,
				/obj/item/knife/kitchen = 2,
			),
		),
		list(
			"name" = "Столовые приборы",
			"icon" = FA_ICON_UTENSILS,
			"products" = list(
				/obj/item/kitchen/fork = 6,
				/obj/item/kitchen/spoon = 10,
			),
		),
		list(
			"name" = "Посуда",
			"icon" = FA_ICON_PLATE_WHEAT,
			"products" = list(
				/obj/item/plate/small = 5,
				/obj/item/plate = 10,
				/obj/item/plate/large = 5,
				/obj/item/reagent_containers/cup/bowl = 30,
				/obj/item/reagent_containers/cup/glass/drinkingglass = 8,
			),
		),
		list(
			"name" = "Приправы",
			"icon" = FA_ICON_BOTTLE_DROPLET,
			"products" = list(
				/obj/item/reagent_containers/condiment/pack/ketchup = 5,
				/obj/item/reagent_containers/condiment/pack/hotsauce = 5,
				/obj/item/reagent_containers/condiment/pack/astrotame = 5,
				/obj/item/reagent_containers/condiment/saltshaker = 5,
				/obj/item/reagent_containers/condiment/peppermill = 5,
			),
		),
		list(
			"name" = "Рецепты",
			"icon" = FA_ICON_BOOK_OPEN_READER,
			"products" = list(
				/obj/item/book/granter/crafting_recipe/cooking_sweets_101 = 2,
			),
		),
	)

	premium = list(
		/obj/item/skillchip/chefs_kiss = 2
	)
	contraband = list(
		/obj/item/kitchen/rollingpin/illegal = 2,
		/obj/item/knife/butcher = 2,
	)
	refill_canister = /obj/item/vending_refill/dinnerware
	default_price = PAYCHECK_CREW * 0.8
	extra_price = PAYCHECK_CREW * 2.4
	payment_department = ACCOUNT_SRV
	light_mask = "dinnerware-light-mask"
	allow_custom = TRUE

/obj/item/vending_refill/dinnerware
	machine_name = "КухаркаМат"
	icon_state = "refill_smoke"
