/obj/machinery/vending/games
	name = "Чистое Веселье"
	desc = "Продаёт вещи, которые Капитану и Главе Персонала вряд ли понравится, если вы будете возиться с ними вместо работы..."
	product_ads = "Сбеги в мир фэнтези!;Подпиши свою gambling addiction!;Разрушь дружбу!;Кидай на инициативу!;Эльфы и дварфы!;Параноидальные компьютеры!;Точно не сатанинское!;Вечное веселье!"
	icon_state = "games"
	panel_type = "panel4"
	product_categories = list(
		list(
			"name" = "Карты",
			"icon" = "diamond",
			"products" = list(
				/obj/item/toy/cards/deck = 5,
				/obj/item/toy/cards/deck/blank = 3,
				/obj/item/toy/cards/deck/blank/black = 3,
				/obj/item/toy/cards/deck/cas = 3,
				/obj/item/toy/cards/deck/cas/black = 3,
				/obj/item/toy/cards/deck/kotahi = 3,
				/obj/item/toy/cards/deck/tarot = 3,
				/obj/item/toy/cards/deck/wizoff = 3,
			),
		),
		list(
			"name" = "Игрушки",
			"icon" = "hat-wizard",
			"products" = list(
				/obj/item/toy/captainsaid = 1,
				/obj/item/toy/intento = 3,
				/obj/item/storage/box/tail_pin = 1,
			),
		),
		list(
			"name" = "Искусство",
			"icon" = "palette",
			"products" = list(
				/obj/item/storage/crayons = 2,
				/obj/item/chisel = 3,
				/obj/item/paint_palette = 3,
				/obj/item/canvas/nineteen_nineteen = 5,
				/obj/item/canvas/twentythree_nineteen = 5,
				/obj/item/canvas/twentythree_twentythree = 5,
				/obj/item/canvas/twentyfour_twentyfour = 5,
				/obj/item/canvas/thirtysix_twentyfour = 3,
				/obj/item/canvas/fortyfive_twentyseven = 3,
				/obj/item/wallframe/painting/large = 5,
				/obj/item/stack/pipe_cleaner_coil/random = 10,
			),
		),
		list(
			"name" = "Рыбалка",
			"icon" = "fish",
			"products" = list(
				/obj/item/storage/toolbox/fishing = 2,
				/obj/item/storage/box/fishing_hooks = 2,
				/obj/item/storage/box/fishing_lines = 2,
				/obj/item/storage/box/fishing_lures = 2,
				/obj/item/book/manual/fish_catalog = 5,
				/obj/item/reagent_containers/cup/fish_feed = 4,
				/obj/item/storage/box/aquarium_props = 4,
				/obj/item/fish_analyzer = 2,
				/obj/item/storage/bag/fishing = 2,
				/obj/item/fishing_rod/telescopic = 1,
				/obj/item/fish_tank = 1,
			),
		),
		list(
			"name" = "Скиллчипы",
			"icon" = "floppy-disk",
			"products" = list(
				/obj/item/skillchip/appraiser = 2,
				/obj/item/skillchip/basketweaving = 2,
				/obj/item/skillchip/bonsai = 2,
				/obj/item/skillchip/intj = 2,
				/obj/item/skillchip/light_remover = 2,
				/obj/item/skillchip/master_angler = 2,
				/obj/item/skillchip/sabrage = 2,
				/obj/item/skillchip/useless_adapter = 5,
				/obj/item/skillchip/wine_taster = 2,
				/obj/item/skillchip/big_pointer = 2,
			),
		),
		list(
			"name" = "Другое",
			"icon" = "star",
			"products" = list(
				/obj/item/camera = 3,
				/obj/item/camera_film = 5,
				/obj/item/cardpack/resin = 20, //Обе колоды карт увеличены до 20 вместо 10 до внедрения сохранения карт.
				/obj/item/cardpack/series_one = 20,
				/obj/item/dyespray = 3,
				/obj/item/hourglass = 2,
				/obj/item/instrument/piano_synth/headphones = 4,
				/obj/item/razor = 3,
				/obj/item/storage/card_binder = 10,
				/obj/item/storage/dice = 10,
			),
		),
	)
	contraband = list(
		/obj/item/dice/fudge = 9,
		/obj/item/clothing/shoes/wheelys/skishoes = 4,
		/obj/item/instrument/musicalmoth = 1,
		/obj/item/gun/ballistic/revolver/russian = 1, //самая опасная игра
		/obj/item/skillchip/acrobatics = 1,
	)
	premium = list(
		/obj/item/disk/holodisk = 5,
		/obj/item/rcl = 2,
		/obj/item/airlock_painter = 1,
		/obj/item/clothing/shoes/wheelys/rollerskates= 3,
		/obj/item/melee/skateboard/pro = 3,
		/obj/item/melee/skateboard/hoverboard = 1,
	)
	refill_canister = /obj/item/vending_refill/games
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND * 1.25
	payment_department = ACCOUNT_SRV
	light_mask = "games-light-mask"
	allow_custom = TRUE

/obj/item/vending_refill/games
	machine_name = "Чистое Веселье"
	icon_state = "refill_games"
