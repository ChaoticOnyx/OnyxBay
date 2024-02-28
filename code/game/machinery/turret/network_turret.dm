#define MAX_TURRET_LOGS 50
// Standard buildable model of turret.
/obj/machinery/turret/network
	name = "sentry turret"
	desc = "An automatic turret capable of identifying and dispatching targets using a mounted firearm."

	idle_power_usage = 5 KILO WATTS
	active_power_usage = 5 KILO WATTS // Determines how fast energy weapons can be recharged, so highly values are better.

	installed_gun = null
	gun_looting_prob = 100

	traverse = 360
	turning_rate = 270

	hostility = /datum/hostility/turret/network

	// Targeting modes.
	var/check_access = FALSE
	var/check_weapons = FALSE
	var/check_records = FALSE
	var/check_arrest = FALSE
	var/check_anomalies = FALSE
	var/check_synth = FALSE
	var/lethal_mode = FALSE

	/// Used for turret's TGUI
	var/page = 0

	/// List of events stored in a neat format
	var/list/logs

/obj/machinery/turret/network/Initialize()
	. = ..()
	name = "[name] [rand(1, 100)]"
	lethal_nonlethal_switch()

/obj/machinery/turret/network/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(I, /obj/item/computer_hardware/hard_drive/portable))
		if(!check_access(user))
			show_splash_text(user, "Access denied!")
			return
		var/obj/item/computer_hardware/hard_drive/portable/drive = I
		var/datum/computer_file/data/logfile/turret_log = prepare_log_file()
		if(drive.store_file(turret_log))
			show_splash_text(user, "Log file downloaded!")
		else
			show_splash_text(user, "Operation failed!")

/obj/machinery/turret/network/RefreshParts()
	. = ..()
	//active_power_usage = 5 * clamp(total_component_rating_of_type(/obj/item/stock_parts/capacitor), 1, 5) KILO WATTS
	//reloading_speed = 10 * clamp(total_component_rating_of_type(/obj/item/stock_parts/manipulator), 1, 5)

	//var/new_range = clamp(total_component_rating_of_type(/obj/item/stock_parts/scanning_module)*3, 4, 8)
	//if(vision_range != new_range)
	//	vision_range = new_range
	//	proximity?.set_range(vision_range)

/obj/machinery/turret/network/proc/add_log(log_string)
	LAZYADD(logs, "([stationtime2text()], [stationdate2text()]) [log_string]")
	if(LAZYLEN(logs) > MAX_TURRET_LOGS)
		LAZYREMOVE(logs, LAZYACCESS(logs, 1))

/obj/machinery/turret/network/proc/prepare_log_file()
	var/datum/computer_file/data/logfile/turret_log = new()
	turret_log.filename = "[name]"
	turret_log.stored_data = "\[b\]Logfile of turret [name]\[/b\]\[BR\]"
	for(var/log_string in logs)
		turret_log.stored_data += "[log_string]\[BR\]"
	turret_log.calculate_size()

	return turret_log

/obj/machinery/turret/network/add_target(atom/A)
	. = ..()
	if(.)
		add_log("Target Engaged: \the [A]")

/obj/machinery/turret/network/toggle_enabled()
	. = ..()
	if(.)
		add_log("Turret was [enabled ? "enabled" : "disabled"]")

/obj/machinery/turret/network/change_firemode(firemode_index)
	. = ..()
	if(.)
		if(installed_gun && length(installed_gun.firemodes))
			var/datum/firemode/current_mode = installed_gun.firemodes[firemode_index]
			add_log("Turret firing mode changed to [current_mode.name]")

/obj/machinery/turret/network/proc/lethal_nonlethal_switch()
	if(!can_non_lethal())
		return

	for(var/i = 1 to installed_gun?.firemodes?.len)
		var/datum/firemode/mode = installed_gun?.firemodes[i]
		if(mode.name == "stun" && !lethal_mode)
			installed_gun.sel_mode = i
			installed_gun.set_firemode()
			break

		if(mode.name != "stun" && lethal_mode)
			installed_gun.sel_mode = i
			installed_gun.set_firemode()
			break

