
//These are shuttle areas; all subtypes are only used as teleportation markers, they have no actual function beyond that.
//Multi area shuttles are a thing now, use subtypes! ~ninjanomnom

/area/shuttle
	name = "Шаттл"
	requires_power = FALSE
	static_lighting = TRUE
	default_gravity = STANDARD_GRAVITY
	always_unpowered = FALSE
	// Loading the same shuttle map at a different time will produce distinct area instances.
	area_flags = NONE
	icon = 'icons/area/areas_station.dmi'
	icon_state = "shuttle"
	flags_1 = CAN_BE_DIRTY_1
	area_limited_icon_smoothing = /area/shuttle
	sound_environment = SOUND_ENVIRONMENT_ROOM


/area/shuttle/place_on_top_react(list/new_baseturfs, turf/added_layer, flags)
	. = ..()
	if(ispath(added_layer, /turf/open/floor/plating))
		new_baseturfs.Add(/turf/baseturf_skipover/shuttle)
		. |= CHANGETURF_GENERATE_SHUTTLE_CEILING
	else if(ispath(new_baseturfs[1], /turf/open/floor/plating))
		new_baseturfs.Insert(1, /turf/baseturf_skipover/shuttle)
		. |= CHANGETURF_GENERATE_SHUTTLE_CEILING

////////////////////////////Custom Shuttles////////////////////////////

/area/shuttle/custom
	requires_power = TRUE

////////////////////////////Многосекционные шаттлы////////////////////////////

////////////////////////////Инфильтратор Синдиката////////////////////////////

/area/shuttle/syndicate
	name = "Шаттл Синдиката"
	ambience_index = AMBIENCE_DANGER
	area_limited_icon_smoothing = /area/shuttle/syndicate

/area/shuttle/syndicate/bridge
	name = "Мост шаттла Синдиката"

/area/shuttle/syndicate/medical
	name = "Медблок шаттла Синдиката"

/area/shuttle/syndicate/armory
	name = "Оружейная шаттла Синдиката"

/area/shuttle/syndicate/eva
	name = "Отсек EVA шаттла Синдиката"

/area/shuttle/syndicate/hallway
	name = "Коридор шаттла Синдиката"

/area/shuttle/syndicate/engineering
	name = "Инженерный отсек шаттла Синдиката"

/area/shuttle/syndicate/airlock
	name = "Шлюз шаттла Синдиката"

////////////////////////////Пиратский шаттл////////////////////////////

/area/shuttle/pirate
	name = "Пиратский шаттл"
	requires_power = TRUE

/area/shuttle/pirate/flying_dutchman
	name = "Летучий Голландец"
	requires_power = FALSE

////////////////////////////Шаттлы охотников за головами////////////////////////////

/area/shuttle/hunter
	name = "Шаттл охотника"

/area/shuttle/hunter/russian
	name = "Российский грузовой перевозчик"
	requires_power = TRUE

/area/shuttle/hunter/mi13_foodtruck
	name = "Совершенно обычный фудтрак"
	requires_power = TRUE
	ambience_index = AMBIENCE_DANGER

////////////////////////////Заброшенный корабль////////////////////////////

/area/shuttle/abandoned
	name = "Заброшенный корабль"
	requires_power = TRUE
	area_limited_icon_smoothing = /area/shuttle/abandoned

/area/shuttle/abandoned/bridge
	name = "Мост заброшенного корабля"

/area/shuttle/abandoned/engine
	name = "Двигатель заброшенного корабля"

/area/shuttle/abandoned/bar
	name = "Бар заброшенного корабля"

/area/shuttle/abandoned/crew
	name = "Жилые помещения заброшенного корабля"

/area/shuttle/abandoned/cargo
	name = "Грузовой отсек заброшенного корабля"

/area/shuttle/abandoned/medbay
	name = "Медблок заброшенного корабля"

/area/shuttle/abandoned/pod
	name = "Спасательная капсула заброшенного корабля"

////////////////////////////Односекционные шаттлы////////////////////////////
/area/shuttle/transit
	name = "Гиперпространство"
	desc = "Уиииии"
	static_lighting = FALSE
	base_lighting_alpha = 255


/area/shuttle/arrival
	name = "Шаттл прибытия"
	area_flags = UNIQUE_AREA // SSjob использует эту зону для позднего присоединения


/area/shuttle/arrival/on_joining_game(mob/living/boarder)
	if(SSshuttle.arrivals?.mode == SHUTTLE_CALL)
		var/atom/movable/screen/splash/Spl = new(null, null, boarder.client, TRUE)
		Spl.fade(TRUE)
		boarder.playsound_local(get_turf(boarder), 'sound/announcer/ApproachingTG.ogg', 25)
	boarder.update_parallax_teleport()


/area/shuttle/pod_1
	name = "Спасательная капсула №1"
	area_flags = NONE

/area/shuttle/pod_2
	name = "Спасательная капсула №2"
	area_flags = NONE

/area/shuttle/pod_3
	name = "Спасательная капсула №3"
	area_flags = NONE

/area/shuttle/pod_4
	name = "Спасательная капсула №4"
	area_flags = NONE

/area/shuttle/mining
	name = "Шахтерский шаттл"

/area/shuttle/mining/large
	name = "Большой шахтерский шаттл"
	requires_power = TRUE

/area/shuttle/labor
	name = "Шаттл трудового лагеря"

/area/shuttle/supply
	name = "Грузовой шаттл"
	area_flags = NOTELEPORT

