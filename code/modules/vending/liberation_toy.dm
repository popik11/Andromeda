/obj/machinery/vending/toyliberationstation
	name = "СиндиТойМат"
	desc = "Одобренный для возрастов 8+ автомат, выдающий игрушки. Если найти нужные провода, можно разблокировать взрослый режим!"
	icon_state = "syndi"
	panel_type = "panel18"
	product_slogans = "Получите крутые игрушки сегодня!;Затриггерь валидного хантера сегодня!;Качественные игрушечные пушки по низким ценам!;Дайте их ГП для полного доступа!;Дайте их ГСБ для пермабрига!"
	product_ads = "Почувствуй себя робастным с нашими игрушками!;Вырази своего внутреннего ребёнка сегодня!;Игрушечные пушки не убивают людей, но валидные хантеры — да!;Кому нужна ответственность, когда есть игрушечные weapon?;Сделай своё следующее убийство ВЕСЁЛЫМ!"
	vend_reply = "Возвращайтесь за новыми!"
	circuit = /obj/item/circuitboard/machine/vending/syndicatedonksofttoyvendor
	products = list(
		/obj/item/card/emagfake = 4,
		/obj/item/hot_potato/harmless/toy = 4,
		/obj/item/toy/sword = 12,
		/obj/item/dualsaber/toy = 12,
		/obj/item/toy/foamblade = 12,
		/obj/item/gun/ballistic/automatic/pistol/toy/riot = 8,
		/obj/item/gun/ballistic/automatic/toy/riot = 8,
		/obj/item/gun/ballistic/shotgun/toy/riot = 8,
		/obj/item/ammo_box/foambox = 20,
	)
	contraband = list(
		/obj/item/toy/balloon/syndicate = 1,
		/obj/item/gun/ballistic/shotgun/toy/crossbow/riot = 8,
		/obj/item/toy/katana = 12,
	)
	premium = list(
		/obj/item/toy/cards/deck/syndicate = 12,
		/obj/item/storage/box/fakesyndiesuit = 4,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot = 4,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/riot = 4,
		/obj/item/ammo_box/foambox/riot = 20,
	)
	armor_type = /datum/armor/vending_toyliberationstation
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES
	light_mask = "donksoft-light-mask"

/datum/armor/vending_toyliberationstation
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50
