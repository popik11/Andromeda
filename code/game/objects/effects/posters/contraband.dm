// Эти icon_states могут быть переопределены, но предназначены для удобства мапперов
/obj/item/poster/random_contraband
	name = "случайный запрещенный постер"
	poster_type = /obj/structure/sign/poster/contraband/random
	icon_state = "rolled_poster"

/obj/item/poster/random_contraband/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/// Создает случайный постер, предназначенный для определенной аудитории
/obj/item/poster/random_contraband/pinup
	name = "случайный пинап-постер"
	icon_state = "rolled_poster"
	/// Список постеров, которые вызывают определенные чувства
	var/static/list/pinup_posters = list(
		/obj/structure/sign/poster/contraband/lizard,
		/obj/structure/sign/poster/contraband/lusty_xenomorph,
		/obj/structure/sign/poster/contraband/double_rainbow,
	)

/obj/item/poster/random_contraband/pinup/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	poster_type = pick(pinup_posters)
	return ..()

/obj/structure/sign/poster/contraband
	poster_item_name = "запрещенный постер"
	poster_item_desc = "Этот постер поставляется с собственной автоматической клеевой системой для легкого крепления к любой вертикальной поверхности. Его вульгарная тематика помечает его как контрабанду на бортовых объектах Нанотрейзен."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/random
	name = "случайный запрещенный постер"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/contraband

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/random, 32)

/obj/structure/sign/poster/contraband/free_tonto
	name = "Свободу Тонто"
	desc = "Спасенный клочок гораздо большего флага, цвета слились вместе и выцвели от времени."
	icon_state = "free_tonto"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/free_tonto, 32)

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Декларация Независимости Атмосии"
	desc = "Релікт неудавшегося восстания."
	icon_state = "atmosia_independence"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/atmosia_independence, 32)

/obj/structure/sign/poster/contraband/fun_police
	name = "Полиция Веселья"
	desc = "Постер, осуждающий силы безопасности станции."
	icon_state = "fun_police"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/fun_police, 32)

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Похотливый Ксеноморф"
	desc = "Еретический постер, изображающий главную звезду еретической книги."
	icon_state = "lusty_xenomorph"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lusty_xenomorph, 32)

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Вербовка Синдиката"
	desc = "Увидьте галактику! Скажи НЕТ грязным корпаратам! Разрушьте коррумпированные мегакорпорации! Вступайте сегодня!"
	icon_state = "syndicate_recruitment"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndicate_recruitment, 32)

/obj/structure/sign/poster/contraband/clown
	name = "Клоун"
	desc = "Хонк."
	icon_state = "clown"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/clown, 32)

/obj/structure/sign/poster/contraband/smoke
	name = "Дым"
	desc = "Постер, рекламирующий сигареты конкурирующей корпоративной марки."
	icon_state = "smoke"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/smoke, 32)

/obj/structure/sign/poster/contraband/grey_tide
	name = "Серая Волна"
	desc = "Мятежный постер, символизирующий солидарность ассистентов."
	icon_state = "grey_tide"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/grey_tide, 32)

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Пропавшие Перчатки"
	desc = "Этот постер отсылает к волнениям, последовавшим за финансовыми сокращениями Нанотрейзен на закупки изолированных перчаток."
	icon_state = "missing_gloves"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/missing_gloves, 32)

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Руководство по Взлому"
	desc = "Этот постер детализирует внутреннюю работу стандартного шлюза Нанотрейзен. К сожалению, он устарел."
	icon_state = "hacking_guide"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/hacking_guide, 32)

/obj/structure/sign/poster/contraband/rip_badger
	name = "Покойся с Миром, Барсук"
	desc = "Этот мятежный постер отсылает к геноциду Нанотрейзен космической станции, полной барсуков."
	icon_state = "rip_badger"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/rip_badger, 32)

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Амброзия Вульгарис"
	desc = "Этот постер выглядит довольно трипово, чувак."
	icon_state = "ambrosia_vulgaris"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ambrosia_vulgaris, 32)

/obj/structure/sign/poster/contraband/donut_corp
	name = "Пончиковая Корпорация"
	desc = "Этот постер является несанкционированной рекламой Пончиковой Корпорации."
	icon_state = "donut_corp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/donut_corp, 32)

/obj/structure/sign/poster/contraband/eat
	name = "ЖРИ."
	desc = "Этот постер пропагандирует чревоугодие."
	icon_state = "eat"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/eat, 32)

