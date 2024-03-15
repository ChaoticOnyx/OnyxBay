#define MAX_TURRET_LOGS 50
// Standard buildable model of turret.
/obj/machinery/turret/network
	name = "sentry turret"
	desc = "An automatic turret capable of identifying and dispatching targets using a mounted firearm."

	idle_power_usage = 50 WATTS
	active_power_usage = 1 KILO WATT // Determines how fast energy weapons can be recharged, so highly values are better.

	installed_gun = null
	gun_looting_prob = 100

	traverse = 360
	turning_rate = 270

	hostility = /datum/hostility/turret/network

	// Targeting modes.
	var/datum/targeting_settings/targeting_settings = /datum/targeting_settings

	/// List of events stored in a neat format
	var/list/logs

	req_access = list(access_ai_upload)

/obj/machinery/turret/network/Initialize()
	. = ..()
	name = "[name] [rand(1, 100)]"
	lethal_nonlethal_switch()
	targeting_settings = new targeting_settings()

/obj/machinery/turret/network/Destroy()
	QDEL_NULL(targeting_settings)
	return ..()

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
	var/total_capacitors = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		total_capacitors++

	active_power_usage = clamp(total_capacitors, 1, 5) KILO WATTS

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

/obj/machinery/turret/network/toggle_enabled(override)
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
		if(mode.name == "stun" && !targeting_settings.lethal_mode)
			installed_gun.sel_mode = i
			installed_gun.set_firemode()
			break

		if(mode.name != "stun" && targeting_settings.lethal_mode)
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
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Turret", "Turret Control Panel")
		ui.open()

/obj/machinery/turret/network/tgui_data(mob/user)
	var/list/data = list()

	data["isMalf"] = FALSE

	var/mob/living/silicon/ai = user
	if(istype(ai))
		data["isMalf"] = ai.is_malf() ? TRUE : FALSE

	data["isEnabled"] = enabled

	data["hasMaster"] = FALSE

	var/obj/machinery/turret_control_panel/control_panel = master_controller?.resolve()
	if(istype(control_panel))
		data["masterController"] = TRUE

	data["hasSignaler"] = istype(signaler) ? TRUE : FALSE

	data["gunData"] += get_gun_data()
	data["settingsData"] += get_turret_data()

	data["targettingData"] = targeting_settings.tgui_data()

	return data

/obj/machinery/turret/network/proc/get_turret_data()
	return list(
		"bearing" = default_bearing,
		"integrity" = integrity,
		"maxIntegrity" = max_integrity,
	)

/obj/machinery/turret/network/proc/get_gun_data()
	var/list/data = list()

	if(!istype(installed_gun))
		return data

	data["gunName"] = installed_gun.name

	if(istype(installed_gun, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/proj_gun = installed_gun
		data["gunAmmo"] = proj_gun.getAmmo()
		data["gunMaxAmmo"] = proj_gun.ammo_magazine?.max_ammo
	else if(istype(installed_gun, /obj/item/gun/energy))
		var/obj/item/gun/energy/egun = installed_gun
		data["gunAmmo"] = egun.power_supply?.charge
		data["gunMaxAmmo"] = egun.power_supply?.maxcharge

	data["storedAmmo"] = stored_ammo

	return data

/obj/machinery/turret/network/tgui_act(action, list/params)
	. = ..()

	if(.)
		return

	switch(action)
		if("toggle")
			switch(params["check"])
				if("power")
					if(world.time >= last_enabled + toggle_cooldown)
						last_enabled = world.time
						enabled = !enabled
						state_machine.evaluate()
					else
						show_splash_text(usr, "Turrets recalibrating!")
					return TRUE

				if("mode")
					targeting_settings.lethal_mode = !targeting_settings.lethal_mode
					lethal_nonlethal_switch()
					return TRUE

				if("synth")
					targeting_settings.check_synth = !targeting_settings.check_synth
					return TRUE

				if("weapon")
					targeting_settings.check_weapons = !targeting_settings.check_weapons
					return TRUE

				if("records")
					targeting_settings.check_records = !targeting_settings.check_records
					return TRUE

				if("arrest")
					targeting_settings.check_arrest = !targeting_settings.check_arrest
					return TRUE

				if("access")
					targeting_settings.check_access = !targeting_settings.check_access
					return TRUE

				if("anomalies")
					targeting_settings.check_anomalies = !targeting_settings.check_anomalies
					return TRUE

		if("changeBearing")
			change_bearing(usr)
			return TRUE

		if("destroySignaler")
			QDEL_NULL(signaler)
			master_controller = null
			return TRUE

// TODO: figure out why it doesn't accept value and loops infinitely.
/obj/machinery/turret/network/proc/change_bearing(mob/user)
	if(!istype(user))
		return

	var/new_bearing = tgui_input_number(user, "", "Bearing Change", 0, 360, -1)
	if(isnull(new_bearing))
		return

	switch(new_bearing) // Maybe if(new_bearing == -1)
		if(-1)
			default_bearing = null
		else
			default_bearing = trunc(new_bearing)

#undef MAX_TURRET_LOGS
