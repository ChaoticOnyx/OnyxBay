/* CONSOLE NANOUI MODULE */

#define NEUROMODRND_OPTION_SHOW_NEUROMODS 1
#define NEUROMODRND_OPTION_SHOW_LIFEFORMS 2
#define NEUROMODRND_MUTAGEN_VOLUME 25

/datum/nano_module/neuromodRnD
	name = "Neuromod RnD"

	/* UI Modes */
	//
	// 0 - Main Menu
	// 1 - Neuromod Researching
	// 2 - Neuromod Production
	// 3 - Data Management
	//

	var/ui_mode = 0
	var/old_mode = 0
	var/show_options = (NEUROMODRND_OPTION_SHOW_NEUROMODS | NEUROMODRND_OPTION_SHOW_LIFEFORMS)
	var/datum/neuromod/selected_neuromod = null
	var/list/nanoui_beaker = null
	var/list/nanoui_shell = null
	var/datum/lifeform/selected_lifeform = null
	var/list/nanoui_lifeform = null
	var/list/nanoui_lifeforms = null

/datum/nano_module/neuromodRnD/proc/GetHost()
	var/obj/machinery/computer/neuromodRnD/computer_host = host
	return computer_host

/datum/nano_module/neuromodRnD/Topic(href, list/href_list)
	if (..()) return 1

	playsound(GetHost(), 'sound/machines/console_click.ogg', 15, 1)

	switch (href_list["option"])
		if ("showNeuromodResearching")
			old_mode = ui_mode
			ui_mode = 1
		if ("showNeuromodProduction")
			old_mode = ui_mode
			ui_mode = 2
		if ("showDataManagement")
			old_mode = ui_mode
			ui_mode = 3
		if ("back")
			ui_mode = old_mode
			old_mode = ui_mode
		if ("ejectBeaker")
			GetHost().EjectBeaker()
		if ("insertBeaker")
			GetHost().InsertBeaker()
		if ("ejectDisk")
			GetHost().EjectDisk()
		if ("insertDisk")
			GetHost().InsertDisk()
		if ("ejectNeuromodShell")
			GetHost().EjectNeuromodShell()
		if ("insertNeuromodShell")
			GetHost().InsertNeuromodShell()
		if ("startResearching")
			GetHost().is_researching = TRUE
			GetHost().research_progress = 0
			GetHost().researching_neuromod = text2path(selected_neuromod)
		if ("stopResearching")
			GetHost().is_researching = FALSE
			GetHost().research_progress = 0
		if ("loadNeuromodFromDisk")
			GetHost().LoadNeuromodFromDisk()
		if ("loadLifeformFromDisk")
			GetHost().LoadLifeformFromDisk()
		if ("selectNeuromod")
			if (!href_list["neuromod_type"]) return 1

			var/list/neuromods = GetHost().neuromods

			if (!neuromods[href_list["neuromod_type"]]) return

			selected_neuromod = href_list["neuromod_type"]
		if ("toggleNeuromodsList")
			show_options ^= NEUROMODRND_OPTION_SHOW_NEUROMODS
		if ("toggleLifeformsList")
			show_options ^= NEUROMODRND_OPTION_SHOW_LIFEFORMS
		if ("flushBeaker")
			GetHost().FlushBeaker()
		if ("clearNeuromodShell")
			GetHost().ClearNeuromodShell()
		if ("selectLifeform")
			if (!href_list["lifeform_type"] || !GetHost().lifeforms[href_list["lifeform_type"]])
				return

			selected_lifeform = href_list["lifeform_type"]

	return 1

/datum/nano_module/neuromodRnD/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nano_ui/master_ui, datum/topic_state/state)
	var/list/data = host.initial_data()
	var/obj/machinery/computer/neuromodRnD/console = GetHost()

	data["mode"] = ui_mode

	data["disk"] = null
	data["beaker"] = console.BeakerToList()
	data["show_options"] = show_options
	data["neuromod_shell"] = console.NeuromodShellToList()
	data["neuromods"] = console.NeuromodsToList()
	data["lifeforms"] = console.LifeformsToList(user)
	data["selected_neuromod"] = console.NeuromodToList(selected_neuromod)
	data["selected_lifeform"] = console.LifeformToList(user, selected_lifeform)
	data["is_researching"] = console.is_researching
	data["research_progress"] = console.research_progress
	data["production_ready"] = FALSE
	data["production_status"] = FALSE

	nanoui_shell = data["neuromod_shell"]
	nanoui_beaker = data["beaker"]
	nanoui_lifeform = data["selected_lifeform"]
	nanoui_lifeforms = data["lifeforms"]

	var/obj/item/weapon/disk/disk = console.GetDisk()

	if (disk)
		if (istype(disk, /obj/item/weapon/disk/neuromod_disk))
			data["disk"] = "neuromod"
		else if (istype(disk, /obj/item/weapon/disk/lifeform_disk))
			data["disk"] = "lifeform"

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "neuromodRnD_console.tmpl", "Neuromod RnD Console", 900, 800, state = state)

		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(TRUE)

/* CONSOLE */

