/datum/disease/chronic_illness
	name = "Наследственная многообразная болезнь"
	max_stages = 5
	spread_text = "Незаразное заболевание"
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	disease_flags = CHRONIC
	infectable_biotypes = MOB_ORGANIC | MOB_MINERAL | MOB_ROBOTIC
	process_dead = TRUE
	stage_prob = 0.25
	cure_text = "Сансуфентанил"
	cures = list(/datum/reagent/medicine/sansufentanyl)
	infectivity = 0
	agent = "Квантовая запутанность"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Болезнь, обнаруженная в лаборатории Интердайн, вызванная воздействием технологий коррекции временного потока."
	severity = DISEASE_SEVERITY_UNCURABLE
	bypasses_immunity = TRUE

/datum/disease/chronic_illness/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			carrier = FALSE // Иди нахуй
		if(2)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Кружится голова."))
				affected_mob.adjust_confusion(6 SECONDS)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_notice("Смотрите на свою руку. Зрение расплывается."))
				affected_mob.set_eye_blur_if_lower(10 SECONDS)
		if(3)
			var/need_mob_update = FALSE
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Острая боль пронзает грудь!"))
				if(prob(45))
					affected_mob.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 20)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("[pick("Сердце замедляется...", "Расслабляетесь, замедляя сердцебиение.")]"))
				need_mob_update += affected_mob.adjustStaminaLoss(70, updating_stamina = FALSE)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("В голове жужжит."))
				SEND_SOUND(affected_mob, sound('sound/items/weapons/flash_ring.ogg'))
			if(SPT_PROB(0.5, seconds_per_tick))
				need_mob_update += affected_mob.adjustBruteLoss(1, updating_health = FALSE)
			if(need_mob_update)
				affected_mob.updatehealth()
		if(4)
			var/need_mob_update = FALSE
			if(prob(30))
				affected_mob.playsound_local(affected_mob, 'sound/effects/singlebeat.ogg', 100, FALSE, use_reverb = FALSE)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Ужасная боль сжимает грудь!"))
				if(prob(75))
					affected_mob.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 45)
			if(SPT_PROB(1, seconds_per_tick))
				need_mob_update += affected_mob.adjustStaminaLoss(100, updating_stamina = FALSE)
				affected_mob.visible_message(span_warning("[affected_mob] падает!"))
				if(prob(30))
					to_chat(affected_mob, span_danger("Зрение мутнеет, и вы теряете сознание!"))
					affected_mob.AdjustSleeping(1 SECONDS)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("[pick("Атомы будто ускоряются на месте.", "Чувствуете, будто вас разрывают на части!")]"))
				affected_mob.emote("scream")
				need_mob_update += affected_mob.adjustBruteLoss(10, updating_health = FALSE)
			if(need_mob_update)
				affected_mob.updatehealth()
		if(5)
			switch(rand(1,2))
				if(1)
					to_chat(affected_mob, span_notice("Атомы начинают выравниваться. Вы в безопасности. Пока что."))
					update_stage(1)
				if(2)
					to_chat(affected_mob, span_boldwarning("В этом временном потоке для вас нет места."))
					affected_mob.adjustStaminaLoss(100, forced = TRUE)
					playsound(affected_mob.loc, 'sound/effects/magic/repulse.ogg', 100, FALSE)
					affected_mob.emote("scream")
					for(var/mob/living/viewers in viewers(3, affected_mob.loc))
						viewers.flash_act()
					new /obj/effect/decal/cleanable/plasma(affected_mob.loc)
					new /obj/effect/decal/cleanable/ash(affected_mob.loc)
					affected_mob.visible_message(span_warning("[affected_mob] стирается из временного потока!"), span_userdanger("Вас вырывают из временной линии!"))
					affected_mob.investigate_log("был удалён/распылен болезнью [name].", INVESTIGATE_DEATHS)
					affected_mob.ghostize(can_reenter_corpse = FALSE)
					qdel(affected_mob)
