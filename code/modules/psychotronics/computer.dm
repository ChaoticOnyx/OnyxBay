
#define NEUROMODRND_MUTAGEN_NEEDED 25

/* CONSOLE */

/obj/machinery/computer/neuromod_rnd
	name = "neuromod RnD console"
	desc = "Use to research neuromod's data disks and fill neuromod's shells."
	icon_keyboard = "telesci_key"
	icon_screen = "dna"
	active_power_usage = 800
	clicksound = null
	circuit = /obj/item/weapon/circuitboard/neuromod_rnd

	var/research_progress = 0
	var/development_progress = 0
	var/max_development_progress = 100
	var/is_researching = FALSE
	var/is_develop = FALSE
	var/datum/neuromod/researching_neuromod = null
	var/list/neuromods = list()
	var/list/lifeforms = list()
	var/list/accepts_disks = list(/obj/item/weapon/disk/neuromod_disk, /obj/item/weapon/disk/lifeform_disk)
	var/datum/lifeform/selected_lifeform = null
	var/datum/neuromod/selected_neuromod = null

/* UI */

/obj/machinery/computer/neuromod_rnd/ui_act(action, params)
	if (..()) return

	. = FALSE

	playsound(src, 'sound/machines/console_click.ogg', 15, 1)

	switch (action)
		if ("ejectBeaker")
			EjectBeaker()
			return TRUE
		if ("insertBeaker")
			InsertBeaker()
			return TRUE
		if ("ejectDisk")
			EjectDisk()
			return TRUE
		if ("insertDisk")
			InsertDisk()
			return TRUE
		if ("ejectNeuromodShell")
			EjectNeuromodShell()
			return TRUE
		if ("insertNeuromodShell")
			InsertNeuromodShell()
			return TRUE
		if ("startResearching")
			is_researching = TRUE
			research_progress = 0
			researching_neuromod = selected_neuromod
			return TRUE
		if ("stopResearching")
			is_researching = FALSE
			research_progress = 0
			researching_neuromod = null
			return TRUE
		if ("loadNeuromodFromDisk")
			LoadNeuromodFromDisk()
			return TRUE
		if ("saveNeuromodToDisk")
			if (!params["neuromod_type"] || !neuromods[params["neuromod_type"]])
				return

			SaveNeuromodToDisk(params["neuromod_type"])
			return TRUE
		if ("loadLifeformFromDisk")
			LoadLifeformFromDisk()
			return TRUE
		if ("saveLifeformToDisk")
			if (!params["lifeform_type"] || !lifeforms[params["lifeform_type"]])
				return

			SaveLifeformToDisk(params["lifeform_type"])
			return TRUE
		if ("selectNeuromod")
			if (!params["neuromod_type"] || !neuromods[params["neuromod_type"]])
				return

			selected_neuromod = text2path(params["neuromod_type"])
			return TRUE
		if ("clearNeuromodShell")
			ClearNeuromodShell()
			return TRUE
		if ("selectLifeform")
			if (!params["lifeform_type"] || !lifeforms[params["lifeform_type"]])
				return

			selected_lifeform = text2path(params["lifeform_type"])
			return TRUE
		if ("startDevelopment")
			if (DevelopmentReady(usr))
				TakeReagents()
				is_develop = TRUE

				var/obj/item/weapon/reagent_containers/neuromod_shell/neuromod_shell = GetNeuromodShell()
				var/datum/lifeform/L = GLOB.lifeforms.Get(selected_lifeform)
				neuromod_shell.created_for = L.mob_type

				return TRUE
		if ("stopDevelopment")
			is_develop = FALSE
			development_progress = 0
			return TRUE

/obj/machinery/computer/neuromod_rnd/ui_data(mob/user, ui_key)
	var/list/data = list()

	data["disk"] = null
	data["beaker"] = BeakerToList()
	data["neuromod_shell"] = NeuromodShellToList()
	data["neuromods"] = NeuromodsToList()
	data["lifeforms"] = LifeformsToList(user)
	data["selected_neuromod"] = NeuromodToList(selected_neuromod)
	data["selected_lifeform"] = null

	if (selected_lifeform)
		data["selected_lifeform"] = LifeformToList(user, selected_lifeform)

	data["is_researching"] = is_researching
	data["research_progress"] = research_progress
	data["development_ready"] = DevelopmentReady(user)
	data["development_progress"] = development_progress

	var/obj/item/weapon/disk/disk = GetDisk()

	if (disk)
		if (istype(disk, /obj/item/weapon/disk/neuromod_disk))
			data["disk"] = "neuromod"
		else if (istype(disk, /obj/item/weapon/disk/lifeform_disk))
			data["disk"] = "lifeform"

	return data

