#define PROCESS_NONE		0
#define PROCESS_SMELT		1
#define PROCESS_COMPRESS	2
#define PROCESS_ALLOY		3
#define POWERUSE_PER_OPERATION 100
#define POWERUISE_PER_FAILURE 500

/obj/machinery/computer/processing_unit_console
	name = "ore redemption console"
	idle_power_usage = 15 WATTS
	active_power_usage = 50 WATTS
	light_color = "#00b000"
	icon_screen = "minerals"

	var/weakref/machine_ref
	var/show_all_ores = FALSE
	var/points = 0
	circuit = /obj/item/circuitboard/processing_unit_console

/obj/machinery/computer/processing_unit_console/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/processing_unit_console/LateInitialize()
	..()
	var/obj/machinery/mineral/processing_unit/p_unit = locate_unit(/obj/machinery/mineral/processing_unit)
	if(istype(p_unit))
		p_unit.console_ref = weakref(src)
		machine_ref = weakref(p_unit)

/obj/machinery/computer/processing_unit_console/attack_hand(mob/user)
	add_fingerprint(user)

	if(machine_ref?.resolve())
		tgui_interact(user)
		return

	var/response = tgui_alert(user, "No connected ore processing units found. Do you wish to rescan?", "Error!", list("Yes", "No"))
	if(response  == "Yes" && Adjacent(user))
		var/obj/machinery/mineral/processing_unit/p_unit = locate_unit(/obj/machinery/mineral/processing_unit)
		if(!p_unit)
			show_splash_text(user, "no ore processing unit found!")
			return

		p_unit.console_ref = weakref(src)
		machine_ref = weakref(p_unit)
		tgui_interact(user)

/obj/machinery/computer/processing_unit_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreRedemptionMachine")
		ui.open()

/obj/machinery/computer/processing_unit_console/tgui_data(mob/user)
	var/obj/machinery/mineral/processing_unit/machine = machine_ref.resolve()
	if(!istype(machine))
		return

	var/list/data = list(
		"unclaimedPoints" = points,
		"materials" = list(),
		"machine_state" = !(machine.stat & POWEROFF)
		)

	for(var/ore in GLOB.ores_by_type)
		var/ore/O = GLOB.ores_by_type[ore]
		data["materials"] += list(list(
				"name" = O.display_name,
				"current_action" = machine.ores_processing[O.name],
				"ore_tag" = O.name
		))

	var/obj/item/card/id/card = user.get_id_card()
	if(istype(card))
		data["user"] = list(
			"name" = card.registered_name,
			"cash" = card.mining_points
		)

	return data

/obj/machinery/computer/processing_unit_console/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/obj/machinery/mineral/processing_unit/machine = machine_ref.resolve()
	if(!istype(machine))
		return TRUE

	switch(action)
		if("claim")
			var/mob/living/user = usr
			if(points < 0)
				show_splash_text(user, "clear the debt first!")
				return TRUE
			var/obj/item/card/id/card = user.get_id_card()
			if(istype(card))
				card.mining_points += points
				points = 0
				show_splash_text(user, "transaction complete")
			else
				show_splash_text(user, "no valid ID detected!")
			return TRUE

		if("change_process")
			var/selected_ore = params["material_name"]
			machine.ores_processing[selected_ore] = params["material_process"]
			return TRUE

		if("toggle_machine")
			machine.toggle()
			return TRUE

/obj/machinery/computer/processing_unit_console/Destroy()
	machine_ref = null
	return ..()

/obj/machinery/mineral/processing_unit
	name = "industrial smelter" //This isn't actually a goddamn furnace, we're in space and it's processing platinum and flammable plasma...

	icon_state = "furnace-map"
	base_icon_state = "furnace"

	ea_color = "#ff9500"

	var/sheets_per_tick = 10
	var/list/ores_processing = list()
	var/list/ores_stored = list()
	var/weakref/console_ref = null

	component_types = list(
			/obj/item/circuitboard/processing_unit,
			/obj/item/stock_parts/capacitor = 2,
			/obj/item/stock_parts/scanning_module,
			/obj/item/stock_parts/micro_laser = 2,
			/obj/item/stock_parts/matter_bin
		)

/obj/machinery/mineral/processing_unit/Initialize()
	. = ..()

	for(var/ore in GLOB.ore_data)
		ores_processing[ore] = PROCESS_NONE
		ores_stored[ore] = 0

/obj/machinery/mineral/processing_unit/Destroy()
	console_ref = null
	return ..()

