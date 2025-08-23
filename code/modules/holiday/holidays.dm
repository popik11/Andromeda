/// Список всей праздничной почты. Не редактируйте напрямую, вместо этого добавляйте в var/list/holiday_mail
GLOBAL_LIST_INIT(holiday_mail, list())

/datum/holiday
	///Название самого праздника. Видно игрокам.
	var/name = "Если вы это видите, код праздничного календаря сломан"

	///Какой день begin_month является началом праздника?
	var/begin_day = 1
	///В каком месяце начинается праздник?
	var/begin_month = 0
	/// Какой день end_month является концом праздника? Значение по умолчанию 0 означает, что праздник длится один день.
	var/end_day = 0
	///В каком месяце заканчивается праздник?
	var/end_month = 0
	/// для вечного рождества или тестирования. Принудительно отмечает праздник.
	var/always_celebrate = FALSE
	/// Хранимая переменная для лучшего расчёта дат определённых праздников, например пасхи.
	var/current_year = 0
	/// На сколько лет смещаются расчёты для begin_day и end_day. Используется для праздников вроде пасхи.
	var/year_offset = 0
	///Часовые пояса, в которых отмечается этот праздник (по умолчанию три часовых пояса охватывают 50-часовое окно для всех часовых поясов)
	var/list/timezones = list(TIMEZONE_LINT, TIMEZONE_UTC, TIMEZONE_ANYWHERE_ON_EARTH)
	///Если определено, дроны/ассистенты без стандартной шляпы будут спавниться с этим предметом в слоте головного убора.
	var/obj/item/holiday_hat
	///Когда этот праздник активен, предотвращает ли он доставку почты в карго? Переопределяет var/list/holiday_mail. Старайтесь не использовать для длительных праздников.
	var/no_mail_holiday = FALSE
	/// Список предметов, добавляемых в пул почты. Может быть взвешенным списком или обычным списком. Оставьте пустым для отсутствия.
	var/list/holiday_mail = list()
	var/poster_name = "общий праздничный постер"
	var/poster_desc = "Постер для празднования какого-то праздника. К сожалению, он незакончен, поэтому нельзя разглядеть, что это за праздник."
	var/poster_icon = "holiday_unfinished"
	/// Цветовая схема этого праздника
	var/list/holiday_colors
	/// Стандартный узор праздника, если запрашиваемый узор равен null.
	var/holiday_pattern = PATTERN_DEFAULT

// Этот проц запускается перед началом игры при активации праздника. Делайте праздничные вещи здесь.
/datum/holiday/proc/celebrate()
	if(no_mail_holiday)
		SSeconomy.mail_blocked = TRUE
	if(LAZYLEN(holiday_mail) && !no_mail_holiday)
		GLOB.holiday_mail += holiday_mail
	return

// При начале раунда этот проц запускается для получения текстового сообщения, которое показывается всем, чтобы поздравить с праздником
/datum/holiday/proc/greet()
	return "Счастливого [name]!"

// Возвращает специальные префиксы для названия станции в определённые дни. Получаются названия вроде "Рождественский Объект Эпсилон". Смотрите new_station_name()
/datum/holiday/proc/getStationPrefix()
	//берём первое слово праздника и используем его
	var/i = findtext(name, " ")
	return copytext(name, 1, i)

// Возвращает 1, если этот праздник следует отмечать сегодня
/datum/holiday/proc/shouldCelebrate(dd, mm, yyyy, ddd)
	if(always_celebrate)
		return TRUE

	if(!end_day)
		end_day = begin_day
	if(!end_month)
		end_month = begin_month
	if(end_month > begin_month) //праздник охватывает несколько месяцев в одном году
		if(mm == end_month) //в последнем месяце
			if(dd <= end_day)
				return TRUE

		else if(mm == begin_month)//в первом месяце
			if(dd >= begin_day)
				return TRUE

		else if(mm in begin_month to end_month) //праздник охватывает 3+ месяцев и мы в середине, день не имеет значения
			return TRUE

	else if(end_month == begin_month) // начинается и заканчивается в одном месяце, простейший случай
		if(mm == begin_month && (dd in begin_day to end_day))
			return TRUE

	else // начинается в одном году, заканчивается в следующем
		if(mm >= begin_month && dd >= begin_day) // Праздник заканчивается в следующем году
			return TRUE
		if(mm <= end_month && dd <= end_day) // Праздник начался в прошлом году
			return TRUE
	return FALSE

/// Процы для возврата праздничных цветов для перекрашивания атомов
/datum/holiday/proc/get_holiday_colors(atom/thing_to_color, pattern = holiday_pattern)
	if(!holiday_colors)
		return
	switch(pattern)
		if(PATTERN_DEFAULT)
			return holiday_colors[(thing_to_color.y % holiday_colors.len) + 1]
		if(PATTERN_VERTICAL_STRIPE)
			return holiday_colors[(thing_to_color.x % holiday_colors.len) + 1]

