/mob
	var
		list/psychoscope_icons[2]

	Initialize()
		. = ..()

		psychoscope_icons[PSYCHOSCOPE_ICON_DOT] = new /image/hud_overlay('icons/mob/hud.dmi', src, "psychoscope_dot")
		psychoscope_icons[PSYCHOSCOPE_ICON_SCAN] = new /image('icons/mob/hud.dmi', src, "psychoscope_scan")
		psychoscope_icons[PSYCHOSCOPE_ICON_SCAN].appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART

/proc/GetLifeformDataByType(var/lifeformType)
	return GLOB.psychoscope_life_data[lifeformType]

/datum/PsychoscopeScanData
	var
		datum/PsychoscopeLifeformData/lifeform
		date = 0
		object_name = ""

	New(lifeform_data, object_name)
		src.date = "[stationdate2text()] - [stationtime2text()]"
		src.lifeform = lifeform_data
		src.object_name = object_name

	proc
		ToList()
			var/list/L = list()

			L["date"] = date
			L["lifeform"] = lifeform.ToList()
			L["object_name"] = object_name

			return L

/datum/PsychoscopeLifeformData
	var
		kingdom = ""
		order = ""
		genus = ""
		species = ""
		desc = ""
		scan_count = 0

	New(kingdom, order, genus, species, desc)
		src.kingdom = kingdom
		src.order = order
		src.genus = genus
		src.species = species
		src.desc = desc
		src.scan_count = 0

	proc
		ToList()
			var/list/L = list()

			L["kingdom"] = kingdom
			L["order"] = order
			L["genus"] = genus
			L["species"] = species
			L["desc"] = desc
			L["scan_count"] = scan_count

			return L

/* PSYCHOSCOPE */

/obj/item/clothing/glasses/hud/psychoscope
	name = "psychoscope"
	desc = "Displays information about lifeforms. Scan target must be alive."
	icon_state = "psychoscope_on"
	off_state = "psychoscope_off"
	active = FALSE
	hud_type = HUD_PSYCHOSCOPE
	electric = TRUE
	action_button_name = "Toggle Psychoscope"
	toggleable = 1
	body_parts_covered = EYES
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 3)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_REINFORCED_GLASS = 500, MATERIAL_GOLD = 200)

	var
		list/scans_journal = list()
		datum/PsychoscopeLifeformData/selected_lifeform = null
		list/total_lifeforms = list()

		/* UI MODES */
		//
		// 0 - Main Menu
		// 1 - List of scans
		// 2 - List of known lifeforms
		// 3 - Lifeform Details
		//

		ui_mode = 0

	proc
		ScanLifeform(var/mob/M)
			if (src.active)
				usr.client.images += M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN]

			if (!do_after(usr, 40, M, 0, 0, INCAPACITATION_DEFAULT, 1, 1))
				usr.client.images.Remove(M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN])
				return

			usr.client.images.Remove(M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN])

			var/datum/PsychoscopeLifeformData/lData = src.GetLifeformData(M)
			to_chat(usr, "New scan data added to your Psychoscope.")

			var/datum/PsychoscopeScanData/sData = new(lData, M.name)
			scans_journal.Add(sData)

		GetLifeformData(var/mob/M, var/count_scan=TRUE)
			if (M.type in GLOB.psychoscope_life_data)
				if (count_scan)
					GLOB.psychoscope_life_data[M.type].scan_count++

				return GLOB.psychoscope_life_data[M.type]
			else
				return GLOB.psychoscope_life_data[/mob]

		/* NOT USED */
		PrintData(var/datum/PsychoscopeLifeformData/lData)
			to_chat(usr, "Scan Data:")
			to_chat(usr, "Kingdom: [lData.kingdom]")
			to_chat(usr, "Order: [lData.order]")
			to_chat(usr, "Genus: [lData.genus]")
			to_chat(usr, "Species: [lData.species]")
			to_chat(usr, "Description: [lData.desc]")

	verb
		ShowPsychoscopeUI()
			set name = "Show Psychoscope UI"
			set desc = "Opens psychoscope's menu."
			set popup_menu = 1
			set category = "Psychoscope"

			ui_interact(usr)

	/* OVERRIDES */

	Initialize()
		. = ..()
		overlay = GLOB.global_hud.material
		icon_state = "psychoscope_off"

	attack_self(mob/user)
		. = ..(user)

		if (!active)
			set_light(0)
		else
			set_light(2, 5, rgb(105, 180, 255))

	/* HotKeys */

	CtrlClick(mob/user)
		. = ..()

		ui_interact(user)

	/* UI */

	Topic(var/href, var/list/href_list)
		. = ..()

		switch(href_list["option"])
			if ("togglePsychoscope")
				attack_self(usr)
			if ("showScansJournal")
				ui_mode = 1
			if ("showMainMenu")
				ui_mode = 0
			if ("deleteScan")
				scans_journal.Remove(locate(href_list["scan_reference"]))
			if ("showLifeformsList")
				ui_mode = 2
			if ("showLifeform")
				ui_mode = 3
				selected_lifeform = (locate(href_list["lifeform_reference"]) in total_lifeforms)

		return 1

	ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
		var/list/data = list()
		total_lifeforms = list()

		for (var/T in GLOB.psychoscope_life_data)
			total_lifeforms.Add(GLOB.psychoscope_life_data[T])

		data["status"] = active
		data["mode"] = ui_mode
		data["scans_journal"] = list()
		data["lifeforms_list"] = list()
		data["lifeforms"] = null

		if (selected_lifeform)
			data["lifeform"] = selected_lifeform.ToList()

		switch(ui_mode)
			if (1)
				for (var/datum/PsychoscopeScanData/sData in scans_journal)
					data["scans_journal"].Add(list(
						list(
							"scan" = sData.ToList(),
							"scan_reference" = "\ref[sData]",
							"lifeform_reference" = "\ref[sData.lifeform]"
						)
					))
			if (2)
				for (var/I in GLOB.psychoscope_life_data)
					var/datum/PsychoscopeLifeformData/D = GetLifeformDataByType(I)

					if (!D || D.species == "Unknown")
						continue

					data["lifeforms_list"].Add(list(
						list(
							"lifeform" = D.ToList(),
							"lifeform_reference" = "\ref[D]"
						)
					))

		ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

		if (!ui)
			ui = new(user, src, ui_key, "psychoscope.tmpl", "Psychoscope UI", 400, 400)

			ui.set_initial_data(data)
			ui.open()

		ui.set_auto_update(TRUE)

	/* HUD */

	process_hud(mob/M)
		if (active)
			if (!can_process_hud(M))
				return

			var/datum/arranged_hud_process/P = arrange_hud_process(M, 0, GLOB.med_hud_users)

			for(var/mob/living/target in P.Mob.in_view(P.Turf) - M)
				if (!target.is_dead())
					P.Client.images += target.psychoscope_icons[PSYCHOSCOPE_ICON_DOT]