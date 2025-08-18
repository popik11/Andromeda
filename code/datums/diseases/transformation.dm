/datum/disease/transformation
	name = "Трансформация"
	max_stages = 5
	spread_text = "Острая"
	spread_flags = DISEASE_SPREAD_SPECIAL
	cure_text = "Любовь кодера (теоретически)."
	agent = "Шалости"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/alien)
	severity = DISEASE_SEVERITY_BIOHAZARD
	stage_prob = 5
	visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	disease_flags = CURABLE
	bypasses_immunity = TRUE
	var/list/stage1 = list("Ты чувствуешь себя заурядным.")
	var/list/stage2 = list("Ты чувствуешь себя скучным.")
	var/list/stage3 = list("Ты чувствуешь себя совершенно обычным.")
	var/list/stage4 = list("Ты чувствуешь себя белым хлебом.")
	var/list/stage5 = list("О, человечество!")
	var/new_form = /mob/living/carbon/human
	var/bantype
	var/transformed_antag_datum //Do we add a specific antag datum once the transformation is complete?

/datum/disease/transformation/Copy()
	var/datum/disease/transformation/D = ..()
	D.stage1 = stage1.Copy()
	D.stage2 = stage2.Copy()
	D.stage3 = stage3.Copy()
	D.stage4 = stage4.Copy()
	D.stage5 = stage5.Copy()
	D.new_form = D.new_form
	return D


/datum/disease/transformation/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if (length(stage1) && SPT_PROB(stage_prob, seconds_per_tick))
				to_chat(affected_mob, pick(stage1))
		if(2)
			if (length(stage2) && SPT_PROB(stage_prob, seconds_per_tick))
				to_chat(affected_mob, pick(stage2))
		if(3)
			if (length(stage3) && SPT_PROB(stage_prob * 2, seconds_per_tick))
				to_chat(affected_mob, pick(stage3))
		if(4)
			if (length(stage4) && SPT_PROB(stage_prob * 2, seconds_per_tick))
				to_chat(affected_mob, pick(stage4))
		if(5)
			do_disease_transformation(affected_mob)


/datum/disease/transformation/proc/do_disease_transformation(mob/living/affected_mob)
	if(iscarbon(affected_mob) && affected_mob.stat != DEAD)
		if(length(stage5))
			to_chat(affected_mob, pick(stage5))
		if(QDELETED(affected_mob))
			return
		if(HAS_TRAIT_FROM(affected_mob, TRAIT_NO_TRANSFORM, REF(src)))
			return
		ADD_TRAIT(affected_mob, TRAIT_NO_TRANSFORM, REF(src))
		for(var/obj/item/W in affected_mob.get_equipped_items(INCLUDE_POCKETS))
			affected_mob.dropItemToGround(W)
		for(var/obj/item/I in affected_mob.held_items)
			affected_mob.dropItemToGround(I)
		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			if(bantype && is_banned_from(affected_mob.ckey, bantype))
				replace_banned_player(new_mob)
			new_mob.set_combat_mode(TRUE)
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
			else
				new_mob.PossessByPlayer(affected_mob.ckey)
		if(transformed_antag_datum)
			new_mob.mind.add_antag_datum(transformed_antag_datum)
		new_mob.name = affected_mob.real_name
		new_mob.real_name = new_mob.name
		qdel(affected_mob)

/datum/disease/transformation/proc/replace_banned_player(mob/living/new_mob) // Этот код может выполниться после трансфера моба, поэтому нужен новый моб для уничтожения при необходимости.
	set waitfor = FALSE

	var/mob/chosen_one = SSpolling.poll_ghosts_for_target("Хотите играть за [span_notice(affected_mob.real_name)]?", check_jobban = bantype, role = bantype, poll_time = 5 SECONDS, checked_target = affected_mob, alert_pic = affected_mob, role_name_text = "жертва трансформации")
	if(chosen_one)
		to_chat(affected_mob, span_userdanger("Твоим персонажем завладел призрак! Оспорь бан профессии, если хочешь избежать этого в будущем!"))
		message_admins("[key_name_admin(chosen_one)] взял под контроль ([key_name_admin(affected_mob)]) для замены забаненного игрока.")
		affected_mob.ghostize(FALSE)
		affected_mob.PossessByPlayer(chosen_one.ckey)
	else
		to_chat(new_mob, span_userdanger("Твоим персонажем завладела смерть! Оспорь бан профессии, если хочешь избежать этого в будущем!"))
		new_mob.investigate_log("был убит, так как не нашлось замены для забаненного игрока.", INVESTIGATE_DEATHS)
		new_mob.death()
		if (!QDELETED(new_mob))
			new_mob.ghostize(can_reenter_corpse = FALSE)