/obj/machinery/mineral/processing_unit/Process()
	if(stat & (NOPOWER | BROKEN | POWEROFF))
		STOP_PROCESSING(SSmachines, src)
		return

	var/obj/machinery/computer/processing_unit_console/console = console_ref?.resolve()
	if(!istype(console))
		return

	//Process our stored ores and spit out sheets.
	var/sheets_processed = 0

	for(var/metal in ores_stored)
		if(sheets_processed >= sheets_per_tick)
			break

		if(ores_stored[metal] <= 0)
			continue

		var/ore/O = GLOB.ore_data[metal]

		if(!O)
			continue

		if(ores_processing[metal] == PROCESS_ALLOY && O.alloy) //Alloying.
			sheets_processed += alloy(O, metal)
		else if(ores_processing[metal] == PROCESS_COMPRESS && O.compresses_to) //Compressing.
			sheets_processed += process_ore(O, metal, sheets_processed, O.compresses_to)
		else if(ores_processing[metal] == PROCESS_SMELT && O.smelts_to) //Smelting.
			sheets_processed += process_ore(O, metal, sheets_processed, O.smelts_to)
		else
			if(console)
				console.points -= O.worth * 3
			use_power_oneoff(POWERUISE_PER_FAILURE)
			ores_stored[metal] -= 1
			sheets_processed++
			unload_item(new /obj/item/ore/slag())

/obj/machinery/mineral/processing_unit/proc/alloy(ore/O, metal)
	var/list/tick_alloys = list()
	var/sheets_processed = 0
	for(var/datum/alloy/A in GLOB.alloy_data)
		if(A.metaltag in tick_alloys)
			continue

		tick_alloys += A.metaltag
		var/enough_metal

		if(!isnull(A.requires[metal]) && ores_stored[metal] >= A.requires[metal]) //We have enough of our first metal, we're off to a good start.
			enough_metal = 1
			for(var/needs_metal in A.requires) //Check if we're alloying the needed metal and have it stored.
				if(ores_processing[needs_metal] != 3 || ores_stored[needs_metal] < A.requires[needs_metal])
					enough_metal = FALSE

		if(!enough_metal)
			continue

		else
			var/total
			var/obj/machinery/computer/processing_unit_console/pu_console = console_ref?.resolve()
			for(var/needs_metal in A.requires)
				if(istype(pu_console))
					var/ore/Ore = GLOB.ore_data[needs_metal]
					pu_console.points += Ore.worth
				use_power_oneoff(POWERUSE_PER_OPERATION)
				ores_stored[needs_metal] -= A.requires[needs_metal]
				total += A.requires[needs_metal]
				total = max(1, round(total * A.product_mod)) //Always get at least one sheet.
				sheets_processed += total - 1

			for(var/i = 0, i < total, i++)
				unload_item(new A.product())

	return sheets_processed

/obj/machinery/mineral/processing_unit/proc/process_ore(ore/O, metal, sheets_processed, result_material)
	var/can_make = Clamp(ores_stored[metal], 0, sheets_per_tick - sheets_processed)
	if(can_make % 2 > 0)
		can_make--

	var/material/M = get_material_by_name(result_material)

	if(!istype(M) || !can_make || ores_stored[metal] < 1)
		return FALSE

	var/obj/machinery/computer/processing_unit_console/pu_console = console_ref?.resolve()
	for(var/i = 0, i < can_make, i += 2)
		if(istype(pu_console))
			pu_console.points += O.worth * 2

		use_power_oneoff(POWERUSE_PER_OPERATION)
		ores_stored[metal] -= 2
		sheets_processed += 2
		unload_item(new M.stack_type())

/obj/machinery/mineral/processing_unit/pickup_item(datum/source, atom/movable/target, direction)
	if(!..())
		return

	if(istype(target, /obj/item/ore))
		var/obj/item/ore/O = target
		if(O.ore && !isnull(ores_stored[O.ore.name]))
			ores_stored[O.ore.name] += 1
		if(!QDELETED(O) && !QDELING(O))
			qdel(O)

/obj/machinery/mineral/processing_unit/RefreshParts()
	var/scan_rating = 0
	var/cap_rating = 0
	var/laser_rating = 0

	for(var/obj/item/stock_parts/P in component_parts)
		if(isscanner(P))
			scan_rating += P.rating
		else if(iscapacitor(P))
			cap_rating += P.rating
		else if(ismicrolaser(P))
			laser_rating += P.rating

	sheets_per_tick += scan_rating + cap_rating + laser_rating

#undef PROCESS_NONE
#undef PROCESS_SMELT
#undef PROCESS_COMPRESS
#undef PROCESS_ALLOY
#undef POWERUSE_PER_OPERATION
#undef POWERUISE_PER_FAILURE