/proc/request_holiday_colors(atom/thing_to_color, pattern)
	switch(pattern)
		if(PATTERN_RANDOM)
			return "#[random_short_color()]"
	if(!length(GLOB.holidays))
		return
	for(var/holiday_key in GLOB.holidays)
		var/datum/holiday/holiday_real = GLOB.holidays[holiday_key]
		if(!holiday_real.holiday_colors)
			continue
		return holiday_real.get_holiday_colors(thing_to_color, pattern || holiday_real.holiday_pattern)

// Собственно праздники

// ЯНВАР

// ФЕВРАЛЬ

/datum/holiday/valentines
	name = "День Святого Валентина"
	begin_day = 13
	end_day = 15
	begin_month = FEBRUARY
	poster_name = "любовный постер"
	poster_desc = "Постер, прославляющий все отношения, построенные сегодня. Конечно, у вас, вероятно, их нет."
	poster_icon = "holiday_love"
	holiday_mail = list(
		/obj/item/food/bonbon/chocolate_truffle,
		/obj/item/food/candyheart,
		/obj/item/food/grown/rose,
		)

/datum/holiday/valentines/getStationPrefix()
	return pick("Любовь","Аморе","Чмок","Объятия")

/datum/holiday/birthday
	name = "День Рождения Space Station 13"
	begin_day = 16
	begin_month = FEBRUARY
	holiday_hat = /obj/item/clothing/head/costume/festive
	poster_name = "station birthday poster"
	poster_desc = "Постер, отмечающий ещё один год работы станции. Почему кто-то может быть рад здесь находиться - beyond вас."
	poster_icon = "holiday_cake" // is a lie
	holiday_mail = list(
		/obj/item/clothing/mask/party_horn,
		/obj/item/food/cakeslice/birthday,
		/obj/item/sparkler,
		/obj/item/storage/box/party_poppers,
	)

/datum/holiday/birthday/greet()
	var/game_age = text2num(time2text(world.timeofday, "YYYY", world.timezone)) - 2003
	var/Fact
	switch(game_age)
		if(16)
			Fact = " SS13 теперь может водить машину!"
		if(18)
			Fact = " SS13 теперь совершеннолетний!"
		if(21)
			Fact = " SS13 теперь может пить!"
		if(26)
			Fact = " SS13 теперь может арендовать машину!"
		if(30)
			Fact = " SS13 теперь может вернуться домой и стать семьянином!"
		if(35)
			Fact = " SS13 теперь может баллотироваться в президенты США!"
		if(40)
			Fact = " SS13 теперь может пережить кризис среднего возраста!"
		if(50)
			Fact = " С золотой годовщиной!"
		if(65)
			Fact = " SS13 теперь может подумать о пенсии!"
	if(!Fact)
		Fact = " SS13 теперь [game_age] лет!"

	return "Скажите 'С Днём Рождения' Space Station 13, впервые публично запущенной 16 февраля 2003 года![Fact]"

// МАРТ

/datum/holiday/pi
	name = "День Пи"
	begin_day = 14
	begin_month = MARCH
	poster_name = "постер дня пи"
	poster_desc = "Постер, отмечающий 3.141529-й день года. По крайней мере, есть бесплатный пирог."
	poster_icon = "holiday_pi"
	holiday_mail = list(
		/obj/item/food/pieslice/apple,
		/obj/item/food/pieslice/bacid_pie,
		/obj/item/food/pieslice/blumpkin,
		/obj/item/food/pieslice/cherry,
		/obj/item/food/pieslice/frenchsilk,
		/obj/item/food/pieslice/frostypie,
		/obj/item/food/pieslice/meatpie,
		/obj/item/food/pieslice/pumpkin,
		/obj/item/food/pieslice/shepherds_pie,
		/obj/item/food/pieslice/tofupie,
		/obj/item/food/pieslice/xemeatpie,
	)

/datum/holiday/pi/getStationPrefix()
	return pick("Синус","Косинус","Тангенс","Секанс", "Косеканс", "Котангенс")

// АПРЕЛЬ

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_month = APRIL
	begin_day = 1
	end_day = 2
	holiday_hat = /obj/item/clothing/head/chameleon/broken
	holiday_mail = list(
		/obj/item/clothing/head/costume/whoopee,
		/obj/item/grown/bananapeel/gros_michel,
	)

/datum/holiday/april_fools/celebrate()
	. = ..()
	SSjob.set_overflow_role(/datum/job/clown)
	SSticker.set_lobby_music('sound/music/lobby_music/clown.ogg', override = TRUE)
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/P = i
		if(P.client)
			P.client.playtitlemusic()

/datum/holiday/april_fools/get_holiday_colors(atom/thing_to_color)
	return "#[random_short_color()]"

