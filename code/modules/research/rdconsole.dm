/*
 *	Research and Development (R&D) Console
 *	
 *	This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
 *	imprinter. It also contains the /datum/research holder with all the known/possible technology paths and device designs.
 *	
 *	Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
 *	aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
 *	linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
 *	allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.
 *	
 *	The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
 *	on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
 *	one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
 *	doesn't have toxins access.
 *	
 *	When a R&D console is destroyed or even partially disassembled, you lose all research data on it. However, there are two ways around
 *	this dire fate:
 *	- The easiest way is to go to the settings menu and select "Sync Database with Network." That causes it to upload (but not download)
 *	it's data to every other device in the game. Each console has a "disconnect from network" option that'll will cause data base sync
 *	operations to skip that console. This is useful if you want to make a "public" R&D console or, for example, give the engineers
 *	a circuit imprinter with certain designs on it and don't want it accidentally updating. The downside of this method is that you have
 *	to have physical access to the other console to send data back. Note: An R&D console is on CentCom so if a random griffan happens to
 *	cause a ton of data to be lost, an admin can go send it back.
 *	- The second method is with Technology Disks and Design Disks. Each of these disks can hold a single technology or design datum in
 *	it's entirety. You can then take the disk to any R&D console and upload it's data to it. This method is a lot more secure (since it
 *	won't update every console in existence) but it's more of a hassle to do. Also, the disks can be stolen.
 */

/obj/machinery/computer/rdconsole
	name = "fabrication control console"
	desc = "Console controlling the various fabrication devices. Uses self-learning matrix to hold and optimize blueprints. Prone to corrupting said matrix, so back up often."
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	light_color = "#a97faa"
	circuit = /obj/item/weapon/circuitboard/rdconsole
	var/datum/research/files							// Stores all the collected research data.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	// Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	// Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	// Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				// Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	// Linked Circuit Imprinter

	var/list/filtered = list( // Filters categories in menu
		"protolathe" = list(),
		"imprinter" = list()
	)

	var/id = 0			// ID of the computer (for server restrictions).
	var/sync = 1		// If sync = 0, it doesn't show up on Server Control Console

/obj/machinery/computer/rdconsole/proc/CallReagentName(reagent_type)
	var/datum/reagent/R = reagent_type
	return ispath(reagent_type, /datum/reagent) ? initial(R.name) : "Unknown"

/obj/machinery/computer/rdconsole/proc/SyncRDevices() // Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in range(4, src))
		if(D.linked_console != null || D.panel_open)
			continue
		if(istype(D, /obj/machinery/r_n_d/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src
	return

// Have it automatically push research to the centcomm server so wild griffins can't fuck up R&D's work
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in SSmachines.machinery)
		for(var/datum/tech/T in files.known_tech)
			C.files.AddTech2Known(T)
		for(var/datum/design/D in files.known_designs)
			C.files.AddDesign2Known(D)
		C.files.RefreshResearch()

/obj/machinery/computer/rdconsole/New()
	..()
	files = new /datum/research(src) // Setup the research data holder.
	if(!id)
		for(var/obj/machinery/r_n_d/server/centcom/S in SSmachines.machinery)
			S.update_connections()
			break

/obj/machinery/computer/rdconsole/Initialize()
	SyncRDevices()
	. = ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/weapon/D, mob/user)
	// Loading a disk into it.
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk))
			t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk))
			d_disk = D
		else
			to_chat(user, SPAN("notice", "Machine cannot accept disks in that format."))
			return
		user.drop_item()
		D.loc = src
		to_chat(user, SPAN("notice", "You add \the [D] to the machine."))
	else
		// The construction/deconstruction of the console code.
		..()

/obj/machinery/computer/rdconsole/attack_hand(mob/user)
	. = ..()
	
	tgui_interact(user)