/obj/machinery/computer/neuromodRnD
	name = "neuromod RnD console"
	desc = "Use to research neuromod's data disks and fill neuromod's shells."
	icon_keyboard = "telesci_key"
	icon_screen = "dna"
	active_power_usage = 800
	clicksound = null
	circuit = /obj/item/weapon/circuitboard/neuromodRnD

	var/datum/nano_module/neuromodRnD/nmod_rnd = null
	var/research_progress = 0
	var/is_researching = FALSE
	var/datum/neuromod/researching_neuromod = null
	var/list/neuromods = null
	var/list/lifeforms = null
	var/list/accepts_disks = null

/* NEUROMODS LIST PROCS */

/obj/machinery/computer/neuromodRnD/proc/NeuromodToList(neuromod_type)
	if (!neuromod_type) return

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	if (!neuromods[neuromod_type]) return

	return (list("researched" = neuromods[neuromod_type]["researched"]) + GLOB.neuromods.ToList(neuromod_type))

/obj/machinery/computer/neuromodRnD/proc/NeuromodsToList()
	var/list/neuromods_list = list()

	if (neuromods.len == 0) return null

	for (var/neuromod_type in neuromods)
		var/datum/neuromod/neuromod = GLOB.neuromods.Get(neuromod_type)

		if (!neuromod) continue

		neuromods_list += (neuromod.ToList() + list("researched" = neuromods[neuromod_type]["researched"]))

	return list(neuromods_list)

/obj/machinery/computer/neuromodRnD/proc/IsNeuromodResearched(neuromod_type)
	if (!neuromod_type) return

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	if (!neuromods[neuromod_type]) return

	return neuromods[neuromod_type]["researched"]

/obj/machinery/computer/neuromodRnD/proc/LoadNeuromodFromDisk()
	var/obj/item/weapon/disk/neuromod_disk/neuromod_disk = GetDisk()

	if (!neuromod_disk || !neuromod_disk.neuromod)
		return

	if (neuromods["[neuromod_disk.neuromod]"])
		return

	AddNeuromod(neuromod_disk.neuromod)

/obj/machinery/computer/neuromodRnD/proc/AddNeuromod(neuromod_type)
	if (!neuromod_type) return

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	if (neuromods[neuromod_type]) return

	neuromods[neuromod_type] = list(
		"researched" = FALSE
	)

/* LIFEFORMS LIST PROCS */

/obj/machinery/computer/neuromodRnD/proc/LifeformToList(mob/user, lifeform_type)
	var/list/lifeform_data = list()

	if (!user || !lifeform_type || !lifeforms[lifeform_type])
		return null

	to_world("Ok")

	var/list/lifeform = GLOB.lifeforms.ToList(user, lifeform_type)

	if (!lifeform) return null

	to_world("Lifeform not null")

	lifeform_data = (list(
		"scan_count" = lifeforms[lifeform_type]["scan_count"]
	) + lifeform)

	return lifeform_data

/obj/machinery/computer/neuromodRnD/proc/LifeformsToList(mob/user)
	var/list/lifeforms_list = list()

	if (lifeforms.len == 0) return null

	for (var/lifeform_type in lifeforms)
		var/datum/lifeform/lifeform = GLOB.lifeforms.Get(lifeform_type)

		if (!lifeform) continue

		lifeforms_list += list(
			lifeform.ToList(user) + list(
			"scan_count" = lifeforms[lifeform_type]["scan_count"]
		))

	return lifeforms_list

/obj/machinery/computer/neuromodRnD/proc/AddLifeform(lifeform_type, custom_data=null, update=FALSE)
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

/obj/machinery/computer/neuromodRnD/proc/LoadLifeformFromDisk()
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

/* DISK PROCS */

/obj/machinery/computer/neuromodRnD/proc/GetDisk()
	for (var/disk_type in accepts_disks)
		var/obj/item/weapon/disk/disk = null
		disk = (locate(disk_type) in contents)

		if (disk) return disk

	return null

/obj/machinery/computer/neuromodRnD/proc/GetLifeformDisk()
	var/obj/item/weapon/disk/lifeform_disk/lifeform_disk = null
	lifeform_disk = (locate(/obj/item/weapon/disk) in contents)

	return lifeform_disk

/obj/machinery/computer/neuromodRnD/proc/GetNeuromodDisk()
	var/obj/item/weapon/disk/neuromod_disk/neuromod_disk = null
	neuromod_disk = (locate(/obj/item/weapon/disk) in contents)

	return neuromod_disk

/obj/machinery/computer/neuromodRnD/proc/EjectDisk()
	var/obj/item/weapon/disk/disk = GetDisk()

	if (!disk) return

	contents -= disk
	usr.put_in_hands(disk)

/obj/machinery/computer/neuromodRnD/proc/InsertDisk()
	if (GetDisk())
		to_chat(usr, "Console's disk slot is already occupied.")
		return

	var/obj/item/weapon/disk/disk = usr.get_active_hand()

	if (!disk) return

	usr.drop_item(disk)
	contents += disk

/* NEUROMOD SHELL PROCS */

