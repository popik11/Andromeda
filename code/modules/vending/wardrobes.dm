GLOBAL_VAR_INIT(roaches_deployed, FALSE)
#define MOTHROACH_START_CHANCE 5
#define MAX_MOTHROACH_AMOUNT 3

/obj/item/vending_refill/wardrobe
	icon_state = "refill_clothes"

/obj/machinery/vending/wardrobe
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES
	panel_type = "panel19"
	light_mask = "wardrobe-light-mask"

/obj/machinery/vending/wardrobe/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	if(GLOB.roaches_deployed || !is_station_level(z) || !prob(MOTHROACH_START_CHANCE))
		return
	for(var/count in 1 to rand(1, MAX_MOTHROACH_AMOUNT))
		new /mob/living/basic/mothroach(src)
	GLOB.roaches_deployed = TRUE


/obj/machinery/vending/wardrobe/on_dispense(obj/item/clothing/food, dispense_returned = FALSE)
	if(!istype(food))
		return
	for(var/mob/living/basic/mothroach/roach in contents)
		// Be slightly nicer on returned items
		var/damage_mult = dispense_returned ? 0.1 : 0.5
		food.take_damage(food.get_integrity() * damage_mult)

/obj/machinery/vending/wardrobe/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	for(var/mob/living/basic/mothroach/roach in contents)
		roach.ai_controller.set_blackboard_key(BB_BASIC_MOB_FLEE_TARGET, src) //scatter away!
		roach.forceMove(drop_location())