/obj/machinery/computer/rdconsole/proc/finish_deconstruct(weakref/W)
	var/mob/user = W.resolve()
	linked_destroy.busy = 0

	if(!linked_destroy.loaded_item)
		to_chat(user, SPAN("notice", "The destructive analyzer appears to be empty."))
		return

	for(var/T in linked_destroy.loaded_item.origin_tech)
		files.UpdateTech(T, linked_destroy.loaded_item.origin_tech[T])

	// Also sends salvaged materials to a linked protolathe, if any.
	if(linked_lathe && linked_destroy.loaded_item.matter)
		for(var/t in linked_destroy.loaded_item.matter)
			if(t in linked_lathe.materials)
				linked_lathe.materials[t] += min(linked_lathe.max_material_storage - linked_lathe.TotalMaterials(), linked_destroy.loaded_item.matter[t] * linked_destroy.decon_mod)

	linked_destroy.loaded_item = null

	for(var/obj/I in linked_destroy.contents)
		for(var/mob/M in I.contents)
			M.death()
		// Only deconsturcts one sheet at a time instead of the entire stack
		if(istype(I,/obj/item/stack/material))
			var/obj/item/stack/material/S = I
			if(S.get_amount() > 1)
				S.use(1)
				linked_destroy.loaded_item = S
			else
				qdel(S)
				linked_destroy.icon_state = "d_analyzer"
		else
			if(!(I in linked_destroy.component_parts))
				qdel(I)
				linked_destroy.icon_state = "d_analyzer"

	use_power_oneoff(linked_destroy.active_power_usage)

	if(user)
		attack_hand(user)

/obj/machinery/computer/rdconsole/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RDConsole")
		ui.open()

/obj/machinery/computer/rdconsole/tgui_data(mob/user)
	var/list/data = list(
		"sync" = sync,
		"disk" = null,
		"techs" = list(),
		"devices" = list(
			list("name" = "destructor", "connected" = !!linked_destroy,   "data" = get_destructor_data()),
			list("name" = "imprinter",  "connected" = !!linked_imprinter, "data" = get_imprinter_data()),
			list("name" = "protolathe", "connected" = !!linked_lathe,     "data" = get_protolathe_data())
		)
	)

	var/obj/item/weapon/disk = t_disk || d_disk

	if(disk)
		var/obj/item/weapon/disk/tech_disk/tech_disk = disk
		var/obj/item/weapon/disk/design_disk/design_disk = disk

		if(istype(tech_disk))
			var/datum/tech/T = tech_disk.stored
			data["disk"] = list(
				"type" = "tech",
				"data" = (T && get_tech_data(T)) || null
			)
		else if(istype(design_disk))
			var/datum/design/D = design_disk.blueprint
			data["disk"] = list(
				"type" = "design",
				"data" = (D && get_design_data(D)) || null
			)

	for(var/datum/tech/T in files.known_tech)
		if(T.level < 1)
			continue
		
		data["techs"] += list(get_tech_data(T))

	return data

/obj/machinery/computer/rdconsole/tgui_act(action, params)
	. = ..()
	
	if(.)
		return TRUE

	switch(action)
		if("print")
			print(params["page"])
			return TRUE
		if("load")
			load_from_disk()
			return TRUE
		if("erase")
			erase_disk()
			return TRUE
		if("eject")
			eject_disk()
			return TRUE
		if("save")
			save_to_disk(params["thing"], params["id"])
			return TRUE
		if("eject_destructor")
			eject_from_destructor(usr)
			return TRUE
		if("deconstruct")
			deconstruct(usr)
			return TRUE
		if("sync")
			do_sync()
			return TRUE
		if("toggle_sync")
			sync = !sync
			return TRUE
		if("imprint")
			imprint(params["id"], params["count"])
			return TRUE
		if("build")
			build(params["id"], params["count"])
			return TRUE
		if("dispose")
			dispose(params["from"], params["thing"])
			return TRUE
		if("eject_sheet")
			eject_sheet(params["from"], params["thing"], params["amount"])
			return TRUE
		if("remove")
			remove_from_queue(params["from"], params["index"])
			return TRUE
		if("find_device")
			find_device()
			return TRUE
		if("reset")
			reset()
			return TRUE
		if("disconnect")
			disconnect(params["thing"])
			return TRUE

/obj/machinery/computer/rdconsole/proc/get_destructor_data()
	if(!linked_destroy)
		return null

	var/obj/item/weapon/loaded_item = linked_destroy.loaded_item

	var/list/data = list(
		"item" = null,
		"techs" = list()
	)

	if(!loaded_item)
		return data

	data["item"] = list(
		"icon" = icon2base64html(loaded_item.type),
		"name" = loaded_item.name
	)

	for(var/T in loaded_item.origin_tech)
		data["techs"] += list(list(
			"name" = CallTechName(T),
			"level" = loaded_item.origin_tech[T]
		))

	return data

/obj/machinery/computer/rdconsole/proc/get_imprinter_data()
	return get_device_data(linked_imprinter)