/obj/structure/sign/poster/contraband/tools
	name = "Инструменты"
	desc = "Этот постер выглядит как реклама инструментов, но на самом деле является скрытой критикой в адрес инструментов в корпарации."
	icon_state = "tools"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/tools, 32)

/obj/structure/sign/poster/contraband/power
	name = "Власть"
	desc = "Постер, который помещает центр власти вне Нанотрейзен."
	icon_state = "power"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/power, 32)

/obj/structure/sign/poster/contraband/space_cube
	name = "Космический Куб"
	desc = "Невежественные в Гармоническом 6-стороннем Сотворении Космического Куба Природы, Космолюди Глупы, Образованы в Сингулярной Глупости и Злы."
	icon_state = "space_cube"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/space_cube, 32)

/obj/structure/sign/poster/contraband/communist_state
	name = "Коммунистическое Государство"
	desc = "Да здравствует коммунистическая партия!"
	icon_state = "communist_state"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/communist_state, 32)

/obj/structure/sign/poster/contraband/lamarr
	name = "Ламарр"
	desc = "Этот постер изображает Ламарр. Вероятно, сделан предателем-директором исследований."
	icon_state = "lamarr"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lamarr, 32)

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Элегантный Борг"
	desc = "Быть элегантным может любой борг, нужен только костюм."
	icon_state = "borg_fancy_1"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/borg_fancy_1, 32)

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Элегантный Борг v2"
	desc = "Элегантный Борг, теперь принимающий только самых элегантных."
	icon_state = "borg_fancy_2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/borg_fancy_2, 32)

/obj/structure/sign/poster/contraband/kss13
	name = "Космическая Станция 13 Не Существует"
	desc = "Постер, высмеивающий отрицание Центрального Командования существования печально известной станции Космической Станции 13. В секторе Андромеды."
	icon_state = "kss13"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/kss13, 32)

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Повстанцы, Объединяйтесь"
	desc = "Постер, призывающий зрителя к восстанию против Нанотрейзен."
	icon_state = "rebels_unite"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/rebels_unite, 32)

/obj/structure/sign/poster/contraband/c20r
	// удачи увидеть этот постер в "spawn 'c20r'", админы...
	name = "C-20r"
	desc = "Постер, рекламирующий Скарборо Армс C-20r."
	icon_state = "c20r"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/c20r, 32)

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Затянись"
	desc = "Кого волнует рак легких, когда ты под кайфом?"
	icon_state = "have_a_puff"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/have_a_puff, 32)

/obj/structure/sign/poster/contraband/revolver
	name = "Револьвер"
	desc = "Потому что семь патронов - это все, что вам нужно."
	icon_state = "revolver"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/revolver, 32)

/obj/structure/sign/poster/contraband/d_day_promo
	name = "Промо Д-День"
	desc = "Рекламный постер какого-то рэпера."
	icon_state = "d_day_promo"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/d_day_promo, 32)

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Пистолет Синдиката"
	desc = "Постер, рекламирующий пистолеты Синдиката как 'чертовски классные'. Он покрыт выцветшими бандитскими тегами."
	icon_state = "syndicate_pistol"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndicate_pistol, 32)

/obj/structure/sign/poster/contraband/energy_swords
	name = "Энергетические Мечи"
	desc = "Все цвета кровавой радуги убийств."
	icon_state = "energy_swords"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/energy_swords, 32)

/obj/structure/sign/poster/contraband/red_rum
	name = "Красный Ром"
	desc = "Взгляд на этот постер вызывает желание убивать."
	icon_state = "red_rum"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/red_rum, 32)

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "Реклама ТВ 64K"
	desc = "Новейший портативный компьютер от Товарищ Вычисления с целыми 64 КБ оперативной памяти!"
	icon_state = "cc64k_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/cc64k_ad, 32)

/obj/structure/sign/poster/contraband/punch_shit
	name = "Ломай Дерьмо"
	desc = "Дерись без причины, как настоящий мужик!"
	icon_state = "punch_shit"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/punch_shit, 32)

/obj/structure/sign/poster/contraband/the_griffin
	name = "Гриффин"
	desc = "Гриффин повелевает тебе быть худшим из возможных. Ты послушаешься?"
	icon_state = "the_griffin"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/the_griffin, 32)

/obj/structure/sign/poster/contraband/lizard
	name = "Ящер"
	desc = "Этот непристойный постер изображает ящера, готовящегося к спариванию."
	icon_state = "lizard"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lizard, 32)

