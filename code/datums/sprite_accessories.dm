/*
 *	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
 *	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
 *	intended to be friendly for people with little to no actual coding experience.
 *	The process of adding in new hairstyles has been made pain-free and easy to do.
 *	Enjoy! - Doohl
 *
 *
 *	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
 *	have to define any UI values for sprite accessories manually for hair and facial
 *	hair. Just add in new hair types and the game will naturally adapt.
 *
 *	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
 *	to the point where you may completely corrupt a server's savefiles. Please refrain
 *	from doing this unless you absolutely know what you are doing, and have defined a
 *	conversion in savefile.dm
 */

/datum/sprite_accessory
	/// The icon file the accessory is located in.
	var/icon
	/// The icon_state of the accessory.
	var/icon_state
	/// The preview name of the accessory.
	var/name
	/// Determines if the accessory will be skipped or included in random hair generations.
	var/gender = NEUTER
	/// Something that can be worn by either gender, but looks different on each.
	var/gender_specific = FALSE
	/// Determines if the accessory will be skipped by color preferences.
	var/use_static
	/**
	 * Currently only used by mutantparts so don't worry about hair and stuff.
	 * This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	 */
	var/color_src = MUTANT_COLOR
	/// Is this part locked from roundstart selection? Used for parts that apply effects.
	var/locked = FALSE
	/// Should we center the sprite?
	var/center = FALSE
	/// The width of the sprite in pixels. Used to center it if necessary.
	var/dimension_x = 32
	/// The height of the sprite in pixels. Used to center it if necessary.
	var/dimension_y = 32
	/// Should this sprite block emissives?
	var/em_block = FALSE
	/// Determines if this is considered "sane" for the purpose of [/proc/randomize_human_normie]
	/// Basically this is to blacklist the extremely wacky stuff from being picked in random human generation.
	var/natural_spawn = TRUE

/datum/sprite_accessory/blank
	name = SPRITE_ACCESSORY_NONE
	icon_state = "Ничего"

////////////////
// Hair Masks //
////////////////

/datum/hair_mask
	var/icon/icon = 'icons/mob/human/hair_masks.dmi'
	var/icon_state = ""
	/// Strict coverage zones will always have the hair mask applied to them, even if a piece of hair at that location would normally resist being masked.
	/// If a piece of headware only covers the top of the head, it should only strictly cover the top zone. But a mostly-enclosed helmet might strictly cover almost all zones.
	var/strict_coverage_zones = NONE

/datum/hair_mask/standard_hat_middle
	icon_state = "hide_above_45deg"
	strict_coverage_zones = HAIR_APPENDAGE_TOP

/datum/hair_mask/standard_hat_low
	icon_state = "hide_above_45deg_low"
	strict_coverage_zones = HAIR_APPENDAGE_TOP | HAIR_APPENDAGE_LEFT | HAIR_APPENDAGE_RIGHT | HAIR_APPENDAGE_REAR

/datum/hair_mask/winterhood
	icon_state = "hide_winterhood"
	strict_coverage_zones = HAIR_APPENDAGE_TOP | HAIR_APPENDAGE_LEFT | HAIR_APPENDAGE_RIGHT | HAIR_APPENDAGE_REAR | HAIR_APPENDAGE_HANGING_REAR

//////////////////////
// Hair Definitions //
//////////////////////
// Cache of each hairstyle's icon after being blended with the given masks
// "joined mask types" is each mask's type as a string joined by commas (for no masks, it is the empty string)
// /datum/sprite_accessory/hair path -> list(joined mask types -> icon)
GLOBAL_LIST_EMPTY(blended_hair_icons_cache)

/datum/sprite_accessory/hair
	icon = 'icons/mob/human/human_face.dmi'   // default icon for all hairs
	var/y_offset = 0 // Y offset to apply so we can have hair that reaches above the player sprite's visual bounding box

	// Some hair will have "appendages", such as pony tails, that stick out from certain parts of the head. These can be layered above or below headwear and resist being masked away by hair masks.
	// Lists should be icon_state strings associated with the HAIR_APPENDAGE defines specifying the part of the head they stick out from.
	// hair_appendages_inner contains icon_states that go in the normal hair layer, hair_appendages_outer contains icon_states that go above the layer for headwear.
	// hair_appendages_inner will be masked normally if their HAIR_APPENDAGE zone is strictly masked by a piece of clothing (a fully enclosed helmet with a transparent visor will strictly mask all zones, a small hat will only strictly mask the top, etc.).
	// hair_appendages_outer will never be masked at all and will just not be shown if their zone has strict masking. These should generally not have visible sprites for every dir.
	var/list/hair_appendages_inner = null
	var/list/hair_appendages_outer = null

/// Retrieve the base hair icon with all hair appendeges blended in, with hair masks applied, from the cache, or generate it if it doesn't exist
/datum/sprite_accessory/hair/proc/getCachedIcon(list/hair_masks)
	var/icon/cachedIcon
	var/joinedMasks = LAZYLEN(hair_masks) ? jointext(hair_masks, ",") : ""
	var/list/masks_to_icons = GLOB.blended_hair_icons_cache[type]
	if(!masks_to_icons)
		GLOB.blended_hair_icons_cache[type] = list()
	else
		cachedIcon = masks_to_icons[joinedMasks]

	if(!cachedIcon)
		if(LAZYLEN(hair_masks))
			if(LAZYLEN(hair_appendages_inner))
				// Check if there are any hair appendages in a zone that is not strictly masked
				var/found_mask_dodger = FALSE
				for(var/datum/hair_mask/mask as anything in hair_masks)
					for(var/appendage in hair_appendages_inner)
						var/zone = hair_appendages_inner[appendage]
						if(!(zone & mask.strict_coverage_zones))
							found_mask_dodger = TRUE

				if(found_mask_dodger)
					// We have to process each icon individually
					cachedIcon = icon(icon, icon_state)
					// mask the base icon
					for(var/datum/hair_mask/mask as anything in hair_masks)
						var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
						mask_icon.Shift(SOUTH, y_offset)
						cachedIcon.Blend(mask_icon, ICON_ADD)

					// mask the appendages if required and add them to the base icon
					for(var/appendage_icon_state in hair_appendages_inner)
						var/icon/appendage_icon = icon(icon, appendage_icon_state)
						var/zone = hair_appendages_inner[appendage_icon_state]
						for(var/datum/hair_mask/mask as anything in hair_masks)
							if(zone & mask.strict_coverage_zones)
								var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
								mask_icon.Shift(SOUTH, y_offset)
								appendage_icon.Blend(mask_icon, ICON_ADD)
						cachedIcon.Blend(appendage_icon, ICON_OVERLAY)
				else
					// No mask dodgers, so we can just mask the full (hopefully cached) icon
					cachedIcon = icon(getCachedIcon())
					for(var/datum/hair_mask/mask as anything in hair_masks)
						var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
						mask_icon.Shift(SOUTH, y_offset)
						cachedIcon.Blend(mask_icon, ICON_ADD)
			else
				// No hair appendages, so just apply all hair masks to the base icon
				cachedIcon = icon(icon, icon_state)
				for(var/datum/hair_mask/mask as anything in hair_masks)
					var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
					mask_icon.Shift(SOUTH, y_offset)
					cachedIcon.Blend(mask_icon, ICON_ADD)
		else
			// no hair masks
			cachedIcon = icon(icon, icon_state)
			if(LAZYLEN(hair_appendages_inner))
				for(var/appendage_icon_state in hair_appendages_inner)
					var/icon/appendage_icon = icon(icon, appendage_icon_state)
					cachedIcon.Blend(appendage_icon, ICON_OVERLAY)
		// set cache
		GLOB.blended_hair_icons_cache[type][joinedMasks] = cachedIcon
	return cachedIcon


