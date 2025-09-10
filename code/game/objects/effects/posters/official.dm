/obj/item/poster/random_official
	name = "случайный официальный постер"
	poster_type = /obj/structure/sign/poster/official/random
	icon_state = "rolled_legit"

/obj/structure/sign/poster/official
	poster_item_name = "мотивационный постер"
	poster_item_desc = "Официальный постер от Нанотрейзен для воспитания покорной и послушной рабочей силы. Поставляется с передовой клеевой основой для легкого крепления к любой вертикальной поверхности."
	poster_item_icon_state = "rolled_legit"
	printable = TRUE

/obj/structure/sign/poster/official/random
	name = "Случайный Официальный Постер (СОП)"
	random_basetype = /obj/structure/sign/poster/official
	icon_state = "random_official"
	never_random = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/random, 32)
//Это жестко прописано здесь, чтобы гарантировать, что мы не печатаем направленные постеры из компьютера управления библиотекой, так как они странно ведут себя как предмет постера
/obj/structure/sign/poster/official/random/directional
	printable = FALSE

/obj/structure/sign/poster/official/here_for_your_safety
	name = "Здесь Для Вашей Безопасности"
	desc = "Постер, прославляющий службу безопасности станции."
	icon_state = "here_for_your_safety"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/here_for_your_safety, 32)

/obj/structure/sign/poster/official/nanotrasen_logo
	name = "Логотип Нанотрейзен"
	desc = "Постер с изображением логотипа Нанотрейзен."
	icon_state = "nanotrasen_logo"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/nanotrasen_logo, 32)

/obj/structure/sign/poster/official/cleanliness
	name = "Чистота"
	desc = "Постер, предупреждающий об опасностях плохой гигиены."
	icon_state = "cleanliness"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/cleanliness, 32)

/obj/structure/sign/poster/official/help_others
	name = "Помогайте Другим"
	desc = "Постер, призывающий вас помогать другим членам экипажа."
	icon_state = "help_others"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/help_others, 32)

/obj/structure/sign/poster/official/build
	name = "Стройте"
	desc = "Постер, прославляющий инженерную команду."
	icon_state = "build"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/build, 32)

/obj/structure/sign/poster/official/bless_this_spess
	name = "Благослови Это Пространство"
	desc = "Постер, благословляющий эту область."
	icon_state = "bless_this_spess"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/bless_this_spess, 32)

/obj/structure/sign/poster/official/science
	name = "Наука"
	desc = "Постер с изображением атома."
	icon_state = "science"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/science, 32)

/obj/structure/sign/poster/official/ian
	name = "Иан"
	desc = "Гав гав. Тяф."
	icon_state = "ian"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ian, 32)

/obj/structure/sign/poster/official/obey
	name = "Повинуйтесь"
	desc = "Постер, инструктирующий зрителя повиноваться власти."
	icon_state = "obey"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/obey, 32)

/obj/structure/sign/poster/official/walk
	name = "Ходите"
	desc = "Постер, призывающий зрителя ходить вместо бега."
	icon_state = "walk"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/walk, 32)

/obj/structure/sign/poster/official/state_laws
	name = "Озвучивайте Законы"
	desc = "Постер, инструктирующий киборгов озвучивать свои законы."
	icon_state = "state_laws"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/state_laws, 32)

/obj/structure/sign/poster/official/love_ian
	name = "Любите Иана"
	desc = "Иан - это любовь, Иан - это жизнь."
	icon_state = "love_ian"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/love_ian, 32)

/obj/structure/sign/poster/official/space_cops
	name = "Космические Копы"
	desc = "Постер, рекламирующий телешоу 'Космические Копы'."
	icon_state = "space_cops"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/space_cops, 32)

/obj/structure/sign/poster/official/ue_no
	name = "Ue No."
	desc = "Эта вещь полностью на японском."
	icon_state = "ue_no"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ue_no, 32)

/obj/structure/sign/poster/official/get_your_legs
	name = "Получите Свои НОГИ"
	desc = "НОГИ: Начальство, Опыт, Гениальность, Исполнительность."
	icon_state = "get_your_legs"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/get_your_legs, 32)

/obj/structure/sign/poster/official/do_not_question
	name = "Не Задавайте Вопросов"
	desc = "Постер, призывающий зрителя не спрашивать о вещах, которые ему не положено знать."
	icon_state = "do_not_question"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/do_not_question, 32)

/obj/structure/sign/poster/official/work_for_a_future
	name = "Работайте Ради Будущего"
	desc = "Постер, призывающий вас работать ради своего будущего."
	icon_state = "work_for_a_future"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/work_for_a_future, 32)