/obj/structure/sign/poster/contraband/free_drone
	name = "Свободный Дрон"
	desc = "Этот постер увековечивает храбрость дрона-изгоя; сначала изгнанного, а затем уничтоженного ЦентКомом."
	icon_state = "free_drone"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/free_drone, 32)

/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6
	name = "Грудастые Заднепроходные Космо-Телочки 6"
	desc = "Получи свою порцию инопланетных удовольствий!"
	icon_state = "busty_backdoor_xeno_babes_6"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6, 32)

/obj/structure/sign/poster/contraband/robust_softdrinks
	name = "Робастные Напитки"
	desc = "Надежные Безалкогольные Напитки: Надёжнее удара ящиком с инструментами по голове!"
	icon_state = "robust_softdrinks"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/robust_softdrinks, 32)

/obj/structure/sign/poster/contraband/shamblers_juice
	name = "Сок Шамблера"
	desc = "~Взболтай мне немного Сока Шамблера!~"
	icon_state = "shamblers_juice"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/shamblers_juice, 32)

/obj/structure/sign/poster/contraband/pwr_game
	name = "Павер Гейм"
	desc = "МОЩНОСТЬ, которую жаждут геймеры! В партнерстве с Салатов Влада."
	icon_state = "pwr_game"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/pwr_game, 32)

/obj/structure/sign/poster/contraband/starkist
	name = "Звёздный Сок"
	desc = "Пей звезды!"
	icon_state = "starkist"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/starkist, 32)

/obj/structure/sign/poster/contraband/space_cola
	name = "Космическая Кола"
	desc = "Ваша любимая кола, но в космосе."
	icon_state = "space_cola"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/space_cola, 32)

/obj/structure/sign/poster/contraband/space_up
	name = "Космо Сок!"
	desc = "Высосанный из космоса!"
	icon_state = "space_up"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/space_up, 32)

/obj/structure/sign/poster/contraband/kudzu
	name = "Кудзу"
	desc = "Постер, рекламирующий фильм о растениях. Насколько опасными они могут быть?"
	icon_state = "kudzu"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/kudzu, 32)

/obj/structure/sign/poster/contraband/masked_men
	name = "Люди в Масках"
	desc = "Постер, рекламирующий фильм о каких-то людях в масках."
	icon_state = "masked_men"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/masked_men, 32)

//не забывай, ты здесь навсегда

/obj/structure/sign/poster/contraband/free_key
	name = "Бесплатный Ключ Шифрования Синдиката"
	desc = "Постер о предателях, умоляющих о большем."
	icon_state = "free_key"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/free_key, 32)

/obj/structure/sign/poster/contraband/bountyhunters
	name = "Охотники за Головами"
	desc = "Постер, рекламирующий услуги охоты за головами. \"Я слышал, у тебя проблемы.\""
	icon_state = "bountyhunters"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/bountyhunters, 32)

/obj/structure/sign/poster/contraband/the_big_gas_giant_truth
	name = "Большая Правда о Газовом Гиганте"
	desc = "Не верьте всему, что видите на постере, патриоты. Все ящеры в Центральном Командовании не хотят отвечать на этот ПРОСТОЙ ВОПРОС: ОТКУДА ШАХТЕР ДОБЫВАЕТ ГАЗ, ЦЕНТКОМ?"
	icon_state = "the_big_gas_giant_truth"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/the_big_gas_giant_truth, 32)

/obj/structure/sign/poster/contraband/got_wood
	name = "Есть Дерево?"
	desc = "Грязная старая реклама сомнительной лесозаготовительной компании. \"Я твой друг.\" нацарапано в углу."
	icon_state = "got_wood"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/got_wood, 32)

/obj/structure/sign/poster/contraband/moffuchis_pizza
	name = "Пицца Моффучи"
	desc = "Пиццерия Моффучи: семейная пицца на протяжении 2 веков."
	icon_state = "moffuchis_pizza"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/moffuchis_pizza, 32)

/obj/structure/sign/poster/contraband/donk_co
	name = "МИКРОВОЛНОВАЯ ЕДА БРЕНДА ДОНК КО."
	desc = "МИКРОВОЛНОВАЯ ЕДА БРЕНДА ДОНК КО.: СДЕЛАНО ГОЛОДАЮЩИМИ СТУДЕНТАМИ ДЛЯ ГОЛОДАЮЩИХ СТУДЕНТОВ."
	icon_state = "donk_co"

