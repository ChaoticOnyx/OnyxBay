
/obj/machinery/stock_parts_processor
	name = "stock parts processor"
	desc = "It stores and vends various stock parts."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "stock_parts_processor"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	idle_power_usage = 25 WATTS
	active_power_usage = 200 WATTS
	clicksound = SFX_USE_BUTTON
	clickvol = 20
	interact_offline = 1

	component_types = list(
		/obj/item/circuitboard/stock_parts_processor,
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/console_screen,
		/obj/item/stock_parts/matter_bin,
	)

	var/list/stored_parts = list()
	var/list/prepared_parts = list()
	var/list/part_names = list()

	var/matter_type = MATERIAL_STEEL
	var/matter_storage = SHEET_MATERIAL_AMOUNT * 25
	var/matter_storage_max = SHEET_MATERIAL_AMOUNT * 50

/obj/machinery/stock_parts_processor/Initialize()
	. = ..()
	update_icon()

/obj/machinery/stock_parts_processor/on_update_icon()
	ClearOverlays()
	if(stat & (NOPOWER | BROKEN))
		set_light(0)
		icon_state = "stock_parts_processor_off"
	else
		AddOverlays(emissive_appearance(icon, "stock_parts_processor-ea"))
		set_light(0.8, 0.5, 2, 3, "#D47ED4")

/obj/machinery/stock_parts_processor/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return

/obj/machinery/stock_parts_processor/proc/load_part(obj/item/stock_parts/SP, mob/user)
	if(SP.type in stored_parts)
		stored_parts[SP.type]++
	else
		stored_parts[SP.type] = 1

	part_names[SP.type] = initial(SP.name)

	if(user)
		to_chat(user, "You load \the [SP] into \the [src]!")

	qdel(SP)
	return

/obj/machinery/stock_parts_processor/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, I))
		return

	if(default_deconstruction_crowbar(user, I))
		return

	if(istype(I, /obj/item/stock_parts))
		if(!user.drop(I, src))
			return

		load_part(I, user)

		updateUsrDialog()
		return

	if(istype(I, /obj/item/storage/part_replacer/mini))
		if(!user.drop(I, src))
			return

		for(var/atom/A in I.contents)
			if(!istype(A, /obj/item/stock_parts))
				continue // Should not happen
			load_part(A)

		to_chat(user, "You recycle \the [I]!")
		qdel(I)

		matter_storage = min(matter_storage_max, matter_storage + SHEET_MATERIAL_AMOUNT)
		updateUsrDialog()
		return

	else if(istype(I, /obj/item/stack/material) && I.get_material_name() == matter_type)
		if((matter_storage_max - matter_storage) < SHEET_MATERIAL_AMOUNT)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return

		var/obj/item/stack/S = I
		var/space_left = matter_storage_max - matter_storage
		var/sheets_to_take = min(S.amount, Floor(space_left / SHEET_MATERIAL_AMOUNT))

		if(sheets_to_take <= 0)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return

		matter_storage = min(matter_storage_max, matter_storage + (sheets_to_take * SHEET_MATERIAL_AMOUNT))
		to_chat(user, SPAN("info", "\The [src] processes \the [I]. Levels of stored matter now: [matter_storage]/[matter_storage_max]"))
		S.use(sheets_to_take)
		updateUsrDialog()
		return

	return ..()

// Uuuugghhhh why in the world aren't type paths normal strings
/obj/machinery/stock_parts_processor/proc/get_part_type(t)
	var/list/types = typesof(/obj/item/stock_parts)
	for(var/path in types)
		if("[path]" == t)
			return path

