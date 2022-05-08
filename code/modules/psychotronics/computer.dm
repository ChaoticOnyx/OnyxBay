
#define NEUROMODRND_MUTAGEN_NEEDED 25

// CONSOLE

/obj/machinery/computer/neuromod_rnd
	name = "neuromod RnD console"
	desc = "Use to research neuromod's data disks and fill neuromod's shells."
	icon_keyboard = "telesci_key"
	icon_screen = "dna"
	active_power_usage = 800
	clicksound = 'sound/machines/console_click.ogg'
	circuit = /obj/item/circuitboard/neuromod_rnd

	// RESEARCHING AND DEVELOPMENT
	var/research_progress = 0
	var/development_progress = 0
	var/max_development_progress = 100
	var/is_researching = FALSE
	var/is_develop = FALSE
	var/datum/neuromod/researching_neuromod = null

	// DATA MANAGEMENT
	var/list/neuromods = list()					// List of all saved neuromods
	var/list/lifeforms = list()					// List of all saved lifeforms
	var/datum/lifeform/selected_lifeform = null	// Contains path to a lifeform
	var/datum/neuromod/selected_neuromod = null	// Contains path to a neuromod

	// ENERGY CONSUMPTION
	active_power_usage = 15 KILOWATTS
	idle_power_usage = 40

	// Disks which this console accepts
	var/list/accepts_disks = list(/obj/item/disk/neuromod_disk, /obj/item/disk/lifeform_disk)

/* UI */

/obj/machinery/computer/neuromod_rnd/tgui_act(action, params)
	. = ..()

	if(.)
		return

	playsound(src, clicksound, 15, 1)

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

				var/obj/item/reagent_containers/neuromod_shell/neuromod_shell = GetNeuromodShell()
				var/datum/lifeform/L = GLOB.lifeforms.Get(selected_lifeform)
				neuromod_shell.created_for = L.mob_type

				return TRUE
		if ("stopDevelopment")
			is_develop = FALSE
			development_progress = 0
			return TRUE

/obj/machinery/computer/neuromod_rnd/tgui_data(mob/user, ui_key)
	var/list/data = list()

	data["disk"] = null
	data["beaker"] = null
	data["neuromod_shell"] = null
	data["neuromods"] = null
	data["lifeforms"] = null
	data["selected_neuromod"] = null
	data["selected_lifeform"] = null

	if (GetBeaker())
		data["beaker"] = BeakerToList()

	if (GetNeuromodShell())
		data["neuromod_shell"] = NeuromodShellToList()

	if (neuromods.len)
		data["neuromods"] = NeuromodsToList()

	if (lifeforms.len)
		data["lifeforms"] = LifeformsToList(user)

	if (selected_neuromod)
		data["selected_neuromod"] = NeuromodToList(selected_neuromod)

	if (selected_lifeform)
		data["selected_lifeform"] = LifeformToList(selected_lifeform)

	data["is_researching"] = is_researching
	data["research_progress"] = research_progress
	data["development_ready"] = DevelopmentReady(user)
	data["development_progress"] = development_progress

	var/obj/item/disk/disk = GetDisk()

	if (disk)
		if (istype(disk, /obj/item/disk/neuromod_disk))
			data["disk"] = "neuromod"
		else if (istype(disk, /obj/item/disk/lifeform_disk))
			data["disk"] = "lifeform"

	return data

/obj/machinery/computer/neuromod_rnd/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "NeuromodRnD", name)
		ui.open()

/* DEVELOPMENT PROCS */

/*
	Checks all requirements for development a neuromod:
	There is must be a beaker with `NEUROMODRND_MUTAGEN_NEEDED` unstable mutagen
	There is must be a selected lifeform
	There is must be a inserted neuromod shell
	There is must be a researched and selected neuromod

	Returns:
	TRUE or FALSE
*/
/obj/machinery/computer/neuromod_rnd/proc/DevelopmentReady()
	. = FALSE

	var/datum/reagent/M = GetMutagen()

	if (!M)
		return FALSE

	if (selected_neuromod && selected_lifeform && GetNeuromodShell() && M.volume >= NEUROMODRND_MUTAGEN_NEEDED)
		var/list/neuromod_data = NeuromodToList(selected_neuromod)

		if (CheckBeakerContent() && neuromod_data["researched"])
			return TRUE

/* NEUROMODS LIST PROCS */