// please make sure they're sorted alphabetically and, where needed, categorized
// try to capitalize the names please~
// try to spell
// you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/hair/afro
	name = "Афро"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Афро 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Афро (Большое)"
	icon_state = "hair_bigafro"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/afro_huge
	name = "Афро (Огромное)"
	icon_state = "hair_hugeafro"
	y_offset = 6
	natural_spawn = FALSE

/datum/sprite_accessory/hair/allthefuzz
	name = "Растрёпанные"
	icon_state = "hair_allthefuzz"

/datum/sprite_accessory/hair/antenna
	name = "Ахоге"
	icon_state = "hair_antenna"
	hair_appendages_inner = list("hair_antenna_a1" = HAIR_APPENDAGE_TOP)

/datum/sprite_accessory/hair/bald
	name = "Лысый"
	icon_state = null

/datum/sprite_accessory/hair/balding
	name = "Лысеющие волосы"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/bedhead
	name = "Всклокоченные"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Всклокоченные 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Всклокоченные 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/bedheadv4
	name = "Всклокоченные 4x"
	icon_state = "hair_bedheadv4"

/datum/sprite_accessory/hair/bedheadlong
	name = "Длинные всклокоченные"
	icon_state = "hair_long_bedhead"

/datum/sprite_accessory/hair/bedheadfloorlength
	name = "Всклокоченные до пола"
	icon_state = "hair_floorlength_bedhead"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/badlycut
	name = "Короче длинные всклокоченные"
	icon_state = "hair_verybadlycut"

/datum/sprite_accessory/hair/beehive
	name = "Пчелиный улей"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/beehive2
	name = "Пчелиный улей 2"
	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bob
	name = "Каре"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Каре 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/bob3
	name = "Каре 3"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bob4
	name = "Каре 4"
	icon_state = "hair_bob4"

/datum/sprite_accessory/hair/bobcurl
	name = "Каре с завитками"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/boddicker
	name = "Боддикер"
	icon_state = "hair_boddicker"

/datum/sprite_accessory/hair/bowlcut
	name = "Горшок"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/bowlcut2
	name = "Горшок 2"
	icon_state = "hair_bowlcut2"

