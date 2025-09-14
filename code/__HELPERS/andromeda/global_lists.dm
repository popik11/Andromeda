/proc/make_andromeda_datum_references()
	make_bloopers()

// Текстовые барки (голоса)
/proc/make_bloopers()
	GLOB.blooper_list = list()
	for(var/sound_blooper_path in subtypesof(/datum/blooper))
		var/datum/blooper/bloop = new sound_blooper_path()
		GLOB.blooper_list[bloop.id] = sound_blooper_path
		if(bloop.allow_random)
			GLOB.blooper_random_list[bloop.id] = sound_blooper_path
