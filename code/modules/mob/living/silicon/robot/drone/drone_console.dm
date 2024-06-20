/obj/machinery/computer/drone_control
	name = "Maintenance Drone Control"
	desc = "Used to monitor the drone population and the assembler that services them."
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "power_key"
	icon_screen = "power_screen"
	light_color = "#FFCC33"
	req_access = list(access_engine_equip)
	circuit = /obj/item/circuitboard/drone_control

	/// Used when pinging drones.
	var/drone_call_area = "Engineering"
	/// Used to enable or disable drone fabrication.
	var/obj/machinery/drone_fabricator/dronefab
	/// Cooldown for area pings
	var/ping_cooldown = 0


/obj/machinery/computer/drone_control/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/drone_control/tgui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/drone_control/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DroneConsole", src)
		ui.open()

/obj/machinery/computer/drone_control/tgui_data(mob/user)
	var/list/data = list(
		"drone_fab" = istype(dronefab),
		"fab_power" = (dronefab?.stat & NOPOWER) ? FALSE : TRUE,
		"drone_prod" = dronefab?.produce_drones,
		"drone_progress" = clamp(dronefab?.drone_progress, 0, 100),
	)
	data["selected_area"] = drone_call_area
	data["ping_cd"] = ping_cooldown > world.time ? TRUE : FALSE

	data["drones"] = list()
	for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
		var/area/A = get_area(D)
		var/turf/T = get_turf(D)
		var/list/drone_data = list(
			name = D.real_name,
			ref = any2ref(D),
			stat = D.stat,
			client = D.client ? TRUE : FALSE,
			health = round(D.health / D.maxHealth, 0.1),
			charge = round(D.cell.charge / D.cell.maxcharge, 0.1),
			location = "[A] ([T.x], [T.y])",
		)
		data["drones"] += list(drone_data)
	return data

/obj/machinery/computer/drone_control/tgui_static_data(mob/user)
	var/list/data = list()
	data["area_list"] = GLOB.tagger_locations
	return data

/obj/machinery/computer/drone_control/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	switch(action)
		if("find_fab")
			find_fab(usr)
			return TRUE

		if("toggle_fab")
			if(QDELETED(dronefab))
				dronefab = null
				return

			dronefab.produce_drones = !dronefab.produce_drones
			var/toggle = dronefab.produce_drones ? "enable" : "disable"
			show_splash_text(usr, "Drone production toggled", SPAN_NOTICE("You [toggle] drone production in the nearby fabricator."))
			message_admins("[key_name_admin(usr)] [toggle]d maintenance drone production from the control console.")
			log_game("[key_name(usr)] [toggle]d maintenance drone production from the control console.")
			return TRUE

		if("set_area")
			drone_call_area = params["area"]
			return TRUE

		if("ping")
			ping_cooldown = world.time + 15 SECONDS
			show_splash_text(usr, "Maintenance request issued!", SPAN_NOTICE("You issue a maintenance request for all active drones, highlighting [drone_call_area]."))
			for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
				if(D.client && D.stat == CONSCIOUS)
					to_chat(usr, SPAN_NOTICE("Maintenance drone presence requested in: [drone_call_area]."))
			return TRUE

		if("resync")
			var/mob/living/silicon/robot/drone/D = locate(params["ref"]) in GLOB.silicon_mob_list
			if(D)
				show_splash_text(usr, "Laws synced", SPAN_NOTICE("You issue a law synchronization directive for the drone."))
				D.law_resync()
			return TRUE

		if("shutdown")
			var/mob/living/silicon/robot/drone/D = locate(params["ref"]) in GLOB.silicon_mob_list
			if(D)
				show_splash_text(usr, "Drone shut down", SPAN_WARNING("You issue a recall command for the unfortunate drone."))
				if(D != usr) // Don't need to bug admins about a suicide
					message_admins("[key_name_admin(usr)] issued recall order for drone [key_name_admin(D)] from control console.")
					log_game("[key_name(usr)] issued recall order for [key_name(D)] from control console.")
					D.shut_down()
			return TRUE

/obj/machinery/computer/drone_control/proc/find_fab(mob/user)
	if(dronefab)
		return

	for(var/obj/machinery/drone_fabricator/fab in get_area(src))
		if(fab.stat & NOPOWER)
			continue
		dronefab = fab
		if(user)
			show_splash_text(user, "Dronefab located!", SPAN_NOTICE("Drone fabricator located."))
		return
	if(user)
		show_splash_text(user, "Unable to locate!", SPAN_WARNING("Unable to locate drone fabricator."))