/obj/machinery/stock_parts_processor/Topic(href, href_list, state)
	if(..())
		return 1

	else if(href_list["part_eject"])
		var/thing = get_part_type(href_list["part_eject"])
		if(thing in stored_parts)
			new thing(loc)
			stored_parts[thing]--
			if(stored_parts[thing] < 1)
				stored_parts.Remove(thing)

	else if(href_list["part_prepare"])
		var/thing = get_part_type(href_list["part_prepare"])
		if(thing in prepared_parts)
			prepared_parts[thing]++
		else
			prepared_parts[thing] = 1

	else if(href_list["part_unprepare"])
		var/thing = get_part_type(href_list["part_unprepare"])
		if(thing in prepared_parts)
			prepared_parts[thing]--
			if(prepared_parts[thing] < 1)
				prepared_parts.Remove(thing)

	else if(href_list["part_unprepare_all"])
		var/thing = get_part_type(href_list["part_unprepare_all"])
		if(thing in prepared_parts)
			prepared_parts.Remove(thing)

	else if(href_list["assemble_rmuk"])
		var/parts_to_spawn = list()
		for(var/thing in prepared_parts)
			if(!(thing in stored_parts) || stored_parts[thing] < prepared_parts[thing])
				to_chat(usr, "\icon[src]<b>\The [src]</b> pings sadly as it lacks stored parts to complete the task.")
				updateUsrDialog()
				return
			parts_to_spawn[thing] = prepared_parts[thing]

		if(length(parts_to_spawn))
			matter_storage -= SHEET_MATERIAL_AMOUNT
			var/obj/item/storage/part_replacer/mini/RMUK = new /obj/item/storage/part_replacer/mini(loc)
			create_objects_in_loc(RMUK, parts_to_spawn)
			for(var/thing in parts_to_spawn)
				stored_parts[thing] -= parts_to_spawn[thing]
				if(stored_parts[thing] < 1)
					stored_parts.Remove(thing)

	if(href_list["clear"])
		prepared_parts.Cut()

	else if(href_list["close"])
		close_browser(usr, "window=stock_parts_processor")
		usr.unset_machine()
		return

	updateUsrDialog()
	return

/obj/machinery/stock_parts_processor/attack_hand(mob/user)
	if(inoperable())
		return

	user.set_machine(src)

	var/dat = "<meta charset=\"utf-8\"><HEAD><TITLE>NT-63-RAA Stock Parts Processor</TITLE></HEAD>"
	dat += "Welcome to <b>NT-63-RAA</b><BR> Stock parts processing system"
	dat += "<BR><FONT SIZE=1>Property of NanoTransen</FONT>"

	dat += "<br><hr>Stored steel: [matter_storage / SHEET_MATERIAL_AMOUNT]/[matter_storage_max / SHEET_MATERIAL_AMOUNT]"
	dat += "<br><hr><b>Stored stock parts</b>:"

	if(!length(stored_parts))
		dat += "<br>No parts found!"
	else
		for(var/thing in stored_parts)
			dat += "<br>"
			dat += "<A href='?src=\ref[src];part_prepare=[thing]'>\[prepare\]</a>"
			dat += "<A href='?src=\ref[src];part_eject=[thing]'> \[eject\]</a>"
			dat += " | [part_names[thing]]: x[stored_parts[thing]]"

	dat += "<br><hr><b>Prepared stock parts:</b> "
	dat += "<A href='?src=\ref[src];clear=1'>\[clear\]</a>"

	if(!length(stored_parts))
		dat += "<br>N/A"
	else
		for(var/thing in prepared_parts)
			dat += "<br>"
			dat += "<A href='?src=\ref[src];part_prepare=[thing]'>\[ + \]</a>"
			dat += "<A href='?src=\ref[src];part_unprepare=[thing]'> \[ - \]</a>"
			dat += "<A href='?src=\ref[src];part_unprepare_all=[thing]'> \[clear\]</a>"
			dat += " | [part_names[thing]]: x[prepared_parts[thing]]"

	dat += "<br>Assemble RMUK: "
	if(matter_storage < SHEET_MATERIAL_AMOUNT)
		dat += "<font color='red'>Not Enough Steel!</font>"
	else
		dat += "<A href='?src=\ref[src];assemble_rmuk=1'>\[press\]</a>"

	show_browser(user, dat, "window=stock_parts_processor")
	onclose(user, "stock_parts_processor")
	return
