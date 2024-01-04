/obj/machinery/computer/processing_unit_console
	name = "ore redemption console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	idle_power_usage = 15 WATTS
	active_power_usage = 50 WATTS

	var/weakref/machine_ref
	var/show_all_ores = FALSE
	var/points = 0
	icon_screen = null
	icon_keyboard = null
	circuit = /obj/item/circuitboard/processing_unit_console

/obj/machinery/computer/processing_unit_console/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/processing_unit_console/LateInitialize()
	..()
	var/obj/machinery/mineral/processing_unit/p_unit = locate_unit(/obj/machinery/mineral/processing_unit)
	p_unit.console_ref = weakref(src)
	machine_ref = weakref(p_unit)

/obj/machinery/computer/processing_unit_console/attack_hand(mob/user)
	add_fingerprint(user)
	if(!machine_ref?.resolve())
		if(tgui_alert(user, "No connected ore processing units found. Do you wish to rescan?", "Error!", list("Yes","No")) == "Yes")
			var/obj/machinery/mineral/processing_unit/p_unit = locate_unit(/obj/machinery/mineral/processing_unit)
			if(!p_unit)
				to_chat(user, SPAN("warning", "No ore processing units found."))
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

	var/list/data = list()
	data["unclaimedPoints"] = points
	data["materials"] = list()

	for(var/ore in ores_by_type)
		var/ore/O = ores_by_type[ore]
		var/obj/item/ore/ore_item = O.ore
		data["materials"] += list(list(
				"name" = O.display_name,
				"id" = "_ref[ore_item]",
				//"amount" = sheet_amount,
				"category" = "material",
				//"value" = ore_values[material.type]
		))

	for(var/datum/alloy/alloy in machine.alloy_data)
		data["materials"] += list(list(
			"name" = alloy.type,
			"id" = "_ref[alloy]",
			"category" = "alloy"
		))

	var/obj/item/card/id/card = user.get_id_card()
	if(istype(card))
		data["user"] = list(
			"name" = card.registered_name,
			"cash" = card.mining_points
		)

	return data

/obj/machinery/computer/processing_unit_console/tgui_static_data(mob/user)
	var/obj/machinery/mineral/processing_unit/machine = machine_ref.resolve()
	if(!istype(machine))
		return

	var/list/data = list()

	for(var/ore in ores_by_type)
		var/ore/O = ores_by_type[ore]
		var/obj/item/ore/ore_item = O.ore
		data["material_icons"] += list(list(
				"id" = "_ref[ore_item]",
				"product_icon" = icon2base64(getFlatIcon(image(icon = initial(ore_item.icon), icon_state = initial(ore_item.icon_state))))
			))

	for(var/datum/alloy/alloy in machine.alloy_data)
		continue

/obj/machinery/computer/processing_unit_console/Destroy()
	machine_ref = null
	return ..()

/obj/machinery/mineral/processing_unit
	name = "industrial smelter" //This isn't actually a goddamn furnace, we're in space and it's processing platinum and flammable plasma...
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace-off"
	light_outer_range = 3
	var/sheets_per_tick = 10
	var/list/ores_processing = list()
	var/list/ores_stored = list()
	var/static/list/alloy_data
	var/active = FALSE
	var/weakref/console_ref = null

	idle_power_usage = 15 WATTS
	active_power_usage = 50 WATTS

	component_types = list(
			/obj/item/circuitboard/refiner,
			/obj/item/stock_parts/capacitor = 2,
			/obj/item/stock_parts/scanning_module,
			/obj/item/stock_parts/micro_laser = 2,
			/obj/item/stock_parts/matter_bin
		)

/obj/machinery/mineral/processing_unit/Initialize()
	. = ..()

	// initialize static alloy_data list
	if(!alloy_data)
		alloy_data = list()
		for(var/alloytype in typesof(/datum/alloy)-/datum/alloy)
			alloy_data += new alloytype()

	ensure_ore_data_initialised()
	for(var/ore in ore_data)
		ores_processing[ore] = 0
		ores_stored[ore] = 0

/obj/machinery/mineral/processing_unit/Destroy()
	console_ref = null
	return ..()