/*
	Returns an ui-compatible list with a neuromod data

	Inputs:
	neuromod_type - `path` or `string` of a neuromod

	Returns:
	list(...) - See /datum/neuromod/ToList() proc
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/NeuromodToList(neuromod_type)
	if (!neuromod_type)
		crash_with("neuromod_type is null")
		return

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	if (!neuromods[neuromod_type])
		crash_with("trying to get [neuromod_type] but it is not exists")
		return

	return (list("researched" = neuromods[neuromod_type]["researched"]) + GLOB.neuromods.ToList(neuromod_type))

/*
	Returns an ui-compatible list with data of all saved neuromods in this console

	Returns:
	list(
		list(...) - See /datum/neuromod/ToList() proc
	)
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/NeuromodsToList()
	var/list/neuromods_list = list()

	if (neuromods.len == 0) return null

	for (var/neuromod_type in neuromods)
		var/datum/neuromod/neuromod = GLOB.neuromods.Get(neuromod_type)

		if (!neuromod) continue

		neuromods_list += (neuromod.ToList() + list("researched" = neuromods[neuromod_type]["researched"]))

	return list(neuromods_list)

/*
	Returns a neuromod's research state

	Inputs:
	neuromod_type - `path` or `string` of a neuromod

	Returns:
	TRUE
	OR
	FALSE
*/
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

/*
	Loads a neuromod data from an inserted disk

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/LoadNeuromodFromDisk()
	var/obj/item/disk/neuromod_disk/neuromod_disk = GetDisk()

	if (!neuromod_disk || !neuromod_disk.neuromod)
		return

	AddNeuromod(neuromod_disk.neuromod, neuromod_disk.researched)

/*
	Saves selected neuromod's data to an inserted disk

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/SaveNeuromodToDisk(neuromod_type)
	if (!neuromod_type)
		crash_with("neuromod_type is null")

	var/obj/item/disk/neuromod_disk/neuromod_disk = GetNeuromodDisk()

	if (!neuromod_disk)
		return

	if (istext(neuromod_type))
		neuromod_type = text2path(neuromod_type)

	neuromod_disk.neuromod = neuromod_type
	neuromod_disk.researched = IsNeuromodResearched(neuromod_type)

/*
	Adds (or replaces) a neuromod to `neuromods` list

	Inputs:
	neuromod_type - `path` or `string` to a neuromod
	researched - is it researched neuromod or not

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/AddNeuromod(neuromod_type, researched)
	if (!neuromod_type)
		crash_with("neuromod_type is null")

	if (researched == null)
		crash_with("researched is null")

	if (ispath(neuromod_type))
		neuromod_type = "[neuromod_type]"

	neuromods[neuromod_type] = list(
		"researched" = researched
	)

/* LIFEFORMS LIST PROCS */

/*
	Returns an ui-compatible list with a lifeform data

	Inputs:
	lifeform_type - `path` or `string` to a neuromod

	Returns:
	list(...) - See /datum/lifeform/ToList() proc
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/LifeformToList(lifeform_type)
	var/list/lifeform_data = list()

	if (!lifeform_type)
		crash_with("lifeform_type is null")
		return null

	if (ispath(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if (!lifeforms[lifeform_type])
		crash_with("trying to get [lifeform_type] but it is not exists")
		return null

	var/list/lifeform = GLOB.lifeforms.ToList(lifeform_type)

	if (!lifeform) return null

	lifeform_data = (list(
		"scan_count" = lifeforms[lifeform_type]["scan_count"]
	) + lifeform)

	return lifeform_data

/*
	Returns an ui-compatible list with data of all saved lifeforms in this console

	Returns:
	list(
		list(...) - See /datum/lifeform/ToList() proc
	)
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/LifeformsToList()
	var/list/lifeforms_list = list()

	if (!lifeforms || lifeforms.len == 0) return null

	for (var/lifeform_type in lifeforms)
		var/datum/lifeform/lifeform = GLOB.lifeforms.Get(lifeform_type)

		if (!lifeform) continue

		lifeforms_list += list(
			lifeform.ToList() + list(
			"scan_count" = lifeforms[lifeform_type]["scan_count"]
		))

	return lifeforms_list

/*
	Adds (or replaces) a lifeform data to `lifeforms` list

	Inputs:
	lifeform_type - `path` or `string` of a lifeform
	lifeform_data - a lifeform data

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/AddLifeform(lifeform_type, lifeform_data)
	if (!lifeform_type)
		crash_with("lifeform_type is null")
		return

	if (!lifeform_data)
		crash_with("lifeform_data is null")
		return

	if (ispath(lifeform_type))
		lifeform_type = "[lifeform_type]"

	lifeforms[lifeform_type] = lifeform_data

/*
	Loads a lifeform data from an inserted disk

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/LoadLifeformFromDisk()
	var/obj/item/disk/lifeform_disk/lifeform_disk = GetDisk()

	if (!lifeform_disk || !lifeform_disk.lifeform_data)
		return

	var/list/lifeform_data = lifeform_disk.lifeform_data.Copy()

	AddLifeform(lifeform_disk.lifeform, lifeform_data)

/*
	Saves selected lifeform's data to an inserted disk

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/SaveLifeformToDisk(lifeform_type)
	if (!lifeform_type)
		crash_with("lifeform_type is null")
		return

	var/obj/item/disk/lifeform_disk/lifeform_disk = GetLifeformDisk()

	if (!lifeform_disk)
		return

	if (istext(lifeform_type))
		lifeform_type = text2path(lifeform_type)

	lifeform_disk.lifeform = lifeform_type
	lifeform_disk.lifeform_data = (LifeformsToList(usr, lifeform_type) + list("scan_count" = lifeforms["[lifeform_type]"]["scan_count"]))

/* DISK PROCS */

