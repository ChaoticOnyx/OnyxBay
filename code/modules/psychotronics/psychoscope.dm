/mob
	var/list/psychoscope_icons[2]
	var/list/neuromods

/mob/Initialize()
	. = ..()

	var/image/psychoscope_dot = new /image/hud_overlay('icons/mob/hud.dmi', src, "psychoscope_dot")
	psychoscope_dot.plane = EFFECTS_ABOVE_LIGHTING_PLANE

	var/image/psychoscope_scan = new /image('icons/mob/hud.dmi', src, "psychoscope_scan")
	psychoscope_scan.appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART
	psychoscope_scan.plane = EFFECTS_ABOVE_LIGHTING_PLANE

	psychoscope_icons[PSYCHOSCOPE_ICON_DOT] = psychoscope_dot
	psychoscope_icons[PSYCHOSCOPE_ICON_SCAN] = psychoscope_scan
	neuromods = list()

/mob/ShiftClick(mob/user)
	. = ..()

	if (src != user && istype(src, /mob))
		var/mob/M = src

		var/atom/equip = user.get_equipped_item(slot_glasses)

		if (equip && equip.type == /obj/item/clothing/glasses/hud/psychoscope)
			var/obj/item/clothing/glasses/hud/psychoscope/pscope = equip

			pscope.ScanLifeform(M, user)

/* PSYCHOSCOPE */

/obj/item/clothing/glasses/hud/psychoscope
	name = "psychoscope"
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

	var/list/scanned = null
	var/selected_lifeform = null
	var/is_scanning = FALSE
	var/list/accepts_disks = null

	/* UI MODES */
	//
	// 0 - Main Menu
	// 1 - List of scans
	// 2 - List of known lifeforms
	// 3 - Lifeform Details
	//

	var/ui_mode = 0
	var/old_mode = 0

/obj/item/clothing/glasses/hud/psychoscope/proc/TechsToList(lifeform_type)
	if (!lifeform_type || !scanned[lifeform_type])
		return

	if (!scanned[lifeform_type]["opened_techs"].len)
		return null

	var/list/techs_list = list()

	for (var/tech in scanned[lifeform_type]["opened_techs"])
		techs_list += list(list(
			"tech_id" = tech,
			"tech_name" = CallTechName(tech),
			"tech_level" = scanned[lifeform_type]["opened_techs"][tech]
		))

	return techs_list

/obj/item/clothing/glasses/hud/psychoscope/proc/NeuromodsToList(lifeform_type)
	if (!lifeform_type || !scanned[lifeform_type])
		return

	if (!scanned[lifeform_type]["opened_neuromods"].len)
		return null

	var/list/neuromods_list = list()

	for (var/neuromod in scanned[lifeform_type]["opened_neuromods"])
		var/datum/neuromod/N = text2path(neuromod)

		if (!N)
			continue

		neuromods_list += list(list(
			"neuromod_name" = initial(N.name),
			"neuromod_desc" = initial(N.desc),
			"neuromod_type" = neuromod
		))

	return neuromods_list

/obj/item/clothing/glasses/hud/psychoscope/proc/ProbNeuromods(lifeform_type)
	if (!lifeform_type || !scanned[lifeform_type])
		return

	var/datum/lifeform/L = GLOB.lifeforms.Get(lifeform_type)

	if (!L)
		return

	for (var/scan = 1, scan <= scanned[lifeform_type]["scan_count"], scan++)
		var/list/neuromod_rewards = L.neuromod_rewards[num2text(scan)]

		for (var/neuromod_reward in neuromod_rewards)
			var/datum/neuromod/N = neuromod_reward

			if (!N || neuromod_reward in scanned[lifeform_type]["opened_neuromods"])
				continue

			var/opened = prob(initial(N.chance))

			if (!opened)
				continue

			to_chat(usr, "A new neuromod available.")
			scanned[lifeform_type]["opened_neuromods"] += "[N]"