/datum/disease/transformation/jungle_flu
	name = "Джунглевая лихорадка"
	cure_text = "Смерть."
	cures = list(/datum/reagent/medicine/adminordrazine)
	spread_text = "Неизвестно"
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	cure_chance = 0.5
	disease_flags = CAN_CARRY|CAN_RESIST
	desc = "Ослабленный, но всё ещё опасный потомок древней \"Лихорадки Джунглей\". Жертвы генетически деградируют до приматов. \
	К счастью, превращённые обезьяны не получают бешеной агрессии оригинала."
	severity = DISEASE_SEVERITY_BIOHAZARD
	stage_prob = 2
	visibility_flags = NONE
	agent = "Конгей Вибрион M-909"
	new_form = /mob/living/carbon/human/species/monkey

	stage1 = list()
	stage2 = list()
	stage3 = list()
	stage4 = list(
		span_warning("Ты дышишь ртом."),
		span_warning("Тебе хочется бананов."),
		span_warning("Спина болит."),
		span_warning("Сознание затуманено."),
	)
	stage5 = list(span_warning("Хочется пообезьянничать."))

/datum/disease/transformation/jungle_flu/do_disease_transformation(mob/living/carbon/affected_mob)
	affected_mob.monkeyize()

/datum/disease/transformation/jungle_flu/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_notice("[pick("Рука", "Спина", "Локоть", "Голова", "Нога")] чешется."))
		if(3)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("Острая боль пронзает голову."))
				affected_mob.adjust_confusion(10 SECONDS)
		if(4)
			if(SPT_PROB(1.5, seconds_per_tick))
				affected_mob.say(pick("Ииии!", "Ииик, уук уук!", "Иии-ииик!", "Унх, унх."), forced = "jungle fever")

/datum/disease/transformation/robot
	name = "Роботическая трансформация"
	cure_text = "Инъекция меди."
	cures = list(/datum/reagent/copper)
	cure_chance = 2.5
	agent = "Наномашины R2D2"
	desc = "Эта болезнь, фактически острая наномашинная инфекция, превращает жертву в киборга."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = NONE
	stage1 = list()
	stage2 = list(span_danger("Бип...буп.."), "Суставы кажутся жесткими.")
	stage3 = list(
		span_danger("Чувствуешь движение...внутри себя."),
		span_danger("Суставы стали очень жесткими."),
		span_warning("Кожа кажется дряблой."),
	)
	stage4 = list(span_danger("Чувствуешь... что-то...внутри себя."), span_danger("Кожа стала очень дряблой."),)
	stage5 = list(span_danger("Кожа будто вот-вот лопнет!"))
	new_form = /mob/living/silicon/robot
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_ROBOTIC
	bantype = JOB_CYBORG

/datum/disease/transformation/robot/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(3)
			if (SPT_PROB(4, seconds_per_tick))
				affected_mob.say(pick("бип, бип!", "Бип, буп", "Буп...боп"), forced = "robotic transformation")
			if (SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("Резкая боль пронзает голову."))
				affected_mob.Unconscious(40)
		if(4)
			if (SPT_PROB(10, seconds_per_tick))
				affected_mob.say(pick("бип, бип!", "Буп боп буп бип.", "Я хххооочччууу ууумеееррееть...", "ууубейи ммеення"), forced = "robotic transformation")


/datum/disease/transformation/xeno
	name = "Ксеноморфная трансформация"
	cure_text = "Спейсациллин и Глицерин (Spaceacillin & Glycerol)"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/glycerol)
	cure_chance = 2.5
	agent = "Микробы «Чужие» Рип-ЛИ"
	desc = "Эта болезнь превращает жертву в ксеноморфа."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = NONE
	stage1 = list()
	stage2 = list("Горло першит.", span_danger("Убить..."))
	stage3 = list(
		span_danger("Чувствуешь движение... внутри."),
		span_danger("Сильно першит в горле."),
		span_warning("Кожа натягивается."),
	)
	stage4 = list(
		span_danger("Чувствуешь... что-то... внутри."),
		span_danger("Кровь кипит!"),
		span_danger("Кожа сильно натянута."),
	)
	stage5 = list(span_danger("Кожа вот-вот лопнет!"))
	new_form = /mob/living/carbon/alien/adult/hunter
	bantype = ROLE_ALIEN


/datum/disease/transformation/xeno/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(3)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("Резкая боль пронзает голову."))
				affected_mob.Unconscious(40)
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.say(pick("Я... сожру тебя...", "Шшшшшшш!", "Ты выглядишь вкусно."), forced = "xenomorph transformation")


