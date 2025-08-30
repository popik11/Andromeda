/obj/machinery/vending/subtype_vendor
	name = "Субтайп ТоргоМат"
	desc = "Торговый автомат, который продаёт все подтипы определённого типа."
	color = COLOR_ADMIN_PINK
	verb_say = "кодит"
	verb_ask = "запрашивает"
	verb_exclaim = "компилирует"
	armor_type = /datum/armor/machinery_vending
	circuit = null
	product_slogans = "Spawn \" слишком раздражает? Слишком лень открывать игровую панель? Этот для вас!;Субтайп торгомат для всех ваших дебаг проблем!"
	default_price = 0
	all_products_free = TRUE
	/// По умолчанию спаунит кодера
	var/type_to_vend = /obj/item/food/grown/citrus

/obj/machinery/vending/subtype_vendor/Initialize(mapload, type_to_vend)
	if(type_to_vend)
		src.type_to_vend = type_to_vend
	return ..()

///Добавляет подтип в список продуктов
/obj/machinery/vending/subtype_vendor/RefreshParts()
	products.Cut()
	for(var/type in typesof(type_to_vend))
		LAZYADDASSOC(products, type, 50)

	//нет канистры для пополнения, поэтому мы заполняем записи их максимальными количествами напрямую
	build_inventories(start_empty = FALSE)

/obj/machinery/vending/subtype_vendor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH|FORBID_TELEKINESIS_REACH))
		return

	if(!user.client?.holder?.check_for_rights(R_SERVER|R_DEBUG))
		speak("Эй! Ты не можешь использовать это! Убирайся отсюда!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/type_to_vend_now = tgui_input_text(user, "Какой тип установить?", "Установить тип для продажи", "/obj/item/toy/plush")
	type_to_vend_now = text2path(type_to_vend_now)
	if(!ispath(type_to_vend_now))
		speak("Это не настоящий путь, придурок! Попробуй ещё раз!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	type_to_vend = type_to_vend_now
	RefreshParts()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