/obj/machinery/mineral/processing_unit/Process()
	var/list/tick_alloys = list()

	if(!active)
		return

	var/obj/machinery/computer/processing_unit_console/console = console_ref?.resolve()
	if(!istype(console))
		return

	//Process our stored ores and spit out sheets.
	var/sheets = 0
	for(var/metal in ores_stored)

		if(sheets >= sheets_per_tick) break

		if(ores_stored[metal] > 0 && ores_processing[metal] != 0)

			var/ore/O = ore_data[metal]

			if(!O) continue

			if(ores_processing[metal] == 3 && O.alloy) //Alloying.

				for(var/datum/alloy/A in alloy_data)

					if(A.metaltag in tick_alloys)
						continue

					tick_alloys += A.metaltag
					var/enough_metal

					if(!isnull(A.requires[metal]) && ores_stored[metal] >= A.requires[metal]) //We have enough of our first metal, we're off to a good start.

						enough_metal = 1

						for(var/needs_metal in A.requires)
							//Check if we're alloying the needed metal and have it stored.
							if(ores_processing[needs_metal] != 3 || ores_stored[needs_metal] < A.requires[needs_metal])
								enough_metal = 0
								break

					if(!enough_metal)
						continue
					else
						var/total
						for(var/needs_metal in A.requires)
							if(console)
								var/ore/Ore = ore_data[needs_metal]
								console.points += Ore.worth
							use_power_oneoff(100)
							ores_stored[needs_metal] -= A.requires[needs_metal]
							total += A.requires[needs_metal]
							total = max(1,round(total*A.product_mod)) //Always get at least one sheet.
							sheets += total-1

						for(var/i=0,i<total,i++)
							unload_item(new A.product())

			else if(ores_processing[metal] == 2 && O.compresses_to) //Compressing.

				var/can_make = Clamp(ores_stored[metal],0,sheets_per_tick-sheets)
				if(can_make%2>0) can_make--

				var/material/M = get_material_by_name(O.compresses_to)

				if(!istype(M) || !can_make || ores_stored[metal] < 1)
					continue

				for(var/i=0,i<can_make,i+=2)
					if(console)
						console.points += O.worth*2
					use_power_oneoff(100)
					ores_stored[metal]-=2
					sheets+=2
					unload_item(new M.stack_type())

			else if(ores_processing[metal] == 1 && O.smelts_to) //Smelting.

				var/can_make = Clamp(ores_stored[metal],0,sheets_per_tick-sheets)

				var/material/M = get_material_by_name(O.smelts_to)
				if(!istype(M) || !can_make || ores_stored[metal] < 1)
					continue

				for(var/i=0,i<can_make,i++)
					if(console)
						console.points += O.worth
					use_power_oneoff(100)
					ores_stored[metal] -= 1
					sheets++
					unload_item(new M.stack_type())
			else
				if(console)
					console.points -= O.worth*3 //reee wasting our materials!
				use_power_oneoff(500)
				ores_stored[metal] -= 1
				sheets++
				unload_item(new /obj/item/ore/slag())
		else
			continue

	console.updateUsrDialog()

/obj/machinery/mineral/processing_unit/pickup_item(datum/source, atom/movable/target, direction)
	if(QDELETED(target))
		return

	if(istype(target, /obj/item/ore))
		var/obj/item/ore/O = target
		if(O.ore && !isnull(ores_stored[O.ore.name]))
			ores_stored[O.ore.name] += 1
		qdel(O)

/obj/machinery/mineral/processing_unit/attackby(obj/item/W, mob/user)
	if(active)
		to_chat(user, SPAN_WARNING("Turn off the machine first!"))
		return

	if(default_deconstruction_screwdriver(user, W))
		return

	else if(default_part_replacement(user, W))
		return

	else if(isWrench(W) && panel_open)
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		set_dir(turn(dir, 270))
		return

/obj/machinery/mineral/processing_unit/RefreshParts()
	..()
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

/obj/machinery/mineral/processing_unit/on_update_icon()
	icon_state = active ? "furnace" : "furnace-off"
