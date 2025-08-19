// Specific AI monitored areas

// Stub defined ai_monitored.dm
/area/station/ai_monitored

/area/station/ai_monitored/turret_protected

// AI
/area/station/ai_monitored
	icon_state = "ai"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/ai_monitored/aisat/exterior
	name = "\improper Внешняя зона ИИ-Спутника"
	icon_state = "ai"
	airlock_wires = /datum/wires/airlock/ai

/area/station/ai_monitored/command/storage/satellite
	name = "\improper Технические помещения ИИ-Спутника"
	icon_state = "ai_storage"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/ai

// Turret protected
/area/station/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/engineering/ambitech.ogg', 'sound/ambience/engineering/ambitech2.ogg', 'sound/ambience/engineering/ambiatmos.ogg', 'sound/ambience/engineering/ambiatmos2.ogg')
	///Some sounds (like the space jam) are terrible when on loop. We use this variable to add it to other AI areas, but override it to keep it from the AI's core.
	var/ai_will_not_hear_this = list('sound/ambience/misc/ambimalf.ogg')
	airlock_wires = /datum/wires/airlock/ai

/area/station/ai_monitored/turret_protected/Initialize(mapload)
	. = ..()
	if(ai_will_not_hear_this)
		ambientsounds += ai_will_not_hear_this

/area/station/ai_monitored/turret_protected/ai_upload
	name = "\improper Камера загрузки ИИ"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/ai_monitored/turret_protected/ai_upload_foyer
	name = "\improper Шлюз загрузки ИИ"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/ai_monitored/turret_protected/ai
	name = "\improper Ядро ИИ"
	icon_state = "ai_chamber"
	ai_will_not_hear_this = null

/area/station/ai_monitored/turret_protected/aisat
	name = "\improper Спутник ИИ"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/ai_monitored/turret_protected/aisat/atmos
	name = "\improper Атмосфера спутника ИИ"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/foyer
	name = "\improper Вестибюль спутника ИИ"
	icon_state = "ai_foyer"

/area/station/ai_monitored/turret_protected/aisat/service
	name = "\improper Сервисный отсек спутника ИИ"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/hallway
	name = "\improper Коридор спутника ИИ"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/teleporter
	name ="\improper Телепорт спутника ИИ"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/equipment
	name ="\improper Оборудование спутника ИИ"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/maint
	name = "\improper Техтоннели спутника ИИ"
	icon_state = "ai_maint"

/area/station/ai_monitored/turret_protected/aisat/uppernorth
	name = "\improper Верхний северный отсек спутника ИИ"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/uppersouth
	name = "\improper Верхний южный отсек спутника ИИ"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat_interior
	name = "\improper Предбанник спутника ИИ"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/ai_monitored/turret_protected/ai_sat_ext_as
	name = "\improper Внешняя зона ИИ Спутника"
	icon_state = "ai_sat_east"

/area/station/ai_monitored/turret_protected/ai_sat_ext_ap
	name = "\improper Внешняя зона ИИ Спутника"
	icon_state = "ai_sat_west"

// Станционные помещения под наблюдением ИИ, перенесены сюда для единообразия

//Командные - под наблюдением ИИ
/area/station/ai_monitored/command/storage/eva
	name = "Хранилище EVA"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER

/area/station/ai_monitored/command/storage/eva/upper
	name = "Верхнее хранилище EVA"

/area/station/ai_monitored/command/nuke_storage
	name = "\improper Хранилище"
	icon_state = "nuke_storage"
	airlock_wires = /datum/wires/airlock/command

//Служба безопасности - под наблюдением ИИ
/area/station/ai_monitored/security/armory
	name = "\improper Оружейная"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security

/area/station/ai_monitored/security/armory/upper
	name = "Верхняя оружейная"
