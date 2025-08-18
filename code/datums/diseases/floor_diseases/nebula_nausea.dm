/// Caused by dirty food. Makes you vomit stars.
/datum/disease/nebula_nausea
	name = "Тошнота туманности"
	desc = "Нельзя удержать красочную красоту космоса внутри себя."
	form = "Состояние"
	agent = "Звёзды"
	cure_text = "Космический очиститель"
	cures = list(/datum/reagent/space_cleaner)
	viable_mobtypes = list(/mob/living/carbon/human)
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	severity = DISEASE_SEVERITY_MEDIUM
	required_organ = ORGAN_SLOT_STOMACH
	max_stages = 5

/datum/disease/advance/nebula_nausea/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("Красочная красота космоса, кажется, нарушила ваш вестибулярный аппарат."))
		if(3)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("Живот переливается цветами, невиданными человеческому глазу."))
		if(4)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("Ощущение будто парите через водоворот небесных красок."))
		if(5)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("Живот превратился в бурлящую туманность с калейдоскопическими узорами."))
			else
				affected_mob.vomit(vomit_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM), vomit_type = /obj/effect/decal/cleanable/vomit/nebula, lost_nutrition = 10, distance = 2)
