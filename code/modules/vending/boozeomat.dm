/obj/machinery/vending/boozeomat
	name = "БухлоМат"
	desc = "Технологическое чудо, предположительно способное смешать именно тот напиток, который ты захочешь, в момент твоего запроса."
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"
	panel_type = "panel22"

	product_categories = list(
		list(
			"name" = "Алкоголь",
			"icon" = "wine-bottle",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/bottle/curacao = 5,
				/obj/item/reagent_containers/cup/glass/bottle/applejack = 5,
				/obj/item/reagent_containers/cup/glass/bottle/wine_voltaic = 5,
				/obj/item/reagent_containers/cup/glass/bottle/tequila = 5,
				/obj/item/reagent_containers/cup/glass/bottle/rum = 5,
				/obj/item/reagent_containers/cup/glass/bottle/cognac = 5,
				/obj/item/reagent_containers/cup/glass/bottle/wine = 5,
				/obj/item/reagent_containers/cup/glass/bottle/absinthe = 5,
				/obj/item/reagent_containers/cup/glass/bottle/vermouth = 5,
				/obj/item/reagent_containers/cup/glass/bottle/gin = 5,
				/obj/item/reagent_containers/cup/glass/bottle/grenadine = 4,
				/obj/item/reagent_containers/cup/glass/bottle/hcider = 5,
				/obj/item/reagent_containers/cup/glass/bottle/amaretto = 5,
				/obj/item/reagent_containers/cup/glass/bottle/ale = 6,
				/obj/item/reagent_containers/cup/glass/bottle/grappa = 5,
				/obj/item/reagent_containers/cup/glass/bottle/navy_rum = 5,
				/obj/item/reagent_containers/cup/glass/bottle/maltliquor = 6,
				/obj/item/reagent_containers/cup/glass/bottle/kahlua = 5,
				/obj/item/reagent_containers/cup/glass/bottle/sake = 5,
				/obj/item/reagent_containers/cup/glass/bottle/beer = 6,
				/obj/item/reagent_containers/cup/glass/bottle/vodka = 5,
				/obj/item/reagent_containers/cup/glass/bottle/whiskey = 5,
				/obj/item/reagent_containers/cup/glass/bottle/coconut_rum = 5,
				/obj/item/reagent_containers/cup/glass/bottle/yuyake = 5,
				/obj/item/reagent_containers/cup/glass/bottle/shochu = 5,
				/obj/item/reagent_containers/cup/soda_cans/beer = 10,
				/obj/item/reagent_containers/cup/soda_cans/beer/rice = 10,
			),
		),

		list(
			"name" = "Безалкогольное",
			"icon" = "bottle-water",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/ice = 10,
				/obj/item/reagent_containers/cup/glass/bottle/juice/limejuice = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/menthol = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/cream = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice = 4,
				/obj/item/reagent_containers/cup/soda_cans/sodawater = 15,
				/obj/item/reagent_containers/cup/soda_cans/sol_dry = 8,
				/obj/item/reagent_containers/cup/soda_cans/cola = 8,
				/obj/item/reagent_containers/cup/soda_cans/tonic = 8,
				/obj/item/reagent_containers/cup/glass/bottle/hakka_mate = 5,
				/obj/item/reagent_containers/cup/soda_cans/melon_soda = 5,
			),
		),

		list(
			"name" = "Посуда",
			"icon" = "wine-glass",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/drinkingglass = 30,
				/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass = 12,
				/obj/item/reagent_containers/cup/glass/flask = 3,
				/obj/item/reagent_containers/cup/glass/bottle = 15,
				/obj/item/reagent_containers/cup/glass/bottle/small = 15,
			),
		),
	)

	contraband = list(
		/obj/item/reagent_containers/cup/glass/mug/tea = 12,
		/obj/item/reagent_containers/cup/glass/bottle/fernet = 5,
	)
	premium = list(
		/obj/item/reagent_containers/cup/bottle/ethanol = 4,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 5,
		/obj/item/reagent_containers/cup/glass/bottle/trappist = 5,
		/obj/item/reagent_containers/cup/glass/bottle/bitters = 5,
	)

	product_slogans = "Надеюсь, никто не попросит у меня чёртову чашку чая...;Алкоголь — друг человечества. Ты бросишь друга?;Рады обслужить вас!;Неужели на этой станции никто не испытывает жажды?"
	product_ads = "Пейте!;Бухло полезно для вас!;Алкоголь — лучший друг человечества.;Рады обслужить вас!;Не желаете хорошего холодного пива?;Ничто не лечит лучше бухла!;Сделайте глоток!;Выпейте!;Выпейте пивка!;Пиво полезно для вас!;Только лучший алкоголь!;Бухло высшего качества с 2053 года!;Отмеченное наградами вино!;Максимум алкоголя!;Мужчины любят пиво.;Тост за прогресс!; Новый лучший напиток, это Пивокин!"
	refill_canister = /obj/item/vending_refill/boozeomat
	default_price = PAYCHECK_CREW * 0.9
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SRV
	light_mask = "boozeomat-light-mask"
	allow_custom = TRUE

/obj/machinery/vending/boozeomat/syndicate
	age_restrictions = FALSE
	initial_language_holder = /datum/language_holder/syndicate
	allow_custom = FALSE

/obj/item/vending_refill/boozeomat
	machine_name = "БухлоМат"
	icon_state = "refill_booze"