/obj/item/clothing/glasses/hud/psychoscope/proc/ProbTechs(lifeform_type)
	if (!lifeform_type || !scanned[lifeform_type])
		return

	var/datum/lifeform/L = GLOB.lifeforms.Get(lifeform_type)

	if (!L)
		return

	for (var/scan = 1, scan <= scanned[lifeform_type]["scan_count"], scan++)
		var/list/techs = L.tech_rewards[num2text(scan)]

		if (!techs)
			continue

		for (var/tech in techs)
			if (scanned[lifeform_type]["opened_techs"][tech] && scanned[lifeform_type]["opened_techs"][tech] >= techs[tech])
				continue

			var/opened = prob(L.tech_chance)

			if (!opened)
				continue

			to_chat(usr, "A new technology available.")
			scanned[lifeform_type]["opened_techs"][tech] = techs[tech]

/obj/item/clothing/glasses/hud/psychoscope/proc/ScannedToList(mob/user)
	if (!scanned || !scanned.len || !user)
		return null

	var/list/nano_list = list()

	for (var/lifeform_type in scanned)
		var/list/L = list(
			"lifeform_type" = lifeform_type,
			"content" = (scanned[lifeform_type].Copy())
		)

		L["content"]["opened_techs"] = TechsToList(lifeform_type)
		L["content"]["opened_neuromods"] = NeuromodsToList(lifeform_type)

		var/datum/lifeform/LF = GLOB.lifeforms.Get(lifeform_type)

		if (!LF)
			return null

		L["content"]["lifeform"] = LF.ToList(user)

		nano_list += list(L)

	return nano_list

/obj/item/clothing/glasses/hud/psychoscope/proc/LifeformScanToList(lifeform_type, mob/user)
	if (!lifeform_type || !istext(lifeform_type) || !scanned[lifeform_type] || !user)
		return null

	var/list/lifeform_list = list(
		"lifeform_type" = lifeform_type,
		"content" = (scanned[lifeform_type].Copy())
	)

	var/datum/lifeform/L = GLOB.lifeforms.Get(lifeform_type)
	lifeform_list["content"]["opened_techs"] = TechsToList(lifeform_type)
	lifeform_list["content"]["opened_neuromods"] = NeuromodsToList(lifeform_type)

	if (!L)
		return null

	lifeform_list["content"]["lifeform"] = L.ToList(user)

	return lifeform_list

/obj/item/clothing/glasses/hud/psychoscope/proc/IsAlreadyScanned(mob/M)
	if (!M)
		return FALSE

	if (!scanned || !scanned.len)
		return FALSE

	for (var/lifeform_type in scanned)
		if (M in scanned[lifeform_type]["scanned_mobs"])
			return TRUE

	return FALSE

/obj/item/clothing/glasses/hud/psychoscope/proc/AddScan(datum/lifeform/lifeform, mob/scan_object, mob/user)
	if (!lifeform || !user)
		return FALSE

	var/res = IsAlreadyScanned(scan_object)

	if (res == TRUE)
		return FALSE

	var/lifeform_type = "[lifeform.type]"

	if (!scanned[lifeform_type])
		scanned[lifeform_type] = list(
			"lifeform" = (lifeform.ToList(user)),
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

/obj/item/clothing/glasses/hud/psychoscope/proc/ScanLifeform(mob/M, mob/user)
	if (!src.active || is_scanning || !user)
		return

	is_scanning = TRUE
	usr.client.images += M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN]
	playsound(src, 'sound/effects/psychoscope/psychoscope_scan.ogg', 10, 0)

	if (!do_after(usr, 40, M, 0, 0, INCAPACITATION_DEFAULT, 1, 1))
		usr.client.images.Remove(M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN])
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		is_scanning = FALSE
		return

	is_scanning = FALSE

	usr.client.images.Remove(M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN])

	var/datum/lifeform/lifeform_data = GLOB.lifeforms.GetByMob(M)

	if (!lifeform_data)
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		to_chat(usr, "Unknown lifeform.")
		return

	var/res = AddScan(lifeform_data, M, user)

	if (res)
		playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)
		to_chat(usr, "A new data added to your Psychoscope.")
	else
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		to_chat(usr, "The object has already scanned.")

/* DISK PROCS */