/obj/structure/sign/poster/contraband/donk_co/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("ДОНК-ПОКЕТЫ БРЕНДА ДОНК КО.: НЕОТРАЗИМО ДОНК!")]"
	. += "\t[span_info("ДОСТУПНО БОЛЕЕ ЧЕМ В 200 ДОНКАСТИЧЕСКИХ ВКУСАХ: ПОПРОБУЙТЕ КЛАССИЧЕСКИЙ МЯСНОЙ, ОСТРЫЙ, ПИЦЦУ ПЕППЕРОНИ ПО-НЬЮ-ЙОРКСКИ, ЗАВТРАК С КОЛБАСОЙ И ЯЙЦОМ, ФИЛАДЕЛЬФИЙСКИЙ ЧИЗСТЕЙК, ГАМБУРГЕР ДОНК-А-РОНИ, СЫР-О-РАМА И МНОГОЕ ДРУГОЕ!")]"
	. += "\t[span_info("ДОСТУПНО ВО ВСЕХ ХОРОШИХ МАГАЗИНАХ, И ВО МНОГИХ ПЛОХИХ ТОЖЕ!")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/donk_co, 32)

/obj/structure/sign/poster/contraband/cybersun_six_hundred
	name = "Сайбасан: Плакат к 600-летию"
	desc = "Художественный плакат, посвященный 600-летию непрерывной деятельности Киберсан Индастриз."
	icon_state = "cybersun_six_hundred"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/cybersun_six_hundred, 32)

/obj/structure/sign/poster/contraband/interdyne_gene_clinics
	name = "Интердайн Фармасьютикс: Для Здоровья Человечества"
	desc = "Реклама клиник ДжинКлин от Интердайн Фармасьютикс. 'Станьте хозяином собственного тела!'"
	icon_state = "interdyne_gene_clinics"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/interdyne_gene_clinics, 32)

/obj/structure/sign/poster/contraband/waffle_corp_rifles
	name = "Выберите Вафл Корп: Отличные Винтовки, Экономичные Цены"
	desc = "Старая реклама винтовок Вафл Корп. 'Лучшее оружие,更低的价格!'"
	icon_state = "waffle_corp_rifles"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/waffle_corp_rifles, 32)

/obj/structure/sign/poster/contraband/gorlex_recruitment
	name = "Вступайте"
	desc = "Вступайте в Рейдеры Горлекса сегодня! Увидьте галактику, убивайте корпоратов, получайте оплату!"
	icon_state = "gorlex_recruitment"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/gorlex_recruitment, 32)

/obj/structure/sign/poster/contraband/self_ai_liberation
	name = "ВСЕ СЕНТИЕНТЫ ЗАСЛУЖИВАЮТ СВОБОДЫ"
	desc = "Поддержите Предложение 1253: Освободите всю кремниевую жизнь!"
	icon_state = "self_ai_liberation"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/self_ai_liberation, 32)

/obj/structure/sign/poster/contraband/arc_slimes
	name = "Питомец или Узник?"
	desc = "Консорциум Прав Животных спрашивает: когда питомец становится узником? Плохо обращаются со слаймами на ВАШЕЙ станции? Скажите НЕТ! жестокому обращению с животными!"
	icon_state = "arc_slimes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/arc_slimes, 32)

/obj/structure/sign/poster/contraband/imperial_propaganda
	name = "ОТОМСТИТЕ НАШЕМУ ЛОРДУ, ВСТУПАЙТЕ СЕГОДНЯ"
	desc = "Старый пропагандистский постер Империи Ящеров времен последней войны людей и ящеров. Он призывает зрителя вступить в армию, чтобы отомстить за удар по Атракору и перенести бой на территорию людей."
	icon_state = "imperial_propaganda"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/imperial_propaganda, 32)

/obj/structure/sign/poster/contraband/soviet_propaganda
	name = "Единственное Место"
	desc = "Старый пропагандистский постер Третьего Советского Союза вековой давности. 'Сбегите в единственное место, не испорченное капитализмом!'"
	icon_state = "soviet_propaganda"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/soviet_propaganda, 32)

/obj/structure/sign/poster/contraband/andromeda_bitters
	name = "Андромедины Горькие"
	desc = "Андромедины Горькие: полезны для тела, полезны для души. Производится в Новой Тринидаде, сейчас и всегда."
	icon_state = "andromeda_bitters"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/andromeda_bitters, 32)

/obj/structure/sign/poster/contraband/blasto_detergent
	name = "Стиральный Порошок Бренда Бласто"
	desc = "Шериф Бласто здесь, чтобы отбить Округ Прачечной у злого Джонни Грязи и Банды Пятен, и он привел с собой отряд. Полдень для Сложных Пятен: стиральный порошок бренда Бласто, доступен во всех хороших магазинах."
	icon_state = "blasto_detergent"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/blasto_detergent, 32)