/obj/machinery/computer/rdconsole/proc/get_protolathe_data()
	return get_device_data(linked_lathe)

/obj/machinery/computer/rdconsole/proc/get_device_data(obj/machinery/device)
	if(!device)
		return null

	var/flag = 0
	if(istype(device, /obj/machinery/r_n_d/circuit_imprinter))
		flag = IMPRINTER
	else if (istype(device, /obj/machinery/r_n_d/protolathe))
		flag = PROTOLATHE
	else
		CRASH("Device [device] must be 'circuit_imprinter' or 'protolathe' type of.")
	
	var/list/data = list(
		"storage" = list(
			"material" = list(
				"total" = device:TotalMaterials(),
				"maximum" = device:max_material_storage,
				"materials" = list()
			),
			"chemical" = list(
				"total" = device:reagents.total_volume,
				"maximum" = device:reagents.maximum_volume,
				"chemicals" = list()
			)
		),
		"filters" = list(),
		"designs" = list(),
		"busy" = device:busy,
		"queue" = list()
	)

	for(var/M in device:materials)
		var/amount = device:materials[M]

		data["storage"]["material"]["materials"] += list(list(
			"name" = M,
			"amount" = amount,
			"icon" = icon2base64html(get_icon_for_material(M)),
			"per_sheet" = SHEET_MATERIAL_AMOUNT
		))

	for(var/datum/reagent/R in device:reagents.reagent_list)
		data["storage"]["chemical"]["chemicals"] += list(list(
			"ref" = "\ref[R]",
			"name" = R.name,
			"units" = R.volume
		))

	for(var/type in device:item_type)
		data["filters"] += type
	
	for(var/datum/design/D in files.known_designs)
		if(!D.build_path || !(D.build_type & flag))
			continue
		
		data["designs"] += list(get_design_data(D))

	for(var/datum/design/D in device:queue)
		data["queue"] += list(get_design_data(D))

	return data

/obj/machinery/computer/rdconsole/proc/get_tech_data(datum/tech/tech)
	return list(
		"id" = tech.id,
		"name" = tech.name,
		"level" = tech.level,
		"description" = tech.desc
	)

/obj/machinery/computer/rdconsole/proc/get_design_data(datum/design/design)
	var/list/data = list(
		"icon" = icon2base64html(design.build_path),
		"id" = design.id,
		"name" = design.name,
		"category" = design.category,
		"build_type" = null,
		"materials" = list(),
		"chemicals" = list(),
		"can_build" = FALSE,
		"multipliers" = list(
			"5" = FALSE,
			"10" = FALSE
		)
	)

	var/mat_efficiency = 1
	var/obj/machinery/device = null

	if(design.build_type & IMPRINTER)
		device = linked_imprinter
		data["build_type"] = "Circuit Imprinter"
	if(design.build_type & PROTOLATHE)
		device = linked_lathe
		data["build_type"] = "Proto-lathe"

	if(device)
		data["can_build"] = device:canBuild(design, 1)
		mat_efficiency = device:mat_efficiency

		for(var/multiplier in data["multipliers"])
			var/n = text2num(multiplier)
			data["multipliers"][multiplier] = device:canBuild(design, n)

	for(var/M in design.materials)
		data["materials"] += list(list(
			"name" = M,
			"required" = design.materials[M] * mat_efficiency
		))

	for(var/C in design.chemicals)
		data["chemicals"] += list(list(
			"name" = CallReagentName(C),
			"required" = design.chemicals[C] * mat_efficiency
		))

	return data

/obj/machinery/computer/rdconsole/proc/reset()
	griefProtection()
	qdel(files)
	files = new /datum/research(src)

/obj/machinery/computer/rdconsole/proc/disconnect_destructor()
	linked_destroy.linked_console = null
	linked_destroy = null

/obj/machinery/computer/rdconsole/proc/disconnect_imprinter()
	linked_imprinter.linked_console = null
	linked_imprinter = null

/obj/machinery/computer/rdconsole/proc/disconnect_protolathe()
	linked_lathe.linked_console = null
	linked_lathe = null

/obj/machinery/computer/rdconsole/proc/disconnect(thing)
	switch(thing)
		if("destructor")
			disconnect_destructor()
			return
		if("imprinter")
			disconnect_imprinter()
			return
		if("protolathe")
			disconnect_protolathe()
			return
	
	CRASH("Invalid thing [thing]")