/datum/disease/transformation/slime
	name = "Трансформация в слизь"
	cure_text = "Масло льда (Frost oil)"
	cures = list(/datum/reagent/consumable/frostoil)
	cure_chance = 55
	agent = "Токсин усиленной мутации"
	desc = "Этот высококонцентрированный экстракт превращает всё в большее количество себя."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = NONE
	stage1 = list("Ты чувствуешь себя нехорошо.")
	stage2 = list("Кожа стала немного скользкой.")
	stage3 = list(
		span_danger("Твои конечности начинают таять."),
		span_danger("Твои конечности теряют форму.")
	)
	stage4 = list(span_danger("Ты превращаешься в слизь."))
	stage5 = list(span_danger("Ты стал слизью."))
	new_form = /mob/living/basic/slime


/datum/disease/transformation/slime/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(isjellyperson(human))
					update_stage(5)
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(!ismonkey(human) && !isjellyperson(human))
					human.set_species(/datum/species/jelly/slime)

/datum/disease/transformation/slime/do_disease_transformation(mob/living/affected_mob)
	if(affected_mob.client && ishuman(affected_mob)) // if they are a human who's not a monkey and are sentient, then let them have the old fun
		var/mob/living/carbon/human/human = affected_mob
		if(!ismonkey(human))
			new_form = /mob/living/basic/slime/random
	return ..()

/datum/disease/transformation/corgi
	name = "Гавканье"
	cure_text = "Смерть"
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "Магия демонического доге"
	desc = "Эта болезнь превращает жертву в корги."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = NONE
	stage1 = list("ГАВ.")
	stage2 = list("Хочется носить глупые шапочки.")
	stage3 = list(
		span_danger("Хочу... шоколада..."),
		span_danger("ТЯФ")
	)
	stage4 = list(span_danger("В голове мелькают образы стиральных машин!"))
	stage5 = list(span_danger("ГАВГАВГАВ!!!"))
	new_form = /mob/living/basic/pet/dog/corgi


/datum/disease/transformation/corgi/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return
	switch(stage)
		if(3)
			if (SPT_PROB(4, seconds_per_tick))
				affected_mob.say(pick("ГАВ!", "ТЯФ"), forced = "corgi transformation")
		if(4)
			if (SPT_PROB(10, seconds_per_tick))
				affected_mob.say(pick("ГАВГАВГАВ", "ГАВ!"), forced = "corgi transformation")


/datum/disease/transformation/morph
	name = "Благословение чревоугодия"
	cure_text = "Ничто"
	cures = list(/datum/reagent/consumable/nothing)
	agent = "Благословение чревоугодия"
	desc = "'Дар' из ужасного места."
	stage_prob = 10
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = NONE
	stage1 = list("В животе урчит.")
	stage2 = list("Кожа обвисла.")
	stage3 = list(
		span_danger("Конечности начинают таять."),
		span_danger("Твои конечности теряют форму.")
	)
	stage4 = list(span_danger("Ты испытываешь ненасытный голод."))
	stage5 = list(span_danger("Ты стал морфом."))
	new_form = /mob/living/basic/morph
	infectable_biotypes = MOB_ORGANIC|MOB_MINERAL|MOB_UNDEAD //магия!
	transformed_antag_datum = /datum/antagonist/morph

/datum/disease/transformation/gondola
	name = "Трансформация в гондолу"
	cure_text = "Концентрированный капсаицин, перорально или инъекционно." //перцовый баллончик не поможет
	cures = list(/datum/reagent/consumable/condensedcapsaicin) //выбивает хипповскую дурь из системы
	cure_chance = 55
	stage_prob = 2.5
	agent = "Спокойствие"
	desc = "Употребление плоти Гондолы имеет ужасную цену."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = NONE
	stage1 = list("Ты чувствуешь себя немного легче.")
	stage2 = list("Ловишь себя на улыбке без причины.")
	stage3 = list(
		span_danger("Тебя охватывает жестокая безмятежность."),
		span_danger("Ты не чувствуешь своих рук!"),
		span_danger("Ты отпускаешь желание причинить вред клоунам."),
	)
	stage4 = list(span_danger("Ты не чувствуешь рук. Тебя это больше не беспокоит."), span_danger("Ты прощаешь клоуна за причинённую боль."))
	stage5 = list(span_danger("Ты стал Гондолой."))
	new_form = /mob/living/basic/pet/gondola


/datum/disease/transformation/gondola/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("smile")
			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
		if(3)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("smile")
			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
		if(4)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("smile")
			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
			if(SPT_PROB(1, seconds_per_tick))
				var/obj/item/held_item = affected_mob.get_active_held_item()
				if(held_item)
					to_chat(affected_mob, span_danger("Ты отпускаешь то, что держал."))
					affected_mob.dropItemToGround(held_item)