/obj/structure/sign/poster/official/soft_cap_pop_art
	name = "Поп-Арт с Мягкой Кепкой"
	desc = "Постер-репродукция дешевого поп-арта."
	icon_state = "soft_cap_pop_art"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/soft_cap_pop_art, 32)

/obj/structure/sign/poster/official/safety_internals
	name = "Безопасность: Дыхательное Оборудование"
	desc = "Постер, инструктирующий зрителя носить дыхательное оборудование в редких средах, где нет кислорода или воздух стал токсичным."
	icon_state = "safety_internals"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/safety_internals, 32)

/obj/structure/sign/poster/official/safety_eye_protection
	name = "Безопасность: Защита Глаз"
	desc = "Постер, инструктирующий зрителя носить защиту для глаз при работе с химикатами, дымом или ярким светом."
	icon_state = "safety_eye_protection"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/safety_eye_protection, 32)

/obj/structure/sign/poster/official/safety_report
	name = "Безопасность: Сообщайте"
	desc = "Постер, призывающий зрителя сообщать о подозрительной деятельности службе безопасности."
	icon_state = "safety_report"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/safety_report, 32)

/obj/structure/sign/poster/official/report_crimes
	name = "Сообщайте о Преступлениях"
	desc = "Постер, поощряющий быстрое сообщение о преступлениях или мятежном поведении службе безопасности станции."
	icon_state = "report_crimes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/report_crimes, 32)

/obj/structure/sign/poster/official/ion_rifle
	name = "Ионная Винтовка"
	desc = "Постер с изображением ионной винтовки."
	icon_state = "ion_rifle"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ion_rifle, 32)

/obj/structure/sign/poster/official/foam_force_ad
	name = "Реклама Пенной Силы"
	desc = "Пенная Сила - пенись или будь вспенен!"
	icon_state = "foam_force_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/foam_force_ad, 32)

/obj/structure/sign/poster/official/cohiba_robusto_ad
	name = "Реклама Коиба Робусто"
	desc = "Коиба Робусто - элегантная сигара. Для настоящих робастеров."
	icon_state = "cohiba_robusto_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/cohiba_robusto_ad, 32)

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	name = "Винтажная Репродукция к 50-летию"
	desc = "Репродукция постера 2505 года, посвященная 50-летию Производства Нанопостеров, дочерней компании Нанотрейзен."
	icon_state = "anniversary_vintage_reprint"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/anniversary_vintage_reprint, 32)

/obj/structure/sign/poster/official/fruit_bowl
	name = "Фруктовая Чаша"
	desc = "Просто, но внушительно."
	icon_state = "fruit_bowl"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/fruit_bowl, 32)

/obj/structure/sign/poster/official/pda_ad
	name = "Реклама КПК"
	desc = "Постер, рекламирующий последнюю модель КПК от поставщиков Нанотрейзен."
	icon_state = "pda_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/pda_ad, 32)

/obj/structure/sign/poster/official/enlist
	name = "Вступайте" // но я думал, что отряд смерти никогда не признавали
	desc = "Возможно именно ТЫ станешь сотрудником ССО Нанотрейзен сегодня!"
	icon_state = "enlist"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/enlist, 32)

/obj/structure/sign/poster/official/nanomichi_ad
	name = "Реклама Нанокасет"
	desc = "Постер, рекламирующий аудиокассеты бренда Нанокасет."
	icon_state = "nanomichi_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/nanomichi_ad, 32)

/obj/structure/sign/poster/official/twelve_gauge
	name = "12 Калибр"
	desc = "Постер, восхваляющий превосходство патронов 12 калибра для дробовика. Ведь один морпех с Фобоса оказался в аду, но смог убить целый легион демонов, благодаря святой дроби."
	icon_state = "twelve_gauge"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/twelve_gauge, 32)

/obj/structure/sign/poster/official/high_class_martini
	name = "Мартини Высшего Класса"
	desc = "Я говорил взбалтывать, не размешивать."
	icon_state = "high_class_martini"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/high_class_martini, 32)

/obj/structure/sign/poster/official/the_owl
	name = "Сова"
	desc = "Сова сделает всё возможное, чтобы защитить станцию. А вы?"
	icon_state = "the_owl"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/the_owl, 32)

/obj/structure/sign/poster/official/no_erp
	name = "Нет ЕРП"
	desc = "Этот постер напоминает экипажу, что дела станции намного важнее, чем базовые потребности."
	icon_state = "no_erp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/no_erp, 32)

