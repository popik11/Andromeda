/// Items grilled through the grill.
/datum/element/grilled_item

/datum/element/grilled_item/Attach(datum/target, grill_time)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/this_food = target

	switch(grill_time) // диапазон 0-20 исключён для предотвращения спама
		if(20 SECONDS to 30 SECONDS)
			this_food.name = "слегка пожаренный [this_food.name]"
			this_food.desc += " Был слегка приготовлен на гриле."

		if(30 SECONDS to 80 SECONDS)
			this_food.name = "пожаренный [this_food.name]"
			this_food.desc += " Был приготовлен на гриле."

		if(80 SECONDS to 100 SECONDS)
			this_food.name = "сильно пожаренный [this_food.name]"
			this_food.desc += " Был тщательно приготовлен на гриле."

		if(100 SECONDS to INFINITY) // гриль-марки достигли максимальной альфа-прозрачности
			this_food.name = "Пережаренный [this_food.name]"
			this_food.desc = "[this_food.name]. Напоминает вам о вашей жене, хотя нет, он выглядит лучше!"

	if(grill_time > 30 SECONDS && isnull(this_food.GetComponent(/datum/component/edible)))
		this_food.AddComponentFrom(SOURCE_EDIBLE_GRILLED, /datum/component/edible, foodtypes = FRIED)

	SEND_SIGNAL(this_food, COMSIG_ITEM_BARBEQUE_GRILLED, grill_time)
	ADD_TRAIT(this_food, TRAIT_FOOD_BBQ_GRILLED, ELEMENT_TRAIT(type))

/datum/element/grilled_item/Detach(atom/source, ...)
	source.name = initial(source.name)
	source.desc = initial(source.desc)
	source.RemoveComponentSource(SOURCE_EDIBLE_GRILLED, /datum/component/edible)
	REMOVE_TRAIT(src, TRAIT_FOOD_BBQ_GRILLED, ELEMENT_TRAIT(type))
	return ..()