/obj/item/clothing/glasses/hud/psychoscope/proc/InsertDisk()
	for (var/disk_type in accepts_disks)
		if (locate(disk_type) in contents)
			to_chat(usr, "Psychoscope's disk slot is already occupied.")
			return

	var/obj/item/weapon/disk/disk = usr.get_active_hand()

	if (!disk || !(disk.type in accepts_disks))
		return

	usr.drop_item(disk)
	contents += disk

/obj/item/clothing/glasses/hud/psychoscope/proc/EjectDisk()
	for (var/disk_type in accepts_disks)
		var/obj/item/disk/disk = (locate(disk_type) in contents)

		if (disk)
			contents -= disk
			usr.put_in_hands(disk)
			return

/* SAVING PROCS */

/obj/item/clothing/glasses/hud/psychoscope/proc/SaveLifeformToDisk(lifeform_type)
	if (!lifeform_type || !scanned[lifeform_type])
		return

	var/obj/item/weapon/disk/lifeform_disk/lifeform_disk = null
	lifeform_disk = (locate(/obj/item/weapon/disk/) in contents)

	if (!lifeform_disk || !istype(lifeform_disk))
		return null

	lifeform_disk.lifeform = lifeform_type
	lifeform_disk.lifeform_data = scanned[lifeform_type].Copy()
	playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

/obj/item/clothing/glasses/hud/psychoscope/proc/SaveNeuromodToDisk(neuromod_type)
	if (!neuromod_type)
		return

	var/obj/item/weapon/disk/neuromod_disk/neuromod_disk = null
	neuromod_disk = (locate(/obj/item/weapon/disk/) in contents)

	if (!neuromod_disk || !istype(neuromod_disk))
		return

	neuromod_disk.neuromod = text2path(neuromod_type)
	playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

/obj/item/clothing/glasses/hud/psychoscope/proc/SaveTechToDisk(tech_id, tech_level)
	if (!tech_id || !tech_level)
		return

	var/obj/item/weapon/disk/tech_disk/tech_disk = null
	tech_disk = (locate(/obj/item/weapon/disk/) in contents)

	if (!tech_disk || !istype(tech_disk))
		return

	if (tech_disk.stored)
		QDEL_NULL(tech_disk.stored)

	for (var/type in subtypesof(/datum/tech))
		var/datum/tech/T = type
		if (initial(T.id) == tech_id)
			tech_disk.stored = new T()
			tech_disk.stored.level = tech_level

			playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

			return

/obj/item/clothing/glasses/hud/psychoscope/verb/TogglePsychoscope()
	set name = "Toggle Psychoscope"
	set desc = "Enables or disables your psychoscope"
	set popup_menu = 1
	set category = "Psychoscope"

	attack_self(usr)

/obj/item/clothing/glasses/hud/psychoscope/verb/ShowPsychoscopeUI()
	set name = "Show Psychoscope UI"
	set desc = "Opens psychoscope's menu."
	set popup_menu = 1
	set category = "Psychoscope"

	tg_ui_interact(usr)

/obj/item/clothing/glasses/hud/psychoscope/verb/RemoveDisk()
	set name = "Remove Disk"
	set desc = "Removes disk from psychoscope."
	set popup_menu = 1
	set category = "Psychoscope"

	EjectDisk()

/* OVERRIDES */

/obj/item/clothing/glasses/hud/psychoscope/Initialize()
	. = ..()

	scanned = list()
	overlay = GLOB.global_hud.material
	icon_state = "psychoscope_off"
	accepts_disks = typesof(/obj/item/weapon/disk/tech_disk, /obj/item/weapon/disk/neuromod_disk, /obj/item/weapon/disk/lifeform_disk)

/obj/item/clothing/glasses/hud/psychoscope/attack_self(mob/user)
	. = ..(user)

	if (!active)
		is_scanning = FALSE
		set_light(0)
	else
		playsound(src, 'sound/effects/psychoscope/psychoscope_on.ogg', 10, 0)
		set_light(2, 5, rgb(105, 180, 255))

/obj/item/clothing/glasses/hud/psychoscope/attackby(I, user)
	if (istype(I, /obj/item/weapon/disk))
		InsertDisk()
		return

	. = ..()