/obj/structure/sign/poster/official/wtf_is_co2
	name = "Диоксид Углерода"
	desc = "Этот информационный постер обучает зрителя тому, что такое диоксид углерода."
	icon_state = "wtf_is_co2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/wtf_is_co2, 32)

/obj/structure/sign/poster/official/dick_gum
	name = "Дик Гумшу"
	desc = "Постер, рекламирующий приключения Дика Гумшу, мышиного детектива. Призывает экипаж обрушить мощь правосудия на саботажников проводов."
	icon_state = "dick_gum"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/dick_gum, 32)

/obj/structure/sign/poster/official/there_is_no_gas_giant
	name = "Газового Гиганта Не Существует"
	desc = "Нанотрейзен распространила постеры, подобные этому, на все станции, напоминая, что слухи о газовом гиганте ложны."
	// И всё же люди продолжают верить...
	icon_state = "there_is_no_gas_giant"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/there_is_no_gas_giant, 32)

/obj/structure/sign/poster/official/periodic_table
	name = "Периодическая Таблица Элементов"
	desc = "Периодическая таблица элементов, от водорода до оганесона и всего промежуточного."
	icon_state = "periodic_table"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/periodic_table, 32)

/obj/structure/sign/poster/official/plasma_effects
	name = "Плазма и Тело"
	desc = "Этот информационный постер предоставляет информацию о воздействии длительного воздействия плазмы на мозг."
	icon_state = "plasma_effects"

/obj/structure/sign/poster/official/plasma_effects/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("Плазма (научное название Аментиум) классифицируется ТерраГруп как опасность для здоровья 1 класса и связана со значительными рисками для здоровья при хроническом воздействии.")]"
	. += "\t[span_info("Известно, что плазма преодолевает гематоэнцефалический барьер и накапливается в тканях мозга, где начинает вызывать ухудшение мозговых функций. Механизм воздействия до конца не изучен, поэтому конкретные профилактические рекомендации отсутствуют, за исключением надлежащего использования СИЗ (перчатки + защитный комбинезон + респиратор).")]"
	. += "\t[span_info("В малых дозах плазма вызывает спутанность сознания, кратковременную амнезию и повышенную агрессию. Эти эффекты сохраняются при постоянном воздействии.")]"
	. += "\t[span_info("У лиц с хроническим воздействием отмечены тяжелые эффекты: усиленная агрессия, долговременная амнезия, симптомы болезни Альцгеймера, шизофрения, дегенерация желтого пятна, аневризмы, повышенный риск инсульта и симптомы болезни Паркинсона.")]"
	. += "\t[span_info("Рекомендуется всем лицам, находящимся в незащищенном контакте с сырой плазмой, регулярно обращаться к медицинским специалистам компании.")]"
	. += "\t[span_info("Не курите! Это убивает не только вас, но и всех остальных, кто оказался с вами в одном помещении наполненным плазмой.")]"
	. += "\t[span_info("Нанотрейзен: Всегда заботимся о вашем здоровье.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/plasma_effects, 32)

/obj/structure/sign/poster/official/terragov
	name = "ТерраГруп: Единство ради Человечества"
	desc = "Постер с логотипом и девизом ТерраГруп, напоминающий зрителям, кто заботится о человечестве."
	icon_state = "terragov"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/terragov, 32)

/obj/structure/sign/poster/official/corporate_perks_vacation
	name = "Корпоративные Привилегии Нанотрейзен: Отпуск"
	desc = "Этот информационный постер предоставляет информацию о некоторых призах программы НТ Корпоративные Привилегии, включая двухнедельный отпуск для двоих на курортном мире Идиллус."
	icon_state = "corporate_perks_vacation"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/corporate_perks_vacation, 32)

/obj/structure/sign/poster/official/jim_nortons
	name = "Квебекский Кофе Джима Нортона"
	desc = "Реклама Джима Нортона, квебекской кофейни, покорившей галактику."
	icon_state = "jim_nortons"

/obj/structure/sign/poster/official/jim_nortons/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>Вы просматриваете некоторую информацию с постера...</i>")
	. += "\t[span_info("С наших корней в Труа-Ривьере мы с 1965 года работаем над тем, чтобы предложить вам лучший кофе, который можно купить за деньги.")]"
	. += "\t[span_info("Так что зайдите сегодня к Джиму - выпейте чашку горячего кофе с пончиком и поживите так, как живут квебекцы.")]"
	. += "\t[span_info("Квебекский Кофе Джима Нортона: Toujours Le Bienvenu (Всегда Добро Пожаловать).")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/jim_nortons, 32)

