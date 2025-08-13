SUBSYSTEM_DEF(modpacks)
	name = "Modpacks"
	init_stage = INITSTAGE_FIRST
	flags = SS_NO_FIRE
	var/list/loaded_modpacks = list()

/datum/controller/subsystem/modpacks/Initialize()
	var/list/all_modpacks = list()
	for(var/modpack in subtypesof(/datum/modpack/))
		all_modpacks.Add(new modpack)
	// Pre-init and register all compiled modpacks.
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.pre_initialize()
		if(QDELETED(package))
			CRASH("Модпак типа [package.type] равен null или помечен на удаление.")
		if(fail_msg)
			CRASH("Модпак [package.name] не смог выполнить пре-инициализацию: [fail_msg].")
		if(loaded_modpacks[package.name])
			CRASH("Попытка зарегистрировать дублирующийся модпак [package.name].")
		loaded_modpacks.Add(package)

	// Handle init and post-init (two stages in case a modpack needs to implement behavior based on the presence of other packs).
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.initialize()
		if(fail_msg)
			CRASH("Модпак [(istype(package) && package.name) || "Неизвестный"] не удалось инициализировать: [fail_msg]")
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.post_initialize()
		if(fail_msg)
			CRASH("Модпак [(istype(package) && package.name) || "Неизвестный"] не удалось пост-инициализировать: [fail_msg]")

	return SS_INIT_SUCCESS

/client/verb/modpacks_list()
	set name = "Модификаций"
	set category = "OOC"

	if(!mob || !SSmodpacks.initialized)
		return

	if(length(SSmodpacks.loaded_modpacks))
		. = "<hr><br><center><b><font size = 3>Список модификаций</font></b></center><br><hr><br>"
		for(var/datum/modpack/M as anything in SSmodpacks.loaded_modpacks)
			if(M.name)
				. += "<div class = 'statusDisplay'>"
				. += "<center><b>[M.name]</b></center>"

				if(M.desc || M.author)
					. += "<br>"
					if(M.desc)
						. += "<br>Описание: [M.desc]"
					if(M.author)
						. += "<br><i>Автор: [M.author]</i>"
				. += "</div><br>"

		var/datum/browser/popup = new(mob, "modpacks_list", "Список Модификаций", 480, 580)
		popup.set_content(.)
		popup.open()
	else
		to_chat(src, "Этот сервер не использует какие-либо модификации.")