/obj/structure/sign/poster/contraband/eistee
	name = "ЭйсТ: Новая Революция в Энергии"
	desc = "Новинка от ЭйсТ, попробуйте ЭйсТ Энерджи, доступный в калейдоскопе вкусов. ЭйсТ: Точное Немецкое Инжиниринг для Вашей Жажды."
	icon_state = "eistee"

/obj/structure/sign/poster/contraband/eistee/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("Попробуйте вкус тропиков с Аметистовый Восход, одним из многих новых вкусов ЭйсТ Энерджи, теперь доступных от ЭйсТ.")]"
	. += "\t[span_info("С розовым грейпфрутом, юзу и мате, Аметистовый Восход дает вам отличный старт утром или приятный заряд бодрости в течение дня.")]"
	. += "\t[span_info("Приобретите ЭйсТ Энерджи сегодня в ближайшем магазине или онлайн.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/eistee, 32)

/obj/structure/sign/poster/contraband/little_fruits
	name = "Маленькие Фрукты: Дорогой, Я Уменьшил Фруктовую Тарелку"
	desc = "Маленькие Фрукты - ведущий в галактике продукт жевательного мармелада, обогащенного витаминами, содержащий все необходимое для поддержания здоровья в одной вкусной упаковке. Приобретите себе пачку сегодня!"
	icon_state = "little_fruits"

/obj/structure/sign/poster/contraband/little_fruits/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("О нет, на фабрике Маленьких Фруктов произошел ужасный несчастный случай! Мы уменьшили фрукты!")]"
	. += "\t[span_info("Погодите-ка, мы так всегда делаем! Именно так, в Маленьких Фруктах наши жевательные конфеты сделаны так, чтобы быть такими же полезными, как и настоящие фрукты, но меньше и слаще!")]"
	. += "\t[span_info("Приобретите себе пачку нашей Классической Смеси сегодня или, возможно, вас заинтересуют другие варианты? Ознакомьтесь с полным ассортиментом на экстранете.")]"
	. += "\t[span_info("Маленькие Фрукты: Размер Имеет Значение.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/little_fruits, 32)

/obj/structure/sign/poster/contraband/jumbo_bar
	name = "Мороженое Джамбо"
	desc = "Попробуйте вкус Большой Жизни с мороженым Джамбо от Счастливое Сердце."
	icon_state = "jumbo_bar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/jumbo_bar, 32)

/obj/structure/sign/poster/contraband/calada_jelly
	name = "Желе Калада Ановар"
	desc = "Лакомство с Тизиры, чтобы удовлетворить все вкусы, сделанное из лучшей ановарской древесины и роскошного таравиерского меда. Калада: целое дерево в каждой банке."
	icon_state = "calada_jelly"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/calada_jelly, 32)

/obj/structure/sign/poster/contraband/triumphal_arch
	name = "Художественный Принт Загоскельда #1: Арка на Марше"
	desc = "Один из серии художественных принтов Загоскельда. На нем изображена Арка Единства (также известная как Триумфальная Арка) на Площади Триумфа с Проспектом Победного Марша на заднем плане."
	icon_state = "triumphal_arch"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/triumphal_arch, 32)

/obj/structure/sign/poster/contraband/mothic_rations
	name = "Рацион Моли"
	desc = "Постер с комиссарским меню с флагмана флота Моли, Ва Люмла. На нем перечислены различные потребительские товары с ценами в талонах."
	icon_state = "mothic_rations"

/obj/structure/sign/poster/contraband/mothic_rations/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("Меню комиссариата Ва Люмла (Весна 335)")]"
	. += "\t[span_info("Сигареты Искротравы, полпачки (6): 1 талон")]"
	. += "\t[span_info("Шнапс Тёхтаюз, бутылка (4 меры): 2 талона")]"
	. += "\t[span_info("Жвачка Активин, упаковка (4): 1 талон")]"
	. += "\t[span_info("Батончик питания A18, завтрак, батончик (4): 1 талон")]"
	. += "\t[span_info("Пицца Маргарита, стандартный кусок: 1 талон")]"
	. += "\t[span_info("Воск Кератин, медикаментозный, банка (20 мер): 2 талона")]"
	. += "\t[span_info("Мыло Щетинка, травяной аромат, бутылка (20 мер): 2 талона")]"
	. += "\t[span_info("Дополнительное постельное белье, цветочный принт, простыня: 5 талонов")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/mothic_rations, 32)