/datum/holiday/spess
	name = "День Космонавтики"
	begin_day = 12
	begin_month = APRIL
	holiday_hat = /obj/item/clothing/head/syndicatefake

/datum/holiday/spess/greet()
	return "В этот день более 600 лет назад товарищ Юрий Гагарин впервые ventured в космос!"

/datum/holiday/tea
	name = "Национальный День Чая"
	begin_day = 21
	begin_month = APRIL
	holiday_mail = list(/obj/item/reagent_containers/cup/glass/mug/tea)

/datum/holiday/tea/getStationPrefix()
	return pick("Крампет","Ассам","Улун","Пуэр","Сладкий Чай","Зелёный","Чёрный")

/datum/holiday/earth
	name = "День Земли"
	begin_day = 22
	begin_month = APRIL

// МАЙ

/datum/holiday/labor
	name = "День Труда"
	begin_day = 1
	begin_month = MAY
	holiday_hat = /obj/item/clothing/head/utility/hardhat
	no_mail_holiday = TRUE

// ИЮНЬ

// ИЮЛЬ

// АВГУСТ

// СЕНТЯБРЬ

// ОКТЯБРЬ

// NOVEMBER

/datum/holiday/october_revolution
	name = "Октябрьская Революция"
	begin_day = 6
	begin_month = NOVEMBER
	end_day = 7
	holiday_colors = list(
		COLOR_MEDIUM_DARK_RED,
		COLOR_GOLD,
		COLOR_MEDIUM_DARK_RED,
	)

/datum/holiday/october_revolution/getStationPrefix()
	return pick("Коммунистический", "Советский", "Большевистский", "Социалистический", "Красный", "Рабочий")

/datum/holiday/hello
	name = "День приветствия"
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Привет", "Aloha", "Bonjour", "Hello", "Hi", "Greetings", "Salutations", "Bienvenidos", "Hola", "Howdy", "Ni hao", "Guten Tag", "Konnichiwa"))]! " + ..()

// ДЕКАБРЬ

/datum/holiday/friday_thirteenth
	name = "Пятница 13-я"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yyyy, ddd)
	if(dd == 13 && ddd == FRIDAY)
		return TRUE
	return FALSE

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Майк","Пятница","Злой","Майерс","Убийство","Смертельный","Колющий")

/datum/holiday/programmers
	name = "День Программиста"
	holiday_mail = list(/obj/item/sticker/robot)

/datum/holiday/programmers/shouldCelebrate(dd, mm, yyyy, ddd) //День программиста выпадает на 2^8-й день года
	if(mm == 9)
		if(yyyy/4 == round(yyyy/4)) //Примечание: Не будет работать правильно 12 сентября 2200 года (по крайней мере это пятница!)
			if(dd == 12)
				return TRUE
		else
			if(dd == 13)
				return TRUE
	return FALSE

/datum/holiday/programmers/getStationPrefix()
	return pick("span>","DEBUG: ","null","/list","ПРЕФИКС СОБЫТИЯ НЕ НАЙДЕН") //Портативность

/datum/holiday/xmas/celebrate()
	. = ..()
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(roundstart_celebrate)))
	GLOB.maintenance_loot += list(
		list(
			/obj/item/clothing/head/costume/santa = 1,
			/obj/item/gift/anything = 1,
			/obj/item/toy/xmas_cracker = 3,
		) = maint_holiday_weight,
	)

/datum/holiday/xmas/proc/roundstart_celebrate()
	for(var/obj/machinery/computer/security/telescreen/entertainment/Monitor as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/security/telescreen/entertainment))
		Monitor.icon_state_on = "entertainment_xmas"

	for(var/mob/living/basic/pet/dog/corgi/ian/Ian in GLOB.mob_living_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat(Ian))


/// Принимает датум праздника, начальный месяц, конечный месяц, максимальное количество дней для проверки и минимальный/максимальный год на вход
/// Возвращает список в форме list("гггг/м/д", ...) представляющий все дни, когда праздник активен в проверяемом диапазоне
/proc/poll_holiday(datum/holiday/path, min_month, max_month, min_year, max_year, max_day)
	var/list/deets = list()
	for(var/year in min_year to max_year)
		for(var/month in min_month to max_month)
			for(var/day in 1 to max_day)
				var/datum/holiday/new_day = new path()
				if(new_day.shouldCelebrate(day, month, year, iso_to_weekday(day_of_month(year, month, day))))
					deets += "[year]/[month]/[day]"
	return deets

/// Делает то же, что и [/proc/poll_holiday], но выводит результат админам вместо возврата
/proc/print_holiday(datum/holiday/path, min_month, max_month, min_year, max_year, max_day)
	var/list/deets = poll_holiday(path, min_month, max_month, min_year, max_year, max_day)
	message_admins("Принятые даты для [path] в диапазоне [min_year]-[max_year]/[min_month]-[max_month]/1-[max_day] следующие: [deets.Join("\n")]")
