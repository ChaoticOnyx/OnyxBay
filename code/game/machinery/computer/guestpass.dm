/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to restricted areas."
	icon_state = "guest"
	light_color = "#0099ff"

	var/temp_access = list() //to prevent agent cards stealing access as permanent
	var/expiration_time = 0
	var/reason = "NOT SPECIFIED"

/obj/item/card/id/guest/GetAccess()
	if (world.time > expiration_time)
		return access
	else
		return temp_access

/obj/item/card/id/guest/examine(mob/user, infix)
	. = ..()

	if(world.time < expiration_time)
		. += SPAN_NOTICE("This pass expires at [worldtime2stationtime(expiration_time)].")
	else
		. += SPAN_NOTICE("It expired at [worldtime2stationtime(expiration_time)].")

/obj/item/card/id/guest/read()
	if (world.time > expiration_time)
		to_chat(usr, "<span class='notice'>This pass expired at [worldtime2stationtime(expiration_time)].</span>")
	else
		to_chat(usr, "<span class='notice'>This pass expires at [worldtime2stationtime(expiration_time)].</span>")

	to_chat(usr, "<span class='notice'>It grants access to following areas:</span>")
	for (var/A in temp_access)
		to_chat(usr, "<span class='notice'>[get_access_desc(A)].</span>")
	to_chat(usr, "<span class='notice'>Issuing reason: [reason].</span>")
	return

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	icon_state = "guest"
	icon_screen = "pass"
	icon_keyboard = "guest_key"
	light_color = "#0099FF"
	light_max_bright_on = 1.0
	light_inner_range_on = 0.5
	light_outer_range_on = 2
	density = 0
	turf_height_offset = 0

	var/obj/item/card/id/giver
	var/list/accesses = list()
	var/giv_name = "NOT SPECIFIED"
	var/reason = "NOT SPECIFIED"
	var/duration = 5

	var/list/internal_log = list()
	var/mode = 0  // 0 - making pass, 1 - viewing logs

/obj/machinery/computer/guestpass/New()
	..()
	uid = "[random_id("guestpass_serial_number",100,999)]-G[rand(10,99)]"

/obj/machinery/computer/guestpass/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/card/id))
		if(!giver && user.drop(O, src))
			giver = O
			SStgui.update_uis(src)
		else if(giver)
			to_chat(user, "<span class='warning'>There is already ID card inside.</span>")
		return
	..()

/obj/machinery/computer/guestpass/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/guestpass/attack_hand(mob/user)
	. = ..()

	tgui_interact(user)

/obj/machinery/computer/guestpass/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Guestpass", src)
		ui.open()

/obj/machinery/computer/guestpass/tgui_data(mob/user)
	var/list/data = list(
		"scanName" = giver?.registered_name,
		"areas",
		"IssueLog" = internal_log,
	)

	var/list/regions = list()
	for(var/i in ACCESS_REGION_SECURITY to ACCESS_REGION_SUPPLY) // code/game/jobs/_access_defs.dm
		var/list/region = list(
			"name" = get_region_accesses_name(i),
			"id" = i,
		)
		var/list/accessess_data = list()
		for(var/j in get_region_accesses(i))
			var/list/access = list()
			access["name"] = get_access_desc(j)
			access["id"] = j
			access["req"] = (j in accesses) ? TRUE : FALSE
			access["allowed"] = (j in giver?.access)
			accessess_data[++accessess_data.len] = access

		region["accesses"] = accessess_data
		regions[++regions.len] = region

	data["regions"] = regions

	return data

/obj/machinery/computer/guestpass/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_access")
			if(isnull(params["area"]))
				return

			var/new_access = text2num(params["area"])
			if(!(new_access in giver.access))
				return

			if(LAZYISIN(accesses, new_access))
				accesses -= new_access
			else
				accesses |= new_access
			return TRUE

		if("scan")
			if(giver)
				if(ishuman(usr))
					usr.pick_or_drop(giver, get_turf(usr))
					giver = null
				else
					giver.forceMove(get_turf(src))
					giver = null
				accesses.Cut()
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id))
					if(usr.drop(I, src))
						giver = I
			return TRUE

		if("deselect_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return

			accesses -= get_region_accesses(region)
			return TRUE

		if("select_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return

			var/list/new_accesses = get_region_accesses(region)
			for(var/A in new_accesses)
				if(A in giver.access)
					accesses |= A
			return TRUE

		if("print")
			var/obj/item/paper/P = new /obj/item/paper(src)
			var/dat = "<h3>Activity log of guest pass terminal #[any2ref(src)]</h3><br>"
			for(var/entry in internal_log)
				dat += "[entry]<br><hr>"
			P.name = "activity log"
			P.info = dat
			usr.pick_or_drop(P, get_turf(usr))
			return TRUE

		if("select_access")
			var/access = text2num(params["access"])
			if(isnull(access))
				return

			accesses |= access
			return TRUE

		if("select_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return

			var/list/new_accesses = get_region_accesses(region)
			for(var/A in new_accesses)
				if(A in giver.access)
					accesses.Add(A)
			return TRUE

		if("deselect_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses -= get_region_accesses(region)
			return TRUE

		if("deselect_all")
			accesses = list()
			return TRUE

		if("select_all")
			for(var/A in get_all_accesses())
				if(A in giver.access)
					accesses += A
			return TRUE

		if("set_name")
			giv_name = params["new_name"]
			return TRUE

		if("set_duration")
			duration = params["new_duration"]
			return TRUE

		if("set_reason")
			reason = params["new_reason"]
			return TRUE

		if("issue")
			if(!giver || !LAZYLEN(accesses))
				return

			var/number = add_zero(random_id("guestpass_id_number", 1000, 9999), 4)
			var/entry = "\[[stationtime2text()]\] Pass #[number] issued by [giver.registered_name] ([giver.assignment]) to [giv_name]. Reason: [reason]. Granted access to following areas: "
			var/list/access_descriptors = list()
			for(var/A in accesses)
				if(A in giver.access)
					access_descriptors += get_access_desc(A)
			entry += english_list(access_descriptors, and_text = ", ")
			entry += ". Expires at [worldtime2stationtime(world.time + duration MINUTES)]."
			internal_log.Add(entry)

			var/obj/item/card/id/guest/pass = new(loc)
			pass.temp_access = accesses.Copy()
			pass.registered_name = giv_name
			pass.expiration_time = world.time + duration MINUTES
			pass.reason = reason
			pass.SetName("guest pass #[number]")
			pass.assignment = "Guest"
			playsound(get_turf(src), 'sound/machines/ping.ogg', 25, 0)