/area/shuttle/escape
	name = "Эвакуационный шаттл"
	area_flags = BLOBS_ALLOWED
	area_limited_icon_smoothing = /area/shuttle/escape
	flags_1 = CAN_BE_DIRTY_1
	area_flags = CULT_PERMITTED

/area/shuttle/escape/backup
	name = "Резервный эвакуационный шаттл"

/area/shuttle/escape/brig
	name = "Бриг эвакуационного шаттла"
	icon_state = "shuttlered"

/area/shuttle/escape/luxury
	name = "Роскошный эвакуационный шаттл"
	area_flags = NOTELEPORT

/area/shuttle/escape/simulation
	name = "Купол симуляции средневековья"
	icon_state = "shuttlectf"
	area_flags = NOTELEPORT
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/shuttle/escape/arena
	name = "Арена"
	area_flags = NOTELEPORT

/area/shuttle/escape/meteor
	name = "\proper метеор с прикрученными двигателями"
	luminosity = NONE

/area/shuttle/escape/engine
	name = "Двигатель эвакуационного шаттла"

/area/shuttle/transport
	name = "Транспортный шаттл"

/area/shuttle/assault_pod
	name = "Стальной дождь"

/area/shuttle/sbc_starfury
	name = "Звездный гнев СБК"

/area/shuttle/sbc_fighter1
	name = "Истребитель СБК 1"

/area/shuttle/sbc_fighter2
	name = "Истребитель СБК 2"

/area/shuttle/sbc_fighter3
	name = "Истребитель СБК 3"

/area/shuttle/sbc_corvette
	name = "Корвет СБК"

/area/shuttle/syndicate_scout
	name = "Разведчик Синдиката"

/area/shuttle/ruin
	name = "Разрушенный шаттл"

/// Специальные шаттлы для руин "Засада каравана"
/area/shuttle/ruin/caravan
	requires_power = TRUE
	name = "Разрушенный шаттл каравана"

/area/shuttle/ruin/caravan/syndicate1
	name = "Истребитель Синдиката"

/area/shuttle/ruin/caravan/syndicate2
	name = "Истребитель Синдиката"

/area/shuttle/ruin/caravan/syndicate3
	name = "Десантный корабль Синдиката"

/area/shuttle/ruin/caravan/pirate
	name = "Пиратский катер"

/area/shuttle/ruin/caravan/freighter1
	name = "Малый грузовик"

/area/shuttle/ruin/caravan/freighter2
	name = "Крошечный грузовик"

/area/shuttle/ruin/caravan/freighter3
	name = "Крошечный грузовик"

// ----------- Материнский корабль киборгов
/area/shuttle/ruin/cyborg_mothership
	name = "Материнский корабль киборгов"
	requires_power = TRUE
	area_limited_icon_smoothing = /area/shuttle/ruin/cyborg_mothership

// ----------- Аренный шаттл
/area/shuttle/shuttle_arena
	name = "Арена"
	default_gravity = STANDARD_GRAVITY
	requires_power = FALSE

/obj/effect/forcefield/arena_shuttle
	name = "портал"
	initial_duration = 0
	var/list/warp_points = list()

/obj/effect/forcefield/arena_shuttle/Initialize(mapload)
	. = ..()
	for(var/obj/effect/landmark/shuttle_arena_safe/exit in GLOB.landmarks_list)
		warp_points += exit

/obj/effect/forcefield/arena_shuttle/Bumped(atom/movable/AM)
	if(!isliving(AM))
		return

	var/mob/living/L = AM
	if(L.pulling && istype(L.pulling, /obj/item/bodypart/head))
		to_chat(L, span_notice("Ваша жертва принята. Вы можете пройти."), confidential = TRUE)
		qdel(L.pulling)
		var/turf/LA = get_turf(pick(warp_points))
		L.forceMove(LA)
		L.remove_status_effect(/datum/status_effect/hallucination)
		to_chat(L, "<span class='reallybig redtext'>Битва выиграна. Ваша жажда крови утихает.</span>", confidential = TRUE)
		for(var/obj/item/chainsaw/doomslayer/chainsaw in L)
			qdel(chainsaw)
		var/obj/item/skeleton_key/key = new(L)
		L.put_in_hands(key)
	else
		to_chat(L, span_warning("Вы еще не достойны пройти. Притащите отрубленную голову к барьеру, чтобы получить доступ в зал чемпионов."), confidential = TRUE)

/obj/effect/landmark/shuttle_arena_safe
	name = "зал чемпионов"
	desc = "Для победителей."

/obj/effect/landmark/shuttle_arena_entrance
	name = "\proper арена"
	desc = "Поле битвы, заполненное лавой."

/obj/effect/forcefield/arena_shuttle_entrance
	name = "портал"
	initial_duration = 0
	var/list/warp_points = list()

/obj/effect/forcefield/arena_shuttle_entrance/Bumped(atom/movable/AM)
	if(!isliving(AM))
		return

	if(!warp_points.len)
		for(var/obj/effect/landmark/shuttle_arena_entrance/S in GLOB.landmarks_list)
			warp_points |= S

	var/obj/effect/landmark/LA = pick(warp_points)
	var/mob/living/M = AM
	M.forceMove(get_turf(LA))
	to_chat(M, "<span class='reallybig redtext'>Вы заперты на смертельной арене! Чтобы сбежать, вам нужно притащить отрубленную голову к порталам выхода.</span>", confidential = TRUE)
	M.apply_status_effect(/datum/status_effect/mayhem)
