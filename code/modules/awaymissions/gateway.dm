GLOBAL_LIST_EMPTY(station_gateways)
GLOBAL_LIST_EMPTY(world_gateways_by_tag)
GLOBAL_LIST_EMPTY(world_awaygateways)
/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE
	var/active = FALSE
	var/ready = FALSE // have we got all the parts for a gateway?
	var/main_part = FALSE
	var/gateway_tag
	var/list/linked = list()

/obj/machinery/gateway/Initialize()
	update_icon()
	if(dir == SOUTH)
		set_density(FALSE)
	. = ..()
	if(gateway_tag)
		GLOB.world_gateways_by_tag[gateway_tag] = src
	detect()

/obj/machinery/gateway/Destroy()
	if(gateway_tag)
		GLOB.world_gateways_by_tag[gateway_tag] = null
	toggleoff(forced_off = TRUE)
	for(var/obj/machinery/gateway/G in linked)
		G.toggleoff()
		G.linked.Remove(src)
	. = ..()

/obj/machinery/gateway/update_icon()
	if(main_part)
		icon_state = active ? "oncenter" : "offcenter"
	else
		icon_state = active ? "on" : "off"

/obj/machinery/gateway/proc/toggleoff(mob/user, forced_off = FALSE)
	for(var/obj/machinery/gateway/G in linked)
		G.active = FALSE
		G.update_icon()
	active = FALSE
	if(dir == SOUTH)
		set_density(FALSE)
	update_icon()

/obj/machinery/gateway/attack_hand(mob/user)
	if(!main_part)
		return
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff(user)

/obj/machinery/gateway/proc/toggleon(mob/user)
	return

/obj/machinery/gateway/proc/detect()
	linked = list()	//clear the list
	var/turf/T = get_turf(loc)

	for(var/i in GLOB.alldirs)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in get_step(T, i)
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if(length(linked) == 8)
		ready = TRUE

//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = 1
	icon_state = "offcenter"
	main_part = TRUE
	//warping vars
	var/wait = 0 //this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate
	var/forced = FALSE
	var/datum/browser/gateway_menu

/obj/machinery/gateway/centerstation/Initialize()
	update_icon()
	wait = world.time + config.misc.gateway_delay	//+ thirty minutes default
	. = ..()
	GLOB.station_gateways.Add(src)

/obj/machinery/gateway/centerstation/Destroy()
	GLOB.station_gateways.Remove(src)
	. = ..()

/obj/machinery/gateway/centerstation/Process()
	if(stat & (NOPOWER))
		if(active)
			toggleoff()
		return

	if(active)
		use_power_oneoff(5000)

/obj/machinery/gateway/centerstation/toggleon(mob/user, forced_on = FALSE)
	if(!ready)
		return
	if(!powered())
		return
	detect()
	if(length(linked) != 8)
		return
	if(!awaygate)
		to_chat(user, SPAN("notice", "Error: No destination found."))
		return
	if(world.time < wait && !forced_on)
		to_chat(user, SPAN("notice", "Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes."))
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = TRUE
		G.update_icon()
	active = TRUE
	awaygate.stationgate = src
	awaygate.toggleon()
	if(dir == SOUTH)
		set_density(TRUE)
	update_icon()

/obj/machinery/gateway/centerstation/toggleoff(mob/user, forced_off = FALSE)
	if(ready && forced && user && !forced_off)
		to_chat(user, SPAN_DANGER("Error: Detected high priority distress signal, user input is overridden. [active ? "The portal has been opened." : "Warpspace triangulation in progress."]"))
		return
	if(awaygate)
		awaygate.stationgate = null
		awaygate.toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = FALSE
		G.update_icon()
	..()

//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/M)
	if(!ready || !active || !awaygate)
		return
	if(awaygate.calibrated)
		var/turf/new_T = get_step(get_turf(awaygate), SOUTH)
		M.forceMove(new_T ? new_T : get_turf(M))
		M.set_dir(SOUTH)
		return
	else
		var/obj/effect/landmark/dest = pick(GLOB.awaydestinations)
		if(dest)
			M.forceMove(get_turf(dest))
			M.set_dir(SOUTH)
			use_power_oneoff(5000)

/obj/machinery/gateway/centerstation/attackby(obj/item/device/W, mob/user)
	if(isMultitool(W))
		to_chat(user, "The gate is already calibrated, there is no work for you to do here.")
		return

/obj/machinery/gateway/centerstation/attack_hand(mob/user)
	show_menu(user)
	..()