/obj/machinery/computer/rdconsole/proc/find_device()
	playsound(src.loc, 'sound/signals/processing19.ogg', 50)

	spawn(10)
		SyncRDevices()

/obj/machinery/computer/rdconsole/proc/eject_sheet_from_imprinter(thing, amount)
	linked_imprinter.eject(thing, text2num(amount))

/obj/machinery/computer/rdconsole/proc/eject_sheet_from_protolathe(thing, amount)
	linked_lathe.eject(thing, text2num(amount))

/obj/machinery/computer/rdconsole/proc/eject_sheet(from, thing, amount)
	switch(from)
		if("imprinter")
			eject_sheet_from_imprinter(thing, amount)
			return TRUE
		if("protolathe")
			eject_sheet_from_protolathe(thing, amount)
			return TRUE
	
	CRASH("Invalid thing [thing]")

/obj/machinery/computer/rdconsole/proc/remove_from_imprinter_queue(index)
	linked_imprinter.removeFromQueue(text2num(index))

/obj/machinery/computer/rdconsole/proc/remove_from_protolathe_queue(index)
	linked_lathe.removeFromQueue(text2num(index))

/obj/machinery/computer/rdconsole/proc/remove_from_queue(from, index)
	switch(from)
		if("imprinter")
			remove_from_imprinter_queue(index)
			return
		if ("protolathe")
			remove_from_protolathe_queue(index)
			return
	
	CRASH("Invalid from [from]")

/obj/machinery/computer/rdconsole/proc/dispose_imprinter(thing)
	if(thing == "all")
		linked_imprinter.reagents.clear_reagents()
		return

	var/datum/reagent/R = locate(thing) in linked_imprinter.reagents.reagent_list
	if(R)
		linked_imprinter.reagents.del_reagent(R.type)

/obj/machinery/computer/rdconsole/proc/dispose_protolathe(thing)
	if(thing == "all")
		linked_lathe.reagents.clear_reagents()
		return
	
	var/datum/reagent/R = locate(thing) in linked_lathe.reagents.reagent_list
	if(R)
		linked_lathe.reagents.del_reagent(R.type)

/obj/machinery/computer/rdconsole/proc/dispose(from, thing)
	switch(from)
		if("imprinter")
			dispose_imprinter(thing)
			return
		if("protolathe")
			dispose_protolathe(thing)
			return
	
	CRASH("Invalid from [from]")

/obj/machinery/computer/rdconsole/proc/build(id, count)
	if(!linked_lathe)
		return
	
	playsound(src.loc, 'sound/signals/processing23.ogg', 50)
	var/datum/design/being_built = null

	for(var/datum/design/D in files.known_designs)
		if(D.id == id)
			being_built = D
			break

	if(being_built)
		var/n = text2num(count)
		n = min(n, (100 - linked_lathe.queue.len))

		for(var/i in 1 to n)
			linked_lathe.addToQueue(being_built)

/obj/machinery/computer/rdconsole/proc/imprint(id, count)
	playsound(loc, 'sound/signals/processing23.ogg', 50)
	var/datum/design/being_built = null

	for(var/datum/design/D in files.known_designs)
		if(D.id == id)
			being_built = D
			break

	if(being_built)
		var/n = text2num(count)
		n = min(n, (100 - linked_imprinter.queue.len))

		for(var/i in 1 to n)
			linked_imprinter.addToQueue(being_built)

/obj/machinery/computer/rdconsole/proc/do_sync(mob/user)
	if(!sync)
		to_chat(user, SPAN("notice", "You must connect to the network first."))
		return

	playsound(loc, 'sound/signals/processing13.ogg', 50)
	griefProtection() // Putting this here because I dont trust the sync process

	spawn(30)
		if(!src)
			return

		for(var/obj/machinery/r_n_d/server/S in SSmachines.machinery)
			var/server_processed = 0
			if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
				for(var/datum/tech/T in files.known_tech)
					S.files.AddTech2Known(T)
				for(var/datum/design/D in files.known_designs)
					S.files.AddDesign2Known(D)
				S.files.RefreshResearch()
				server_processed = 1
			if((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom))
				for(var/datum/tech/T in S.files.known_tech)
					files.AddTech2Known(T)
				for(var/datum/design/D in S.files.known_designs)
					files.AddDesign2Known(D)
				files.RefreshResearch()
				server_processed = 1
			if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
				S.produce_heat()

