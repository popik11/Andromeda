/obj/crystal_mass
	name = "crystal mass"
	desc = "Вы видите эту массивную кристаллическую глыбу, надвигающуюся на вас, трескающуюся и скрежещущую при каждом, казалось бы, случайном движении."
	icon = 'icons/turf/walls.dmi'
	icon_state = "crystal_cascade_1"
	layer = AREA_LAYER
	plane = ABOVE_LIGHTING_PLANE
	opacity = FALSE
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_power = 1
	light_range = 5
	light_color = COLOR_VIVID_YELLOW
	move_resist = INFINITY
	///Все направления, в которые мы можем расширяться
	var/list/available_dirs = list(NORTH,SOUTH,EAST,WEST,UP,DOWN)
	///Обработчик, помогающий правильно убивать мобов, которых накрывает кристалл
	var/datum/component/supermatter_crystal/sm_comp
	///Кулдаун на процесс расширения
	COOLDOWN_DECLARE(sm_wall_cooldown)

/obj/crystal_mass/Initialize(mapload, dir_to_remove)
	. = ..()
	icon_state = "crystal_cascade_[rand(1,6)]"
	START_PROCESSING(SSsupermatter_cascade, src)

	sm_comp = AddComponent(/datum/component/supermatter_crystal, null, null)

	playsound(src, 'sound/misc/cracking_crystal.ogg', 45, TRUE)

	available_dirs -= dir_to_remove

	var/turf/our_turf = get_turf(src)

	if(our_turf)
		our_turf.opacity = FALSE

	// В идеале это было бы частью компонента СМ, но сама СМ особым образом обрабатывает пули (эмиттеры - это пули).
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(eat_bullets))

/obj/crystal_mass/process()

	if(!COOLDOWN_FINISHED(src, sm_wall_cooldown))
		return

	if(!available_dirs || available_dirs.len <= 0)
		return PROCESS_KILL

	COOLDOWN_START(src, sm_wall_cooldown, rand(0, 3 SECONDS))

	var/picked_dir = pick_n_take(available_dirs)
	var/turf/next_turf = get_step_multiz(src, picked_dir)

	icon_state = "crystal_cascade_[rand(1,6)]"

	if(!next_turf || locate(/obj/crystal_mass) in next_turf)
		return

	for(var/atom/movable/checked_atom as anything in next_turf)
		if(isliving(checked_atom))
			sm_comp.dust_mob(src, checked_atom, span_danger("[src] выбрасывает щупальце в сторону [checked_atom], касаясь [checked_atom.p_them()]... \
					Тело [checked_atom.p_their()] начинает сиять ослепительным светом, кристаллизуясь изнутри и присоединяясь к [src]!"),
				span_userdanger("Кристаллическая масса бросается на вас и ударяет в грудь. Когда ваше зрение заполняется ослепляющим светом, вы думаете: \"Чёрт.\""))
		else if(istype(checked_atom, /obj/cascade_portal))
			checked_atom.visible_message(span_userdanger("[checked_atom] визжит и схлопывается, будучи пораженным [src]! Слишком поздно!"))
			playsound(get_turf(checked_atom), 'sound/effects/magic/charge.ogg', 50, TRUE)
			playsound(get_turf(checked_atom), 'sound/effects/supermatter.ogg', 50, TRUE)
			qdel(checked_atom)
		else if(isitem(checked_atom))
			playsound(get_turf(checked_atom), 'sound/effects/supermatter.ogg', 50, TRUE)
			qdel(checked_atom)

	new /obj/crystal_mass(next_turf, get_dir(next_turf, src))

/obj/crystal_mass/proc/eat_bullets(datum/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	visible_message(
		span_warning("[hitting_projectile] влетает в [src] с громким хрустом, прежде чем мгновенно вспыхнуть и обратиться в пепел."),
		null,
		span_hear("Вы слышите громкий хруст, и вас накрывает волна тепла."),
	)

	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(hitting_projectile)
	return COMPONENT_BULLET_BLOCKED

/obj/crystal_mass/singularity_act()
	return

/obj/crystal_mass/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("Это была очень тупая идея."))
	jedi.ghostize()
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/crystal_mass/Destroy()
	STOP_PROCESSING(SSsupermatter_cascade, src)
	sm_comp = null
	return ..()

/obj/cascade_portal
	name = "Bluespace Rift"
	desc = "Ваш разум начинает кружиться, пытаясь осознать увиденное."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	light_color = COLOR_RED
	light_power = 0.7
	light_range = 15
	move_resist = INFINITY
	pixel_x = -96
	pixel_y = -96
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/cascade_portal/Initialize(mapload)
	. = ..()
	var/turf/location = get_turf(src)
	var/area_name = get_area_name(src)
	message_admins("Выходной разлом создан в [area_name]. [ADMIN_VERBOSEJMP(location)]")
	log_game("Блюспейсный выходной разлом создан в [area_name].")
	investigate_log("создан в [area_name].", INVESTIGATE_ENGINE)

/obj/cascade_portal/Destroy(force)
	var/turf/location = get_turf(src)
	var/area_name = get_area_name(src)
	message_admins("Выходной разлом в [area_name] удален. [ADMIN_VERBOSEJMP(location)]")
	log_game("Блюспейсный выходной разлом в [area_name] был удален.")
	investigate_log("был удален.", INVESTIGATE_ENGINE)
	return ..()

/obj/cascade_portal/Bumped(atom/movable/hit_object)
	consume(hit_object)
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/**
 * Процедура поглощения объектов, сталкивающихся с порталом
 *
 * Аргументы: atom/movable/consumed_object - объект, попадающий в портал
 */
/obj/cascade_portal/proc/consume(atom/movable/consumed_object)
	if(isliving(consumed_object))
		consumed_object.visible_message(span_danger("[consumed_object] заходит в [src]... \
			Ослепляющий свет окутывает тело [consumed_object.p_their()] перед полным исчезновением!"),
			span_userdanger("Вы заходите в [src], и ваше тело омывается мощным синим светом. \
				Вы размышляете об этом решении, прежде чем приземлиться лицом в холодный твердый пол."),
			span_hear("Вы слышите громкий хруст, искажение пронзает вас."))

		var/list/arrival_turfs = get_area_turfs(/area/centcom/central_command_areas/evacuation)
		var/turf/arrival_turf
		do
			arrival_turf = pick_n_take(arrival_turfs)
		while(!is_safe_turf(arrival_turf))

		var/mob/living/consumed_mob = consumed_object
		message_admins("[key_name_admin(consumed_mob)] вошел в [src] [ADMIN_VERBOSEJMP(src)].")
		investigate_log("был активирован [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.forceMove(arrival_turf)
		consumed_mob.Paralyze(100)
		consumed_mob.adjustBruteLoss(30)
		consumed_mob.flash_act(1, TRUE, TRUE)

		new /obj/effect/particle_effect/sparks(consumed_object)
		playsound(consumed_object, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else if(isitem(consumed_object))
		consumed_object.visible_message(span_danger("[consumed_object] ударяется о [src] и исчезает из виду."), null,
			span_hear("Вы слышите громкий хруст, искажение пронзает вас."))

		qdel(consumed_object)