/obj/machinery/gateway/centerstation/attack_ghost(mob/user)
	show_menu(user)
	..()

/obj/machinery/gateway/centerstation/proc/show_menu(mob/user)
	if(is_admin(user))
		var/dat = "Gateway Admin Actions\
		<BR><a href='?src=\ref[src];select_awaygateway=1'>[awaygate ? "Selected awaygate location is [awaygate.gateway_area_name]" : "Awaygate not found."]</a>\
		<BR><a href='?src=\ref[src];toggle_forced=1'>The forced mode is now [forced ? "on" : "off"]</a>\
		<BR><a href='?src=\ref[src];toggleon=1'>Forced toggle on</a>\
		<BR><a href='?src=\ref[src];toggleoff=1'>Forced toggle off</a>\
		<BR><a href='?src=\ref[src];detect=1'>Detect gateways</a>\
		"
		if(!gateway_menu || gateway_menu.user != user)
			gateway_menu = new /datum/browser(user, "gateway", "<B>[src]</B>", 360, 410)
			gateway_menu.set_content(dat)
		else
			gateway_menu.set_content(dat)
			gateway_menu.update()
		gateway_menu.open()

/obj/machinery/gateway/centerstation/Topic(href,href_list)
	var/mob/user = usr
	if(!is_admin(user) || !ready)
		return

	if(href_list["select_awaygateway"])
		switch(alert(user, "Do you want to pick gateway from tag list or from area list?",, "Tag", "Area"))
			if("Tag")
				var/obj/machinery/gateway/centeraway/selected = GLOB.world_gateways_by_tag[input(user, "Choose gateway tag", "Gateway") in GLOB.world_gateways_by_tag]
				if(!istype(selected))
					return
				awaygate = selected
			if("Area")
				var/obj/machinery/gateway/centeraway/selected = GLOB.world_awaygateways[input(user, "Choose gateway area", "Gateway") in GLOB.world_awaygateways]
				if(!istype(selected))
					return
				awaygate = selected

	if(href_list["toggle_forced"])
		forced = !forced
		to_chat(user, "The forced mode is now [forced ? "on" : "off"]")

	if(href_list["toggleon"])
		toggleon(user, TRUE)

	if(href_list["toggleoff"])
		toggleoff(user, TRUE)

	if(href_list["detect"])
		detect()

	show_menu(user)
	return TRUE

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = 1
	icon_state = "offcenter"
	use_power = POWER_USE_OFF
	main_part = TRUE
	var/calibrated = TRUE
	var/obj/machinery/gateway/centerstation/stationgate
	var/gateway_area_name // it's required to delete src from list even if smart CE rename the area


/obj/machinery/gateway/centeraway/Initialize()
	update_icon()
	. = ..()
	gateway_area_name = get_area(src).name
	GLOB.world_awaygateways[gateway_area_name] = src

/obj/machinery/gateway/centeraway/Destroy()
	GLOB.world_awaygateways[gateway_area_name] = null
	. = ..()

/obj/machinery/gateway/centeraway/toggleon(mob/user)
	if(!ready)
		return
	detect()
	if(length(linked) != 8)
		return
	if(!stationgate)
		to_chat(user, SPAN("notice", "Error: No destination found."))
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = TRUE
		G.update_icon()
	active = TRUE
	if(dir == SOUTH)
		set_density(TRUE)
	update_icon()

/obj/machinery/gateway/centeraway/Bumped(atom/movable/M)
	if(!ready)	return
	if(!active)	return
	if(istype(M, /mob/living/carbon))
		for(var/obj/item/implant/exile/E in M)//Checking that there is an exile implant in the contents
			if(E.imp_in == M)//Checking that it's actually implanted vs just in their pocket
				to_chat(M, "The remote gate has detected your exile implant and is blocking your entry.")
				return
	var/turf/new_T = get_step(get_turf(stationgate), SOUTH)
	M.forceMove(new_T ? new_T : get_turf(M))
	M.set_dir(SOUTH)


/obj/machinery/gateway/centeraway/attackby(obj/item/device/W, mob/user)
	if(isMultitool(W))
		if(calibrated)
			to_chat(user, "The gate is already calibrated, there is no work for you to do here.")
			return
		else
			to_chat(user, SPAN("notice", "<b>Recalibration successful!</b></span>: This gate's systems have been fine tuned.  Travel to this gate will now be on target."))
			calibrated = TRUE
			return