/obj/machinery/turret/network/proc/can_non_lethal()
	if(!islist(installed_gun?.firemodes))
		return FALSE

	for(var/datum/firemode/mode in installed_gun?.firemodes)
		if(mode.name == "stun")
			return TRUE

	return FALSE

/obj/machinery/turret/network/proc/isLocked(mob/user)
	if(ailock && issilicon(user))
		show_splash_text(user, "Blocked by firewall!")
		return TRUE

	if(malf_upgraded && !issilicon(user))
		return TRUE

	return FALSE

/obj/machinery/turret/network/attack_ai(mob/user)
	if(isLocked(user))
		return

	tgui_interact(user)

/obj/machinery/turret/network/attack_hand(mob/user)
	if(isLocked(user))
		return

	tgui_interact(user)

/obj/machinery/turret/network/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Turret", "Turret Control Panel")
		ui.open()

/obj/machinery/turret/network/tgui_data(mob/user)
	var/list/data = list(
		"lethalMode" = lethal_mode,
		"checkSynth" = check_synth,
		"checkWeapon" = check_weapons,
		"checkRecords" = check_records,
		"checkArrests" = check_arrest,
		"checkAccess" = check_access,
		"checkAnomalies" = check_anomalies,
		"page" = page,
		"masterController" = FALSE,
		"isMalf" = FALSE,
	)

	data += get_turret_data()

	data += get_gun_data()

	if(istype(signaler))
		data["signalerInstalled"] = TRUE

	var/obj/machinery/turret_control_panel/control_panel = master_controller?.resolve()
	if(istype(control_panel))
		data["masterController"] = TRUE

	if(issilicon(user))
		var/mob/living/silicon/ai = user
		if(ai.is_malf())
			data["isMalf"] = TRUE

	return data

/obj/machinery/turret/network/proc/get_turret_data()
	var/list/data = list(
		"status" = enabled,
		"storedAmmo" = stored_ammo,
		"currentBearing" = current_bearing,
		"defaultBearing" = default_bearing,
		"signalerInstalled" = FALSE,
		"integrity" = integrity,
		"maxIntegrity" = max_integrity
	)

	return data

/obj/machinery/turret/network/proc/get_gun_data()
	var/list/data = list()
	if(istype(installed_gun))
		data["gun"] = installed_gun.name
		if(istype(installed_gun, /obj/item/gun/projectile))
			var/obj/item/gun/projectile/proj_gun = installed_gun
			data["gunAmmo"] = proj_gun.getAmmo()
			data["gunMaxAmmo"] = proj_gun.ammo_magazine?.max_ammo
		else if(istype(installed_gun, /obj/item/gun/energy))
			var/obj/item/gun/energy/egun = installed_gun
			data["gunAmmo"] = egun.power_supply?.charge
			data["gunMaxAmmo"] = egun.power_supply?.maxcharge

	return data

/obj/machinery/turret/network/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			enabled = !enabled
			return TRUE

		if("change_page")
			page = !page
			return TRUE

		if("lethal_mode")
			lethal_mode = !lethal_mode
			lethal_nonlethal_switch()
			return TRUE

		if("check_synth")
			check_synth = !check_synth
			return TRUE

		if("check_weapon")
			check_weapons = !check_weapons
			return TRUE

		if("check_records")
			check_records = !check_records
			return TRUE

		if("check_arrest")
			check_arrest = !check_arrest
			return TRUE

		if("check_access")
			check_access = !check_access
			return TRUE

		if("check_anomalies")
			check_anomalies = !check_anomalies
			return TRUE

		if("adjust_default_bearing")
			default_bearing = Clamp(text2num(params["new_bearing"]), 0, 360)
			return TRUE

		if("destroy_signaler")
			QDEL_NULL(signaler)
			master_controller = null
			return TRUE

/obj/item/circuitboard/sentry_turret
	name = "circuitboard (sentry turret)"
	board_type = "machine"
	build_path = /obj/machinery/turret/network
	origin_tech = "{'programming':5,'combat':5,'engineering':4}"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 2)

#undef MAX_TURRET_LOGS
