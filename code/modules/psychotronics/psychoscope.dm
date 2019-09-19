/mob
	var
		list/psychoscope_icons[2]
		list/neuromods = list()

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

		if (equip && equip.type == /obj/item/clothing/glasses/hud/Psychoscope)
			var/obj/item/clothing/glasses/hud/Psychoscope/pscope = equip

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
		class = ""
		genus = ""
		species = ""
		desc = ""
		scan_count = 0
		list/scanned_list = list()
		list/tech_rewards = list()
		list/neuromod_rewards = list()
		list/opened_neuromods = list()

	New(kingdom, class, genus, species, desc, list/tech_rewards, list/neuromod_rewards)
		src.kingdom = kingdom
		src.class = class
		src.genus = genus
		src.species = species
		src.desc = desc
		src.tech_rewards = tech_rewards
		src.neuromod_rewards = neuromod_rewards

	proc
		ProbNeuromods()
			for (var/scan = scan_count, scan > 0, scan--)
				var/list/neuromods = neuromod_rewards[num2text(scan)]

				if (!neuromods || neuromods.len == 0)
					continue

				for (var/N in neuromods)
					if (!N in subtypesof(/datum/NeuromodData))
						continue

					var/datum/NeuromodData/nData = N

					if (nData in opened_neuromods)
						continue

					var/unlocked = prob(initial(nData.chance))

					if (unlocked && !isnull(nData) && nData in subtypesof(/datum/NeuromodData))
						opened_neuromods.Add(nData)
						to_chat(usr, "New neuromod available!")

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

		GetUnlockedNeuromods()
			var/list/neuromods_list = list()

			for (var/N in opened_neuromods)
				to_world("N")
				var/datum/NeuromodData/nData = N

				if (isnull(nData))
					continue

				neuromods_list.Add(list(
					list("neuromod_name" = initial(nData.name), "neuromod_type" = nData, "neuromod_desc" = initial(nData.desc))
				))

			return neuromods_list

		ToList()
			var/list/L = list()

			L["kingdom"] = kingdom
			L["class"] = class
			L["genus"] = genus
			L["species"] = species
			L["desc"] = desc
			L["scan_count"] = scan_count
			L["opened_techs"] = GetUnlockedTechs()
			L["opened_neuromods"] = GetUnlockedNeuromods()

			return L

/* PSYCHOSCOPE */

/obj/item/clothing/glasses/hud/Psychoscope
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
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 3)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_REINFORCED_GLASS = 500, MATERIAL_GOLD = 200)

	var
		list/scans_journal = list()
		datum/PsychoscopeLifeformData/selected_lifeform = null
		list/total_lifeforms = list()
		is_scanning = FALSE
		list/last_techs = list()

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

			if (lData == null)
				playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
				to_chat(usr, "Unknown lifeform.")
				return
			else
				playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)
				to_chat(usr, "New data added to your Psychoscope.")

			var/datum/PsychoscopeScanData/sData = new(lData, M.name)
			scans_journal.Add(sData)

		GetLifeformData(mob/M, count_scan=TRUE)
			if (M.type in GLOB.psychoscope_lifeform_data)
				var/datum/PsychoscopeLifeformData/lData = GLOB.psychoscope_lifeform_data[M.type]

				if ("\ref[M]" in lData["scanned_list"])
					return 0
				if (count_scan)
					lData.scan_count++
					lData.scanned_list.Add("\ref[M]")
					lData.ProbNeuromods()

				return lData
			else
				return null

		PrintTechs(datum/PsychoscopeLifeformData/lData)
			var/list/techs_list = lData.GetUnlockedTechs()
			var/obj/item/LifeformScanDisk/disk = new(usr.loc)
			disk.origin_tech = list()
			disk.desc += "\nLoaded Technologies:"

			for (var/tech in techs_list)
				disk.origin_tech.Add(list(tech["tech_id"] = tech["tech_level"]))
				disk.desc += "\n[tech["tech_name"]] - [tech["tech_level"]]"

			if (!usr.put_in_any_hand_if_possible(disk, FALSE, FALSE))
				disk.Move(usr.loc)

		PrintNeuromodData(neuromod_type)
			neuromod_type = text2path(neuromod_type)
			if (!ispath(neuromod_type))
				return

			var/datum/NeuromodData/D = new neuromod_type
			var/obj/item/NeuromodDataDisk/disk = new(usr.loc)

			disk.neuromod_data = D
			disk.name = D.name
			disk.desc += "\n[D.name] - [D.desc]"

			if (!usr.put_in_any_hand_if_possible(disk, FALSE, FALSE))
				disk.Move(usr.loc)

		/* NOT USED */
		PrintData(datum/PsychoscopeLifeformData/lData)
			to_chat(usr, "Scan Data:")
			to_chat(usr, "Kingdom: [lData.kingdom]")
			to_chat(usr, "class: [lData.class]")
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
			playsound(src, 'sound/effects/psychoscope/psychoscope_on.ogg', 10, 0)
			set_light(2, 5, rgb(105, 180, 255))

	/* HotKeys */

	CtrlClick(mob/user)
		. = ..()

		ui_interact(user)

	/* UI */

	Topic(href, list/href_list)
		. = ..()

		playsound(src, 'sound/machines/console_click2.ogg', 10, 1)

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
			if ("printNeuromodData")
				PrintNeuromodData(href_list["neuromod_type"])

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