/*
	Returns an inserted disk

	Returns:
	/obj/item/disk/
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/GetDisk()
	for (var/disk_type in accepts_disks)
		var/obj/item/disk/disk = null
		disk = (locate(disk_type) in contents)

		if (disk) return disk

	return null

/*
	Get an inserted lifeform data disk

	Returns:
	/obj/item/disk/lifeform_disk/
	OR
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/GetLifeformDisk()
	var/obj/item/disk/lifeform_disk/lifeform_disk = null
	lifeform_disk = (locate(/obj/item/disk) in contents)

	return lifeform_disk

/*
	Get an inserted neuromod data disk

	Returns:
	/obj/item/disk/neuromod_disk/
	OR
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/GetNeuromodDisk()
	var/obj/item/disk/neuromod_disk/neuromod_disk = null
	neuromod_disk = (locate(/obj/item/disk) in contents)

	return neuromod_disk

/*
	Ejects an inserted disk

	Return:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/EjectDisk()
	var/obj/item/disk/disk = GetDisk()

	if (!disk) return

	contents -= disk
	usr.put_in_hands(disk)

/*
	Insert a disk which is in user's hands

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/InsertDisk()
	if (GetDisk())
		to_chat(usr, "Console's disk slot is already occupied.")
		return

	var/obj/item/disk/disk = usr.get_active_hand()

	if (!disk) return

	usr.drop_item(disk)
	contents += disk

/* NEUROMOD SHELL PROCS */

/*
	Clears neuromod shell from any neuromod in there

	Return:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/ClearNeuromodShell()
	var/obj/item/reagent_containers/neuromod_shell/shell = GetNeuromodShell()

	if (!shell || !shell.neuromod) return

	shell.neuromod = null
	shell.created_for = null

/*
	Returns an ui-compatible list with a neuromod shell data

	Returns:
	list(
		"neuromod" = list(...), - See /datum/neuromod/ToList()
		"created_for" = /mob/...
	)
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/NeuromodShellToList()
	var/obj/item/reagent_containers/neuromod_shell/shell = GetNeuromodShell()

	if (!shell) return null

	var/list/shell_data = list(
		"neuromod" = null
	)

	shell_data["neuromod"] = null

	if (shell.neuromod)
		shell_data["neuromod"] = GLOB.neuromods.ToList(shell.neuromod)

	shell_data["created_for"] = shell.created_for

	return shell_data

/*
	Returns an inserted neuromod shell

	Returns:
	/obj/item/reagent_conainers/neuromod_shell/
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/GetNeuromodShell()
	return (locate(/obj/item/reagent_containers/neuromod_shell/) in contents)

/*
	Ejects an inserted neuromod shell

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/EjectNeuromodShell()
	var/obj/item/reagent_containers/neuromod_shell/neuromod_shell = GetNeuromodShell()

	if (neuromod_shell)
		contents -= neuromod_shell
		usr.put_in_hands(neuromod_shell)

/*
	Insert a neuromod which is in user's hands

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/InsertNeuromodShell()
	var/obj/item/reagent_containers/neuromod_shell/neuromod_shell = usr.get_active_hand()

	if (!neuromod_shell || !istype(neuromod_shell)) return

	if (GetNeuromodShell())
		to_chat(usr, "Console's neuromod shell slot is already occupied.")
		return

	usr.drop_item(neuromod_shell)
	contents += neuromod_shell

/* BEAKER PROCS */

