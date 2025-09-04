/// Открыть все двери
/datum/grand_finale/all_access
	name = "Связь"
	desc = "Верховное использование собранной силы! Откройте каждую дверь, что у них есть! Теперь никто не сможет удержать вас снаружи, как и любого другого!"
	icon = 'icons/mob/actions/actions_spells.dmi'
	icon_state = "knock"

/datum/grand_finale/all_access/trigger(mob/living/carbon/human/invoker)
	message_admins("[key_name(invoker)] убрал все требования доступа к дверям")
	for(var/obj/machinery/door/target_door as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door))
		if(is_station_level(target_door.z))
			target_door.unlock()
			target_door.req_access = list()
			target_door.req_one_access = list()
			INVOKE_ASYNC(target_door, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
			CHECK_TICK
	priority_announce("АУЛИЕ ОКСИН ФИЕРА!!", null, 'sound/effects/magic/knock.ogg', sender_override = "[invoker.real_name]", color_override = "purple")
