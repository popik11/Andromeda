#define DOOM_SINGULARITY "singularity"
#define DOOM_TESLA "tesla"
#define DOOM_METEORS "meteors"

/// Убей себя и, вероятно, кучу других людей
/datum/grand_finale/armageddon
	name = "Аннигиляция"
	desc = "Этот экипаж оскорбил вас за пределами мира шуток. Принесите высшую жертву, чтобы преподать им урок, который ваши старшие действительно оценят. \
		ВЫ НЕ ВЫЖИТЕ."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	minimum_time = 90 MINUTES // Это, вероятно, немедленно завершит раунд, если будет завершено.
	ritual_invoke_time = 60 SECONDS // Дайте экипажу время помешать этому.
	dire_warning = TRUE
	glow_colour = "#be000048"
	/// Фразы, которые можно выкрикнуть перед смертью
	var/static/list/possible_last_words = list(
		"Пламя и разрушение!",
		"Дооооооооом!!",
		"ХАХАХАХАХАХА!! АХАХАХАХАХАХАХАА!!",
		"Хи-хи-хи!! Ху-ху-ху!! Ха-ха-хаа!!",
		"Охохохохохо!!",
		"Трепещите в страхе, жалкие смертные!",
		"Содрогайтесь перед моим величием!",
		"Молитесь своим богам!",
		"Это бесполезно!",
		"Если бы боги хотели, чтобы вы жили, они не создали бы меня!",
		"Бог остаётся на небесах из страха перед тем, что я создал!",
		"Пришло разрушение!",
		"Всё творение, склонитесь перед моей волей!",
	)

/datum/grand_finale/armageddon/trigger(mob/living/carbon/human/invoker)
	priority_announce(pick(possible_last_words), null, 'sound/effects/magic/voidblink.ogg', sender_override = "[invoker.real_name]", color_override = "purple")
	var/turf/current_location = get_turf(invoker)
	invoker.gib(DROP_ALL_REMAINS)

	var/static/list/doom_options = list()
	if (!length(doom_options))
		doom_options = list(DOOM_SINGULARITY, DOOM_TESLA)
		if (!SSmapping.is_planetary())
			doom_options += DOOM_METEORS

	switch(pick(doom_options))
		if (DOOM_SINGULARITY)
			var/obj/singularity/singulo = new(current_location)
			singulo.energy = 300
		if (DOOM_TESLA)
			var/obj/energy_ball/tesla = new (current_location)
			tesla.energy = 200
		if (DOOM_METEORS)
			GLOB.meteor_mode ||= new()
			GLOB.meteor_mode.meteordelay = 0
			GLOB.meteor_mode.start_meteor()
			priority_announce("Обнаружены метеоры на курсе столкновения со станцией.", "Метеорная тревога", ANNOUNCER_METEORS)

#undef DOOM_SINGULARITY
#undef DOOM_TESLA
#undef DOOM_METEORS
