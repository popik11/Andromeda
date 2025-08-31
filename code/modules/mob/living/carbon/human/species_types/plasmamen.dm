/datum/species/plasmaman
	name = "\improper Plasmaman"
	plural_form = "Plasmamen"
	id = SPECIES_PLASMAMAN
	sexes = FALSE
	meat = /obj/item/stack/sheet/mineral/plasma
	// plasmemes get hard to wound since they only need a severe bone wound to dismember, but unlike skellies, they can't pop their bones back into place
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_HARDLY_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_UNHUSKABLE,
	)

	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	inherent_respiration_type = RESPIRATION_PLASMA
	mutantlungs = /obj/item/organ/lungs/plasmaman
	smoker_lungs = /obj/item/organ/lungs/plasmaman/plasmaman_smoker
	mutanttongue = /obj/item/organ/tongue/bone/plasmaman
	mutantliver = /obj/item/organ/liver/bone/plasmaman
	mutantstomach = /obj/item/organ/stomach/bone/plasmaman
	mutantappendix = null
	mutantheart = null
	heatmod = 1.5
	payday_modifier = 1.0
	breathid = GAS_PLASMA
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	species_cookie = /obj/item/reagent_containers/condiment/milk
	outfit_important_for_life = /datum/outfit/plasmaman
	species_language_holder = /datum/language_holder/skeleton

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/plasmaman,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/plasmaman,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/plasmaman,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/plasmaman,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/plasmaman,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/plasmaman,
	)

	// Body temperature for Plasmen is much lower human as they can handle colder environments
	bodytemp_normal = (BODYTEMP_NORMAL - 40)
	// The minimum amount they stabilize per tick is reduced making hot areas harder to deal with
	bodytemp_autorecovery_min = 2
	// They are hurt at hot temps faster as it is harder to hold their form
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT - 20) // about 40C
	// This effects how fast body temp stabilizes, also if cold resit is lost on the mob
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 50) // about -50c

	outfit_override_registry = list(
		/datum/outfit/syndicate = /datum/outfit/syndicate/plasmaman,
		/datum/outfit/syndicate/full = /datum/outfit/syndicate/full/plasmaman,
		/datum/outfit/syndicate/leader = /datum/outfit/syndicate/leader/plasmaman,
		/datum/outfit/syndicate/reinforcement = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/cybersun = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/donk = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/gorlex = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/interdyne = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/mi13 = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/reinforcement/waffle = /datum/outfit/syndicate/reinforcement/plasmaman,
		/datum/outfit/syndicate/support = /datum/outfit/syndicate/support/plasmaman,
		/datum/outfit/syndicate/full/loneop = /datum/outfit/syndicate/full/plasmaman/loneop,
	)

	/// If the bones themselves are burning clothes won't help you much
	var/internal_fire = FALSE

/datum/species/plasmaman/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	if(job?.plasmaman_outfit)
		equipping.equipOutfit(job.plasmaman_outfit, visuals_only)
	else
		give_important_for_life(equipping)

/datum/species/plasmaman/get_scream_sound(mob/living/carbon/human)
	return pick(
		'sound/mobs/humanoids/plasmaman/plasmeme_scream_1.ogg',
		'sound/mobs/humanoids/plasmaman/plasmeme_scream_2.ogg',
		'sound/mobs/humanoids/plasmaman/plasmeme_scream_3.ogg',
	)

/datum/species/plasmaman/get_physical_attributes()
	return "Плазмалюди буквально дышат и живут плазмой. Они самовоспламеняются при контакте с кислородом, и помимо всех связанных с этим особенностей, \
		они очень уязвимы ко всем видам физического урона из-за своей хрупкой структуры."

/datum/species/plasmaman/get_species_description()
	return "Обнаруженные на ледяной луне Фрейя, плазмалюди состоят из колониальных \
		грибковых организмов, которые вместе образуют разумное существо. В человеческом пространстве \
		они обычно прикреплены к скелетам, чтобы придать человеческий облик."

/datum/species/plasmaman/get_species_lore()
	return list(
		"Запутанный вид, плазмалюди действительно \"грибы среди нас\". \
		То, что кажется единым существом, на самом деле является колонией миллионов организмов, \
		окружающих найденную (или предоставленную) скелетную структуру.",

		"Изначально обнаружены Нанотрейзен, когда исследователь \
		упал в открытый резервуар с жидкой плазмой, ранее незамеченная грибковая колония захватила тело, создав \
		первого \"настоящего\" плазмачеловека. С тех пор процесс был упрощён за счёт щедрых пожертвований трупов заключённых, и плазмалюди \
		были массово размещены по всей NT для усиления рабочей силы.",

		"Новые на галактической сцене, плазмалюди - чистый лист. \
		Их внешность, бычно считающийся \"жутковатой\", вызывает много опасений у сослуживцев. \
		Возможно, дело в целом в \"воспламеняющемся фиолетовом скелете\".",

		"Колониды, из которых состоят плазмалюди, требуют богатую плазмой атмосферу, в которой они эволюционировали. \
		Их псевдо-нервная система работает с экстернализированными электрическими импульсами, которые немедленно воспламеняют их плазменные тела при наличии кислорода.",
	)

/datum/species/plasmaman/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-shield",
			SPECIES_PERK_NAME = "Защищённость",
			SPECIES_PERK_DESC = "Плазмалюди иммунны к радиации, ядам и большинству болезней.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bone",
			SPECIES_PERK_NAME = "Устойчивость к Ранам",
			SPECIES_PERK_DESC = "Плазмалюди имеют более высокую переносимость урона, который ранил бы других.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Плазменное Исцеление",
			SPECIES_PERK_DESC = "Плазмалюди могут залечивать раны, потребляя плазму.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hard-hat",
			SPECIES_PERK_NAME = "Защитный Шлем",
			SPECIES_PERK_DESC = "Шлемы плазмалюдей обеспечивают им защиту от вспышек сварки, а также встроенный фонарик.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Живой Факел",
			SPECIES_PERK_DESC = "Плазмалюди мгновенно воспламеняются, когда их тело контактирует с кислородом.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Сложная Биология",
			SPECIES_PERK_DESC = "Плазмалюди требуют специализированных медицинских знаний для \
				лечения. Не ожидайте быстрого оживления, если вам вообще повезёт \
				получить его.",
		),
	)

	return to_add