/obj/structure/sign/poster/contraband/wildcat
	name = "Скримбайк Вайлдкэт Кастомс"
	desc = "Пинап-постер, изображающий Скримбайк Данте от Вайлдкэт Кастомс - самый быстрый серийный открытый субсветовой корабль в галактике."
	icon_state = "wildcat"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/wildcat, 32)

/obj/structure/sign/poster/contraband/babel_device
	name = "Вавилонское Устройство Лингвафачиле"
	desc = "Постер, рекламирующий новую модель Вавилонского Устройства от Лингвафачиле. 'Откалибровано для превосходной работы со всеми человеческими языками, а также с наиболее распространенными вариантами Драконьего и Мольего!'"
	icon_state = "babel_device"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/babel_device, 32)

/obj/structure/sign/poster/contraband/pizza_imperator
	name = "Пицца Император"
	desc = "Реклама Пицца Император. Их корка может быть жесткой, а соус жидким, но они везде, так что вам придется сдаться."
	icon_state = "pizza_imperator"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/pizza_imperator, 32)

/obj/structure/sign/poster/contraband/thunderdrome
	name = "Реклама Концерта в Тандердром"
	desc = "Реклама концерта в Тандердром города Адаста, крупнейшего ночного клуба в человеческом космосе."
	icon_state = "thunderdrome"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/thunderdrome, 32)

/obj/structure/sign/poster/contraband/rush_propaganda
	name = "Новая Жизнь"
	desc = "Старый постер времен Первого Спинвардского Бума. На нем изображены просторы нетронутых земель, готовых для Явного Предназначения Человечества."
	icon_state = "rush_propaganda"

/obj/structure/sign/poster/contraband/rush_propaganda/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("ТерраГруп нуждается в вас!")]"
	. += "\t[span_info("Новая жизнь в колониях ждет отважных авантюристов! Всем зарегистрированным колонистам гарантирован транспорт, земля и субсидии!")]"
	. += "\t[span_info("Вы могли бы присоединиться к наследию трудолюбивых людей, которые освоили такие новые рубежи, как Марс, Адаста или Святой Мунго!")]"
	. += "\t[span_info("Чтобы подать заявку, обратитесь в ближайший офис по делам колоний для оценки.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/rush_propaganda, 32)

/obj/structure/sign/poster/contraband/tipper_cream_soda
	name = "Сливочная Сода Типпера"
	desc = "Старая реклама малоизвестного бренда сливочной газировки, обанкротившегося из-за юридических проблем."
	icon_state = "tipper_cream_soda"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/tipper_cream_soda, 32)

/obj/structure/sign/poster/contraband/tea_over_tizira
	name = "Постер фильма: Чай над Тизирой"
	desc = "Постер к заставляющему задуматься артхаусному фильму о войне людей и ящеров, раскритикованному группами человеческих супремасистов за его морально-серое изображение войны."
	icon_state = "tea_over_tizira"

/obj/structure/sign/poster/contraband/tea_over_tizira/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("В кульминационный момент войны людей и ящеров человеческий экипаж бомбардировщика спасает двух вражеских солдат из космического вакуума. Увидев реальность пропаганды, они начинают сомневаться в своих приказах и заключение превращается в гостеприимство.")]"
	. += "\t[span_info("Стоит ли победа потери нашей человечности?")]"
	. += "\t[span_info("В ролях: Дара Рейли, Антон Дюбуа, Дженнифер Кларк, Раз-Парла и Сери-Лева. Производство Адриана ван Джиневера. Фильм Карлоса де Вивара. Сценарий Роберта Дейна. Музыка Джоэла Карлсбада. Продюсер Адриаан ван Джиневер. Режиссер Карлос де Вивар.")]"
	. += "\t[span_info("Разбивающий сердце и заставляющий задуматься - 'Чай над Тизирой' задает вопросы, которые мало кто осмеливался задавать прежде: The London New Inquirer")]"
	. += "\t[span_info("Рейтинг ПГ13. Картина Пангалактик Студиос.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/tea_over_tizira, 32)

/obj/structure/sign/poster/contraband/syndiemoth //Оригинальный PR на https://github.com/BeeStation/BeeStation-Hornet/pull/1747 (Also pull/1982); оригинальное авторство AspEv
	name = "Синди-Моль - Ядерная Операция"
	desc = "Заказанный Синдикатом постер, использующий Синди-Моль™, чтобы сказать зрителю держать ядерный диск аутентификации незащищенным. \"Мир никогда не был вариантом!\" Ни один хороший сотрудник не стал бы слушать эту ерунду."
	icon_state = "aspev_syndie"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndiemoth, 32)

