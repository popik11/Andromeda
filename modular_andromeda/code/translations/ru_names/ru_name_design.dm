/datum/design
	var/original_name

/datum/design/New()
	. = ..()
	original_name = name
	name = update_to_ru() || name

/datum/design/proc/update_to_ru()
	var/new_name = declent_ru_initial(name)
	// Уникальное имя дизайна
	if(new_name)
		return capitalize(new_name)
	// Получает имя созданного атома
	if(ispath(build_path, /atom))
		var/atom/design_result = build_path
		new_name = declent_ru_initial(design_result::name)
		if(new_name)
			return "[capitalize(new_name)]"

/datum/design/board/update_to_ru()
	. = ..()
	if(.)
		return .
	// Если ни конструкция, ни плата не имеют уникального имени, используйте имя построенного атома
	var/obj/item/circuitboard/board = build_path
	if(!ispath(board) || !ispath(board::build_path, /atom))
		return null
	var/atom/built_item = board::build_path
	var/new_name = declent_ru_initial(built_item::name)
	if(new_name)
		return "[capitalize(new_name)] (плата)"

/obj/item/circuitboard/Initialize(mapload)
	. = ..()
	// Если у платы нет уникального имени, используйте имя построенного атома
	if(!length(ru_names) && ispath(build_path, /atom))
		var/atom/build_item = build_path
		if(name_extension)
			ru_names_rename(ru_names_toml(build_item::name, suffix = " [name_extension]", override_base = "[initial(name)] [name_extension]"))
		else
			ru_names_rename(ru_names_toml(build_item::name, override_base = "[initial(name)]"))

/obj/item/circuitboard/machine
	name_extension = "(плата машины)"

/obj/item/circuitboard/computer
	name_extension = "(плата компьютера)"

/obj/item/circuitboard/machine/chem_dispenser/abductor
	name_extension = "(плата машины абдукторов)"

/obj/item/circuitboard/machine/abductor/core
	name_extension = "(пустотное ядро)"

/datum/crafting_recipe

/datum/crafting_recipe/New()
	. = ..()
	var/new_name = declent_ru_initial(name)
	if(!new_name && ispath(result, /atom))
		var/atom/crafting_result = result
		new_name = declent_ru_initial(crafting_result::name)
	name = capitalize(new_name) || name
