/mob
	var/list/psychoscope_icons[2]	// Contains HUD icons for a psychoscope

/mob/Initialize()
	. = ..()

	// Creates HUD icons.

	var/image/psychoscope_dot = new /image/hud_overlay('icons/mob/hud.dmi', src, "psychoscope_dot")
	psychoscope_dot.plane = EFFECTS_ABOVE_LIGHTING_PLANE

	var/image/psychoscope_scan = new /image('icons/mob/hud.dmi', src, "psychoscope_scan")
	psychoscope_scan.appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART
	psychoscope_scan.plane = EFFECTS_ABOVE_LIGHTING_PLANE

	psychoscope_icons[PSYCHOSCOPE_ICON_DOT] = psychoscope_dot
	psychoscope_icons[PSYCHOSCOPE_ICON_SCAN] = psychoscope_scan

// Psychoscope scanning on Shift + LMB
/mob/ShiftClick(mob/user)
	..()

	if(src != user && istype(src, /mob))
		var/mob/M = src

		var/obj/item/clothing/glasses/psychoscope/psychoscope = user.get_equipped_item(slot_glasses)

		if(psychoscope && istype(psychoscope))
			psychoscope.ScanLifeform(M)

/* PSYCHOSCOPE */

/obj/item/clothing/glasses/psychoscope
	name = "\improper psychoscope"
	desc = "Displays information about lifeforms. Scan target must be alive."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "psychoscope_on"
	off_state = "psychoscope_off"
	activation_sound = null // DAT SOUND LOUD AS FUCK
	active = FALSE
	hud_type = HUD_PSYCHOSCOPE
	electric = TRUE
	action_button_name = "Toggle Psychoscope"
	toggleable = 1
	body_parts_covered = EYES
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 4)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_REINFORCED_GLASS = 500, MATERIAL_GOLD = 200)
	w_class = ITEM_SIZE_NORMAL

	/* ENERGY MANAGEMENT */
	var/obj/item/weapon/cell/bcell = null
	var/cell_panel_opened = FALSE

	/* DATA MANAGEMENT */
	var/selected_lifeform = null			// For UI
	var/list/scanned = list()				// List of all scanned data, every scanned mob, opened neuromods/techs and etc.
	var/is_scanning = FALSE					// Must be TRUE while a psychoscope does scan.
	var/list/accepts_disks = list(/obj/item/weapon/disk/tech_disk,		// Disks which can be inserted into a psychoscope.
								  /obj/item/weapon/disk/neuromod_disk,
								  /obj/item/weapon/disk/lifeform_disk)

/* OPENING PROCS */