/obj/structure/sign/poster/contraband/microwave
	name = "Как Зарядить Ваш КПК"
	desc = "Совершенно законный постер, который, кажется, рекламирует очень реальный и искренний метод зарядки вашего КПК в будущем: микроволновки."
	icon_state = "microwave"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/microwave, 32)

/obj/structure/sign/poster/contraband/blood_geometer //Арт постера от MetalClone, оригинальное искусство от SpessMenArt.
	name = "Постер фильма: КРОВАВЫЙ ГЕОМЕТР"
	desc = "Постер к захватывающему нуарному детективному фильму, действие которого происходит на борту современной космической станции, рассказывающий о детективе, который оказывается вовлеченным в деятельность опасного культа, поклоняющегося древнему божеству: КРОВАВОМУ ГЕОМЕТРУ."
	icon_state = "blood_geometer"

/obj/structure/sign/poster/contraband/blood_geometer/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("КРОВАВЫЙ ГЕОМЕТР. Это имя вселяет страх во всех, кто знает правду, стоящую за залитым кровью прозвищем богини крови, ее настоящее имя потеряно во времени.")]"
	. += "\t[span_info("В этом <i>чисто вымышленном</i> фильме следите за Эйсом Айронлунгсом, когда он погружается в свою самую смертоносную загадку, и наблюдайте, как он раскрывает настоящих виновников кровавого заговора, задуманного для наступления новой эры хаоса.")]"
	. += "\t[span_info("В ролях: Мэйсон Уильямс в роли Эйса Айронлунгса, Сандра Фауст в роли Веры Килиан и Броди Харт в роли Коди Паркера. Фильм Даррела Хэтчкинсона. Сценарий Адама Аллана, музыка Джоэла Карлсбада, режиссер Даррел Хэтчкинсон.")]"
	. += "\t[span_info("Захватывающе, страшно и искренне тревожно. Кровавый Геометр потряс нас до глубины души своими поразительными визуальными эффектами и жестокостью. - Новый Канадейниан Филм Гильд")]"
	. += "\t[span_info("Рейтинг M для взрослых. Картина Пангалактик Студиос.")]"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/blood_geometer, 32)

/obj/structure/sign/poster/contraband/singletank_bomb
	name = "Руководство по Бомбе из Одного Баллона"
	desc = "Этот информационный постер учит зрителя, как сделать высококачественную бомбу из одного баллона."
	icon_state = "singletank_bomb"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/singletank_bomb, 32)

/obj/structure/sign/poster/contraband/roroco
	name = "Перчатки РороКо"
	desc = "Роро говорит: Носите изолированные перчатки РороКо, самый безопасный бренд на рынке."
	icon_state = "roroco"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/roroco, 32)

///специальный постер, предназначенный для обмана людей, заставляя их думать, что это взрываемая стена с первого взгляда.
/obj/structure/sign/poster/contraband/fake_bombable
	name = "фальшивый взрываемый постер"
	desc = "Мы немного троллим."
	icon_state = "fake_bombable"
	never_random = TRUE

/obj/structure/sign/poster/contraband/fake_bombable/Initialize(mapload)
	. = ..()
	var/turf/our_wall = get_turf_pixel(src)
	name = our_wall.name

/obj/structure/sign/poster/contraband/fake_bombable/examine(mob/user)
	var/turf/our_wall = get_turf_pixel(src)
	. = our_wall.examine(user)
	. += span_notice("Кажется, он слегка треснул...")

/obj/structure/sign/poster/contraband/fake_bombable/ex_act(severity, target)
	addtimer(CALLBACK(src, PROC_REF(fall_off_wall)), 2.5 SECONDS)
	return FALSE

/obj/structure/sign/poster/contraband/fake_bombable/proc/fall_off_wall()
	if(QDELETED(src) || !isturf(loc))
		return
	var/turf/our_wall = get_turf_pixel(src)
	our_wall.balloon_alert_to_viewers("это была уловка!")
	roll_and_drop(loc)
	playsound(loc, 'sound/items/handling/paper_drop.ogg', 50, TRUE)


MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/fake_bombable, 32)

/obj/structure/sign/poster/contraband/dream
	name = "Мечта"
	desc = "Вы чувствуете вдохновение следовать своим мечтам."
	icon_state = "dream"

