/datum/nano_module/neuromodRnD
	name = "Neuromod RnD"

	var
		/* UI Modes */
		//
		// 0 - Main Menu
		// 1 - Neuromod Researching
		// 2 - Neuromod Production
		// 3 - Neuromods List
		//

		ui_mode = 0
		old_mode = 0

	proc
		GetHost()
			var/obj/machinery/computer/neuromodRnD/computer_host = host
			return computer_host

	Topic(href, list/href_list)
		if (..()) return 1

		playsound(GetHost(), 'sound/machines/console_click.ogg', 15, 1)

		switch (href_list["option"])
			if ("showNeuromodResearching")
				old_mode = ui_mode
				ui_mode = 1
			if ("showNeuromodProduction")
				old_mode = ui_mode
				ui_mode = 2
			if ("showNeuromodsList")
				old_mode = ui_mode
				ui_mode = 3
			if ("back")
				ui_mode = old_mode
				old_mode = ui_mode
			if ("ejectNeuromod")
				GetHost().EjectNeuromod()
			if ("ejectNeuromodData")
				GetHost().EjectNeuromodData()
			if ("insertNeuromod")
				GetHost().InsertNeuromod()
			if ("insertNeuromodData")
				GetHost().InsertNeuromodData()
			if ("startResearching")
				GetHost().is_researching = TRUE
				GetHost().research_progress = 0
			if ("stopResearching")
				GetHost().is_researching = FALSE
				GetHost().research_progress = 0

		return 1

	ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nano_ui/master_ui, datum/topic_state/state)
		var/list/data = host.initial_data()

		data["mode"] = ui_mode

		data["inserted_neuromod"] = GetHost().GetInsertedNeuromod()
		if (data["inserted_neuromod"])
			data["inserted_neuromod"] = data["inserted_neuromod"].ToList()

		data["inserted_neuromod_data"] = GetHost().GetInsertedNeuromodDataDisk()
		data["is_researched"] = FALSE

		if (data["inserted_neuromod_data"])
			data["inserted_neuromod_data"] = data["inserted_neuromod_data"].ToList()

			if (GetHost().GetInsertedNeuromodDataDisk().neuromod_data.type in GetHost().researched_neuromods)
				data["is_researched"] = TRUE

		data["research_progress"] = GetHost().research_progress
		data["is_researching"] = GetHost().is_researching
		data["researched_neuromods"] = list()

		for (var/I in GetHost().researched_neuromods)
			var/datum/neuromodData/N = I

			if (!N)
				continue

			data["researched_neuromods"].Add(list(
				list("neuromod_name" = initial(N.name), "neuromod_desc" = initial(N.desc))
			))

		ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

		if (!ui)
			ui = new(user, src, ui_key, "neuromodRnD_console.tmpl", "Neuromod RnD Console", 900, 800, state = state)

			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(TRUE)

/obj/machinery/computer/neuromodRnD
	name = "neuromod RnD console"
	desc = "Use to research neuromod's data disks and fill neuromod's shells."
	icon_keyboard = "telesci_key"
	icon_screen = "dna"
	active_power_usage = 800
	clicksound = null
	circuit = /obj/item/weapon/circuitboard/neuromodRnD

	var
		datum/nano_module/neuromodRnD/nmod_rnd = null
		research_progress = 0
		is_researching = FALSE
		list/researched_neuromods = list()

	proc
		GetInsertedNeuromod()
			return (locate(/obj/item/weapon/reagent_containers/neuromod/) in contents)

		GetInsertedNeuromodDataDisk()
			return (locate(/obj/item/neuromodDataDisk) in contents)

		InsertNeuromod()
			var/obj/item/weapon/reagent_containers/neuromod/N = usr.get_active_hand()

			if (!N)
				return

			if (GetInsertedNeuromod())
				to_chat(usr, "Console's neuromod slot is already occupied.")
				return

			usr.drop_item(N)
			contents += N

		InsertNeuromodData()
			var/obj/item/neuromodDataDisk/N = usr.get_active_hand()

			if (!N)
				return

			if (!N.neuromod_data)
				to_chat(usr, "The neuromod data is empty.")
				return

			if (GetInsertedNeuromodDataDisk())
				to_chat(usr, "Console's neuromod data slot is already occupied.")
				return

			usr.drop_item(N)
			contents += N

		EjectNeuromod()
			var/obj/item/weapon/reagent_containers/neuromod/N = GetInsertedNeuromod()

			if (!N)
				return

			contents -= N
			usr.put_in_hands(N)

		EjectNeuromodData()
			var/obj/item/neuromodDataDisk/N = GetInsertedNeuromodDataDisk()

			if (!N)
				return

			contents -= N
			usr.put_in_hands(N)

	New(loc, ...)
		nmod_rnd = new(src)

		..()

	Destroy()
		qdel(nmod_rnd)
		nmod_rnd = null

		..()

	Process()
		if (is_researching)
			var/obj/item/neuromodDataDisk/N = GetInsertedNeuromodDataDisk()

			if (!N || !(N.neuromod_data) || (N.neuromod_data.type in researched_neuromods))
				research_progress = 0
				is_researching = FALSE

				playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
			else
				research_progress += 1

				if (research_progress > N.neuromod_data.research_time)
					is_researching = FALSE
					researched_neuromods.Add(N.neuromod_data.type)
					research_progress = 0
					playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)

	attackby(I, user)
		if (istype(I, /obj/item/weapon/reagent_containers/neuromod))
			InsertNeuromod()
			return
		else if (istype(I, /obj/item/neuromodDataDisk))
			InsertNeuromodData()
			return

		. = ..()

	attack_ai(mob/user)
		ui_interact(user)

	attack_hand(mob/user)
		..()

		if(stat & (BROKEN|NOPOWER))
			return
		ui_interact(user)

	ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)
		nmod_rnd.ui_interact(user, ui_key, ui, force_open, state)

	nano_container()
		return nmod_rnd

	interact(mob/user)
		nmod_rnd.ui_interact(user)
