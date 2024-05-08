GLOBAL_LIST_EMPTY(mecha_tracker_list)

/obj/machinery/computer/mecha
	name = "Exosuit Control"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "mecha"
	light_color = "#a97faa"
	req_access = list(access_robotics)
	circuit = /obj/item/circuitboard/mecha_control
	var/list/located
	var/screen = 0

/obj/machinery/computer/mecha/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/mecha/tgui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/mecha/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechaControlConsole", name)
		ui.open()

/obj/machinery/computer/mecha/tgui_data(mob/user)
	var/list/data = list(
		"beacons" = list()
	)

	for(var/thing in GLOB.mecha_tracker_list)
		var/obj/item/mecha_parts/mecha_tracking/TR = thing
		var/list/tr_data = TR.get_mecha_info()
		if(tr_data)
			data["beacons"] += list(tr_data)

	return data

/obj/machinery/computer/mecha/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("send_message")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["mt_ref"]) in GLOB.mecha_tracker_list
			if(istype(MT))
				var/message = tgui_input_text(usr, "Input message", "Transmit message")
				if(!message || !trim(message))
					return

				var/obj/mecha/M = MT.in_mecha()
				if(M)
					M.occupant_message(message)
			return TRUE

		if("shock")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["mt_ref"]) in GLOB.mecha_tracker_list
			if(!istype(MT))
				return

			MT.shock()
			return TRUE

/obj/item/mecha_parts/mecha_tracking
	name = "Exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	origin_tech = list(TECH_DATA = 2, TECH_MAGNET = 2)

/obj/item/mecha_parts/mecha_tracking/Initialize()
	. = ..()
	GLOB.mecha_tracker_list += src

/obj/item/mecha_parts/mecha_tracking/Destroy()
	GLOB.mecha_tracker_list -= src
	return ..()

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info()
	var/obj/mecha/M = in_mecha()
	if(!istype(M))
		return FALSE

	var/list/data = list(
		"name" = M.name,
		"cellCharge" = M.get_charge(),
		"integrity" = M.health,
		"integrityMax" = initial(M.health),
		"airtank" = M.return_pressure(),
		"pilot" = M.occupant,
		"location" = get_area(M),
		"equipment" = M.selected,
		"ref" = any2ref(src),
		"logs" = M.get_mecha_log(),
	)

	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		data["cargo"] = length(RM.cargo)
		data["cargoCapacity"] = RM.cargo_capacity

	return data

/obj/item/mecha_parts/mecha_tracking/emp_act()
	qdel_self()

/obj/item/mecha_parts/mecha_tracking/ex_act()
	qdel_self()

/obj/item/mecha_parts/mecha_tracking/proc/in_mecha()
	if(ismech(loc))
		return loc

	return FALSE

/obj/item/mecha_parts/mecha_tracking/proc/shock()
	var/obj/mecha/M = in_mecha()
	if(M)
		M.emp_act(2)
	qdel_self()

/obj/structure/closet/crate/mechabeacons
	name = "exosuit tracking beacons crate"

/obj/structure/closet/crate/mechabeacons/WillContain()
	return list(/obj/item/mecha_parts/mecha_tracking = 7)
