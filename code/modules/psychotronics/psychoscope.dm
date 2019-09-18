/mob
	var
		list/psychoscope_icons[2]

	Initialize()
		. = ..()

		psychoscope_icons[PSYCHOSCOPE_ICON_DOT] = new /image/hud_overlay('icons/mob/hud.dmi', src, "psychoscope_dot")
		psychoscope_icons[PSYCHOSCOPE_ICON_SCAN] = new /image('icons/mob/hud.dmi', src, "psychoscope_scan")
		psychoscope_icons[PSYCHOSCOPE_ICON_SCAN].appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART

/mob/ShiftClick(mob/user)
	. = ..()

	if (src != user && istype(src, /mob))
		var/mob/M = src

		var/atom/equip = user.get_equipped_item(slot_glasses)

		if (equip && equip.type == /obj/item/clothing/glasses/hud/psychoscope)
			var/obj/item/clothing/glasses/hud/psychoscope/pscope = equip

			pscope.ScanLifeform(M)

/proc/GetLifeformDataByType(var/lifeformType)
	return GLOB.psychoscope_lifeform_data[lifeformType]

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
		max_scans = 0
		scanned_list = list()
		tech_rewards = list()

	New(kingdom, order, genus, species, desc, list/tech_rewards)
		src.kingdom = kingdom
		src.order = order
		src.genus = genus
		src.species = species
		src.desc = desc
		src.scan_count = 0
		src.tech_rewards = tech_rewards

		for (var/tech_level in tech_rewards)
			if (text2num(tech_level) > max_scans)
				max_scans = text2num(tech_level)

	proc
		GetUnlockedTechs()
			var/list/tech_list = list()

			for (var/scan = scan_count, scan > 0, scan--)
				var/list/reward = tech_rewards[num2text(scan)]

				if (!reward || reward.len == 0)
					continue

				for (var/I in reward)
					tech_list.Add(list(
						list("tech_name" = CallTechName(I), "tech_level" = reward[I], "tech_id" = I)
					))

				return tech_list

		ToList()
			var/list/L = list()

			L["kingdom"] = kingdom
			L["order"] = order
			L["genus"] = genus
			L["species"] = species
			L["desc"] = desc
			L["scan_count"] = scan_count
			L["max_scans"] = max_scans
			L["opened_techs"] = GetUnlockedTechs()

			return L

/* PSYCHOSCOPE */

/obj/item/clothing/glasses/hud/psychoscope
	name = "psychoscope"
	desc = "Displays information about lifeforms. Scan target must be alive."
	icon = 'icons/obj/psychotronics.dmi'
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
		is_scanning = FALSE
		list/last_techs = list()

		list/stored_material =  list(MATERIAL_STEEL = 0, MATERIAL_GLASS = 0)
		list/storage_capacity = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 100)

		/* UI MODES */
		//
		// 0 - Main Menu
		// 1 - List of scans
		// 2 - List of known lifeforms
		// 3 - Lifeform Details
		//

		ui_mode = 0
		old_mode = 0

	proc
		ScanLifeform(mob/M)
			if (!src.active || is_scanning)
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

			var/datum/PsychoscopeLifeformData/lData = src.GetLifeformData(M)

			if (!lData)
				playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
				to_chat(usr, "Unknown lifeform.")
				return

			if (lData.scan_count > lData.max_scans)
				playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
				to_chat(usr, "No new data detected.")
				lData.scan_count = lData.max_scans
			else
				playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)
				to_chat(usr, "New data added to your Psychoscope.")

			var/datum/PsychoscopeScanData/sData = new(lData, M.name)
			scans_journal.Add(sData)

		GetLifeformData(mob/M, count_scan=TRUE)
			if (M.type in GLOB.psychoscope_lifeform_data)
				if ("\ref[M]" in GLOB.psychoscope_lifeform_data[M.type]["scanned_list"])
					return null
				if (count_scan)
					GLOB.psychoscope_lifeform_data[M.type].scan_count++
					GLOB.psychoscope_lifeform_data[M.type].scanned_list.Add("\ref[M]")

				return GLOB.psychoscope_lifeform_data[M.type]
			else
				return null

		PrintTechs(datum/PsychoscopeLifeformData/lData)
			var/list/techs_list = lData.GetUnlockedTechs()
			var/obj/item/lifeform_scan_disk/disk = new(usr.loc)
			disk.origin_tech = list()
			disk.desc += "\nLoaded Technologies:"

			for (var/tech in techs_list)
				disk.origin_tech.Add(list(tech["tech_id"] = tech["tech_level"]))
				disk.desc += "\n[tech["tech_name"]] - [tech["tech_level"]]"

			if (!usr.put_in_any_hand_if_possible(disk, FALSE, FALSE))
				disk.Move(usr.loc)

		/* NOT USED */
		PrintData(datum/PsychoscopeLifeformData/lData)
			to_chat(usr, "Scan Data:")
			to_chat(usr, "Kingdom: [lData.kingdom]")
			to_chat(usr, "Order: [lData.order]")
			to_chat(usr, "Genus: [lData.genus]")
			to_chat(usr, "Species: [lData.species]")
			to_chat(usr, "Description: [lData.desc]")

	verb
		TogglePsychoscope()
			set name = "Toggle Psychoscope"
			set desc = "Enables or disables your psychoscope"
			set popup_menu = 1
			set category = "Psychoscope"

			attack_self(usr)

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

	Topic(href, list/href_list)
		. = ..()

		switch(href_list["option"])
			if ("togglePsychoscope")
				attack_self(usr)
			if ("showScansJournal")
				old_mode = ui_mode
				ui_mode = 1
			if ("back")
				ui_mode = old_mode
				old_mode = ui_mode
			if ("deleteScan")
				scans_journal.Remove(locate(href_list["scan_reference"]))
			if ("showLifeformsList")
				old_mode = ui_mode
				ui_mode = 2
			if ("showLifeform")
				old_mode = ui_mode
				ui_mode = 3
				selected_lifeform = (locate(href_list["lifeform_reference"]) in total_lifeforms)
			if ("printTechs")
				PrintTechs((locate(href_list["lifeform_reference"]) in total_lifeforms))
			if ("showMainMenu")
				ui_mode = 0
				old_mode = 0

		return 1

	ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
		var/list/data = list()
		total_lifeforms = list()

		for (var/T in GLOB.psychoscope_lifeform_data)
			total_lifeforms.Add(GLOB.psychoscope_lifeform_data[T])

		data["status"] = active
		data["mode"] = ui_mode
		data["scans_journal"] = list()
		data["lifeforms_list"] = list()

		if (selected_lifeform)
			data["lifeform"] = selected_lifeform.ToList()
			data["lifeform_reference"] = "\ref[selected_lifeform]"

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
				for (var/I in GLOB.psychoscope_lifeform_data)
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