/obj/machinery/computer/neuromod_rnd/tg_ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "neuromod_rnd", "Neuromod RnD", 500, 600, master_ui, state)
		ui.open()

/* DEVELOPMENT PROCS */

/obj/machinery/computer/neuromod_rnd/proc/DevelopmentReady(mob/user)
	. = FALSE

	var/datum/reagent/M = GetMutagen()

	if (selected_neuromod && selected_lifeform && GetNeuromodShell() && M.volume >= NEUROMODRND_MUTAGEN_NEEDED)
		var/list/neuromod_data = NeuromodToList(selected_neuromod)
		var/list/lifeform_data = LifeformToList(user, selected_lifeform)

		if (CheckBeakerContent() &&\
			lifeform_data["scan_count"] >= lifeform_data["neuromod_prod_scans"] &&\
			neuromod_data["researched"])
			return TRUE

/* NEUROMODS LIST PROCS */

/obj/machinery/computer/neuromod_rnd/proc/NeuromodToList(neuromod_type)
	if (!neuromod_type) return

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	if (!neuromods[neuromod_type]) return

	return (list("researched" = neuromods[neuromod_type]["researched"]) + GLOB.neuromods.ToList(neuromod_type))

/obj/machinery/computer/neuromod_rnd/proc/NeuromodsToList()
	var/list/neuromods_list = list()

	if (neuromods.len == 0) return null

	for (var/neuromod_type in neuromods)
		var/datum/neuromod/neuromod = GLOB.neuromods.Get(neuromod_type)

		if (!neuromod) continue

		neuromods_list += (neuromod.ToList() + list("researched" = neuromods[neuromod_type]["researched"]))

	return list(neuromods_list)

/obj/machinery/computer/neuromod_rnd/proc/IsNeuromodResearched(neuromod_type)
	if (!neuromod_type)
		crash_with("neuromod_type is null")
		return null

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	if (!neuromods[neuromod_type])
		crash_with("trying to get [neuromod_type] but it is not exists")
		return null

	return neuromods[neuromod_type]["researched"]

/obj/machinery/computer/neuromod_rnd/proc/LoadNeuromodFromDisk()
	var/obj/item/weapon/disk/neuromod_disk/neuromod_disk = GetDisk()

	if (!neuromod_disk || !neuromod_disk.neuromod)
		return

	if (neuromods["[neuromod_disk.neuromod]"])
		return

	AddNeuromod(neuromod_disk.neuromod, neuromod_disk.researched)

/obj/machinery/computer/neuromod_rnd/proc/SaveNeuromodToDisk(neuromod_type)
	if (!neuromod_type)
		crash_with("neuromod_type is null")

	var/obj/item/weapon/disk/neuromod_disk/neuromod_disk = GetNeuromodDisk()

	if (!neuromod_disk)
		return

	if (istext(neuromod_type))
		neuromod_type = text2path(neuromod_type)

	neuromod_disk.neuromod = neuromod_type
	neuromod_disk.researched = IsNeuromodResearched(neuromod_type)

/obj/machinery/computer/neuromod_rnd/proc/AddNeuromod(neuromod_type, is_researched=FALSE)
	if (!neuromod_type) return

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	if (neuromods[neuromod_type]) return

	neuromods[neuromod_type] = list(
		"researched" = FALSE
	)

/* LIFEFORMS LIST PROCS */