/obj/machinery/vending/wardrobe/sec_wardrobe
	name = "Офицерский Стиль"
	desc = "Торговый автомат для офицеров и связанной с офицерской одежды!"
	icon_state = "secdrobe"
	product_ads = "Бей преступников со стилем!;Он красный, так что кровь не видно!;Вы имеете право быть модным!;Теперь вы можете быть модной полицией, которой всегда хотели быть!"
	vend_reply = "Спасибо за использование СекДроб!"
	products = list(
		/obj/item/clothing/head/beret/sec = 3,
		/obj/item/clothing/head/soft/sec = 3,
		/obj/item/clothing/mask/bandana/striped/security = 3,
		/obj/item/clothing/under/rank/security/officer = 3,
		/obj/item/clothing/under/rank/security/officer/skirt = 3,
		/obj/item/clothing/under/rank/security/officer/grey = 3,
		/obj/item/clothing/under/pants/slacks = 3,
		/obj/item/clothing/under/rank/security/officer/blueshirt = 3,
		/obj/item/clothing/gloves/color/black/security/blu = 3,
		/obj/item/clothing/suit/armor/vest/secjacket = 3,
		/obj/item/clothing/suit/hooded/wintercoat/security = 3,
		/obj/item/clothing/suit/armor/vest = 3,
		/obj/item/clothing/gloves/color/black/security = 3,
		/obj/item/clothing/shoes/jackboots/sec = 3,
		/obj/item/storage/backpack/security = 3,
		/obj/item/storage/backpack/satchel/sec = 3,
		/obj/item/storage/backpack/duffelbag/sec = 3,
		/obj/item/storage/backpack/messenger/sec = 3,
	)
	premium = list(
		/obj/item/clothing/under/rank/security/officer/formal = 3,
		/obj/item/clothing/suit/jacket/officer/blue = 3,
		/obj/item/clothing/head/beret/sec/navyofficer = 3,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/sec_wardrobe
	payment_department = ACCOUNT_SEC
	light_color = COLOR_MOSTLY_PURE_RED
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/sec_wardrobe
	machine_name = "Офицерский Стиль"

/obj/machinery/vending/wardrobe/medi_wardrobe
	name = "Доктор Стиль"
	desc = "Торговый автомат, который, по слухам, способен выдавать одежду для медицинского персонала."
	icon_state = "medidrobe"
	product_ads = "Сделай эти кровавые пятна модными!!"
	vend_reply = "Спасибо за использование Доктор Стиль!"
	products = list(
		/obj/item/clothing/accessory/pocketprotector = 4,
		/obj/item/clothing/head/costume/nursehat = 4,
		/obj/item/clothing/head/beret/medical = 4,
		/obj/item/clothing/head/utility/surgerycap = 4,
		/obj/item/clothing/head/utility/surgerycap/purple = 4,
		/obj/item/clothing/head/utility/surgerycap/green = 4,
		/obj/item/clothing/head/beret/medical/paramedic = 4,
		/obj/item/clothing/head/soft/paramedic = 4,
		/obj/item/clothing/head/utility/head_mirror = 4,
		/obj/item/clothing/mask/bandana/striped/medical = 4,
		/obj/item/clothing/mask/surgical = 4,
		/obj/item/clothing/under/rank/medical/doctor = 4,
		/obj/item/clothing/under/rank/medical/doctor/skirt = 4,
		/obj/item/clothing/under/rank/medical/scrubs/blue = 4,
		/obj/item/clothing/under/rank/medical/scrubs/green = 4,
		/obj/item/clothing/under/rank/medical/scrubs/purple = 4,
		/obj/item/clothing/under/rank/medical/paramedic = 4,
		/obj/item/clothing/under/rank/medical/paramedic/skirt = 4,
		/obj/item/clothing/suit/toggle/labcoat = 4,
		/obj/item/clothing/suit/toggle/labcoat/paramedic = 4,
		/obj/item/clothing/suit/apron/surgical = 4,
		/obj/item/clothing/suit/hooded/wintercoat/medical = 4,
		/obj/item/clothing/suit/hooded/wintercoat/medical/paramedic = 4,
		/obj/item/clothing/shoes/sneakers/white = 4,
		/obj/item/clothing/shoes/sneakers/blue = 4,
		/obj/item/clothing/gloves/latex/nitrile = 4,
		/obj/item/clothing/gloves/latex = 4,
		/obj/item/storage/backpack/duffelbag/med = 4,
		/obj/item/storage/backpack/medic = 4,
		/obj/item/storage/backpack/satchel/med = 4,
		/obj/item/storage/backpack/messenger/med = 4,
		/obj/item/radio/headset/headset_med = 4,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/medi_wardrobe
	payment_department = ACCOUNT_MED
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/medi_wardrobe
	machine_name = "Доктор Стиль"

/obj/machinery/vending/wardrobe/engi_wardrobe
	name = "Технарь Стиль"
	desc = "Торговый автомат, известный продажей производственной одежды."
	icon_state = "engidrobe"
	product_ads = "Гарантированно защитит ваши ноги от промышленных травм!;Боитесь радиации? Тогда носите жёлтое!"
	vend_reply = "Спасибо за использование Технарь Стиль!"
	products = list(
		/obj/item/clothing/accessory/pocketprotector = 3,
		/obj/item/clothing/head/utility/hardhat = 3,
		/obj/item/clothing/head/utility/hardhat/welding = 3,
		/obj/item/clothing/head/beret/engi = 3,
		/obj/item/clothing/mask/bandana/striped/engineering = 3,
		/obj/item/clothing/under/rank/engineering/engineer = 3,
		/obj/item/clothing/under/rank/engineering/engineer/skirt = 3,
		/obj/item/clothing/under/rank/engineering/engineer/hazard = 3,
		/obj/item/clothing/suit/hazardvest = 3,
		/obj/item/clothing/suit/hooded/wintercoat/engineering = 3,
		/obj/item/clothing/shoes/workboots = 3,
		/obj/item/storage/backpack/industrial = 3,
		/obj/item/storage/backpack/satchel/eng = 3,
		/obj/item/storage/backpack/duffelbag/engineering = 3,
		/obj/item/storage/backpack/messenger/eng = 3,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/engi_wardrobe
	payment_department = ACCOUNT_ENG
	light_color = COLOR_VIVID_YELLOW
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/engi_wardrobe
	machine_name = "Технарь Стиль"

/obj/machinery/vending/wardrobe/atmos_wardrobe
	name = "Атмос Стиль"
	desc = "Этот относительно неизвестный торговый автомат выдаёт одежду для Атмосферных Техников, столь же неизвестной профессии."
	icon_state = "atmosdrobe"
	product_slogans = "Получите свою огнестойкую одежду прямо здесь!!!"
	vend_reply = "Спасибо за использование Атмос Стиль!"
	products = list(
		/obj/item/clothing/accessory/pocketprotector = 3,
		/obj/item/clothing/under/rank/engineering/atmospheric_technician = 3,
		/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt = 3,
		/obj/item/clothing/suit/atmos_overalls = 3,
		/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 3,
		/obj/item/clothing/shoes/sneakers/black = 3,
		/obj/item/storage/backpack/satchel/eng = 3,
		/obj/item/storage/backpack/industrial = 3,
		/obj/item/storage/backpack/duffelbag/engineering = 3,
		/obj/item/storage/backpack/messenger/eng = 3,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/atmos_wardrobe
	payment_department = ACCOUNT_ENG
	light_color = COLOR_VIVID_YELLOW
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/atmos_wardrobe
	machine_name = "Атмос Стиль"

/obj/machinery/vending/wardrobe/cargo_wardrobe
	name = "Карго Стиль"
	desc = "Высокотехнологичный торговый автомат, позволяющий бесплатно купить одежду, связанную с карго."
	icon_state = "cargodrobe"
	product_ads = "Улучшенный стиль помощника! Выбери свой сегодня!;Эти шорты удобные и легко носятся, получи свои сейчас!"
	vend_reply = "Спасибо за использование Карго Стиль!"
	products = list(
		/obj/item/clothing/head/beret/cargo = 3,
		/obj/item/clothing/mask/bandana/striped/cargo = 3,
		/obj/item/clothing/head/soft = 3,
		/obj/item/clothing/head/utility/hardhat/orange = 3,
		/obj/item/clothing/under/rank/cargo/tech = 3,
		/obj/item/clothing/under/rank/cargo/tech/skirt = 3,
		/obj/item/clothing/under/rank/cargo/tech/alt = 3,
		/obj/item/clothing/under/rank/cargo/tech/skirt/alt = 3,
		/obj/item/clothing/suit/toggle/cargo_tech = 3,
		/obj/item/clothing/suit/hooded/wintercoat/cargo = 3,
		/obj/item/clothing/suit/hazardvest = 3,
		/obj/item/clothing/gloves/fingerless = 3,
		/obj/item/clothing/shoes/sneakers/black = 3,
		/obj/item/storage/backpack = 3,
		/obj/item/storage/backpack/satchel = 3,
		/obj/item/storage/backpack/satchel/leather = 3,
		/obj/item/storage/backpack/duffelbag = 3,
		/obj/item/storage/backpack/messenger = 3,
		/obj/item/radio/headset/headset_cargo = 3,
		/obj/item/clothing/accessory/pocketprotector = 3,
	)
	premium = list(
		/obj/item/storage/bag/mail = 3,
		/obj/item/clothing/head/costume/mailman = 1,
		/obj/item/clothing/under/misc/mailman = 1,
		/obj/item/flatpack/mailsorter = 1,
		/obj/item/clothing/under/rank/cargo/miner = 3,
		/obj/item/clothing/under/rank/cargo/miner/lavaland = 3,
		/obj/item/clothing/under/rank/cargo/bitrunner = 3,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/cargo_wardrobe
	payment_department = ACCOUNT_CAR
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/cargo_wardrobe
	machine_name = "Карго Стиль"

/obj/machinery/vending/wardrobe/robo_wardrobe
	name = "Робо Стиль"
	desc = "Торговый автомат, предназначенный для выдачи одежды, известный только робототехникам."
	icon_state = "robodrobe"
	product_ads = "Ты делаешь меня TRUE, используй определения!;0110001101101100011011110111010001101000011001010111001101101000011001010111001001100101"
	vend_reply = "Спасибо за использование Робо Стиль!"
	products = list(
		/obj/item/clothing/glasses/hud/diagnostic = 2,
		/obj/item/clothing/head/soft/black = 2,
		/obj/item/clothing/mask/bandana/skull/black = 2,
		/obj/item/clothing/under/rank/rnd/roboticist = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/skirt = 2,
		/obj/item/clothing/suit/toggle/labcoat/roboticist = 2,
		/obj/item/clothing/suit/hooded/wintercoat/science/robotics = 2,
		/obj/item/clothing/gloves/fingerless = 2,
		/obj/item/clothing/shoes/sneakers/black = 2,
		/obj/item/storage/backpack/science = 3,
		/obj/item/storage/backpack/satchel/science = 3,
		/obj/item/storage/backpack/duffelbag/science = 3,
		/obj/item/storage/backpack/messenger/science = 3,
		/obj/item/radio/headset/headset_sci = 2,
	)
	contraband = list(
		/obj/item/clothing/under/costume/mech_suit = 2,
		/obj/item/clothing/suit/hooded/techpriest = 2,
		/obj/item/organ/tongue/robot = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/robo_wardrobe
	extra_price = PAYCHECK_COMMAND * 1.2
	payment_department = ACCOUNT_SCI
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/robo_wardrobe
	machine_name = "Робо Стиль"

/obj/machinery/vending/scidrobe
	name = "Научный Стиль"
	desc = "Простая торговая машина, подходящая для выдачи хорошо скроенной научной одежды. Одобрено Космическими Кубинцами."
	icon_state = "scidrobe"
	product_ads = "Томление по запаху плазменной опалённой плоти? Покупайте нашу научную одежду сейчас!;Сделано с 10% ауксетиков, так что вам не придётся беспокоиться о потере руки!"
	vend_reply = "Спасибо за использование Научный Стиль!"
	products = list(
		/obj/item/clothing/accessory/pocketprotector = 3,
		/obj/item/clothing/head/beret/science = 3,
		/obj/item/clothing/mask/gas = 3,
		/obj/item/clothing/mask/bandana/striped/science = 3,
		/obj/item/clothing/under/rank/rnd/scientist = 3,
		/obj/item/clothing/under/rank/rnd/scientist/skirt = 3,
		/obj/item/clothing/suit/toggle/labcoat/science = 3,
		/obj/item/clothing/suit/hooded/wintercoat/science = 3,
		/obj/item/clothing/gloves/latex = 3,
		/obj/item/clothing/shoes/sneakers/white = 3,
		/obj/item/storage/backpack/science = 3,
		/obj/item/storage/backpack/satchel/science = 3,
		/obj/item/storage/backpack/duffelbag/science = 3,
		/obj/item/storage/backpack/messenger/science = 3,
		/obj/item/radio/headset/headset_sci = 3,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/science_wardrobe
	payment_department = ACCOUNT_SCI
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/science_wardrobe
	machine_name = "Научный Стиль"

/obj/machinery/vending/wardrobe/hydro_wardrobe
	name = "Агроном Стиль"
	desc = "Машина с запоминающимся названием. Выдаёт одежду и снаряжение, связанное с ботаникой."
	icon_state = "hydrobe"
	product_ads = "Вы любите почву? Тогда покупайте нашу одежду!;Получите комплекты одежды, подходящие для ваших зелёных пальцев, здесь!"
	vend_reply = "Спасибо за использование Агроном Стиль!"
	products = list(
		/obj/item/clothing/accessory/armband/hydro = 3,
		/obj/item/clothing/mask/bandana/striped/botany = 3,
		/obj/item/clothing/under/rank/civilian/hydroponics = 3,
		/obj/item/clothing/under/rank/civilian/hydroponics/skirt = 3,
		/obj/item/clothing/suit/apron = 3,
		/obj/item/clothing/suit/apron/overalls = 3,
		/obj/item/clothing/suit/apron/waders = 3,
		/obj/item/clothing/suit/hooded/wintercoat/hydro = 3,
		/obj/item/storage/backpack/botany = 3,
		/obj/item/storage/backpack/satchel/hyd = 3,
		/obj/item/storage/backpack/duffelbag/hydroponics = 3,
		/obj/item/storage/backpack/messenger/hyd = 3,
		/obj/item/radio/headset/headset_srv = 3,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/hydro_wardrobe
	payment_department = ACCOUNT_SRV
	light_color = LIGHT_COLOR_ELECTRIC_GREEN
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/hydro_wardrobe
	machine_name = "Агроном Стиль"

/obj/machinery/vending/wardrobe/curator_wardrobe
	name = "Чтивый Стиль"
	desc = "Торговый автомат со скудным ассортиментом, способный продавать только одежду для кураторов и библиотекарей."
	icon_state = "curadrobe"
	product_slogans = "Очки для ваших глаз и литература для вашей души, у Чтивый Стиль есть всё!; Впечатлите и очаруйте гостей вашей библиотеки расширенной линейкой ручек от Чтивый Стиль!"
	vend_reply = "Спасибо за использование Чтивый Стиль!"
	products = list(
		/obj/item/clothing/accessory/pocketprotector = 2,
		/obj/item/pen = 4,
		/obj/item/pen/red = 2,
		/obj/item/pen/blue = 2,
		/obj/item/pen/fourcolor = 1,
		/obj/item/pen/fountain = 2,
		/obj/item/clothing/glasses/regular = 2,
		/obj/item/clothing/glasses/regular/jamjar = 1,
		/obj/item/clothing/under/rank/civilian/curator = 1,
		/obj/item/clothing/under/rank/civilian/curator/skirt = 1,
		/obj/item/clothing/under/rank/captain/suit = 1,
		/obj/item/clothing/under/rank/captain/suit/skirt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/suit = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt = 1,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 1,
		/obj/item/storage/backpack/satchel/explorer = 1,
		/obj/item/storage/backpack/messenger/explorer = 1,
		/obj/item/storage/bag/books = 1,
		/obj/item/radio/headset/headset_srvent = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/curator_wardrobe
	payment_department = ACCOUNT_SRV
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/curator_wardrobe
	machine_name = "Чтивый Стиль"

/obj/machinery/vending/wardrobe/coroner_wardrobe
	name = "Некро Стиль"
	desc = "Любимица нигилистов."
	icon_state = "coroner_drobe"
	product_ads = "Любой день на земле — хороший день!;Мой день начинается, когда ваш заканчивается!;И они называют это умирающим бизнесом!;Увидимся, когда ты умрёшь!"
	vend_reply = "Не забудьте нашу акцию \"Купи один — получи второй по цене захоронения бесплатно\"!"
	products = list(
		/obj/item/clothing/head/utility/surgerycap/black = 1,
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/clothing/suit/apron/surgical = 1,
		/obj/item/clothing/suit/hooded/wintercoat/medical/coroner = 1,
		/obj/item/clothing/suit/toggle/labcoat/coroner = 1,
		/obj/item/clothing/under/rank/medical/coroner = 1,
		/obj/item/clothing/under/rank/medical/coroner/skirt = 1,
		/obj/item/clothing/under/rank/medical/scrubs/coroner = 1,
		/obj/item/clothing/shoes/sneakers/black = 1,
		/obj/item/clothing/gloves/latex/coroner = 1,
		/obj/item/cautery/cruel = 1,
		/obj/item/hemostat/cruel = 1,
		/obj/item/retractor/cruel = 1,
		/obj/item/scalpel/cruel = 1,
		/obj/item/surgicaldrill/cruel = 1,
		/obj/item/circular_saw/cruel = 1,
		/obj/item/bonesetter/cruel = 1,
		/obj/item/blood_filter/cruel = 1,
		/obj/item/storage/backpack/coroner = 1,
		/obj/item/storage/backpack/duffelbag/coroner = 1,
		/obj/item/storage/backpack/messenger/coroner = 1,
		/obj/item/storage/backpack/satchel/coroner = 1,
		/obj/item/storage/box/bodybags = 3,
		/obj/item/radio/headset/headset_srvmed = 2,
		/obj/item/toy/crayon/white = 2,
	)
	contraband = list(
		/obj/item/knife/ritual = 1,
		/obj/item/scythe = 1,
		/obj/item/storage/fancy/pickles_jar = 1,
		/obj/item/table_clock = 1,
	)
	premium = list(
		/obj/item/autopsy_scanner = 1,
		/obj/item/storage/medkit/coroner = 1,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/coroner_wardrobe
	payment_department = ACCOUNT_MED
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/coroner_wardrobe
	machine_name = "Некро Стиль"

/obj/machinery/vending/wardrobe/bar_wardrobe
	name = "Барный Стиль"
	desc = "Стильный торговый автомат для выдачи самой стильной барной одежды!"
	icon_state = "bardrobe"
	product_ads = "Гарантированно защищает от пятен от пролитых напитков!"
	vend_reply = "Спасибо за использование Барный Стиль!"
	products = list(
		/obj/item/clothing/glasses/sunglasses/reagent = 1,
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/clothing/head/hats/tophat = 2,
		/obj/item/clothing/head/soft/black = 2,
		/obj/item/clothing/neck/petcollar = 1,
		/obj/item/clothing/neck/bowtie = 2,
		/obj/item/clothing/under/costume/buttondown/slacks/service = 2,
		/obj/item/clothing/under/costume/buttondown/skirt/service = 2,
		/obj/item/clothing/under/rank/civilian/purple_bartender = 2,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 1,
		/obj/item/clothing/suit/armor/vest/alt = 1,
		/obj/item/clothing/shoes/sneakers/black = 2,
		/obj/item/storage/belt/bandolier = 1,
		/obj/item/storage/bag/money = 2,
		/obj/item/storage/dice/hazard = 1,
		/obj/item/storage/box/beanbag = 1,
		/obj/item/circuitboard/machine/dish_drive = 1,
		/obj/item/rag = 2,
		/obj/item/radio/headset/headset_srv = 2,
	)
	premium = list(
		/obj/item/storage/box/dishdrive = 1,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/bar_wardrobe
	payment_department = ACCOUNT_MED
	extra_price = PAYCHECK_COMMAND
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/bar_wardrobe
	machine_name = "Барный Стиль"

/obj/machinery/vending/wardrobe/chef_wardrobe
	name = "Мишлен Стиль"
	desc = "Этот торговый автомат может и не выдаёт мясо, но он точно выдаёт одежду для поваров."
	icon_state = "chefdrobe"
	product_ads = "Наша одежда гарантированно защитит вас от брызг еды!"
	vend_reply = "Спасибо за использование Мишлен Стиль!"
	products = list(
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/clothing/head/soft/mime = 2,
		/obj/item/clothing/head/utility/chefhat = 2,
		/obj/item/clothing/under/costume/buttondown/slacks/service = 2,
		/obj/item/clothing/under/costume/buttondown/skirt/service = 2,
		/obj/item/clothing/under/rank/civilian/cookjorts = 2,
		/obj/item/clothing/under/suit/waiter = 2,
		/obj/item/clothing/suit/apron/chef = 2,
		/obj/item/clothing/suit/toggle/chef = 2,
		/obj/item/clothing/suit/hooded/wintercoat = 2,
		/obj/item/clothing/shoes/cookflops = 2,
		/obj/item/clothing/shoes/sneakers/black = 2,
		/obj/item/storage/box/mousetraps = 2,
		/obj/item/circuitboard/machine/dish_drive = 1,
		/obj/item/rag = 2,
		/obj/item/radio/headset/headset_srv = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/chef_wardrobe
	payment_department = ACCOUNT_SRV
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/chef_wardrobe
	machine_name = "Мишлен Стиль"

/obj/machinery/vending/wardrobe/jani_wardrobe
	name = "Чистый Стиль"
	desc = "Самомоющаяся торговая машина, способная выдавать одежду для уборщиков."
	icon_state = "janidrobe"
	product_ads = "Приходите и заберите свою уборочную одежду, одобренную ящеро-уборщиками по всей вселенной!"
	vend_reply = "Спасибо за использование Чистый Стиль!"
	products = list(
		/obj/item/clothing/head/soft/purple = 2,
		/obj/item/clothing/mask/bandana/purple = 2,
		/obj/item/clothing/under/rank/civilian/janitor = 2,
		/obj/item/clothing/under/rank/civilian/janitor/skirt = 2,
		/obj/item/clothing/suit/hooded/wintercoat/janitor = 2,
		/obj/item/clothing/shoes/sneakers/black = 2,
		/obj/item/clothing/gloves/color/black = 2,
		/obj/item/clothing/shoes/galoshes = 2,
		/obj/item/storage/belt/janitor = 2,
		/obj/item/watertank/janitor = 1,
		/obj/item/flashlight = 2,
		/obj/item/pushbroom = 2,
		/obj/item/paint/paint_remover = 2,
		/obj/item/melee/flyswatter = 2,
		/obj/item/clothing/suit/caution = 6,
		/obj/item/holosign_creator = 2,
		/obj/item/lightreplacer = 2,
		/obj/item/soap/nanotrasen = 2,
		/obj/item/storage/bag/trash = 2,
		/obj/item/plunger = 2,
		/obj/item/wirebrush = 2,
		/obj/item/radio/headset/headset_srv = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/jani_wardrobe
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND * 0.8
	payment_department = ACCOUNT_SRV
	light_color = COLOR_STRONG_MAGENTA
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/jani_wardrobe
	machine_name = "Чистый Стиль"

/obj/machinery/vending/wardrobe/law_wardrobe
	name = "Справедливый Стиль"
	desc = "Возражение! Этот гардероб выдаёт верховенство закона... и одежду для адвокатов."
	icon_state = "lawdrobe"
	product_ads = "ПРОТЕСТУЮ! Получите верховенство закона для себя!"
	vend_reply = "Спасибо за использование Справедливый Стиль!"
	products = list(
		/obj/item/clothing/accessory/lawyers_badge = 2,
		/obj/item/clothing/neck/tie = 3,
		/obj/item/clothing/under/rank/civilian/lawyer/bluesuit = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt = 1,
		/obj/item/clothing/suit/toggle/lawyer = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/purpsuit = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt = 1,
		/obj/item/clothing/suit/toggle/lawyer/purple = 1,
		/obj/item/clothing/under/costume/buttondown/slacks/service = 1,
		/obj/item/clothing/under/costume/buttondown/skirt/service = 1,
		/obj/item/clothing/suit/toggle/lawyer/black = 1,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 1,
		/obj/item/clothing/under/suit/black = 1,
		/obj/item/clothing/under/suit/black/skirt = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/beige = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/beige/skirt = 1,
		/obj/item/clothing/under/suit/black_really = 1,
		/obj/item/clothing/under/suit/black_really/skirt = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/blue = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/red = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/red/skirt = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/black = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/black/skirt = 1,
		/obj/item/clothing/shoes/laceup = 2,
		/obj/item/radio/headset/headset_srv = 2,
		/obj/item/storage/box/evidence = 2,
		/obj/item/reagent_containers/cup/fish_feed = 1,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/law_wardrobe
	payment_department = ACCOUNT_SRV
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/law_wardrobe
	machine_name = "Справедливый Стиль"

/obj/machinery/vending/wardrobe/chap_wardrobe
	name = "Святой Стиль"
	desc = "Бог желает вашей покупки."
	icon_state = "chapdrobe"
	product_ads = "Вас беспокоят культисты или надоедливые ревенанты? Тогда приходите и оденьтесь как святой человек!;Одежда для служителей и культа!"
	vend_reply = "Спасибо за использование Святой Стиль!"
	products = list(
		/obj/item/choice_beacon/holy = 1,
		/obj/item/clothing/accessory/pocketprotector/cosmetology = 1,
		/obj/item/clothing/under/rank/civilian/chaplain = 1,
		/obj/item/clothing/under/rank/civilian/chaplain/skirt = 2,
		/obj/item/clothing/shoes/sneakers/black = 1,
		/obj/item/clothing/suit/chaplainsuit/nun = 1,
		/obj/item/clothing/head/chaplain/nun_hood = 1,
		/obj/item/clothing/suit/chaplainsuit/holidaypriest = 1,
		/obj/item/clothing/suit/hooded/chaplainsuit/monkhabit = 1,
		/obj/item/clothing/head/chaplain/kippah = 3,
		/obj/item/clothing/suit/chaplainsuit/whiterobe = 1,
		/obj/item/clothing/head/chaplain/taqiyah/white = 1,
		/obj/item/clothing/head/chaplain/taqiyah/red = 3,
		/obj/item/clothing/suit/chaplainsuit/monkrobeeast = 1,
		/obj/item/clothing/head/rasta = 1,
		/obj/item/clothing/suit/chaplainsuit/shrinehand = 1,
		/obj/item/storage/backpack/cultpack = 1,
		/obj/item/storage/fancy/candle_box = 2,
		/obj/item/radio/headset/headset_srv = 2,
		/obj/item/clothing/suit/chaplainsuit/habit = 1,
		/obj/item/clothing/head/chaplain/habit_veil = 1,
	)
	contraband = list(
		/obj/item/toy/plush/ratplush = 1,
		/obj/item/toy/plush/narplush = 1,
		/obj/item/clothing/head/chaplain/medievaljewhat = 3,
		/obj/item/clothing/head/chaplain/clownmitre = 1,
		/obj/item/clothing/suit/chaplainsuit/clownpriest = 1,
	)
	premium = list(
		/obj/item/clothing/head/chaplain/bishopmitre = 1,
		/obj/item/clothing/suit/chaplainsuit/bishoprobe = 1,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/chap_wardrobe
	payment_department = ACCOUNT_SRV
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/chap_wardrobe
	machine_name = "Святой Стиль"

/obj/machinery/vending/wardrobe/chem_wardrobe
	name = "Менделеевский Стиль"
	desc = "Торговый автомат для выдачи одежды, связанной с химией."
	icon_state = "chemdrobe"
	product_ads = "Наша одежда на 0.5% более устойчива к разливам кислот! Получите свою сейчас!;Официальный производитель Хайзенберг Корп.; Твой \"Синий Лёд\" не будет продаваться, если производитель выглядит как торчёк."
	vend_reply = "Спасибо за использование Менделеевский Стиль!"
	products = list(
		/obj/item/clothing/head/beret/medical = 2,
		/obj/item/clothing/under/rank/medical/chemist = 2,
		/obj/item/clothing/under/rank/medical/chemist/skirt = 2,
		/obj/item/clothing/suit/toggle/labcoat/chemist = 2,
		/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry = 2,
		/obj/item/clothing/gloves/latex = 2,
		/obj/item/clothing/shoes/sneakers/white = 2,
		/obj/item/storage/backpack/chemistry = 2,
		/obj/item/storage/backpack/satchel/chem = 2,
		/obj/item/storage/backpack/duffelbag/chemistry = 2,
		/obj/item/storage/backpack/messenger/chem = 2,
		/obj/item/storage/bag/chemistry = 2,
		/obj/item/ph_booklet = 3,
		/obj/item/radio/headset/headset_med = 2,
	)
	contraband = list(
		/obj/item/reagent_containers/spray/syndicate = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/chem_wardrobe
	payment_department = ACCOUNT_MED
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/chem_wardrobe
	machine_name = "Менделеевский Стиль"

/obj/machinery/vending/wardrobe/gene_wardrobe
	name = "Генный Стиль"
	desc = "Стиль заложен у нас в генах, но иногда бывают мутации..."
	icon_state = "genedrobe"
	product_ads = "Идеально для безумного учёного в вас!"
	vend_reply = "Спасибо за использование Генный Стиль!"
	products = list(
		/obj/item/clothing/under/rank/rnd/geneticist = 2,
		/obj/item/clothing/under/rank/rnd/geneticist/skirt = 2,
		/obj/item/clothing/suit/toggle/labcoat/genetics = 2,
		/obj/item/clothing/suit/hooded/wintercoat/science/genetics = 2,
		/obj/item/clothing/gloves/latex = 2,
		/obj/item/clothing/shoes/sneakers/white = 2,
		/obj/item/storage/backpack/genetics = 2,
		/obj/item/storage/backpack/satchel/gen = 2,
		/obj/item/storage/backpack/duffelbag/genetics = 2,
		/obj/item/storage/backpack/messenger/gen = 2,
		/obj/item/radio/headset/headset_sci = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/gene_wardrobe
	payment_department = ACCOUNT_SCI
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/gene_wardrobe
	machine_name = "Генный Стиль"

/obj/machinery/vending/wardrobe/viro_wardrobe
	name = "Патогенный Стиль"
	desc = "Зарази их всех! Зарази их своей модой!"
	icon_state = "virodrobe"
	product_slogans = "Вирусы донимают? Тогда переходите на стерилизованную одежду уже сегодня!"
	vend_reply = "Спасибо за использование Патогенный Стиль"
	products = list(
		/obj/item/clothing/mask/surgical = 2,
		/obj/item/clothing/under/rank/medical/virologist = 2,
		/obj/item/clothing/under/rank/medical/virologist/skirt = 2,
		/obj/item/clothing/head/beret/medical = 2,
		/obj/item/clothing/shoes/sneakers/white = 2,
		/obj/item/clothing/suit/toggle/labcoat/virologist = 2,
		/obj/item/clothing/suit/hooded/wintercoat/medical/viro = 2,
		/obj/item/clothing/gloves/latex = 2,
		/obj/item/storage/backpack/virology = 2,
		/obj/item/storage/backpack/satchel/vir = 2,
		/obj/item/storage/backpack/duffelbag/virology = 2,
		/obj/item/storage/backpack/messenger/vir = 2,
		/obj/item/radio/headset/headset_med = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/viro_wardrobe
	payment_department = ACCOUNT_MED
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/viro_wardrobe
	machine_name = "Патогенный Стиль"

/obj/machinery/vending/wardrobe/det_wardrobe
	name = "Расследовательский Стиль"
	desc = "Автомат для всех ваших детективных нужд, пока вам нужна одежда."
	icon_state = "detdrobe"
	product_ads = "Применяйте свои блестящие дедуктивные методы со стилем!"
	vend_reply = "Спасибо за использование Расследовательский Стиль!"
	products = list(
		/obj/item/clothing/head/fedora/det_hat = 2,
		/obj/item/clothing/under/rank/security/detective = 2,
		/obj/item/clothing/under/rank/security/detective/skirt = 2,
		/obj/item/clothing/suit/toggle/jacket/det_trench = 2,
		/obj/item/clothing/suit/jacket/det_suit = 2,
		/obj/item/clothing/shoes/sneakers/brown = 2,
		/obj/item/clothing/gloves/latex = 2,
		/obj/item/clothing/gloves/color/black = 2,
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/clothing/under/rank/security/detective/noir = 2,
		/obj/item/clothing/under/rank/security/detective/noir/skirt = 2,
		/obj/item/clothing/shoes/laceup = 2,
		/obj/item/clothing/head/fedora = 2,
		/obj/item/clothing/suit/toggle/jacket/det_trench/noir = 1,
		/obj/item/clothing/suit/jacket/det_suit/noir = 1,
		/obj/item/clothing/neck/tie/disco = 1,
		/obj/item/clothing/under/rank/security/detective/disco = 1,
		/obj/item/clothing/suit/jacket/det_suit/disco = 1,
		/obj/item/clothing/shoes/discoshoes = 1,
		/obj/item/clothing/glasses/regular/kim = 1,
		/obj/item/clothing/under/rank/security/detective/kim = 1,
		/obj/item/clothing/suit/jacket/det_suit/kim = 1,
		/obj/item/clothing/gloves/kim = 1,
		/obj/item/clothing/shoes/kim = 1,
		/obj/item/reagent_containers/cup/glass/flask/det = 2,
		/obj/item/storage/fancy/cigarettes = 5,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 5,
	)
	premium = list(
		/obj/item/clothing/head/flatcap = 1,
		/obj/item/clothing/glasses/sunglasses/noir = 1,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/det_wardrobe
	extra_price = PAYCHECK_COMMAND * 1.75
	payment_department = ACCOUNT_SEC
	allow_custom = TRUE

/obj/item/vending_refill/wardrobe/det_wardrobe
	machine_name = "Расследовательский Стиль"

/obj/machinery/vending/wardrobe/cent_wardrobe
	name = "Центком Стиль"
	desc = "Уникальный торговый автомат для всех ваших эстетических потребностей в стиле ЦентКом!"
	icon_state = "centdrobe"
	product_ads = "Покажите этим ОБР, кто самый стильный в комнате для брифингов!"
	vend_reply = "Спасибо за использование Центком Стиль!"
	products = list(
		/obj/item/clothing/glasses/sunglasses = 3,
		/obj/item/clothing/head/hats/centcom_cap = 3,
		/obj/item/clothing/head/hats/centhat = 3,
		/obj/item/clothing/head/hats/intern = 3,
		/obj/item/clothing/under/rank/centcom/commander = 3,
		/obj/item/clothing/under/rank/centcom/centcom_skirt = 3,
		/obj/item/clothing/under/rank/centcom/intern = 3,
		/obj/item/clothing/under/rank/centcom/official = 3,
		/obj/item/clothing/under/rank/centcom/officer = 3,
		/obj/item/clothing/under/rank/centcom/officer_skirt = 3,
		/obj/item/clothing/suit/armor/centcom_formal = 3,
		/obj/item/clothing/suit/space/officer = 3,
		/obj/item/clothing/suit/hooded/wintercoat/centcom = 3,
		/obj/item/clothing/shoes/laceup = 3,
		/obj/item/clothing/shoes/jackboots = 3,
		/obj/item/clothing/gloves/combat = 3,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/cent_wardrobe

/obj/item/vending_refill/wardrobe/cent_wardrobe
	machine_name = "Центком Стиль"
	light_color = LIGHT_COLOR_ELECTRIC_GREEN

#undef MOTHROACH_START_CHANCE
#undef MAX_MOTHROACH_AMOUNT