/obj/structure/sign/poster/official/twenty_four_seven
	name = "Супермаркеты 24-Семь"
	desc = "Реклама супермаркетов 24-Семь, рекламирующая их новые 24-Стопы в рамках партнерства с Нанотрейзен."
	icon_state = "twenty_four_seven"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/twenty_four_seven, 32)

/obj/structure/sign/poster/official/tactical_game_cards
	name = "Тактические Игровые Карты Нанотрейзен"
	desc = "Реклама коллекционных карточных игр Нанотрейзен: ПОКУПАЙТЕ БОЛЬШЕ КАРТ."
	icon_state = "tactical_game_cards"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/tactical_game_cards, 32)

/obj/structure/sign/poster/official/midtown_slice
	name = "Пицца Кусочек Мидтауна"
	desc = "Реклама пиццы Кусочек Мидтауна, официального пиццерии-партнера Нанотрейзен. Кусочек Мидтауна: как кусочек дома, где бы вы ни были."
	icon_state = "midtown_slice"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/midtown_slice, 32)

//SafetyMoth Оригинальный PR на https://github.com/BeeStation/BeeStation-Hornet/pull/1747 (Также pull/1982)
//Авторство SafetyMoth принадлежит AspEv
/obj/structure/sign/poster/official/moth_hardhat
	name = "Моль Безопасности - Каски"
	desc = "Этот информационный постер использует Моль Безопасности™, чтобы сказать зрителю носить каски в опасных зонах. \"Это как лампа для вашей головы!\""
	icon_state = "aspev_hardhat"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_hardhat, 32)

/obj/structure/sign/poster/official/moth_piping
	name = "Моль Безопасности - Трубопроводы"
	desc = "Этот информационный постер использует Моль Безопасности™, чтобы рассказать атмосферным техникам о правильных типах трубопроводов. \"Трубы, а не насосы! Правильная прокладка труб предотвращает плохую производительность!\""
	icon_state = "aspev_piping"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_piping, 32)

/obj/structure/sign/poster/official/moth_meth
	name = "Моль Безопасности - Метамфетамин"
	desc = "Этот информационный постер использует Моль Безопасности™, чтобы сказать зрителю получить одобрение ГВ перед приготовлением метамфетамина. \"Держитесь близко к номинальной температуре и никогда не превышайте её!\" ...Вам никогда не следует это готовить."
	icon_state = "aspev_meth"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_meth, 32)

/obj/structure/sign/poster/official/moth_epi
	name = "Моль Безопасности - Эпинефрин"
	desc = "Этот информационный постер использует Моль Безопасности™, чтобы проинформировать зрителя о помощи раненым/умершим членам экипажа с помощью инъекторов эпинефрина. \"Предотвратите гниение органов этим простым трюком!\""
	icon_state = "aspev_epi"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_epi, 32)

/obj/structure/sign/poster/official/moth_delam
	name = "Моль Безопасности - Меры Предосторожности при Деламинации"
	desc = "Этот информационный постер использует Моль Безопасности™, чтобы сказать зрителю прятаться в шкафчиках при деламинации Кристалла Суперматерии, чтобы предотвратить галлюцинации. Эвакуация может быть лучшей стратегией."
	icon_state = "aspev_delam"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_delam, 32)

//Конец постеров от AspEv

/obj/structure/sign/poster/fluff/lizards_gas_payment
	name = "Пожалуйста, Платите"
	desc = "Грубо сделанный постер, просящий читателя оплатить любые предметы, которые они хотели бы взять с собой со станции."
	icon_state = "gas_payment"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/fluff/lizards_gas_payment, 32)

/obj/structure/sign/poster/fluff/lizards_gas_power
	name = "Экономьте Энергию"
	desc = "Грубо сделанный постер, просящий читателя выключить питание перед уходом. Надеемся, оно будет включено для их повторного открытия."
	icon_state = "gas_power"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/fluff/lizards_gas_power, 32)

/obj/structure/sign/poster/official/festive
	name = "Праздничный Информационный Постер"
	desc = "Постер, информирующий о активных праздниках. Сегодня их нет, так что вам следует вернуться к работе."
	icon_state = "holiday_none"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/festive, 32)

/obj/structure/sign/poster/official/boombox
	name = "Бумбокс"
	desc = "Устаревший постер, содержащий список предполагаемых 'слов-убийц' и кодовых фраз. Постер утверждает, что конкурирующие корпорации используют их для дистанционного отключения своих агентов."
	icon_state = "boombox"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/boombox, 32)

/obj/structure/sign/poster/official/download
	name = "Вы Не Стали бы Скачивать Пистолет"
	desc = "Постер, напоминающий экипажу, что корпоративные секреты должны оставаться на рабочем месте."
	icon_state = "download_gun"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/download, 32)
