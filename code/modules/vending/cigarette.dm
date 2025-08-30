/obj/machinery/vending/cigarette
	name = "ТабакоМат Делюкс"
	desc = "Если уж зарабатывать рак, то делать это со стилем."
	product_slogans = "Космические сигареты вкусны, как и должны быть.;Лучше ящик инструментов, чем переключение.;Кури!;Не верь отчетам - кури сегодня!"
	product_ads = "Вероятно, не вредно для вас!;Не верь ученым!;Это полезно для вас!;Не бросай, покупай больше!;Кури!;Никотиновый рай.;Лучшие сигареты с 2150 года.;Отмеченные наградами сигареты."
	icon_state = "cigs"
	panel_type = "panel5"
	products = list(
		/obj/item/storage/fancy/cigarettes = 5,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 4,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 3,
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/greyscale = 4,
		/obj/item/storage/fancy/rollingpapers = 5,
	)
	contraband = list(
		/obj/item/vape = 5,
		/obj/item/cigarette/dart = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_greytide = 1,
	)
	premium = list(
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 3,
		/obj/item/storage/box/gum/nicotine = 2,
		/obj/item/lighter = 3,
		/obj/item/storage/fancy/cigarettes/cigars = 1,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 1,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba = 1,
	)

	refill_canister = /obj/item/vending_refill/cigarette
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SRV
	light_mask = "cigs-light-mask"
	allow_custom = TRUE

/obj/machinery/vending/cigarette/syndicate
	products = list(
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_greytide = 1,
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/greyscale = 4,
		/obj/item/storage/fancy/rollingpapers = 5,
	)
	initial_language_holder = /datum/language_holder/syndicate
	allow_custom = FALSE

/obj/machinery/vending/cigarette/beach //Используется в руине lavaland_biodome_beach.dmm
	name = "ТабакоМат Ультра"
	desc = "Теперь с дополнительными премиум продуктами!"
	product_ads = "Вероятно, не вредно для вас!;Дурь проведет тебя через времена без денег лучше, чем деньги через времена без дури!;Это полезно для вас!"
	product_slogans = "Включись, настройся, выпади!;Лучшая жизнь через химию!;Затянись!;Не забывай держать улыбку на губах и песню в сердце!"
	products = list(
		/obj/item/storage/fancy/cigarettes = 5,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_cannabis = 5,
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/greyscale = 4,
		/obj/item/storage/fancy/rollingpapers = 5,
	)
	premium = list(
		/obj/item/storage/fancy/cigarettes/cigpack_mindbreaker = 5,
		/obj/item/vape = 5,
		/obj/item/lighter = 3,
	)
	initial_language_holder = /datum/language_holder/beachbum
	allow_custom = FALSE

/obj/item/vending_refill/cigarette
	machine_name = "ТабакоМат Делюкс"
	icon_state = "refill_smoke"

/obj/machinery/vending/cigarette/pre_throw(obj/item/thrown_item)
	if(istype(thrown_item, /obj/item/lighter))
		var/obj/item/lighter/thrown_lighter = thrown_item
		thrown_lighter.set_lit(TRUE)