/*
	Removes `NEUROMODRND_MUTAGEN_NEEDED` of mutagen from a beaker

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/TakeReagents()
	var/obj/item/reagent_containers/vessel/beaker/beaker = GetBeaker()

	if (!beaker)
		crash_with("beaker is null")

	beaker.reagents.remove_reagent(/datum/reagent/mutagen, NEUROMODRND_MUTAGEN_NEEDED, TRUE)

/*
	Returns an ui-compatible list with a beaker data

	Returns:
	list(
		"check_status" = TRUE or FALSE,
		"volume_max" = `number`,
		"volume" = `number`
	)
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/BeakerToList()
	var/obj/item/reagent_containers/vessel/beaker/beaker = GetBeaker()

	if (!beaker) return null

	var/list/beaker_data = list(
		"check_status" = CheckBeakerContent(),
		"volume_max" = beaker.volume,
		"volume" = beaker.reagents.total_volume
	)

	return beaker_data

/*
	Returns a reference to a mutagen in an inserted beaker

	Returns:
	/datum/reagent/mutagen/
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/GetMutagen()
	var/obj/item/reagent_containers/vessel/beaker/beaker = GetBeaker()

	if (!beaker) return null

	if (!CheckBeakerContent()) return null

	var/datum/reagent/mutagen/M = beaker.reagents.reagent_list[1]

	if (istype(M))
		return M

	return null

/*
	Checks an inserted beaker content:
	Beaker must be with only unstable mutagen
	Mutagen's volume must be >= `NEUROMODRND_MUTAGEN_NEEDED`

	Returns:
	TRUE OR FALSE
*/
/obj/machinery/computer/neuromod_rnd/proc/CheckBeakerContent()
	var/obj/item/reagent_containers/vessel/beaker/beaker = GetBeaker()

	if (!beaker) return null

	var/datum/reagents/reagents = beaker.reagents

	if (reagents.reagent_list.len == 0 || reagents.reagent_list.len > 1)
		return FALSE

	var/datum/reagent/reagent = reagents.reagent_list[1]

	if (!reagent || !istype(reagent, /datum/reagent/mutagen))
		return FALSE

	return TRUE

/*
	Returns an inserted beaker

	Returns:
	/obj/item/reagent_containers/vessel/beaker/
	OR
	null
*/
/obj/machinery/computer/neuromod_rnd/proc/GetBeaker()
	var/obj/item/reagent_containers/vessel/beaker/beaker = null
	beaker = (locate(/obj/item/reagent_containers/vessel/beaker) in contents)

	return beaker

/*
	Ejects an inserted beaker

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/EjectBeaker()
	var/obj/item/reagent_containers/vessel/beaker/beaker = GetBeaker()

	if (beaker)
		contents -= beaker
		usr.put_in_hands(beaker)

/*
	Insert a beaker which is in user's hands

	Returns:
	Nothing
*/
/obj/machinery/computer/neuromod_rnd/proc/InsertBeaker()
	if (GetBeaker())
		to_chat(usr, "Console's beaker slot is already occupied.")
		return

	var/obj/item/reagent_containers/vessel/beaker/beaker = usr.get_active_hand()

	if (beaker)
		usr.drop_item(beaker)
		contents += beaker

/* OVERRIDES */

/obj/machinery/computer/neuromod_rnd/Process()
	if (!is_researching && !is_develop)
		update_use_power(POWER_USE_IDLE)

	// Process researching
	if (is_researching)
		update_use_power(POWER_USE_ACTIVE)

		// Stops researching
		if (!researching_neuromod || IsNeuromodResearched(researching_neuromod) || (stat & (BROKEN | NOPOWER)))
			research_progress = 0
			is_researching = FALSE

			playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)

		// Finishing the researching
		else
			research_progress += 1

			if (research_progress > initial(researching_neuromod.research_time))
				is_researching = FALSE
				neuromods["[researching_neuromod]"]["researched"] = TRUE
				research_progress = 0
				researching_neuromod = null
				playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

	// Process development
	if (is_develop)
		update_use_power(POWER_USE_ACTIVE)

		if (stat & (BROKEN | NOPOWER))
			is_develop = FALSE
			development_progress = 0
			playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)

		development_progress += 1

		// Finishing the development
		if (development_progress > max_development_progress)
			development_progress = 0
			is_develop = FALSE

			var/obj/item/reagent_containers/neuromod_shell/N = GetNeuromodShell()

			if (!N)
				crash_with("Development over with no neuromod shell in the console!")
				return

			N.neuromod = selected_neuromod
			N.UpdateDesc()
			playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

/obj/machinery/computer/neuromod_rnd/attackby(atom/I, user)

	// Handling inserting of items
	if (istype(I, /obj/item/reagent_containers/neuromod_shell))
		InsertNeuromodShell()
		return
	else if (istype(I, /obj/item/reagent_containers/vessel/beaker))
		InsertBeaker()
		return
	else
		for (var/disk_type in accepts_disks)
			if (istype(I, disk_type))
				InsertDisk()
				return

	. = ..()

/obj/machinery/computer/neuromod_rnd/attack_ai(mob/user)
	tgui_interact(user)

/obj/machinery/computer/neuromod_rnd/attack_hand(mob/user)
	..()

	if(stat & (BROKEN|NOPOWER))
		return
	tgui_interact(user)

/obj/machinery/computer/neuromod_rnd/interact(mob/user)
	tgui_interact(user)

#undef NEUROMODRND_MUTAGEN_NEEDED
