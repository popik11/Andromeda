/obj/machinery/vending/donksofttoyvendor
	name = "ТоргоМат Той"
	desc = "Одобренный для возрастов 8+ автомат, выдающий игрушки."
	icon_state = "nt-donk"
	panel_type = "panel18"
	product_slogans = "Получи крутые игрушки сегодня!;Затриггерь валидного хантера сегодня!;Качественные игрушечные оружием по низким ценам!;Дайте их ГП для полного доступа!;Дайте их ГСБ для пермабрига!"
	product_ads = "Почувствуй себя робастным с нашими игрушками!;Вырази своего внутреннего ребёнка сегодня!;Игрушечные оружие не убивают людей, но валидные хантеры — да!;Кому нужна ответственность, когда есть игрушечные weapon?;Сделай своё следующее убийство ВЕСЁЛЫМ!"
	vend_reply = "Возвращайтесь за новыми!"
	light_mask = "donksoft-light-mask"
	circuit = /obj/item/circuitboard/machine/vending/donksofttoyvendor
	products = list(
		/obj/item/card/emagfake = 4,
		/obj/item/hot_potato/harmless/toy = 4,
		/obj/item/toy/sword = 12,
		/obj/item/toy/foamblade = 12,
		/obj/item/gun/ballistic/automatic/pistol/toy = 8,
		/obj/item/gun/ballistic/automatic/toy = 8,
		/obj/item/gun/ballistic/shotgun/toy = 8,
		/obj/item/ammo_box/foambox/mini = 20,
	)
	contraband = list(
		/obj/item/toy/balloon/syndicate = 1,
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 8,
		/obj/item/toy/katana = 12,
		/obj/item/ammo_box/foambox/riot/mini = 20,
	)
	premium = list(
		/obj/item/dualsaber/toy = 4,
		/obj/item/storage/box/fakesyndiesuit = 4,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted = 4,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted = 4,
	)
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES

/obj/item/vending_refill/donksoft
	machine_name = "ТоргоМат Той"
	icon_state = "refill_donksoft"