/obj/machinery/computer/rdconsole/proc/deconstruct(mob/user)
	if(linked_destroy.busy)
		to_chat(user, SPAN("notice", "The destructive analyzer is busy at the moment."))
		return

	playsound(loc, 'sound/signals/processing22.ogg', 50)
	linked_destroy.busy = 1
	flick("d_analyzer_process", linked_destroy)
	addtimer(CALLBACK(src, .proc/finish_deconstruct, weakref(user)), 24)

/obj/machinery/computer/rdconsole/proc/eject_from_destructor(mob/user)
	if(linked_destroy.busy)
		to_chat(user, SPAN("notice", "The destructive analyzer is busy at the moment."))
		return
	
	if(linked_destroy.loaded_item)
		linked_destroy.loaded_item.dropInto(linked_destroy.loc)
		linked_destroy.loaded_item = null
		linked_destroy.icon_state = "d_analyzer"

/obj/machinery/computer/rdconsole/proc/make_report(body)
	var/obj/item/weapon/paper/PR = new /obj/item/weapon/paper

	PR.name = "fabricator report"
	PR.info = "<center><b>[station_name()] Fabricator Laboratory</b>"
	PR.info += "<h2>Fabricator Status Report</h2>"
	PR.info += "<i>report prepared at [stationtime2text()] local time</i></center><br>"

	PR.info += body

	PR.info_links = PR.info
	PR.icon_state = "paper_words"
	PR.dropInto(loc)

/obj/machinery/computer/rdconsole/proc/print_techs()
	var/body = ""
	body += "<ul>"

	for(var/datum/tech/T in files.known_tech)
		if(T.level < 1)
			continue

		body += "<hr><li>"
		body += "<p>[T.name]</p>"
		body +=  "<p>Level: [T.level]</p>"
		body +=  "<p>Summary: [T.desc]</p></li>"

	body += "</ul>"
	
	make_report(body)

/obj/machinery/computer/rdconsole/proc/print_designs()
	var/body = ""

	body += "<ul>"

	for(var/datum/design/D in files.known_designs)
		if(!D.build_path)
			continue

		body += "<li><b>[D.name]</b>: [D.desc]</li>"

	body += "</ul>"

	make_report(body)

/obj/machinery/computer/rdconsole/proc/print(page)
	switch(page)
		if("techs")
			print_techs()
			return
		if("designs")
			print_designs()
			return

	CRASH("Invalid page [page]")

/obj/machinery/computer/rdconsole/proc/load_tech_from_disk()
	files.AddTech2Known(t_disk.stored)
	griefProtection() // Update centcomm too

/obj/machinery/computer/rdconsole/proc/load_design_from_disk()
	files.AddDesign2Known(d_disk.blueprint)
	griefProtection() // Update centcomm too

/obj/machinery/computer/rdconsole/proc/load_from_disk()
	playsound(src.loc, 'sound/signals/processing9.ogg', 50)

	if(t_disk)
		load_tech_from_disk()
	else if(d_disk)
		load_design_from_disk()

/obj/machinery/computer/rdconsole/proc/save_tech_to_disk(id)
	for(var/datum/tech/T in files.known_tech)
		if(id == T.id)
			t_disk.stored = T
			return

/obj/machinery/computer/rdconsole/proc/save_design_to_disk(id)
	for(var/datum/design/D in files.known_designs)
		if(id == D.id)
			d_disk.blueprint = D
			return

/obj/machinery/computer/rdconsole/proc/save_to_disk(thing, id)
	playsound(src.loc, 'sound/signals/processing9.ogg', 50)

	switch(thing)
		if("tech")
			save_tech_to_disk(id)
			return
		if("design")
			save_design_to_disk(id)
			return
	
	CRASH("Invalid thing [thing]")

/obj/machinery/computer/rdconsole/proc/erase_disk()
	t_disk?.stored = null
	d_disk?.blueprint = null

/obj/machinery/computer/rdconsole/proc/eject_disk()
	t_disk?.dropInto(loc)
	t_disk = null

	d_disk?.dropInto(loc)
	d_disk = null

/obj/machinery/computer/rdconsole/robotics
	name = "robotics fabrication console"
	id = 2
	req_access = list(access_robotics)

/obj/machinery/computer/rdconsole/core
	name = "core fabricator console"
	id = 1
