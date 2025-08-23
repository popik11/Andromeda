/// Поглощает объекты, которые врезаются в суперматерию из трамвая.
/// Трамвай вызывает forceMove (не вызывает Bump/ed), а не Move, и я боюсь, что изменение этого вызовет хаос.
/obj/machinery/power/supermatter_crystal/proc/tram_contents_consume(datum/source, list/tram_contents)
	SIGNAL_HANDLER

	for(var/atom/thing_to_consume as anything in tram_contents)
		Bumped(thing_to_consume)

/obj/machinery/power/supermatter_crystal/proc/eat_bullets(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	var/turf/local_turf = loc
	if(!istype(local_turf))
		return NONE

	var/kiss_power = 0
	if (istype(projectile, /obj/projectile/kiss/death))
		kiss_power = 20000
	else if (istype(projectile, /obj/projectile/kiss))
		kiss_power = 60


	if(!istype(projectile.firer, /obj/machinery/power/emitter))
		investigate_log("был поражен [projectile], выпущенным [key_name(projectile.firer)]", INVESTIGATE_ENGINE)
	if(projectile.armor_flag != BULLET || kiss_power)
		if(kiss_power)
			psy_coeff = 1
		log_activation(who = projectile.firer, how = projectile.fired_from)
	else
		external_damage_immediate += projectile.damage * bullet_energy * 0.1
		// Прекращаем получать урон на аварийной точке, кричим игрокам на точке опасности.
		// Это не чисто и мы повторяем [/obj/machinery/power/supermatter_crystal/proc/calculate_damage], извините за это.
		var/damage_to_be = damage + external_damage_immediate * clamp((emergency_point - damage) / emergency_point, 0, 1)
		if(damage_to_be > danger_point)
			visible_message(span_notice("[src] сжимается под напряжением, сопротивляясь дальнейшим ударам!"))
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	if(istype(projectile, /obj/projectile/beam/emitter/hitscan))
		var/obj/projectile/beam/emitter/hitscan/mahlaser = projectile
		if(mahlaser?.integrity_heal)
			damage = max(0, damage - mahlaser?.integrity_heal)
		if(mahlaser?.energy_reduction)
			internal_energy = max(0, internal_energy - mahlaser?.energy_reduction)
		if(mahlaser?.psi_change)
			psy_coeff = clamp(psy_coeff + mahlaser?.psi_change, 0, 1)
	external_power_immediate += projectile.damage * bullet_energy + kiss_power
	if(istype(projectile, /obj/projectile/beam/emitter/hitscan/magnetic))
		absorption_ratio = clamp(absorption_ratio + 0.05, 0.15, 1)

	qdel(projectile)
	return COMPONENT_BULLET_BLOCKED

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("был поглощен сингулярностью.", INVESTIGATE_ENGINE)
	message_admins("Сингулярность поглотила осколок суперматерии и теперь может перейти в шестую стадию.")
	visible_message(span_userdanger("[src] поглощается сингулярностью!"))
	var/turf/sm_turf = get_turf(src)
	for(var/mob/hearing_mob as anything in GLOB.player_list)
		if(!is_valid_z_level(get_turf(hearing_mob), sm_turf))
			continue
		SEND_SOUND(hearing_mob, 'sound/effects/supermatter.ogg') //все узнают об этом
		to_chat(hearing_mob, span_bolddanger("Ужасный скрежет заполняет ваши уши, и волна ужаса накрывает вас..."))
	qdel(src)
	return gain

/obj/machinery/power/supermatter_crystal/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("Это была очень глупая идея."))
	jedi.investigate_log("имел [jedi.p_their()] мозг распылен при касании [src] телекинезом.", INVESTIGATE_DEATHS)
	jedi.ghostize()
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/power/supermatter_crystal/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/scalpel/supermatter))
		var/obj/item/scalpel/supermatter/scalpel = item
		to_chat(user, span_notice("Вы осторожно начинаете соскабливать [src] с помощью [scalpel]..."))
		if(!scalpel.use_tool(src, user, 60, volume=100))
			return
		if (scalpel.usesLeft)
			to_chat(user, span_danger("Вы извлекаете осколок из [src]. [src] начинает бурно реагировать!"))
			new /obj/item/nuke_core/supermatter_sliver(src.drop_location())
			supermatter_sliver_removed = TRUE
			external_power_trickle += 800
			log_activation(who = user, how = scalpel)
			scalpel.usesLeft--
			if (!scalpel.usesLeft)
				to_chat(user, span_notice("Крошечный кусочек [scalpel] отваливается, делая его бесполезным!"))
		else
			to_chat(user, span_warning("Вам не удалось извлечь осколок из [src]! [scalpel] больше недостаточно острый."))
		return

	if(istype(item, /obj/item/hemostat/supermatter))
		to_chat(user, span_warning("Вы тыкаете [src] гипер-ноблиевыми наконечниками [item]. Ничего не происходит."))
		return

	if(istype(item, /obj/item/destabilizing_crystal))
		var/obj/item/destabilizing_crystal/destabilizing_crystal = item

		if(!is_main_engine)
			to_chat(user, span_warning("Вы не можете использовать [destabilizing_crystal] на [name]."))
			return

		if(get_integrity_percent() < SUPERMATTER_CASCADE_PERCENT)
			to_chat(user, span_warning("Вы можете применить [destabilizing_crystal] только к [name], который цел как минимум на [SUPERMATTER_CASCADE_PERCENT]%."))
			return

		to_chat(user, span_warning("Вы начинаете прикреплять [destabilizing_crystal] к [src]..."))
		if(do_after(user, 3 SECONDS, src))
			message_admins("[ADMIN_LOOKUPFLW(user)] прикрепил [destabilizing_crystal] к суперматерии в [ADMIN_VERBOSEJMP(src)].")
			user.log_message("прикрепил [destabilizing_crystal] к суперматерии", LOG_GAME)
			user.investigate_log("прикрепил [destabilizing_crystal] к кристаллу суперматерии.", INVESTIGATE_ENGINE)
			to_chat(user, span_danger("[destabilizing_crystal] защелкивается на [src]."))
			set_delam(SM_DELAM_PRIO_IN_GAME, /datum/sm_delam/cascade)
			external_damage_immediate += 10
			external_power_trickle += 500
			log_activation(who = user, how = destabilizing_crystal)
			qdel(destabilizing_crystal)
		return

	return ..()

//Не взрывайте наше внутреннее радио.
/obj/machinery/power/supermatter_crystal/contents_explosion(severity, target)
	return

/obj/machinery/power/supermatter_crystal/proc/wrench_act_callback(mob/user, obj/item/tool)
	if(moveable)
		default_unfasten_wrench(user, tool)

/obj/machinery/power/supermatter_crystal/proc/consume_callback(matter_increase, damage_increase)
	external_power_trickle += matter_increase
	external_damage_immediate += damage_increase