/*
	Opens one neuromod with a some chance (/datum/neuromod/chance).
	A opened neuromod will be added to `scanned[lifeform_type]["opened_neuromods"]` list.

	Inputs:
	lifeform_type - `text` or `path` to a lifeform (/datum/lifeform/)
*/
/obj/item/clothing/glasses/psychoscope/proc/ProbNeuromods(lifeform_type)
	if(!istext(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if(!scanned[lifeform_type])
		return

	var/datum/lifeform/L = GLOB.lifeforms.Get(lifeform_type)

	for(var/scan = 1, scan <= scanned[lifeform_type]["scan_count"], scan++)
		var/list/neuromod_rewards = L.neuromod_rewards[num2text(scan)]

		for(var/neuromod_reward in neuromod_rewards)
			var/datum/neuromod/N = neuromod_reward

			if(!N || neuromod_reward in scanned[lifeform_type]["opened_neuromods"])
				continue

			var/opened = prob(initial(N.chance))

			if(!opened)
				continue

			to_chat(usr, "A new neuromod available.")
			scanned[lifeform_type]["opened_neuromods"] += N
			return

/*
	Opens one technology with a some chance (/datum/lifeform/tech_chance).
	A opened technology will be added to `scanned[lifeform_type]["opened_techs"]` list.
	If there is a tehcnology with the same name - its technology level will be replaced.

	Inputs:
	lifeform_type - `text` or `path` to a lifeform (/datum/lifeform/)
*/
/obj/item/clothing/glasses/psychoscope/proc/ProbTechs(lifeform_type)
	if(!lifeform_type)
		crash_with("lifeform_type must be no null")
		return

	if(!istext(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if(!scanned[lifeform_type])
		return

	var/datum/lifeform/L = GLOB.lifeforms.Get(lifeform_type)

	if(!L)
		crash_with("L must be not null")
		return

	for(var/scan = 1, scan <= scanned[lifeform_type]["scan_count"], scan++)
		var/list/techs = L.tech_rewards[num2text(scan)]

		if(!techs)
			continue

		for(var/tech in techs)
			if(scanned[lifeform_type]["opened_techs"][tech] && scanned[lifeform_type]["opened_techs"][tech] >= techs[tech])
				continue

			var/opened = prob(L.tech_chance)

			if(!opened)
				continue

			to_chat(usr, "A new technology available.")
			scanned[lifeform_type]["opened_techs"][tech] = techs[tech]
			return

/* TO LIST PROCS */

/*
	Creates list which contains a data about all opened neuromods.

	Inputs:
	lifeform_type - `text` or `path` to a lifeform (/datum/lifeform/)

	Returns:
	list(
		list(neuromod_name, neuromod_desc, neuromod_type),
		...
	)
	OR
	null
*/
/obj/item/clothing/glasses/psychoscope/proc/NeuromodsToList(lifeform_type)
	if(!lifeform_type)
		crash_with("lifeform_type is null")
		return

	if(!istext(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if(!scanned[lifeform_type])
		crash_with("trying to get [lifeform_type] but it is not exists")
		return

	if(!scanned[lifeform_type]["opened_neuromods"].len)
		return

	var/list/neuromods_list = list()

	for(var/neuromod in scanned[lifeform_type]["opened_neuromods"])
		var/datum/neuromod/N = neuromod

		if(!N)
			continue

		neuromods_list += list(list(
			"neuromod_name" = initial(N.name),
			"neuromod_desc" = initial(N.desc),
			"neuromod_type" = neuromod
		))

	return neuromods_list

/*
	Creates list which contains a data about all opened techs.

	Inputs:
	lifeform_type - `text` or `path` to a lifeform (/datum/lifeform/)

	Returns:
	list(
		list("tech_id", "tech_name", "tech_level"),
		...
	)
	OR
	null
*/
/obj/item/clothing/glasses/psychoscope/proc/TechsToList(lifeform_type)
	if(!istext(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if(!scanned[lifeform_type])
		return

	if(!scanned[lifeform_type]["opened_techs"].len)
		return

	var/list/techs_list = list()

	for(var/tech in scanned[lifeform_type]["opened_techs"])
		techs_list += list(list(
			"tech_id" = tech,
			"tech_name" = CallTechName(tech),
			"tech_level" = scanned[lifeform_type]["opened_techs"][tech]
		))

	return techs_list

/*
	Converts list `scanned` into a ui-compatible list.

	Returns:
	list(
		list(
			"opened_techs" = list(...),		<-- See src.TechsToList() proc
			"opened_neuromods" = list(...),	<-- See src.NeuromodsToList() proc
			"lifeform" = list(...),			<-- See /datum/lifeform/ToList() proc
			"scanned_mobs" = list(...),		<-- List of scanned mobs
			"scan_count" = N,				<-- Total scan count for a lifeform
			"scans_journal" = list(...)		<-- Just date (when scanned) and name (who scanned)
		),
		...
	)
*/
/obj/item/clothing/glasses/psychoscope/proc/ScannedToList()
	if(!scanned.len)
		return

	var/list/scanned_list = list()

	for(var/lifeform_type in scanned)
		var/list/L = LifeformScanToList(lifeform_type)

		if(L)
			scanned_list += list(L)

	return scanned_list

/*
	Converts only one lifeform's scan data into a ui-compatible list.

	Inputs:
	lifeform_type - `string` or `path` of /datum/lifeform

	Returns:
	list(
		"opened_techs" = list(...),		<-- See src.TechsToList() proc
		"opened_neuromods" = list(...),	<-- See src.NeuromodsToList() proc
		"lifeform" = list(...),			<-- See /datum/lifeform/ToList() proc
		"scanned_mobs" = list(...),		<-- List of scanned mobs
		"scan_count" = N,				<-- Total scan count for a lifeform
		"scans_journal" = list(...)		<-- Just date (when scanned) and name (who scanned)
	)
*/
/obj/item/clothing/glasses/psychoscope/proc/LifeformScanToList(lifeform_type)
	if(!lifeform_type)
		crash_with("lifeform_type must be not null")
		return

	if(!istext(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if(!scanned[lifeform_type])
		crash_with("trying to get [lifeform_type] but it is not exists")
		return

	var/datum/lifeform/L = GLOB.lifeforms.Get(lifeform_type)

	if(!L)
		return

	var/list/lifeform_list = scanned[lifeform_type].Copy()

	lifeform_list["opened_techs"] = TechsToList(lifeform_type)
	lifeform_list["opened_neuromods"] = NeuromodsToList(lifeform_type)
	lifeform_list["lifeform"] = L.ToList()

	return lifeform_list

/* SCAN PROCS */

/*
	Checks if a mob is already scanned (in `scanned["scanned_mobs"]`).

	Inputs:
	target - a mob whom we want to check

	Returns:
	TRUE or FALSE
*/
/obj/item/clothing/glasses/psychoscope/proc/IsAlreadyScanned(mob/target)
	if(!target)
		crash_with("target must be not null")
		return

	if(!scanned || !scanned.len)
		return FALSE

	for(var/lifeform_type in scanned)
		if(target in scanned[lifeform_type]["scanned_mobs"])
			return TRUE

	return FALSE

/*
	Adds a scan entry in list `scanned` for the target mob (if it not scanned early).

	Inputs:
	lifeform - instance of lifeform of the target mob.
	scan_object - the target mob

	Returns:
	TRUE if a scan entry added.
	FALSE if something is wrong.
*/
/obj/item/clothing/glasses/psychoscope/proc/AddScan(datum/lifeform/lifeform, mob/scan_object)
	if(!lifeform)
		crash_with("lifeform must be not null")
		return

	if(!scan_object)
		crash_with("scan_object must be not null")
		return

	var/res = IsAlreadyScanned(scan_object)

	if(res == TRUE)
		return FALSE

	var/lifeform_type = "[lifeform.type]"

	if(!scanned[lifeform_type])
		scanned[lifeform_type] = list(
			"lifeform" = (lifeform.ToList()),
			"scan_count" = 1,
			"scans_journal" = list(list(
				"date" = "[stationdate2text()] - [stationtime2text()]",
				"name" = scan_object.name
			)),
			"opened_neuromods" = list(),
			"opened_techs" = list(),
			"scanned_mobs" = list(scan_object)
		)

		ProbTechs(lifeform_type)
		ProbNeuromods(lifeform_type)

		return TRUE

	scanned[lifeform_type]["scan_count"]++
	scanned[lifeform_type]["scans_journal"] += list(list(
		"date" = "[stationdate2text()] - [stationtime2text()]",
		"name" = scan_object.name
	))
	scanned[lifeform_type]["scanned_mobs"] += scan_object
	ProbTechs(lifeform_type)
	ProbNeuromods(lifeform_type)

	return TRUE

/*
	Do a scan procedure.

	Inputs:
	target - the target mob for a procedure

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/proc/ScanLifeform(mob/target)
	if(!src.active || is_scanning)
		return

	var/image/icon_scan = target.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN]

	if(!icon_scan)
		crash_with("icon_scan msut be not null")
		return

	is_scanning = TRUE
	usr.client.images += icon_scan
	playsound(src, 'sound/effects/psychoscope/psychoscope_scan.ogg', 10, 0)

	if(!do_after(usr, 40, target, 0, 0, INCAPACITATION_DEFAULT, 1, 1))
		usr.client.images -= icon_scan
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		is_scanning = FALSE
		return

	is_scanning = FALSE

	usr.client.images -= icon_scan

	var/datum/lifeform/lifeform_data = GLOB.lifeforms.GetByMob(target)

	if(!lifeform_data)
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		to_chat(usr, "Unknown lifeform.")
		return

	var/res = AddScan(lifeform_data, target)

	if(res)
		playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)
	else
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		to_chat(usr, "The object has already scanned.")

/* DISK PROCS */

/*
	Inserts a disk if it has usr.
	See `accepts_disks` for a list of insertable disks.

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/proc/InsertDisk()
	for(var/disk_type in accepts_disks)
		if(locate(disk_type) in contents)
			to_chat(usr, "Psychoscope's disk slot is already occupied.")
			return

	var/obj/item/weapon/disk/disk = usr.get_active_hand()

	if(!disk || !(disk.type in accepts_disks))
		return

	usr.drop_item(disk)
	contents += disk

/*
	Ejects an inserted disk and puts it in usr's hands.

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/proc/EjectDisk()
	for(var/disk_type in accepts_disks)
		var/obj/item/disk/disk = (locate(disk_type) in contents)

		if(disk)
			contents -= disk
			usr.put_in_hands(disk)
			return

/* SAVING PROCS */

/*
	Saves a lifeform's data to an inserted disk.

	Inputs:
	lifeform_type - `text` or `path` of /datum/lifeform

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/proc/SaveLifeformToDisk(lifeform_type)
	if(!lifeform_type)
		crash_with("lifeform_type is null")
		return

	if(ispath(lifeform_type))
		lifeform_type = "[lifeform_type]"

	if(!scanned[lifeform_type])
		crash_with("trying to get [lifeform_type] but it is not exists")
		return

	var/obj/item/weapon/disk/lifeform_disk/lifeform_disk = null
	lifeform_disk = (locate(/obj/item/weapon/disk/lifeform_disk) in contents)

	if(!lifeform_disk)
		return

	lifeform_disk.lifeform = lifeform_type
	lifeform_disk.lifeform_data = scanned[lifeform_type].Copy()
	playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

/*
	Saves a neuromod's data to an inserted disk.

	Inputs:
	neuromod_type - `text` or `path` of /datum/neuromod

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/proc/SaveNeuromodToDisk(neuromod_type)
	if(!neuromod_type)
		crash_with("neuromod_type is null")
		return

	if(istext(neuromod_type))
		neuromod_type = text2path(neuromod_type)

	var/obj/item/weapon/disk/neuromod_disk/neuromod_disk = null
	neuromod_disk = (locate(/obj/item/weapon/disk/neuromod_disk/) in contents)

	if(!neuromod_disk)
		return

	neuromod_disk.neuromod = neuromod_type
	playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

/*
	Saves tech's data to an inserted disk.

	Inputs:
	tech_id - Id of a tech.
	tech_level - level of a tech.

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/proc/SaveTechToDisk(tech_id, tech_level)
	if(!tech_id)
		crash_with("tech_id is null")
		return

	if(!tech_level)
		crash_with("tech_level is null")
		return

	var/obj/item/weapon/disk/tech_disk/tech_disk = null
	tech_disk = (locate(/obj/item/weapon/disk/tech_disk/) in contents)

	if(!tech_disk)
		return

	if(tech_disk.stored)
		QDEL_NULL(tech_disk.stored)

	for(var/type in subtypesof(/datum/tech))
		var/datum/tech/T = type
		if(initial(T.id) == tech_id)
			tech_disk.stored = new T()
			tech_disk.stored.level = tech_level

			playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

			return

/* TOGGLING PROCS */

/obj/item/clothing/glasses/psychoscope/proc/Enable(mob/user)
	if(bcell && bcell.charge <= 0)
		Disable(user)

		if(user)
			to_chat(user, SPAN_WARNING("No power!"))

		return

	if(!bcell)
		Disable(user)
		return

	if(!active)
		if(user)
			to_chat(user, "You activate the optical matrix on \the [src.name].")

		active = TRUE
		icon_state = initial(icon_state)
		is_scanning = FALSE
		playsound(src, 'sound/effects/psychoscope/psychoscope_on.ogg', 10, 0)
		set_light(2, 5, rgb(105, 180, 255))
		update_icon()

/obj/item/clothing/glasses/psychoscope/proc/Disable(mob/user)
	if(active)
		if(user)
			to_chat(user, "You deactivate the optical matrix on \the [src.name].")

		active = FALSE
		is_scanning = FALSE
		icon_state = off_state
		set_light(0)

/* VERBS */

/*
	Just toggles a psychoscope.

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/verb/TogglePsychoscope()
	set name = "Toggle Psychoscope"
	set desc = "Enables or disables your psychoscope"
	set popup_menu = 1
	set category = "Psychoscope"

	attack_self(usr)

/*
	Shows a psychoscope's UI.

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/verb/ShowPsychoscopeUI()
	set name = "Show Psychoscope UI"
	set desc = "Opens psychoscope's menu."
	set popup_menu = 1
	set category = "Psychoscope"

	tg_ui_interact(usr)

/*
	Removes an inserted disk.

	Returns:
	Nothing
*/
/obj/item/clothing/glasses/psychoscope/verb/RemoveDisk()
	set name = "Remove Disk"
	set desc = "Removes disk from psychoscope."
	set popup_menu = 1
	set category = "Psychoscope"

	EjectDisk()

/* OVERRIDES */

/obj/item/clothing/glasses/psychoscope/examine(mob/user)
	. = ..()

	. += "\nThe battery panel is [cell_panel_opened ? "opened" : "closed"]."

/obj/item/clothing/glasses/psychoscope/attack_hand(mob/user)
	if(cell_panel_opened && bcell)
		if(!do_after(user, 10, user, FALSE, TRUE, INCAPACITATION_DEFAULT, FALSE, FALSE))
			return

		visible_message("[user] ejects \the [bcell] from \the [src]")
		user.put_in_hands(bcell)
		bcell = null

		return

	. = ..()

/obj/item/clothing/glasses/psychoscope/attackby(obj/item/weapon/I, mob/user)
	if(isScrewdriver(I))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

		if(!do_after(user, 10, user, FALSE, TRUE, INCAPACITATION_DEFAULT, FALSE, FALSE))
			return

		cell_panel_opened = !cell_panel_opened
		visible_message("[user] [cell_panel_opened ? "opens" : "closes"] the battery panel of \the [src]")

		return

	if(istype(I, /obj/item/weapon/cell))
		if(cell_panel_opened && !bcell)
			if(!do_after(user, 10, user, FALSE, TRUE, INCAPACITATION_DEFAULT, FALSE, FALSE))
				return

			visible_message("[user] inserts \the [I] in \the [src]")
			user.unEquip(I)
			I.forceMove(src)
			bcell = I
		else
			to_chat(user, SPAN_NOTICE("Open the battery panel before."))

		return

	. = ..()

/obj/item/clothing/glasses/psychoscope/attack_self(mob/user)
	if(active)
		Disable(user)
	else
		Enable(user)

	user.update_inv_glasses()
	update_icon()
	user.update_action_buttons()

/obj/item/clothing/glasses/psychoscope/Process()
	if(active)
		if(!bcell)
			Disable()

		var/en_consumption = 3
		if(is_scanning)
			en_consumption += 15

		if(!bcell.use(en_consumption))
			Disable()

/obj/item/clothing/glasses/psychoscope/Destroy()
	STOP_PROCESSING(SSprocessing, src)

	. = ..()

/obj/item/clothing/glasses/psychoscope/Initialize()
	. = ..()

	overlay = GLOB.global_hud.material
	icon_state = "psychoscope_off"
	START_PROCESSING(SSprocessing, src)

/*
	Toggles a psychoscope.
*/
/obj/item/clothing/glasses/psychoscope/proc/Toggle(mob/user)
	if(active)
		Disable(user)
	else
		Enable(user)
/*
	Inserting a disk.
*/
/obj/item/clothing/glasses/psychoscope/attackby(I, user)
	if(istype(I, /obj/item/weapon/disk))
		InsertDisk()
		return

	. = ..()

/* HotKeys */

/*
	Shows up a psychoscope's UI.
*/
/obj/item/clothing/glasses/psychoscope/AltClick(mob/user)
	tg_ui_interact(user)

/* UI */

/obj/item/clothing/glasses/psychoscope/tg_ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "psychoscope", "Psychoscope", 500, 600, master_ui, state)
		ui.open()

/obj/item/clothing/glasses/psychoscope/ui_data(mob/user, ui_key)
	var/list/data = list()

	data["status"] = active
	data["scanned"] = ScannedToList()
	data["total_lifeforms"] = GLOB.lifeforms.list_of_lifeforms.len
	data["opened_lifeforms"] = scanned.len
	data["selected_lifeform"] = null
	data["inserted_disk"] = null
	data["charge"] = null
	data["max_charge"] = null

	if(bcell)
		data["charge"] = bcell.charge
		data["max_charge"] = bcell.maxcharge

	var/obj/item/weapon/disk/inserted_disk = null
	inserted_disk = (locate(/obj/item/weapon/disk) in contents)

	if(istype(inserted_disk, /obj/item/weapon/disk/tech_disk))
		data["inserted_disk"] = "tech"
	else if(istype(inserted_disk, /obj/item/weapon/disk/neuromod_disk))
		data["inserted_disk"] = "neuromod"
	else if(istype(inserted_disk, /obj/item/weapon/disk/lifeform_disk))
		data["inserted_disk"] = "lifeform"

	if(selected_lifeform)
		data["selected_lifeform"] = LifeformScanToList(selected_lifeform)

	return data

/obj/item/clothing/glasses/psychoscope/ui_act(action, params)
	if(..()) return

	. = FALSE

	if(!bcell)
		return

	if(!bcell.charge)
		return

	playsound(src, 'sound/effects/using/console/press15.ogg', rand(5, 20), TRUE)

	switch(action)
		if("togglePsychoscope")
			TogglePsychoscope()
			return TRUE
		if("showLifeform")
			if(!params["lifeform_type"] || !scanned[params["lifeform_type"]])
				return

			selected_lifeform = params["lifeform_type"]
			return TRUE
		if("ejectDisk")
			EjectDisk(usr)
			return TRUE
		if("insertDisk")
			InsertDisk(usr)
			return TRUE
		if("saveTechToDisk")
			if(!params["lifeform_type"] || !params["tech_id"] || !params["tech_level"])
				return

			if(!scanned[params["lifeform_type"]]["opened_techs"][params["tech_id"]] || scanned[params["lifeform_type"]]["opened_techs"][params["tech_id"]] < text2num(params["tech_level"]))
				return

			SaveTechToDisk(params["tech_id"], text2num(params["tech_level"]))
			return TRUE
		if("saveNeuromodToDisk")
			if(!params["neuromod_type"] || !params["lifeform_type"] || !(text2path(params["neuromod_type"]) in scanned[params["lifeform_type"]]["opened_neuromods"]))
				return

			SaveNeuromodToDisk(params["neuromod_type"])
			return TRUE
		if("saveLifeformToDisk")
			if(!params["lifeform_type"] || !scanned[params["lifeform_type"]])
				return

			SaveLifeformToDisk(params["lifeform_type"])
			return TRUE

/* HUD */

/obj/item/clothing/glasses/psychoscope/process_hud(mob/M)
	if(active)
		if(!can_process_hud(M))
			return

		var/datum/arranged_hud_process/P = arrange_hud_process(M, 0, GLOB.med_hud_users)

		for(var/mob/living/target in P.Mob.in_view(P.Turf) - M)
			if(!target.is_dead())
				P.Client.images += target.psychoscope_icons[PSYCHOSCOPE_ICON_DOT]
