/obj/machinery/vending/donksnack
	name = "ДонкКоМат"
	desc = "Снековый автомат от Донк Ко."
	product_slogans = "Просто разогрей и ешь!;Оригинальный дом Донк Покета!"
	product_ads = "Оригинальный!;Ты хочешь замутить крутой Донк!;Лучший!;Еда выбора опытного предателя!;Теперь на 12% больше омнизина!;Ешь ДОНК или СДОХНИ!;Самый популярный в галактике микроволновый снек!*;Попробуйте наши НОВЫЕ Готовые-Донк Блюда!"
	icon_state = "snackdonk"
	panel_type = "panel18"
	light_mask = "donksoft-light-mask"
	circuit = /obj/item/circuitboard/machine/vending/donksnackvendor
	products = list(
		/obj/item/food/donkpocket = 6,
		/obj/item/food/donkpocket/berry = 6,
		/obj/item/food/donkpocket/honk = 6,
		/obj/item/food/donkpocket/pizza = 6,
		/obj/item/food/donkpocket/spicy = 6,
		/obj/item/food/donkpocket/teriyaki = 6,
		/obj/item/food/tatortot = 12,
	)
	contraband = list(
		/obj/item/food/waffles = 2,
		/obj/item/food/donkpocket/dank = 2,
		/obj/item/food/donkpocket/gondola = 1,
	)
	premium = list(
		/obj/item/storage/box/donkpockets = 3,
		/obj/item/storage/box/donkpockets/donkpocketberry = 3,
		/obj/item/storage/box/donkpockets/donkpockethonk = 3,
		/obj/item/storage/box/donkpockets/donkpocketpizza = 3,
		/obj/item/storage/box/donkpockets/donkpocketspicy = 3,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki = 3,
		/obj/item/storage/belt/military/snack = 2,
		/obj/item/mod/module/microwave_beam = 1,
	)
	initial_language_holder = /datum/language_holder/syndicate
	refill_canister = /obj/item/vending_refill/donksnackvendor
	default_price = PAYCHECK_CREW * 1.4
	extra_price = PAYCHECK_CREW * 5
	payment_department = NO_FREEBIES

/obj/item/vending_refill/donksnackvendor
	machine_name = "ДонкКоСнекоМат"
	icon_state = "refill_donksnack"
