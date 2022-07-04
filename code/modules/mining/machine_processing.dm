/obj/machinery/mineral // Generic mineral machine with some useful procs & variables. ~ Max
	dir = NORTH
	density = TRUE
	anchored = TRUE
	var/holo_active = FALSE
	var/input_turf = null
	var/output_turf = null

/obj/machinery/mineral/update_icon()
	overlays.Cut()
	if(holo_active)
		var/image/I = image('icons/obj/machines/holo_dirs.dmi', "holo-arrows")
		I.pixel_x = -16
		I.pixel_y = -16
		I.alpha = 210
		overlays |= I

/obj/machinery/mineral/Initialize()
	. = ..()
	verbs += /obj/machinery/mineral/proc/toggle_holo
	locate_turfs()

/obj/machinery/mineral/proc/locate_turfs()
	input_turf = get_turf(get_step(src, dir))
	output_turf = get_turf(get_step(src, flip_dir[dir]))

/obj/machinery/mineral/proc/toggle_holo()
	set name = "Toggle holo-helper"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return FALSE
	holo_active = !holo_active
	to_chat(SPAN_NOTICE("[usr] toggles holo-projector [holo_active ? "on" : "off"]."))
	update_icon()
	return

/**********************Mineral processing unit console**************************/

/obj/machinery/computer/processing_unit_console
	name = "ore redemption console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	icon_keyboard = null
	icon_keyboard = null
	circuit = /obj/item/circuitboard/processing_unit_console

	var/obj/machinery/mineral/processing_unit/machine = null
	var/show_all_ores = 0
	var/points = 0
	var/obj/item/card/id/inserted_id

/obj/machinery/computer/processing_unit_console/Initialize()
	. = ..()
	for(var/dir in GLOB.alldirs)
		machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, dir))
		if(machine)
			machine.console = src
			break

/obj/machinery/computer/processing_unit_console/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/computer/processing_unit_console/interact(mob/user)

	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	user.set_machine(src)

	var/dat = "<meta charset=\"utf-8\"><h1>Ore processor console</h1>"

	dat += "Current unclaimed points: [points]<br>"

	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
		dat += "<A href='?src=\ref[src];choice=claim'>Claim points.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>"

	dat += "<hr><table>"

	for(var/ore in machine.ores_processing)

		if(!machine.ores_stored[ore] && !show_all_ores) continue
		var/ore/O = ore_data[ore]
		if(!O) continue
		dat += "<tr><td width = 40><b>[capitalize(O.display_name)]</b></td><td width = 30>[machine.ores_stored[ore]]</td><td width = 100>"
		if(machine.ores_processing[ore])
			switch(machine.ores_processing[ore])
				if(0)
					dat += "<font color='red'>not processing</font>"
				if(1)
					dat += "<font color='orange'>smelting</font>"
				if(2)
					dat += "<span class='info'>compressing</span>"
				if(3)
					dat += "<font color='gray'>alloying</font>"
		else
			dat += "<font color='red'>not processing</font>"
		dat += ".</td><td width = 30><a href='?src=\ref[src];toggle_smelting=[ore]'>\[change\]</a></td></tr>"

	dat += "</table><hr>"
	dat += "Currently displaying [show_all_ores ? "all ore types" : "only available ore types"]. <A href='?src=\ref[src];toggle_ores=1'>\[[show_all_ores ? "show less" : "show more"]\]</a></br>"
	dat += "The ore processor is currently <A href='?src=\ref[src];toggle_power=1'>[(machine.active ? "<font color='green'>processing</font>" : "<font color='red'>disabled</font>")]</a>."
	show_browser(user, dat, "window=processor_console;size=400x500")
	onclose(user, "processor_console")
	return

/obj/machinery/computer/processing_unit_console/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				if(!usr.get_active_hand())
					usr.put_in_hands(inserted_id)
				inserted_id = null
			if(href_list["choice"] == "claim")
				if(access_mining_station in inserted_id.access)
					if(points >= 0)
						inserted_id.mining_points += points
						if(points != 0)
							ping( "\The [src] pings, \"Point transfer complete! Transaction total: [points] points!\"" )
						points = 0
					else
						to_chat(usr, "<span class='warning'>[station_name()]'s mining division is currently indebted to NanoTrasen. Transaction incomplete until debt is cleared.</span>")
				else
					to_chat(usr, "<span class='warning'>Required access not found.</span>")
		else if(href_list["choice"] == "insert")
			var/obj/item/card/id/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else to_chat(usr, "<span class='warning'>No valid ID.</span>")

	if(href_list["toggle_smelting"])

		var/choice = input("What setting do you wish to use for processing [href_list["toggle_smelting"]]?") as null|anything in list("Smelting","Compressing","Alloying","Nothing")
		if(!choice) return

		switch(choice)
			if("Nothing") choice = 0
			if("Smelting") choice = 1
			if("Compressing") choice = 2
			if("Alloying") choice = 3

		machine.ores_processing[href_list["toggle_smelting"]] = choice

	if(href_list["toggle_power"])

		machine.active = !machine.active
		if(machine.active)
			machine.icon_state = "furnace"
		else
			machine.icon_state = "furnace-off"

	if(href_list["toggle_ores"])

		show_all_ores = !show_all_ores

	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "industrial smelter" //This isn't actually a goddamn furnace, we're in space and it's processing platinum and flammable plasma...
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace-off"
	light_outer_range = 3
	var/obj/machinery/computer/processing_unit_console/console = null
	var/sheets_per_tick = 10
	var/list/ores_processing[0]
	var/list/ores_stored[0]
	var/static/list/alloy_data
	var/active = FALSE
	use_power = 1
	idle_power_usage = 15
	active_power_usage = 50

	component_types = list(
			/obj/item/circuitboard/processing_unit,
			/obj/item/stock_parts/capacitor = 2,
			/obj/item/stock_parts/scanning_module,
			/obj/item/stock_parts/micro_laser = 2,
			/obj/item/stock_parts/matter_bin
		)

/obj/machinery/mineral/processing_unit/update_icon()
	..()
	icon_state = active ? "furnace" : "furnace-off"

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

	return

/obj/machinery/mineral/processing_unit/Process()
	var/list/tick_alloys = list()

	if(!input_turf || !output_turf)
		locate_turfs()

	//Grab some more ore to process this tick.
	for(var/i = 0, i<sheets_per_tick, i++)
		var/obj/item/ore/O = locate() in input_turf
		if(!O) break
		if(O.ore && !isnull(ores_stored[O.ore.name]))
			ores_stored[O.ore.name] += 1
		else
			to_world_log("[src] encountered ore [O] with oretag [O.ore ? O.ore : "(no ore)"] which this machine did not have an entry for!")

		qdel(O)

	if(!active) // This thing kinda works, won't touch. ~ Max
		if(icon_state != "furnace-off")
			update_icon()
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
							new A.product(output_turf)

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
					new M.stack_type(output_turf)

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
					new M.stack_type(output_turf)
			else
				if(console)
					console.points -= O.worth*3 //reee wasting our materials!
				use_power_oneoff(500)
				ores_stored[metal] -= 1
				sheets++
				new /obj/item/ore/slag(output_turf)
		else
			continue

	console.updateUsrDialog()

/obj/machinery/mineral/processing_unit/attackby(obj/item/W, mob/user)
	if(active)
		to_chat(user, SPAN_WARNING("Turn off the machine first!"))
		return
	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_part_replacement(user, W))
		return
	if(isWrench(W))
		if(!panel_open)
			return
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		set_dir(turn(dir, 270))
		locate_turfs()
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