/* HotKeys */

/obj/item/clothing/glasses/hud/psychoscope/AltClick(mob/user)
	. = ..()

	tg_ui_interact(user)

/* UI */

/obj/item/clothing/glasses/hud/psychoscope/tg_ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "psychoscope", "Psychoscope", 500, 600, master_ui, state)
		ui.open()

/obj/item/clothing/glasses/hud/psychoscope/ui_data(mob/user, ui_key)
	var/list/data = list()

	data["status"] = active
	data["mode"] = ui_mode
	data["scanned"] = ScannedToList(user)
	data["total_lifeforms"] = GLOB.lifeforms.list_of_lifeforms.len
	data["opened_lifeforms"] = scanned.len
	data["selected_lifeform"] = null
	data["inserted_disk"] = null

	var/obj/item/weapon/disk/inserted_disk = null
	inserted_disk = (locate(/obj/item/weapon/disk) in contents)

	if (istype(inserted_disk, /obj/item/weapon/disk/tech_disk))
		data["inserted_disk"] = "tech"
	else if (istype(inserted_disk, /obj/item/weapon/disk/neuromod_disk))
		data["inserted_disk"] = "neuromod"
	else if (istype(inserted_disk, /obj/item/weapon/disk/lifeform_disk))
		data["inserted_disk"] = "lifeform"

	if (selected_lifeform)
		data["selected_lifeform"] = LifeformScanToList(selected_lifeform, user)

	return data

/obj/item/clothing/glasses/hud/psychoscope/ui_act(action, params)
	if (..()) return

	. = FALSE

	playsound(src, 'sound/machines/console_click2.ogg', 10, 1)

	switch(action)
		if ("togglePsychoscope")
			attack_self(usr)
			return TRUE
		if ("showScansJournal")
			if (!params["lifeform_type"] || !istext(params["lifeform_type"]) || !scanned[params["lifeform_type"]])
				return

			selected_lifeform = params["lifeform_type"]

			ui_mode = 1
			return TRUE
		if ("close")
			ui_mode = old_mode
			old_mode = ui_mode
			return TRUE
		if ("showLifeformsList")
			old_mode = ui_mode
			ui_mode = 2
			return TRUE
		if ("showLifeform")
			if (!params["lifeform_type"] || !scanned[params["lifeform_type"]])
				return

			old_mode = ui_mode
			ui_mode = 3
			selected_lifeform = params["lifeform_type"]
			return TRUE
		if ("showMainMenu")
			ui_mode = 0
			old_mode = 0
			return TRUE
		if ("ejectDisk")
			EjectDisk(usr)
			return TRUE
		if ("insertDisk")
			InsertDisk(usr)
			return TRUE
		if ("saveTechToDisk")
			if (!params["lifeform_type"] || !params["tech_id"] || !params["tech_level"])
				return

			if (!scanned[params["lifeform_type"]]["opened_techs"][params["tech_id"]] || scanned[params["lifeform_type"]]["opened_techs"][params["tech_id"]] < text2num(params["tech_level"]))
				return

			SaveTechToDisk(params["tech_id"], text2num(params["tech_level"]))
			return TRUE
		if ("saveNeuromodToDisk")
			if (!params["neuromod_type"] || !params["lifeform_type"] || !(params["neuromod_type"] in scanned[params["lifeform_type"]]["opened_neuromods"]))
				return

			SaveNeuromodToDisk(params["neuromod_type"])
			return TRUE
		if ("saveLifeformToDisk")
			if (!params["lifeform_type"] || !scanned[params["lifeform_type"]])
				return

			SaveLifeformToDisk(params["lifeform_type"])
			return TRUE

/* HUD */

/obj/item/clothing/glasses/hud/psychoscope/process_hud(mob/M)
	if (active)
		if (!can_process_hud(M))
			return

		var/datum/arranged_hud_process/P = arrange_hud_process(M, 0, GLOB.med_hud_users)

		for(var/mob/living/target in P.Mob.in_view(P.Turf) - M)
			if (!target.is_dead())
				P.Client.images += target.psychoscope_icons[PSYCHOSCOPE_ICON_DOT]