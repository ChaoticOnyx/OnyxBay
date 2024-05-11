/obj/machinery/computer/prisoner
	name = "prisoner management console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "security_key"
	icon_screen = "explosive"
	light_color = "#a91515"
	req_access = list(access_armory)
	circuit = /obj/item/circuitboard/prisoner
	var/id = 0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0

/obj/machinery/computer/prisoner/tgui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/computer/prisoner/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/prisoner/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrisonerImplantManager", name)
		ui.open()

/obj/machinery/computer/prisoner/tgui_data(mob/user)
	var/list/data = list()

	for(var/obj/item/implant/I in GLOB.implants_list)
		if(!istype(I, /obj/item/implant/tracking) && !istype(I, /obj/item/implant/chem))
			continue

		var/turf/T = get_turf(I)
		if(!istype(T) || !AreConnectedZLevels(T?.z, z))
			continue

		if(!I.implanted)
			continue

		var/list/implant_data = list(
			"implantee" = I.imp_in?.name,
			"ref" = any2ref(I),
		)

		if(istype(I, /obj/item/implant/tracking))
			var/obj/item/implant/tracking/tracking = I
			var/loc_display = tracking.malfunction ? pick(playerlocs) : "Space"
			var/coordinates = "error not found"
			if(!tracking.malfunction && !isspaceturf(T))
				loc_display = get_area(T)
				coordinates = "X: [T.x], Y: [T.y]"
			implant_data["location"] = loc_display
			implant_data["id"] = tracking.id
			implant_data["coordinates"] = coordinates
			data["trackingImplants"] += list(implant_data)

		if(istype(I, /obj/item/implant/chem))
			implant_data["remainingUnits"] = I.reagents?.total_volume
			data["chemImplants"] += list(implant_data)

	return data

/obj/machinery/computer/prisoner/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("inject")
			var/obj/item/implant/I = locate(params["ref"]) in GLOB.implants_list
			I?.activate(text2num(params["amt"]))
			return TRUE

		if("warn")
			var/warning = tgui_input_text(usr, "Message:", "Enter your message")
			if(!warning)
				return

			var/obj/item/implant/I = locate(params["ref"]) in GLOB.implants_list
			var/mob/living/warned = I?.imp_in
			if(!istype(warned))
				return

			to_chat(warned, SPAN_WARNING("You hear a voice in your head saying: '[warning]'"))
			INVOKE_ASYNC(GLOBAL_PROC, /proc/tgui_alert, warned, warning, "You hear a voice in your head!")
			return TRUE