/obj/machinery/computer/neuromodRnD/proc/ClearNeuromodShell()
	var/obj/item/weapon/reagent_containers/neuromod_shell/shell = GetNeuromodShell()

	if (!shell || !shell.neuromod) return

	shell.neuromod = null

/obj/machinery/computer/neuromodRnD/proc/NeuromodShellToList()
	var/obj/item/weapon/reagent_containers/neuromod_shell/shell = GetNeuromodShell()

	if (!shell) return null

	var/list/shell_data = list(
		"neuromod" = null
	)

	var/list/neuromod_data = GLOB.neuromods.ToList(shell.neuromod)

	if (neuromod_data)
		shell_data["neuromod"] = neuromod_data

	return shell_data

/obj/machinery/computer/neuromodRnD/proc/GetNeuromodShell()
	return (locate(/obj/item/weapon/reagent_containers/neuromod_shell/) in contents)

/obj/machinery/computer/neuromodRnD/proc/EjectNeuromodShell()
	var/obj/item/weapon/reagent_containers/neuromod_shell/neuromod_shell = GetNeuromodShell()

	if (neuromod_shell)
		contents -= neuromod_shell
		usr.put_in_hands(neuromod_shell)

/obj/machinery/computer/neuromodRnD/proc/InsertNeuromodShell()
	var/obj/item/weapon/reagent_containers/neuromod_shell/neuromod_shell = usr.get_active_hand()

	if (!neuromod_shell) return

	if (GetNeuromodShell())
		to_chat(usr, "Console's neuromod shell slot is already occupied.")
		return

	usr.drop_item(neuromod_shell)
	contents += neuromod_shell

/* BEAKER PROCS */

/obj/machinery/computer/neuromodRnD/proc/FlushBeaker()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return

	beaker.reagents.clear_reagents()

/obj/machinery/computer/neuromodRnD/proc/BeakerToList()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return null

	var/list/beaker_data = list(
		"check_status" = CheckBeakerContent(),
		"volume_max" = beaker.volume,
		"volume" = beaker.reagents.total_volume
	)

	return beaker_data

/obj/machinery/computer/neuromodRnD/proc/GetMutagen()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return null

	if (!CheckBeakerContent()) return null

	return beaker.reagents.reagent_list[1]

/obj/machinery/computer/neuromodRnD/proc/CheckBeakerContent()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (!beaker) return null

	var/datum/reagents/reagents = beaker.reagents

	if (reagents.reagent_list.len == 0 || reagents.reagent_list.len > 1)
		return FALSE

	var/datum/reagent/reagent = reagents.reagent_list[1]

	if (!reagent || !istype(reagent, /datum/reagent/mutagen))
		return FALSE

	return TRUE

/obj/machinery/computer/neuromodRnD/proc/GetBeaker()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = null
	beaker = (locate(/obj/item/weapon/reagent_containers/glass/beaker) in contents)

	return beaker

/obj/machinery/computer/neuromodRnD/proc/EjectBeaker()
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = GetBeaker()

	if (beaker)
		contents -= beaker
		usr.put_in_hands(beaker)

/obj/machinery/computer/neuromodRnD/proc/InsertBeaker()
	if (GetBeaker())
		to_chat(usr, "Console's beaker slot is already occupied.")
		return

	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = usr.get_active_hand()

	if (beaker)
		usr.drop_item(beaker)
		contents += beaker

/* OVERRIDES */

/obj/machinery/computer/neuromodRnD/Initialize()
	. = ..()

	nmod_rnd = new(src)
	neuromods = list()
	lifeforms = list()

	accepts_disks = typesof(/obj/item/weapon/disk/neuromod_disk, /obj/item/weapon/disk/lifeform_disk)

/obj/machinery/computer/neuromodRnD/Destroy()
	qdel(nmod_rnd)
	nmod_rnd = null

	..()

/obj/machinery/computer/neuromodRnD/Process()
	if (is_researching)
		if (!researching_neuromod || IsNeuromodResearched(researching_neuromod))
			research_progress = 0
			is_researching = FALSE

			playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		else
			research_progress += 10

			to_world("Before progress: [research_progress]")

			if (research_progress > initial(researching_neuromod.research_time))
				to_world("Progress: [research_progress]")
				to_world("Time: [initial(researching_neuromod.research_time)]")
				is_researching = FALSE
				neuromods["[researching_neuromod]"]["researched"] = TRUE
				research_progress = 0
				playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

/obj/machinery/computer/neuromodRnD/attackby(atom/I, user)
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

/obj/machinery/computer/neuromodRnD/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/neuromodRnD/attack_hand(mob/user)
	..()

	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/neuromodRnD/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)
	nmod_rnd.ui_interact(user, ui_key, ui, force_open, state)

/obj/machinery/computer/neuromodRnD/nano_container()
	return nmod_rnd

/obj/machinery/computer/neuromodRnD/interact(mob/user)
	nmod_rnd.ui_interact(user)

#undef NEUROMODRND_OPTION_SHOW_NEUROMODS
#undef NEUROMODRND_OPTION_SHOW_LIFEFORMS
#undef NEUROMODRND_MUTAGEN_VOLUME
