///Специальный торговый автомат с хот-догами, найденный в кафетерии миссии музея или во время праздника хот-догов.
/obj/machinery/vending/hotdog
	name = "ХотдоггоМат"
	desc = "Устаревший автомат по продаже хот-догов, цены застряли на уровне 20-летней давности."
	icon_state = "hotdog-vendor"
	icon_deny = "hotdog-vendor-deny"
	panel_type = "panel17"
	product_slogans = "Мяснее чем когда-либо!;Теперь на 20% больше глутамата!;ХОТДОГИ!;Теперь дружественно к Тиризанам!"
	product_ads = "Ваш лучший и единственный автоматический диспенсер хот-догов!;Обслуживаем вас лучшими булочками с 2469 года!;Доступно в 12 различных вкусах!"
	vend_reply = "Приятного аппетита!"
	light_mask = "hotdog-vendor-light-mask"
	default_price = PAYCHECK_LOWER
	product_categories = list(
		list(
			"name" = "Хот-доги",
			"icon" = "hotdog",
			"products" = list(
				/obj/item/food/hotdog = 8,
				/obj/item/food/pigblanket = 4,
				/obj/item/food/danish_hotdog = 4,
				/obj/item/food/little_hawaii_hotdog = 4,
				/obj/item/food/butterdog = 4,
				/obj/item/food/plasma_dog_supreme = 2,
			),
		),
		list(
			name = "Сосиски",
			"icon" = FA_ICON_BACON,
			"products" = list(
				/obj/item/food/sausage = 8,
				/obj/item/food/tiziran_sausage = 4,
				/obj/item/food/fried_blood_sausage = 4,
			),
		),
		list(
			"name" = "Соусы",
			"icon" = FA_ICON_BOWL_FOOD,
			"products" = list(
				/obj/item/reagent_containers/condiment/pack/ketchup = 4,
				/obj/item/reagent_containers/condiment/pack/hotsauce = 4,
				/obj/item/reagent_containers/condiment/pack/bbqsauce = 4,
				/obj/item/reagent_containers/condiment/pack/soysauce = 4,
				/obj/item/reagent_containers/condiment/pack/mayonnaise = 4,
			),
		),
	)
	refill_canister = /obj/item/vending_refill/hotdog

/obj/item/vending_refill/hotdog
	machine_name = "ХотдоггоМат"
	icon_state = "refill_snack"

///Милая особенность, которая отличает его от других пищевых автоматов. Ведь такое не каждый день встретишь.
/obj/machinery/vending/hotdog/on_dispense(obj/item/vended_item, dispense_returned = FALSE)
	// Применяется только к нововыданным предметам
	if(dispense_returned)
		return
	if(istype(vended_item, /obj/item/food))
		ADD_TRAIT(vended_item, TRAIT_FOOD_CHEF_MADE, VENDING_MACHINE_TRAIT)