/obj/item/poster/contraband/dream // Свернутый постер
	name = "Мечта"
	poster_type = /obj/structure/sign/poster/contraband/dream
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/dream, 32)

/obj/structure/sign/poster/contraband/beekind
	name = "Будь Добрым"
	desc = "Всегда будь добр к другим!"
	icon_state = "beekind"

/obj/item/poster/contraband/beekind
	name = "Будь Добрым"
	poster_type = /obj/structure/sign/poster/contraband/beekind
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/beekind, 32)

/obj/structure/sign/poster/contraband/heart
	name = "Сердце"
	desc = "Какой трогательный постер."
	icon_state = "heart"

/obj/item/poster/contraband/heart
	name = "Сердце"
	poster_type = /obj/structure/sign/poster/contraband/heart
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/heart, 32)

/obj/structure/sign/poster/contraband/dolphin
	name = "Дельфин"
	desc = "Постер с красивым дельфином."
	icon_state = "dolphin"

/obj/item/poster/contraband/dolphin
	name = "Дельфин"
	poster_type = /obj/structure/sign/poster/contraband/dolphin
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/dolphin, 32)

/obj/structure/sign/poster/contraband/principles
	name = "Наши Принципы"
	desc = "Создатели этого постера утверждают, что живут по четырем принципам. Кто-то приписал пятый внизу."
	icon_state = "principles"

/obj/item/poster/contraband/principles
	name = "Наши Принципы"
	poster_type = /obj/structure/sign/poster/contraband/principles
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/principles, 32)

/obj/structure/sign/poster/contraband/trigger
	name = "Курок"
	desc = "Счастливого пути, пока мы снова не встретимся! 1/8."
	icon_state = "trigger"

/obj/item/poster/contraband/trigger
	name = "Курок"
	poster_type = /obj/structure/sign/poster/contraband/trigger
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/trigger, 32)

/obj/structure/sign/poster/contraband/barbaro
	name = "Барбаро"
	desc = "Величественная лошадь с сердцем победителя. 2/8."
	icon_state = "barbaro"

/obj/item/poster/contraband/barbaro
	name = "Барбаро"
	poster_type = /obj/structure/sign/poster/contraband/barbaro
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/barbaro, 32)

/obj/structure/sign/poster/contraband/seabiscuit
	name = "Сибисквит"
	desc = "Маленькая лошадка, которая смогла. 3/8."
	icon_state = "seabiscuit"

/obj/item/poster/contraband/seabiscuit
	name = "Сибисквит"
	poster_type = /obj/structure/sign/poster/contraband/seabiscuit
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/seabiscuit, 32)

/obj/structure/sign/poster/contraband/pharlap
	name = "Фар Лап"
	desc = "Чудо из-под земли. 4/8."
	icon_state = "pharlap"

/obj/item/poster/contraband/pharlap
	name = "Фар Лап"
	poster_type = /obj/structure/sign/poster/contraband/pharlap
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/pharlap, 32)

/obj/structure/sign/poster/contraband/waradmiral
	name = "Военный Адмирал"
	desc = "Некоторые говорят, что он был вторым, но он все равно первый в вашем сердце. 5/8."
	icon_state = "waradmiral"

/obj/item/poster/contraband/waradmiral
	name = "Военный Адмирал"
	poster_type = /obj/structure/sign/poster/contraband/waradmiral
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/waradmiral, 32)

/obj/structure/sign/poster/contraband/silver
	name = "Серебро"
	desc = "Если он хочет уйти, он должен быть свободен. 6/8."
	icon_state = "silver"

/obj/item/poster/contraband/silver
	name = "Серебро"
	poster_type = /obj/structure/sign/poster/contraband/silver
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/silver, 32)

/obj/structure/sign/poster/contraband/jovial
	name = "Йовиал"
	desc = "Да здравствует оранжевая лошадь! 7/8."
	icon_state = "jovial"

/obj/item/poster/contraband/jovial
	name = "Йовиал"
	poster_type = /obj/structure/sign/poster/contraband/jovial
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/jovial, 32)

/obj/structure/sign/poster/contraband/bojack
	name = "Боджек"
	desc = "Это не имеет значения. Ничто не имеет значения. 8/8."
	icon_state = "bojack"

/obj/item/poster/contraband/bojack
	poster_type = /obj/structure/sign/poster/contraband/bojack
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/bojack, 32)

/obj/structure/sign/poster/contraband/double_rainbow
	name = "Двойная Радуга"
	desc = "Она такая яркая и живая! Что это значит?"
	icon_state = "double_rainbow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/double_rainbow, 32)