/datum/sprite_accessory/hair/braid
	name = "Коса (До пола)"
	icon_state = "hair_braid"
	hair_appendages_inner = list("hair_braid_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_braid_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/braided
	name = "Плетёные"
	icon_state = "hair_braided"

/datum/sprite_accessory/hair/front_braid
	name = "Плетёные спереди"
	icon_state = "hair_braidfront"
	hair_appendages_inner = list("hair_braidfront_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_braidfront_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "Коса (Высокая)"
	icon_state = "hair_braid2"
	hair_appendages_inner = list("hair_braid2_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_braid2_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/lowbraid
	name = "Коса (Низкая)"
	icon_state = "hair_hbraid"

/datum/sprite_accessory/hair/shortbraid
	name = "Коса (Короткая)"
	icon_state = "hair_shortbraid"
	hair_appendages_inner = list("hair_shortbraid_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_shortbraid_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/braidtail
	name = "Плетёный хвост"
	icon_state = "hair_braidtail"
	hair_appendages_inner = list("hair_braidtail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_braidtail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/bun
	name = "Пучок"
	icon_state = "hair_bun"

/datum/sprite_accessory/hair/bun2
	name = "Пучок 2"
	icon_state = "hair_bunhead2"
	hair_appendages_inner = list("hair_bunhead2_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_bunhead2_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/bun3
	name = "Пучок 3"
	icon_state = "hair_bun3"

/datum/sprite_accessory/hair/largebun
	name = "Пучок (Большой)"
	icon_state = "hair_largebun"

/datum/sprite_accessory/hair/manbun
	name = "Пучок (Мужской)"
	icon_state = "hair_manbun"
	hair_appendages_inner = list("hair_manbun_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_manbun_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/tightbun
	name = "Пучок (Тугой)"
	icon_state = "hair_tightbun"

/datum/sprite_accessory/hair/business
	name = "Деловая причёска"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Деловая причёска 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Деловая причёска 3"
	icon_state = "hair_business3"

/datum/sprite_accessory/hair/business4
	name = "Деловая причёска 4"
	icon_state = "hair_business4"

/datum/sprite_accessory/hair/buzz
	name = "Ёжик"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/chinbob
	name = "Каре до подбородка"
	icon_state = "hair_chinbob"

/datum/sprite_accessory/hair/comet
	name = "Комета"
	icon_state = "hair_comet"

/datum/sprite_accessory/hair/cia
	name = "ЦРУ"
	icon_state = "hair_cia"

/datum/sprite_accessory/hair/coffeehouse
	name = "Кофейня"
	icon_state = "hair_coffeehouse"

/datum/sprite_accessory/hair/combover
	name = "Зачёс"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/cornrows1
	name = "Косички"
	icon_state = "hair_cornrows"

/datum/sprite_accessory/hair/cornrows2
	name = "Косички 2"
	icon_state = "hair_cornrows2"

/datum/sprite_accessory/hair/cornrowbun
	name = "Пучок из косичек"
	icon_state = "hair_cornrowbun"

/datum/sprite_accessory/hair/cornrowbraid
	name = "Коса из косичек"
	icon_state = "hair_cornrowbraid"

/datum/sprite_accessory/hair/cornrowdualtail
	name = "Хвост из косичек"
	icon_state = "hair_cornrowtail"
	hair_appendages_inner = list("hair_cornrowtail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_cornrowtail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/crew
	name = "Короткая стрижка"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/curls
	name = "Кудри"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/cut
	name = "Стрижка"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/dandpompadour
	name = "Денди Помпадур"
	icon_state = "hair_dandypompadour"

/datum/sprite_accessory/hair/devillock
	name = "Дьявольский замок"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/doublebun
	name = "Двойной пучок"
	icon_state = "hair_doublebun"
	hair_appendages_inner = list("hair_doublebun_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_doublebun_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/dreadlocks
	name = "Дреды"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/drillhair
	name = "Дрилруру"
	icon_state = "hair_drillruru"
	hair_appendages_inner = list("hair_drillruru_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_drillruru_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/drillhairextended
	name = "Дриллы (Удлинённые)"
	icon_state = "hair_drillhairextended"
	hair_appendages_inner = list("hair_drillhairextended_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_drillhairextended_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/emo
	name = "Эмо"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/emofrine
	name = "Эмо чёлка"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/nofade
	name = "Фейд (Отсутствует)"
	icon_state = "hair_nofade"

/datum/sprite_accessory/hair/highfade
	name = "Фейд (Высокий)"
	icon_state = "hair_highfade"

/datum/sprite_accessory/hair/medfade
	name = "Фейд (Средний)"
	icon_state = "hair_medfade"

/datum/sprite_accessory/hair/lowfade
	name = "Фейд (Низкий)"
	icon_state = "hair_lowfade"

/datum/sprite_accessory/hair/baldfade
	name = "Фейд (Лысый)"
	icon_state = "hair_baldfade"

/datum/sprite_accessory/hair/feather
	name = "Перо"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/father
	name = "Отец"
	icon_state = "hair_father"

/datum/sprite_accessory/hair/sargeant
	name = "Площадка"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/flair
	name = "Флер"
	icon_state = "hair_flair"

/datum/sprite_accessory/hair/bigflattop
	name = "Площадка (Большая)"
	icon_state = "hair_bigflattop"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/flow_hair
	name = "Струящиеся волосы"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/gelled
	name = "Заглаженные назад"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/gentle
	name = "Нежные"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Полу-чёсаные волосы"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Полу-чёсаные волосы 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/halfshaved
	name = "Полу-выбритые"
	icon_state = "hair_halfshaved"

/datum/sprite_accessory/hair/hedgehog
	name = "Ёжик"
	icon_state = "hair_hedgehog"

/datum/sprite_accessory/hair/himecut
	name = "Стрижка Химе"
	icon_state = "hair_himecut"

/datum/sprite_accessory/hair/himecut2
	name = "Стрижка Химе 2"
	icon_state = "hair_himecut2"

/datum/sprite_accessory/hair/shorthime
	name = "Стрижка Химе (Короткая)"
	icon_state = "hair_shorthime"

/datum/sprite_accessory/hair/himeup
	name = "Причёска Химе"
	icon_state = "hair_himeup"

/datum/sprite_accessory/hair/hitop
	name = "Хайтоп"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/jade
	name = "Джейд"
	icon_state = "hair_jade"

/datum/sprite_accessory/hair/jensen
	name = "Причёска Дженсена"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/joestar
	name = "Джостар"
	icon_state = "hair_joestar"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/keanu
	name = "Причёска Киану"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/kusangi
	name = "Причёска Кусанаги"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/long
	name = "Длинные волосы 1"
	icon_state = "hair_long"
	hair_appendages_inner = list("hair_long_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long2
	name = "Длинные волосы 2"
	icon_state = "hair_long2"
	hair_appendages_inner = list("hair_long2_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long3
	name = "Длинные волосы 3"
	icon_state = "hair_long3"
	hair_appendages_inner = list("hair_long3_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long_over_eye
	name = "Длинные на глаз"
	icon_state = "hair_longovereye"

/datum/sprite_accessory/hair/longbangs
	name = "Длинные чёлки"
	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/longemo
	name = "Длинные эмо"
	icon_state = "hair_longemo"

/datum/sprite_accessory/hair/longfringe
	name = "Длинная чёлка"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/sidepartlongalt
	name = "Длинный боковой пробор"
	icon_state = "hair_longsidepart"
	hair_appendages_inner = list("hair_longsidepart_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_longsidepart_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/megaeyebrows
	name = "Мега-брови"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/messy
	name = "Растрёпанные"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/modern
	name = "Современные"
	icon_state = "hair_modern"

/datum/sprite_accessory/hair/mohawk
	name = "Могавк"
	icon_state = "hair_d"
	natural_spawn = FALSE // прости, маленький

/datum/sprite_accessory/hair/nitori
	name = "Нитори"
	icon_state = "hair_nitori"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/reversemohawk
	name = "Могавк (Обратный)"
	icon_state = "hair_reversemohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/shavedmohawk
	name = "Могавк (Выбритый)"
	icon_state = "hair_shavedmohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/unshavenmohawk
	name = "Могавк (Небритый)"
	icon_state = "hair_unshaven_mohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/mulder
	name = "Малдер"
	icon_state = "hair_mulder"

/datum/sprite_accessory/hair/odango
	name = "Оданго"
	icon_state = "hair_odango"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/ombre
	name = "Омбре"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/oneshoulder
	name = "На одно плечо"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/over_eye
	name = "На глаз"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/hair_overeyetwo
	name = "На глаз 2"
	icon_state = "hair_overeyetwo"

/datum/sprite_accessory/hair/oxton
	name = "Окстон"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/parted
	name = "С пробором"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/partedside
	name = "С пробором (Сбоку)"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/kagami
	name = "Хвостики"
	icon_state = "hair_kagami"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail
	name = "Хвостики 2"
	icon_state = "hair_pigtails"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail2
	name = "Хвостики 3"
	icon_state = "hair_pigtails2"
	natural_spawn = FALSE
	hair_appendages_inner = list("hair_pigtails2_a1" = HAIR_APPENDAGE_LEFT, "hair_pigtails2_a2" = HAIR_APPENDAGE_RIGHT)

/datum/sprite_accessory/hair/pixie
	name = "Пикси"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/pompadour
	name = "Помпадур"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Помпадур (Большой)"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/ponytail1
	name = "Хвост"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Хвост 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Хвост 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Хвост 4"
	icon_state = "hair_ponytail4"
	hair_appendages_inner = list("hair_ponytail4_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail4_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ponytail5
	name = "Хвост 5"
	icon_state = "hair_ponytail5"
	hair_appendages_inner = list("hair_ponytail5_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_ponytail5_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/ponytail6
	name = "Хвост 6"
	icon_state = "hair_ponytail6"
	hair_appendages_inner = list("hair_ponytail6_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail6_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ponytail7
	name = "Хвост 7"
	icon_state = "hair_ponytail7"
	hair_appendages_inner = list("hair_ponytail7_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail7_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/highponytail
	name = "Хвост (Высокий)"
	icon_state = "hair_highponytail"
	hair_appendages_inner = list("hair_highponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_highponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/stail
	name = "Хвост (Короткий)"
	icon_state = "hair_stail"
	hair_appendages_inner = list("hair_stail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_stail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/longponytail
	name = "Хвост (Длинный)"
	icon_state = "hair_longstraightponytail"
	hair_appendages_inner = list("hair_longstraightponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_longstraightponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/countryponytail
	name = "Хвост (Кантри)"
	icon_state = "hair_country"
	hair_appendages_inner = list("hair_country_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_country_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/fringetail
	name = "Хвост (С чёлкой)"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/sidetail
	name = "Хвост (Сбоку)"
	icon_state = "hair_sidetail"

/datum/sprite_accessory/hair/sidetail2
	name = "Хвост (Сбоку) 2"
	icon_state = "hair_sidetail2"

/datum/sprite_accessory/hair/sidetail3
	name = "Хвост (Сбоку) 3"
	icon_state = "hair_sidetail3"
	hair_appendages_inner = list("hair_sidetail3_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_sidetail3_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/sidetail4
	name = "Хвост (Сбоку) 4"
	icon_state = "hair_sidetail4"
	hair_appendages_inner = list("hair_sidetail4_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_sidetail4_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/spikyponytail
	name = "Хвост (Колючий)"
	icon_state = "hair_spikyponytail"
	hair_appendages_inner = list("hair_spikyponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_spikyponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/poofy
	name = "Пышные"
	icon_state = "hair_poofy"

/datum/sprite_accessory/hair/quiff
	name = "Квифф"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/ronin
	name = "Ронин"
	icon_state = "hair_ronin"

/datum/sprite_accessory/hair/shaved
	name = "Выбритые"
	icon_state = "hair_shaved"

/datum/sprite_accessory/hair/shavedpart
	name = "Выбритая часть"
	icon_state = "hair_shavedpart"

/datum/sprite_accessory/hair/shortbangs
	name = "Короткие чёлки"
	icon_state = "hair_shortbangs"

/datum/sprite_accessory/hair/shortbangs2
	name = "Короткие чёлки 2"
	icon_state = "hair_shortbangs2"

/datum/sprite_accessory/hair/short
	name = "Короткие волосы"
	icon_state = "hair_a"

/datum/sprite_accessory/hair/shorthair2
	name = "Короткие волосы 2"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shorthair3
	name = "Короткие волосы 3"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/shorthair4
	name = "Короткие волосы 4"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/shorthair5
	name = "Короткие волосы 5"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/shorthair6
	name = "Короткие волосы 6"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/shorthair7
	name = "Короткие волосы 7"
	icon_state = "hair_shorthairg"

/datum/sprite_accessory/hair/shorthaireighties
	name = "Короткие волосы 80-х"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/rosa
	name = "Короткие волосы Розы"
	icon_state = "hair_rosa"

/datum/sprite_accessory/hair/shoulderlength
	name = "Волосы до плеч"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/sidecut
	name = "Сайдкат"
	icon_state = "hair_sidecut"

/datum/sprite_accessory/hair/skinhead
	name = "Бритоголовый"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/protagonist
	name = "Слегка длинные волосы"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/spiky
	name = "Колючие"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Колючие 2"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/spiky3
	name = "Колючие 3"
	icon_state = "hair_spiky2"

/datum/sprite_accessory/hair/swept
	name = "Зачёсанные назад волосы"
	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Зачёсанные назад волосы 2"
	icon_state = "hair_swept2"

/datum/sprite_accessory/hair/thinning
	name = "Редеющие"
	icon_state = "hair_thinning"

/datum/sprite_accessory/hair/thinningfront
	name = "Редеющие (Спереди)"
	icon_state = "hair_thinningfront"

/datum/sprite_accessory/hair/thinningrear
	name = "Редеющие (Сзади)"
	icon_state = "hair_thinningrear"

/datum/sprite_accessory/hair/topknot
	name = "Топ-кнот"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/tressshoulder
	name = "Прядь на плече"
	icon_state = "hair_tressshoulder"
	hair_appendages_inner = list("hair_tressshoulder_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_tressshoulder_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/trimmed
	name = "Подстриженные"
	icon_state = "hair_trimmed"

/datum/sprite_accessory/hair/trimflat
	name = "Ровно подстриженные"
	icon_state = "hair_trimflat"

/datum/sprite_accessory/hair/twintails
	name = "Два хвостика"
	icon_state = "hair_twintail"

/datum/sprite_accessory/hair/undercut
	name = "Андеркат"
	icon_state = "hair_undercut"

/datum/sprite_accessory/hair/undercutleft
	name = "Андеркат Слева"
	icon_state = "hair_undercutleft"

/datum/sprite_accessory/hair/undercutright
	name = "Андеркат Справа"
	icon_state = "hair_undercutright"

/datum/sprite_accessory/hair/unkept
	name = "Запущенные"
	icon_state = "hair_unkept"

/datum/sprite_accessory/hair/updo
	name = "Причёска вверх"
	icon_state = "hair_updo"
	hair_appendages_inner = list("hair_updo_a1" = HAIR_APPENDAGE_TOP)

/datum/sprite_accessory/hair/longer
	name = "Очень длинные волосы"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longest
	name = "Очень длинные волосы 2"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longest2
	name = "Очень длинные на глаз"
	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/veryshortovereye
	name = "Очень короткие на глаз"
	icon_state = "hair_veryshortovereyealternate"

/datum/sprite_accessory/hair/longestalt
	name = "Очень длинные с чёлкой"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/volaju
	name = "Волаю"
	icon_state = "hair_volaju"

/datum/sprite_accessory/hair/wisp
	name = "Прядь"
	icon_state = "hair_wisp"
	hair_appendages_inner = list("hair_wisp_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_wisp_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ziegler
	name = "Циглер"
	icon_state = "hair_ziegler"
	hair_appendages_inner = list("hair_ziegler_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ziegler_a1o" = HAIR_APPENDAGE_REAR)

/*
////////////////////////////////////////
/  =--------------------------------=  /
/  == Определения Градиентов Волос ==  /
/  =--------------------------------=  /
////////////////////////////////////////
*/

/datum/sprite_accessory/gradient
	icon = 'icons/mob/human/species/hair_gradients.dmi'
	///применяется ли этот градиент к волосам и/или бороде. Некоторые градиенты плохо работают на бородах.
	var/gradient_category = GRADIENT_APPLIES_TO_HAIR|GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/gradient/full
	name = "Полный"
	icon_state = "full"

/datum/sprite_accessory/gradient/fadeup
	name = "Затухание вверх"
	icon_state = "fadeup"

/datum/sprite_accessory/gradient/fadedown
	name = "Затухание вниз"
	icon_state = "fadedown"

/datum/sprite_accessory/gradient/vertical_split
	name = "Вертикальное разделение"
	icon_state = "vsplit"

/datum/sprite_accessory/gradient/horizontal_split
	name = "Горизонтальное разделение"
	icon_state = "bottomflat"

/datum/sprite_accessory/gradient/reflected
	name = "Отражённый"
	icon_state = "reflected_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected/beard
	icon_state = "reflected_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/reflected_inverse
	name = "Обратное отражение"
	icon_state = "reflected_inverse_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected_inverse/beard
	icon_state = "reflected_inverse_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy
	name = "Волнистый"
	icon_state = "wavy"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/long_fade_up
	name = "Длинное затухание вверх"
	icon_state = "long_fade_up"

/datum/sprite_accessory/gradient/long_fade_down
	name = "Длинное затухание вниз"
	icon_state = "long_fade_down"

/datum/sprite_accessory/gradient/short_fade_up
	name = "Короткое затухание вверх"
	icon_state = "short_fade_up"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_up/beard
	icon_state = "short_fade_down"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/short_fade_down
	name = "Короткое затухание вниз"
	icon_state = "short_fade_down_beard"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_down/beard
	icon_state = "short_fade_down_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy_spike
	name = "Колючий волнистый"
	icon_state = "wavy_spiked"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/striped
	name = "Полосатый"
	icon_state = "striped"

/datum/sprite_accessory/gradient/striped_vertical
	name = "Вертикальные полосы"
	icon_state = "striped_vertical"

////////////////////////
// Определения Бороды //
////////////////////////

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/human/human_face.dmi'
	gender = MALE // блевать (если только вы не дварф, дварфам нравятся чиксы с бородой :P)
	em_block = TRUE

// пожалуйста, убедитесь, что они отсортированы по алфавиту и распределены по категориям

/datum/sprite_accessory/facial_hair/abe
	name = "Борода (Авраам Линкольн)"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/brokenman
	name = "Борода (Сломанный человек)"
	icon_state = "facial_brokenman"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Борода (Ремешок)"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Борода (Дварф)"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Борода (Полная)"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/croppedfullbeard
	name = "Борода (Подстриженная)"
	icon_state = "facial_croppedfullbeard"

/datum/sprite_accessory/facial_hair/gt
	name = "Борода (Эспаньолка)"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/hip
	name = "Борода (Хипстер)"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/jensen
	name = "Борода (Дженсен)"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Борода (Шея)"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Борода (Очень длинная)"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/muttonmus
	name = "Борода (Бараньи усы)"
	icon_state = "facial_muttonmus"

/datum/sprite_accessory/facial_hair/martialartist
	name = "Борода (Мастер боевых искусств)"
	icon_state = "facial_martialartist"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinlessbeard
	name = "Борода (Без подбородка)"
	icon_state = "facial_chinlessbeard"

/datum/sprite_accessory/facial_hair/moonshiner
	name = "Борода (Самогонщик)"
	icon_state = "facial_moonshiner"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Борода (Длинная)"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/volaju
	name = "Борода (Волаю)"
	icon_state = "facial_volaju"

/datum/sprite_accessory/facial_hair/threeoclock
	name = "Борода (Трёхчасовая щетина)"
	icon_state = "facial_3oclock"

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Борода (Пятичасовая щетина)"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/fiveoclockm
	name = "Борода (Пятичасовые усы)"
	icon_state = "facial_5oclockmoustache"

/datum/sprite_accessory/facial_hair/sevenoclock
	name = "Борода (Семичасовая щетина)"
	icon_state = "facial_7oclock"

/datum/sprite_accessory/facial_hair/sevenoclockm
	name = "Борода (Семичасовые усы)"
	icon_state = "facial_7oclockmoustache"

/datum/sprite_accessory/facial_hair/moustache
	name = "Усы"
	icon_state = "facial_moustache"

/datum/sprite_accessory/facial_hair/pencilstache
	name = "Усы (Карандаш)"
	icon_state = "facial_pencilstache"

/datum/sprite_accessory/facial_hair/smallstache
	name = "Усы (Маленькие)"
	icon_state = "facial_smallstache"

/datum/sprite_accessory/facial_hair/walrus
	name = "Усы (Морж)"
	icon_state = "facial_walrus"

/datum/sprite_accessory/facial_hair/fu
	name = "Усы (Фу Маньчжу)"
	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/hogan
	name = "Усы (Халк Хоган)"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/selleck
	name = "Усы (Селлек)"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Усы (Квадратные)"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/vandyke
	name = "Усы (Ван Дайк)"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/watson
	name = "Усы (Ватсон)"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/handlebar
	name = "Усы (Рульки)"
	icon_state = "facial_handlebar"

/datum/sprite_accessory/facial_hair/handlebar2
	name = "Усы (Рульки 2)"
	icon_state = "facial_handlebar2"

/datum/sprite_accessory/facial_hair/elvis
	name = "Бакенбарды (Элвис)"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/mutton
	name = "Бакенбарды (Бараньи отбивные)"
	icon_state = "facial_mutton"

/datum/sprite_accessory/facial_hair/sideburn
	name = "Бакенбарды"
	icon_state = "facial_sideburn"

/datum/sprite_accessory/facial_hair/shaved
	name = "Выбритый"
	icon_state = null
	gender = NEUTER

///////////////////////////
// Underwear Definitions //
///////////////////////////

/datum/sprite_accessory/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	use_static = FALSE
	em_block = TRUE


//МУЖСКОЕ НИЖНЕЕ БЕЛЬЕ
/datum/sprite_accessory/underwear/nude
	name = "Ничего"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/underwear/male_briefs
	name = "Трусы-плавки"
	icon_state = "male_briefs"
	gender = MALE

/datum/sprite_accessory/underwear/male_boxers
	name = "Боксеры"
	icon_state = "male_boxers"
	gender = MALE

/datum/sprite_accessory/underwear/male_stripe
	name = "Полосатые боксеры"
	icon_state = "male_stripe"
	gender = MALE

/datum/sprite_accessory/underwear/male_midway
	name = "Боксеры Мидуэй"
	icon_state = "male_midway"
	gender = MALE

/datum/sprite_accessory/underwear/male_longjohns
	name = "Кальсоны"
	icon_state = "male_longjohns"
	gender = MALE

/datum/sprite_accessory/underwear/male_kinky
	name = "Поддерживающие трусы"
	icon_state = "male_kinky"
	gender = MALE

/datum/sprite_accessory/underwear/male_mankini
	name = "Манкини"
	icon_state = "male_mankini"
	gender = MALE

/datum/sprite_accessory/underwear/male_hearts
	name = "Боксеры с сердцами"
	icon_state = "male_hearts"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_commie
	name = "Коммунистические боксеры"
	icon_state = "male_commie"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_usastripe
	name = "Боксеры Свободы"
	icon_state = "male_assblastusa"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_uk
	name = "Британские боксеры"
	icon_state = "male_uk"
	gender = MALE
	use_static = TRUE


//ЖЕНСКОЕ НИЖНЕЕ БЕЛЬЕ
/datum/sprite_accessory/underwear/female_bikini
	name = "Бикини"
	icon_state = "female_bikini"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_lace
	name = "Кружевное бикини"
	icon_state = "female_lace"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_bralette
	name = "Бралетте с шортами"
	icon_state = "female_bralette"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_sport
	name = "Спортивный топ с шортами"
	icon_state = "female_sport"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_thong
	name = "Тонг"
	icon_state = "female_thong"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_strapless
	name = "Бикини без бретелек"
	icon_state = "female_strapless"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_babydoll
	name = "Бэбидол"
	icon_state = "female_babydoll"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_onepiece
	name = "Цельный купальник"
	icon_state = "swim_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_onepiece
	name = "Цельный купальник без бретелек"
	icon_state = "swim_strapless_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_twopiece
	name = "Двухсекционный купальник"
	icon_state = "swim_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_twopiece
	name = "Двухсекционный купальник без бретелек"
	icon_state = "swim_strapless_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_stripe
	name = "Полосатый купальник без бретелек"
	icon_state = "swim_stripe"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_halter
	name = "Купальник с завязкой на шее"
	icon_state = "swim_halter"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white_neko
	name = "Неко бикини (Белое)"
	icon_state = "female_neko_white"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_black_neko
	name = "Неко бикини (Черное)"
	icon_state = "female_neko_black"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_commie
	name = "Коммунистическое бикини"
	icon_state = "female_commie"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_usastripe
	name = "Бикини Свободы"
	icon_state = "female_assblastusa"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_uk
	name = "Британское бикини"
	icon_state = "female_uk"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_kinky
	name = "Белье"
	icon_state = "female_kinky"
	gender = FEMALE
	use_static = TRUE

////////////////////////////
//    Определения Маек    //
////////////////////////////

/datum/sprite_accessory/undershirt
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE

/datum/sprite_accessory/undershirt/nude
	name = "Ничего"
	icon_state = null
	gender = NEUTER

// пожалуйста, убедитесь, что они отсортированы по алфавиту и распределены по категориям

/datum/sprite_accessory/undershirt/bluejersey
	name = "Джерси (Синее)"
	icon_state = "shirt_bluejersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redjersey
	name = "Джерси (Красное)"
	icon_state = "shirt_redjersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluepolo
	name = "Поло (Синяя)"
	icon_state = "bluepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/grayyellowpolo
	name = "Поло (Серо-желтая)"
	icon_state = "grayyellowpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redpolo
	name = "Поло (Красная)"
	icon_state = "redpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whitepolo
	name = "Поло (Белая)"
	icon_state = "whitepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/alienshirt
	name = "Футболка (Пришелец)"
	icon_state = "shirt_alien"
	gender = NEUTER

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Футболка (Группа)"
	icon_state = "band"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_black
	name = "Футболка (Черная)"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirt
	name = "Футболка (Синяя)"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/clownshirt
	name = "Футболка (Клоун)"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/undershirt/commie
	name = "Футболка (Коммунист)"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirt
	name = "Футболка (Зеленая)"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Футболка (Серая)"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ian
	name = "Футболка (Ян)"
	icon_state = "ian"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ilovent
	name = "Футболка (Я люблю NT)"
	icon_state = "ilovent"
	gender = NEUTER

/datum/sprite_accessory/undershirt/lover
	name = "Футболка (Любовник)"
	icon_state = "lover"
	gender = NEUTER

/datum/sprite_accessory/undershirt/matroska
	name = "Футболка (Матрешка)"
	icon_state = "matroska"
	gender = NEUTER

/datum/sprite_accessory/undershirt/meat
	name = "Футболка (Мясо)"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/undershirt/nano
	name = "Футболка (Нанотрейзен)"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/undershirt/peace
	name = "Футболка (Мир)"
	icon_state = "peace"
	gender = NEUTER

/datum/sprite_accessory/undershirt/pacman
	name = "Футболка (Пакман)"
	icon_state = "pogoman"
	gender = NEUTER

/datum/sprite_accessory/undershirt/question
	name = "Футболка (Вопрос)"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirt
	name = "Футболка (Красная)"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/skull
	name = "Футболка (Череп)"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ss13
	name = "Футболка (SS13)"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/undershirt/stripe
	name = "Футболка (Полосатая)"
	icon_state = "shirt_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tiedye
	name = "Футболка (Тай-дай)"
	icon_state = "shirt_tiedye"
	gender = NEUTER

/datum/sprite_accessory/undershirt/uk
	name = "Футболка (Великобритания)"
	icon_state = "uk"
	gender = NEUTER

/datum/sprite_accessory/undershirt/usa
	name = "Футболка (США)"
	icon_state = "shirt_assblastusa"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_white
	name = "Футболка (Белая)"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blackshortsleeve
	name = "Футболка с коротким рукавом (Черная)"
	icon_state = "blackshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshortsleeve
	name = "Футболка с коротким рукавом (Синяя)"
	icon_state = "blueshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshortsleeve
	name = "Футболка с коротким рукавом (Зеленая)"
	icon_state = "greenshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/purpleshortsleeve
	name = "Футболка с коротким рукавом (Фиолетовая)"
	icon_state = "purpleshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whiteshortsleeve
	name = "Футболка с коротким рукавом (Белая)"
	icon_state = "whiteshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra
	name = "Спортивный бюстгальтер"
	icon_state = "sports_bra"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra2
	name = "Спортивный бюстгальтер (Альт)"
	icon_state = "sports_bra_alt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirtsport
	name = "Спортивная футболка (Синяя)"
	icon_state = "blueshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirtsport
	name = "Спортивная футболка (Зеленая)"
	icon_state = "greenshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirtsport
	name = "Спортивная футболка (Красная)"
	icon_state = "redshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Майка (Черная)"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankfire
	name = "Майка (Огонь)"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Майка (Серая)"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/female_midriff
	name = "Майка (Мидриф)"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_red
	name = "Майка (Красная)"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankstripe
	name = "Майка (Полосатая)"
	icon_state = "tank_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_white
	name = "Майка (Белая)"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redtop
	name = "Топ (Красный)"
	icon_state = "redtop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/whitetop
	name = "Топ (Белый)"
	icon_state = "whitetop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tshirt_blue
	name = "Футболка (Синяя)"
	icon_state = "blueshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_green
	name = "Футболка (Зеленая)"
	icon_state = "greenshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_red
	name = "Футболка (Красная)"
	icon_state = "redshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/yellowshirt
	name = "Футболка (Желтая)"
	icon_state = "yellowshirt"
	gender = NEUTER

////////////////////////
// Определения Носков //
////////////////////////

/datum/sprite_accessory/socks
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE

/datum/sprite_accessory/socks/nude
	name = "Ничего"
	icon_state = null

// пожалуйста, убедитесь, что они отсортированы по алфавиту и распределены по категориям

/datum/sprite_accessory/socks/ace_knee
	name = "До колен (Асексуальные)"
	icon_state = "ace_knee"

/datum/sprite_accessory/socks/bee_knee
	name = "До колен (Пчелиные)"
	icon_state = "bee_knee"

/datum/sprite_accessory/socks/black_knee
	name = "До колен (Черные)"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/commie_knee
	name = "До колен (Коммунистические)"
	icon_state = "commie_knee"

/datum/sprite_accessory/socks/usa_knee
	name = "До колен (Свобода)"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "До колен (Радужные)"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/striped_knee
	name = "До колен (Полосатые)"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "До колен (Тонкие)"
	icon_state = "thin_knee"

/datum/sprite_accessory/socks/trans_knee
	name = "До колен (Транс)"
	icon_state = "trans_knee"

/datum/sprite_accessory/socks/uk_knee
	name = "До колен (Великобритания)"
	icon_state = "uk_knee"

/datum/sprite_accessory/socks/white_knee
	name = "До колен (Белые)"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/fishnet_knee
	name = "До колен (Сетка)"
	icon_state = "fishnet_knee"

/datum/sprite_accessory/socks/black_norm
	name = "Обычные (Черные)"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_norm
	name = "Обычные (Белые)"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/pantyhose
	name = "Колготки"
	icon_state = "pantyhose"

/datum/sprite_accessory/socks/black_short
	name = "Короткие (Черные)"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_short
	name = "Короткие (Белые)"
	icon_state = "white_short"

/datum/sprite_accessory/socks/stockings_blue
	name = "Чулки (Синие)"
	icon_state = "stockings_blue"

/datum/sprite_accessory/socks/stockings_cyan
	name = "Чулки (Бирюзовые)"
	icon_state = "stockings_cyan"

/datum/sprite_accessory/socks/stockings_dpink
	name = "Чулки (Темно-розовые)"
	icon_state = "stockings_dpink"

/datum/sprite_accessory/socks/stockings_green
	name = "Чулки (Зеленые)"
	icon_state = "stockings_green"

/datum/sprite_accessory/socks/stockings_orange
	name = "Чулки (Оранжевые)"
	icon_state = "stockings_orange"

/datum/sprite_accessory/socks/stockings_programmer
	name = "Чулки (Программист)"
	icon_state = "stockings_lpink"

/datum/sprite_accessory/socks/stockings_purple
	name = "Чулки (Фиолетовые)"
	icon_state = "stockings_purple"

/datum/sprite_accessory/socks/stockings_yellow
	name = "Чулки (Желтые)"
	icon_state = "stockings_yellow"

/datum/sprite_accessory/socks/stockings_fishnet
	name = "Чулки (Сетка)"
	icon_state = "fishnet_full"

/datum/sprite_accessory/socks/ace_thigh
	name = "До бедра (Асексуальные)"
	icon_state = "ace_thigh"

/datum/sprite_accessory/socks/bee_thigh
	name = "До бедра (Пчелиные)"
	icon_state = "bee_thigh"

/datum/sprite_accessory/socks/black_thigh
	name = "До бедра (Черные)"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/commie_thigh
	name = "До бедра (Коммунистические)"
	icon_state = "commie_thigh"

/datum/sprite_accessory/socks/usa_thigh
	name = "До бедра (Свобода)"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "До бедра (Радужные)"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/striped_thigh
	name = "До бедра (Полосатые)"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "До бедра (Тонкие)"
	icon_state = "thin_thigh"

/datum/sprite_accessory/socks/trans_thigh
	name = "До бедра (Транс)"
	icon_state = "trans_thigh"

/datum/sprite_accessory/socks/uk_thigh
	name = "До бедра (Великобритания)"
	icon_state = "uk_thigh"

/datum/sprite_accessory/socks/white_thigh
	name = "До бедра (Белые)"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/fishnet_thigh
	name = "До бедра (Сетка)"
	icon_state = "fishnet_thigh"

/datum/sprite_accessory/socks/thocks
	name = "Токси"
	icon_state = "thocks"

/////////////////////////////////
// Определения Частей Мутантов //
/////////////////////////////////

/datum/sprite_accessory/lizard_markings
	icon = 'icons/mob/human/species/lizard/lizard_markings.dmi'

/datum/sprite_accessory/lizard_markings/dtiger
	name = "Темное тигриное тело"
	icon_state = "dtiger"
	gender_specific = TRUE

/datum/sprite_accessory/lizard_markings/ltiger
	name = "Светлое тигриное тело"
	icon_state = "ltiger"
	gender_specific = TRUE

/datum/sprite_accessory/lizard_markings/lbelly
	name = "Светлое брюшко"
	icon_state = "lbelly"
	gender_specific = TRUE

/datum/sprite_accessory/tails
	em_block = TRUE
	/// Описывает, какие спрайты позвоночника хвоста использовать, если есть.
	var/spine_key = NONE

///Используется для рыбных хвостов, которые бывают разных видов.
/datum/sprite_accessory/tails/fish
	icon = 'icons/mob/human/fish_features.dmi'
	color_src = TRUE

/datum/sprite_accessory/tails/fish/simple
	name = "Простой"
	icon_state = "simple"

/datum/sprite_accessory/tails/fish/crescent
	name = "Полумесяц"
	icon_state = "crescent"

/datum/sprite_accessory/tails/fish/long
	name = "Длинный"
	icon_state = "long"
	center = TRUE
	dimension_x = 38

/datum/sprite_accessory/tails/fish/shark
	name = "Акулий"
	icon_state = "shark"

/datum/sprite_accessory/tails/fish/chonky
	name = "Толстый"
	icon_state = "chonky"
	center = TRUE
	dimension_x = 36

/datum/sprite_accessory/tails/lizard
	icon = 'icons/mob/human/species/lizard/lizard_tails.dmi'
	spine_key = SPINE_KEY_LIZARD

/datum/sprite_accessory/tails/lizard/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/lizard/smooth
	name = "Гладкий"
	icon_state = "smooth"

/datum/sprite_accessory/tails/lizard/dtiger
	name = "Темный тигровый"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/lizard/ltiger
	name = "Светлый тигровый"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/lizard/spikes
	name = "С шипами"
	icon_state = "spikes"

/datum/sprite_accessory/tails/lizard/short
	name = "Короткий"
	icon_state = "short"
	spine_key = NONE

/datum/sprite_accessory/tails/felinid/cat
	name = "Кошка"
	icon = 'icons/mob/human/cat_features.dmi'
	icon_state = "default"
	color_src = HAIR_COLOR

/datum/sprite_accessory/tails/monkey

/datum/sprite_accessory/tails/monkey/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/monkey/default
	name = "Обезьяний"
	icon = 'icons/mob/human/species/monkey/monkey_tail.dmi'
	icon_state = "default"
	color_src = FALSE

/datum/sprite_accessory/tails/xeno
	icon_state = "default"
	color_src = FALSE
	center = TRUE

/datum/sprite_accessory/tails/xeno/default
	name = "Ксеноморф"
	icon = 'icons/mob/human/species/alien/tail_xenomorph.dmi'
	dimension_x = 40

/datum/sprite_accessory/tails/xeno/queen
	name = "Королева ксеноморфов"
	icon = 'icons/mob/human/species/alien/tail_xenomorph_queen.dmi'
	dimension_x = 64

/datum/sprite_accessory/pod_hair
	icon = 'icons/mob/human/species/podperson_hair.dmi'
	em_block = TRUE

/datum/sprite_accessory/pod_hair/ivy
	name = "Плющ"
	icon_state = "ivy"

/datum/sprite_accessory/pod_hair/cabbage
	name = "Капуста"
	icon_state = "cabbage"

/datum/sprite_accessory/pod_hair/spinach
	name = "Шпинат"
	icon_state = "spinach"

/datum/sprite_accessory/pod_hair/prayer
	name = "Молитва"
	icon_state = "prayer"

/datum/sprite_accessory/pod_hair/vine
	name = "Лоза"
	icon_state = "vine"

/datum/sprite_accessory/pod_hair/shrub
	name = "Кустарник"
	icon_state = "shrub"

/datum/sprite_accessory/pod_hair/rose
	name = "Роза"
	icon_state = "rose"

/datum/sprite_accessory/pod_hair/orchid
	name = "Орхидея"
	icon_state = "orchid"

/datum/sprite_accessory/pod_hair/fig
	name = "Инжир"
	icon_state = "fig"

/datum/sprite_accessory/pod_hair/hibiscus
	name = "Гибискус"
	icon_state = "hibiscus"

/datum/sprite_accessory/snouts
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'
	em_block = TRUE

/datum/sprite_accessory/snouts/sharp
	name = "Острый"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/round
	name = "Круглый"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharplight
	name = "Острый + Светлый"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Круглый + Светлый"
	icon_state = "roundlight"

/datum/sprite_accessory/horns
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'
	em_block = TRUE

/datum/sprite_accessory/horns/simple
	name = "Простой"
	icon_state = "simple"

/datum/sprite_accessory/horns/short
	name = "Короткий"
	icon_state = "short"

/datum/sprite_accessory/horns/curled
	name = "Завитой"
	icon_state = "curled"

/datum/sprite_accessory/horns/ram
	name = "Баран"
	icon_state = "ram"

/datum/sprite_accessory/horns/angler
	name = "Удильщик"
	icon_state = "angler"

/datum/sprite_accessory/ears
	icon = 'icons/mob/human/cat_features.dmi'
	em_block = TRUE

/datum/sprite_accessory/ears/cat
	name = "Кошачьи"
	icon_state = "cat"
	color_src = HAIR_COLOR

/datum/sprite_accessory/ears/cat/big
	name = "Большие"
	icon_state = "big"

/datum/sprite_accessory/ears/cat/miqo
	name = "Коеурл"
	icon_state = "miqo"

/datum/sprite_accessory/ears/cat/fold
	name = "Сложенные"
	icon_state = "fold"

/datum/sprite_accessory/ears/cat/lynx
	name = "Рысь"
	icon_state = "lynx"

/datum/sprite_accessory/ears/cat/round
	name = "Круглые"
	icon_state = "round"

/datum/sprite_accessory/ears/fox
	icon = 'icons/mob/human/fox_features.dmi'
	name = "Лисьи"
	icon_state = "fox"
	color_src = HAIR_COLOR
	locked = TRUE

/datum/sprite_accessory/wings
	icon = 'icons/mob/human/species/wings.dmi'
	em_block = TRUE

/datum/sprite_accessory/wings_open
	icon = 'icons/mob/human/species/wings.dmi'
	em_block = TRUE

/datum/sprite_accessory/wings/angel
	name = "Ангельские"
	icon_state = "angel"
	color_src = FALSE
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	locked = TRUE

/datum/sprite_accessory/wings_open/angel
	name = "Ангельские"
	icon_state = "angel"
	color_src = FALSE
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings/dragon
	name = "Драконьи"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/dragon
	name = "Драконьи"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/megamoth
	name = "Мегамоль"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/megamoth
	name = "Мегамоль"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/mothra
	name = "Мотра"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/mothra
	name = "Мотра"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/skeleton
	name = "Скелетные"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/skeleton
	name = "Скелетные"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/robotic
	name = "Роботизированные"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/robotic
	name = "Роботизированные"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/fly
	name = "Мушиные"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/fly
	name = "Мушиные"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/slime
	name = "Слизневые"
	icon_state = "slime"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/slime
	name = "Слизневые"
	icon_state = "slime"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/frills
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'

/datum/sprite_accessory/frills/simple
	name = "Простые"
	icon_state = "simple"

/datum/sprite_accessory/frills/short
	name = "Короткие"
	icon_state = "short"

/datum/sprite_accessory/frills/aquatic
	name = "Водные"
	icon_state = "aqua"

/datum/sprite_accessory/spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'
	em_block = TRUE

/datum/sprite_accessory/tail_spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'
	em_block = TRUE

/datum/sprite_accessory/spines/short
	name = "Короткие"
	icon_state = "short"

/datum/sprite_accessory/tail_spines/short
	name = "Короткие"
	icon_state = "short"

/datum/sprite_accessory/spines/shortmeme
	name = "Короткие + Мембрана"
	icon_state = "shortmeme"

/datum/sprite_accessory/tail_spines/shortmeme
	name = "Короткие + Мембрана"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines/long
	name = "Длинные"
	icon_state = "long"

/datum/sprite_accessory/tail_spines/long
	name = "Длинные"
	icon_state = "long"

/datum/sprite_accessory/spines/longmeme
	name = "Длинные + Мембрана"
	icon_state = "longmeme"

/datum/sprite_accessory/tail_spines/longmeme
	name = "Длинные + Мембрана"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/aquatic
	name = "Водные"
	icon_state = "aqua"

/datum/sprite_accessory/tail_spines/aquatic
	name = "Водные"
	icon_state = "aqua"

/datum/sprite_accessory/caps
	icon = 'icons/mob/human/species/mush_cap.dmi'
	color_src = HAIR_COLOR
	em_block = TRUE

/datum/sprite_accessory/caps/round
	name = "Круглая"
	icon_state = "round"

/datum/sprite_accessory/moth_wings
	icon = 'icons/mob/human/species/moth/moth_wings.dmi'
	color_src = null
	em_block = TRUE

/datum/sprite_accessory/moth_wings/plain
	name = "Обычные"
	icon_state = "plain"

/datum/sprite_accessory/moth_wings/monarch
	name = "Монарх"
	icon_state = "monarch"

/datum/sprite_accessory/moth_wings/luna
	name = "Луна"
	icon_state = "luna"

/datum/sprite_accessory/moth_wings/atlas
	name = "Атлас"
	icon_state = "atlas"

/datum/sprite_accessory/moth_wings/reddish
	name = "Красноватые"
	icon_state = "redish"

/datum/sprite_accessory/moth_wings/royal
	name = "Королевские"
	icon_state = "royal"

/datum/sprite_accessory/moth_wings/gothic
	name = "Готические"
	icon_state = "gothic"

/datum/sprite_accessory/moth_wings/lovers
	name = "Влюбленные"
	icon_state = "lovers"

/datum/sprite_accessory/moth_wings/whitefly
	name = "Белая муха"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_wings/burnt_off
	name = "Обгоревшие"
	icon_state = "burnt_off"
	locked = TRUE

/datum/sprite_accessory/moth_wings/firewatch
	name = "Огненная стража"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_wings/deathhead
	name = "Мертвая голова"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_wings/poison
	name = "Ядовитые"
	icon_state = "poison"

/datum/sprite_accessory/moth_wings/ragged
	name = "Обтрёпанные"
	icon_state = "ragged"

/datum/sprite_accessory/moth_wings/moonfly
	name = "Лунная муха"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_wings/snow
	name = "Снежные"
	icon_state = "snow"

/datum/sprite_accessory/moth_wings/oakworm
	name = "Дубовый червь"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_wings/jungle
	name = "Джунгли"
	icon_state = "jungle"

/datum/sprite_accessory/moth_wings/witchwing
	name = "Ведьмино крыло"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_wings/rosy
	name = "Розовые"
	icon_state = "rosy"

/datum/sprite_accessory/moth_wings/feathery
	name = "Перьевые"
	icon_state = "feathery"

/datum/sprite_accessory/moth_wings/brown
	name = "Коричневые"
	icon_state = "brown"

/datum/sprite_accessory/moth_wings/plasmafire
	name = "Плазменный огонь"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_wings/moffra
	name = "Моффра"
	icon_state = "moffra"

/datum/sprite_accessory/moth_wings/lightbearer
	name = "Светоносец"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_wings/dipped
	name = "Окунутые"
	icon_state = "dipped"

/datum/sprite_accessory/moth_antennae //Наконец разделяем спрайт
	icon = 'icons/mob/human/species/moth/moth_antennae.dmi'
	color_src = null

/datum/sprite_accessory/moth_antennae/plain
	name = "Обычные"
	icon_state = "plain"

/datum/sprite_accessory/moth_antennae/reddish
	name = "Красноватые"
	icon_state = "reddish"

/datum/sprite_accessory/moth_antennae/royal
	name = "Королевские"
	icon_state = "royal"

/datum/sprite_accessory/moth_antennae/gothic
	name = "Готические"
	icon_state = "gothic"

/datum/sprite_accessory/moth_antennae/whitefly
	name = "Белая муха"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_antennae/lovers
	name = "Влюбленные"
	icon_state = "lovers"

/datum/sprite_accessory/moth_antennae/burnt_off
	name = "Обгоревшие"
	icon_state = "burnt_off"

/datum/sprite_accessory/moth_antennae/firewatch
	name = "Огненная стража"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_antennae/deathhead
	name = "Мертвая голова"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_antennae/poison
	name = "Ядовитые"
	icon_state = "poison"

/datum/sprite_accessory/moth_antennae/ragged
	name = "Обтрёпанные"
	icon_state = "ragged"

/datum/sprite_accessory/moth_antennae/moonfly
	name = "Лунная муха"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_antennae/oakworm
	name = "Дубовый червь"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_antennae/jungle
	name = "Джунгли"
	icon_state = "jungle"

/datum/sprite_accessory/moth_antennae/witchwing
	name = "Ведьмино крыло"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_antennae/regal
	name = "Величественные"
	icon_state = "regal"

/datum/sprite_accessory/moth_antennae/rosy
	name = "Розовые"
	icon_state = "rosy"

/datum/sprite_accessory/moth_antennae/feathery
	name = "Перьевые"
	icon_state = "feathery"

/datum/sprite_accessory/moth_antennae/brown
	name = "Коричневые"
	icon_state = "brown"

/datum/sprite_accessory/moth_antennae/plasmafire
	name = "Плазменный огонь"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_antennae/moffra
	name = "Моффра"
	icon_state = "moffra"

/datum/sprite_accessory/moth_antennae/lightbearer
	name = "Светоносец"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_antennae/dipped
	name = "Окунутые"
	icon_state = "dipped"

/datum/sprite_accessory/moth_markings // отметины, которые могут быть у моли. наконец-то что-то кроме скучного загара
	icon = 'icons/mob/human/species/moth/moth_markings.dmi'
	color_src = null

/datum/sprite_accessory/moth_markings/reddish
	name = "Красноватые"
	icon_state = "reddish"

/datum/sprite_accessory/moth_markings/royal
	name = "Королевские"
	icon_state = "royal"

/datum/sprite_accessory/moth_markings/gothic
	name = "Готические"
	icon_state = "gothic"

/datum/sprite_accessory/moth_markings/whitefly
	name = "Белая муха"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_markings/lovers
	name = "Влюбленные"
	icon_state = "lovers"

/datum/sprite_accessory/moth_markings/burnt_off
	name = "Обгоревшие"
	icon_state = "burnt_off"

/datum/sprite_accessory/moth_markings/firewatch
	name = "Огненная стража"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_markings/deathhead
	name = "Мертвая голова"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_markings/poison
	name = "Ядовитые"
	icon_state = "poison"

/datum/sprite_accessory/moth_markings/ragged
	name = "Обтрёпанные"
	icon_state = "ragged"

/datum/sprite_accessory/moth_markings/moonfly
	name = "Лунная муха"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_markings/oakworm
	name = "Дубовый червь"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_markings/jungle
	name = "Джунгли"
	icon_state = "jungle"

/datum/sprite_accessory/moth_markings/witchwing
	name = "Ведьмино крыло"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_markings/lightbearer
	name = "Светоносец"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_markings/dipped
	name = "Окунутые"
	icon_state = "dipped"