/obj/machinery/computer/neuromod_rnd/proc/LifeformToList(mob/user, lifeform_type)
	var/list/lifeform_data = list()

	if (!user)
		crash_with("user is null")
		return null

	if (!lifeform_type)
		crash_with("lifeform_type is null")
		return null

	if (ispath(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if (!lifeforms[lifeform_type])
		crash_with("trying to get [lifeform_type] but it is not exists")
		return null

	var/list/lifeform = GLOB.lifeforms.ToList(user, lifeform_type)

	if (!lifeform) return null

	lifeform_data = (list(
		"scan_count" = lifeforms[lifeform_type]["scan_count"]
	) + lifeform)

	return lifeform_data

/obj/machinery/computer/neuromod_rnd/proc/LifeformsToList(mob/user)
	var/list/lifeforms_list = list()

	if (!lifeforms || lifeforms.len == 0) return null

	for (var/lifeform_type in lifeforms)
		var/datum/lifeform/lifeform = GLOB.lifeforms.Get(lifeform_type)

		if (!lifeform) continue

		lifeforms_list += list(
			lifeform.ToList(user) + list(
			"scan_count" = lifeforms[lifeform_type]["scan_count"]
		))

	return lifeforms_list

/obj/machinery/computer/neuromod_rnd/proc/AddLifeform(lifeform_type, custom_data=null, update=FALSE)
	if (ispath(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if (update == FALSE && lifeforms[lifeform_type])
		return

	if (update && !lifeforms[lifeform_type])
		return

	if (custom_data)
		lifeforms[lifeform_type] = custom_data
	else
		lifeforms[lifeform_type] = list(
			"scan_count" = 0
		)

/obj/machinery/computer/neuromod_rnd/proc/LoadLifeformFromDisk()
	var/obj/item/weapon/disk/lifeform_disk/lifeform_disk = GetDisk()

	if (!lifeform_disk || !lifeform_disk.lifeform_data)
		return

	var/list/lifeform_data = list(
		"scan_count" = lifeform_disk.lifeform_data["scan_count"]
	)

	if (lifeforms["[lifeform_disk.lifeform]"])
		AddLifeform(lifeform_disk.lifeform, lifeform_data, TRUE)
	else
		AddLifeform(lifeform_disk.lifeform, lifeform_data, FALSE)

/obj/machinery/computer/neuromod_rnd/proc/SaveLifeformToDisk(lifeform_type)
	if (!lifeform_type)
		crash_with("lifeform_type is null")
		return

	var/obj/item/weapon/disk/lifeform_disk/lifeform_disk = GetLifeformDisk()

	if (!lifeform_disk)
		return

	if (istext(lifeform_type))
		lifeform_type = text2path(lifeform_type)

	lifeform_disk.lifeform = lifeform_type
	lifeform_disk.lifeform_data = LifeformsToList(usr, lifeform_type)

/* DISK PROCS */

/obj/machinery/computer/neuromod_rnd/proc/GetDisk()
	for (var/disk_type in accepts_disks)
		var/obj/item/weapon/disk/disk = null
		disk = (locate(disk_type) in contents)

		if (disk) return disk

	return null

/obj/machinery/computer/neuromod_rnd/proc/GetLifeformDisk()
	var/obj/item/weapon/disk/lifeform_disk/lifeform_disk = null
	lifeform_disk = (locate(/obj/item/weapon/disk) in contents)

	return lifeform_disk

/obj/machinery/computer/neuromod_rnd/proc/GetNeuromodDisk()
	var/obj/item/weapon/disk/neuromod_disk/neuromod_disk = null
	neuromod_disk = (locate(/obj/item/weapon/disk) in contents)

	return neuromod_disk

/obj/machinery/computer/neuromod_rnd/proc/EjectDisk()
	var/obj/item/weapon/disk/disk = GetDisk()

	if (!disk) return

	contents -= disk
	usr.put_in_hands(disk)

/obj/machinery/computer/neuromod_rnd/proc/InsertDisk()
	if (GetDisk())
		to_chat(usr, "Console's disk slot is already occupied.")
		return

	var/obj/item/weapon/disk/disk = usr.get_active_hand()

	if (!disk) return

	usr.drop_item(disk)
	contents += disk

/* NEUROMOD SHELL PROCS */

/obj/machinery/computer/neuromod_rnd/proc/ClearNeuromodShell()
	var/obj/item/weapon/reagent_containers/neuromod_shell/shell = GetNeuromodShell()

	if (!shell || !shell.neuromod) return

	shell.neuromod = null

/obj/machinery/computer/neuromod_rnd/proc/NeuromodShellToList()
	var/obj/item/weapon/reagent_containers/neuromod_shell/shell = GetNeuromodShell()

	if (!shell) return null

	var/list/shell_data = list(
		"neuromod" = null
	)

	var/list/neuromod_data = GLOB.neuromods.ToList(shell.neuromod)

	if (neuromod_data)
		shell_data["neuromod"] = neuromod_data

	return shell_data

/obj/machinery/computer/neuromod_rnd/proc/GetNeuromodShell()
	return (locate(/obj/item/weapon/reagent_containers/neuromod_shell/) in contents)

/obj/machinery/computer/neuromod_rnd/proc/EjectNeuromodShell()
	var/obj/item/weapon/reagent_containers/neuromod_shell/neuromod_shell = GetNeuromodShell()

	if (neuromod_shell)
		contents -= neuromod_shell
		usr.put_in_hands(neuromod_shell)

/obj/machinery/computer/neuromod_rnd/proc/InsertNeuromodShell()
	var/obj/item/weapon/reagent_containers/neuromod_shell/neuromod_shell = usr.get_active_hand()

	if (!neuromod_shell) return

	if (GetNeuromodShell())
		to_chat(usr, "Console's neuromod shell slot is already occupied.")
		return

	usr.drop_item(neuromod_shell)
	contents += neuromod_shell

/* BEAKER PROCS */

/obj/machinery/computer/neuromod_rnd/proc/TakeReagents()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return

	beaker.reagents.remove_reagent(/datum/reagent/mutagen, NEUROMODRND_MUTAGEN_NEEDED, TRUE)

/obj/machinery/computer/neuromod_rnd/proc/BeakerToList()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return null

	var/list/beaker_data = list(
		"check_status" = CheckBeakerContent(),
		"volume_max" = beaker.volume,
		"volume" = beaker.reagents.total_volume
	)

	return beaker_data

/obj/machinery/computer/neuromod_rnd/proc/GetMutagen()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return null

	if (!CheckBeakerContent()) return null

	return beaker.reagents.reagent_list[1]

/obj/machinery/computer/neuromod_rnd/proc/CheckBeakerContent()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return null

	var/datum/reagents/reagents = beaker.reagents

	if (reagents.reagent_list.len == 0 || reagents.reagent_list.len > 1)
		return FALSE

	var/datum/reagent/reagent = reagents.reagent_list[1]

	if (!reagent || !istype(reagent, /datum/reagent/mutagen))
		return FALSE

	return TRUE

/obj/machinery/computer/neuromod_rnd/proc/GetBeaker()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = null
	beaker = (locate(/obj/item/weapon/reagent_containers/glass/beaker) in contents)

	return beaker

/obj/machinery/computer/neuromod_rnd/proc/EjectBeaker()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (beaker)
		contents -= beaker
		usr.put_in_hands(beaker)

/obj/machinery/computer/neuromod_rnd/proc/InsertBeaker()
	if (GetBeaker())
		to_chat(usr, "Console's beaker slot is already occupied.")
		return

	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = usr.get_active_hand()

	if (beaker)
		usr.drop_item(beaker)
		contents += beaker

/* OVERRIDES */

/obj/machinery/computer/neuromod_rnd/Process()
	if (is_researching)
		if (!researching_neuromod || IsNeuromodResearched(researching_neuromod))
			research_progress = 0
			is_researching = FALSE

			playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		else
			research_progress += 10

			if (research_progress > initial(researching_neuromod.research_time))
				is_researching = FALSE
				neuromods["[researching_neuromod]"]["researched"] = TRUE
				research_progress = 0
				researching_neuromod = null
				playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

	if (is_develop)
		development_progress += 10

		if (development_progress > max_development_progress)
			development_progress = 0
			is_develop = FALSE

			var/obj/item/weapon/reagent_containers/neuromod_shell/N = GetNeuromodShell()

			if (!N)
				crash_with("Development over with no neuromod shell in the console!")
				return

			N.neuromod = selected_neuromod
			playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

/obj/machinery/computer/neuromod_rnd/attackby(atom/I, user)
	if (istype(I, /obj/item/weapon/reagent_containers/neuromod_shell))
		InsertNeuromodShell()
		return
	else if (I.type in accepts_disks)
		InsertDisk()
		return
	else if (istype(I, /obj/item/weapon/reagent_containers/glass/beaker))
		InsertBeaker()
		return

	. = ..()

/obj/machinery/computer/neuromod_rnd/attack_ai(mob/user)
	tg_ui_interact(user)

/obj/machinery/computer/neuromod_rnd/attack_hand(mob/user)
	..()

	if(stat & (BROKEN|NOPOWER))
		return
	tg_ui_interact(user)

/obj/machinery/computer/neuromod_rnd/interact(mob/user)
	tg_ui_interact(user)

#undef NEUROMODRND_MUTAGEN_NEEDED
