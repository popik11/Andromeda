/obj/machinery/vending/cytopro
	name = "ЦитоПро"
	desc = "Для всех ваших цитологических нужд!"
	product_slogans = "Клонирование? Не смешите.;Не будьте некультурными, выращивайте клетки!;Кому нужны фермы, когда есть чаны?"
	product_ads = "Вырастите своих собственных маленьких существ!;Биология у вас под рукой!"
	icon_state = "cytopro"
	icon_deny = "cytopro-deny"
	panel_type = "panel2"
	light_mask = "cytopro-light-mask"
	products = list(
		/obj/item/storage/bag/xeno = 5,
		/obj/item/reagent_containers/condiment/protein = 10,
		/obj/item/storage/box/swab = 3,
		/obj/item/storage/box/petridish = 3,
		/obj/item/storage/box/monkeycubes = 3,
		/obj/item/biopsy_tool = 3,
		/obj/item/clothing/under/rank/rnd/scientist = 5,
		/obj/item/clothing/suit/toggle/labcoat/science = 5,
		/obj/item/clothing/suit/bio_suit/scientist = 3,
		/obj/item/clothing/head/bio_hood/scientist = 3,
		/obj/item/reagent_containers/dropper = 5,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/petri_dish/random = 6,
	)
	contraband = list(
		/obj/item/knife/kitchen = 3,
	)
	refill_canister = /obj/item/vending_refill/cytopro
	default_price = PAYCHECK_CREW * 1
	extra_price = PAYCHECK_COMMAND * 0.5
	payment_department = ACCOUNT_SCI
	allow_custom = TRUE

/obj/item/vending_refill/cytopro
	machine_name = "ЦитоПро"
	icon_state = "refill_plant"
