/area/station/service
	airlock_wires = /datum/wires/airlock/service

/*
* Bar/Kitchen Areas
*/

/area/station/service/cafeteria
	name = "\improper Кафетерий"
	icon_state = "cafeteria"

/area/station/service/minibar
	name = "\improper Мини-бар"
	icon_state = "minibar"

/area/station/service/kitchen
	name = "\improper Кухня"
	icon_state = "kitchen"

/area/station/service/kitchen/coldroom
	name = "\improper Холодильная камера кухни"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/kitchen/diner
	name = "\improper Закусочная"
	icon_state = "diner"

/area/station/service/kitchen/kitchen_backroom
	name = "\improper Подсобка кухни"
	icon_state = "kitchen_backroom"

/area/station/service/bar
	name = "\improper Бар"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "Обожаю бывать в баре!"
	mood_trait = TRAIT_EXTROVERT
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/station/service/bar/atrium
	name = "\improper Атриум"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/bar/backroom
	name = "\improper Закулисье бара"
	icon_state = "bar_backroom"

/*
* Развлекательные/Библиотечные зоны
*/

/area/station/service/theater
	name = "\improper Театр"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/theater_dressing
	name = "\improper Гримерка театра"
	icon_state = "theatre_dressing"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/greenroom
	name = "\improper Гринум"
	icon_state = "theatre_green"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/library
	name = "\improper Библиотека"
	icon_state = "library"
	mood_bonus = 5
	mood_message = "Обожаю бывать в библиотеке!"
	mood_trait = TRAIT_INTROVERT
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/station/service/library/garden
	name = "\improper Библиотечный сад"
	icon_state = "library_garden"

/area/station/service/library/lounge
	name = "\improper Библиотечная гостиная"
	icon_state = "library_lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/library/artgallery
	name = "\improper Художественная галерея"
	icon_state = "library_gallery"

/area/station/service/library/private
	name = "\improper Частный кабинет библиотеки"
	icon_state = "library_gallery_private"

/area/station/service/library/upper
	name = "\improper Верхний этаж библиотеки"
	icon_state = "library"

/area/station/service/library/printer
	name = "\improper Комната принтеров"
	icon_state = "library"

/*
* Часовня/Монастырские зоны
*/

/area/station/service/chapel
	name = "\improper Часовня"
	icon_state = "chapel"
	mood_bonus = 5
	mood_message = "В часовне я чувствую умиротворение."
	mood_trait = TRAIT_SPIRITUAL
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/service/chapel/monastery
	name = "\improper Монастырь"

/area/station/service/chapel/office
	name = "\improper Офис часовни"
	icon_state = "chapeloffice"

/area/station/service/chapel/asteroid
	name = "\improper Часовня на астероиде"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/station/service/chapel/asteroid/monastery
	name = "\improper Монастырь на астероиде"

/area/station/service/chapel/dock
	name = "\improper Док часовни"
	icon_state = "construction"

/area/station/service/chapel/storage
	name = "\improper Склад часовни"
	icon_state = "chapelstorage"

/area/station/service/chapel/funeral
	name = "\improper Траурный зал"
	icon_state = "chapelfuneral"

/area/station/service/hydroponics/garden/monastery
	name = "\improper Монастырский сад"
	icon_state = "hydro"

/*
* Гидропоника/Садовые зоны
*/

/area/station/service/hydroponics
	name = "Гидропоника"
	icon_state = "hydro"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/service/hydroponics/upper
	name = "Верхняя гидропоника"
	icon_state = "hydro"

/area/station/service/hydroponics/garden
	name = "Сад"
	icon_state = "garden"

/*
* Разные/Несортированные помещения
*/

/area/station/service/lawoffice
	name = "\improper Юридический офис"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/janitor
	name = "\improper Комната уборщика"
	icon_state = "janitor"
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/barber
	name = "\improper Парикмахерская"
	icon_state = "barber"

/area/station/service/boutique
	name = "\improper Бутик"
	icon_state = "boutique"

/*
* Заброшенные помещения
*/

/area/station/service/hydroponics/garden/abandoned
	name = "\improper Заброшенный сад"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/kitchen/abandoned
	name = "\improper Заброшенная кухня"
	icon_state = "abandoned_kitchen"

/area/station/service/electronic_marketing_den
	name = "\improper Электронный маркетинговый зал"
	icon_state = "abandoned_marketing_den"

/area/station/service/abandoned_gambling_den
	name = "\improper Заброшенный игорный зал"
	icon_state = "abandoned_gambling_den"

/area/station/service/abandoned_gambling_den/gaming
	name = "\improper Заброшенный игровой зал"
	icon_state = "abandoned_gaming_den"

/area/station/service/theater/abandoned
	name = "\improper Заброшенный театр"
	icon_state = "abandoned_theatre"

/area/station/service/library/abandoned
	name = "\improper Заброшенная библиотека"
	icon_state = "abandoned_library"
