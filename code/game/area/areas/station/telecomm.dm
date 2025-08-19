/*
* Зоны телекоммуникационного спутника
*/

/area/station/tcommsat
	icon_state = "tcomsatcham"
	ambientsounds = list(
		'sound/ambience/engineering/ambisin2.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/general/ambigen9.ogg',
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambitech3.ogg',
		'sound/ambience/misc/ambimystery.ogg',
		)
	airlock_wires = /datum/wires/airlock/engineering

/area/station/tcommsat/computer
	name = "\improper Диспетчерская телекоммуникаций"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/tcommsat/server
	name = "\improper Серверная телекоммуникаций"
	icon_state = "tcomsatcham"

/area/station/tcommsat/server/upper
	name = "\improper Верхняя серверная телекоммуникаций"

/*
* Станционные телекоммуникационные зоны
*/

/area/station/comms
	name = "\improper Коммуникационный ретранслятор"
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/server
	name = "\improper Серверная сообщений"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION
