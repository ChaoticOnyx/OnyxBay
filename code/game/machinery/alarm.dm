////////////////////////////////////////
//CONTAINS: Air Alarms and Fire Alarms//
////////////////////////////////////////

#define GET_DANGER_LEVEL(ret, current_value, danger_levels) \
	if((current_value > danger_levels[4] && danger_levels[4] > 0) || current_value < danger_levels[1]) { ret = 2; } \
	else if((current_value > danger_levels[3] && danger_levels[3] > 0) || current_value < danger_levels[2]) { ret = 1; } \
	else { ret = 0; }

#define OVERALL_DANGER_LEVEL(ret, environment) \
	ret = 0; \
	var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume; \
	var/environment_pressure = environment.return_pressure(); \
	var/other_moles = environment.total_moles - (environment.gas["oxygen"] + environment.gas["nitrogen"] + environment.gas["carbon_dioxide"]); \
	GET_DANGER_LEVEL(pressure_dangerlevel, environment_pressure, TLV["pressure"]) \
	GET_DANGER_LEVEL(oxygen_dangerlevel, (environment.gas["oxygen"] * partial_pressure), TLV["oxygen"]) \
	GET_DANGER_LEVEL(co2_dangerlevel, (environment.gas["carbon_dioxide"] * partial_pressure), TLV["carbon dioxide"]) \
	GET_DANGER_LEVEL(temperature_dangerlevel, environment.temperature, TLV["temperature"]) \
	GET_DANGER_LEVEL(other_dangerlevel, (other_moles * partial_pressure), TLV["other"]) \
	ret = max(pressure_dangerlevel, oxygen_dangerlevel, co2_dangerlevel, other_dangerlevel, temperature_dangerlevel);


#define AALARM_MODE_SCRUBBING	1
#define AALARM_MODE_REPLACEMENT	2 //like scrubbing, but faster.
#define AALARM_MODE_PANIC		3 //constantly sucks all air
#define AALARM_MODE_CYCLE		4 //sucks off all air, then refill and switches to scrubbing
#define AALARM_MODE_FILL		5 //emergency fill
#define AALARM_MODE_OFF			6 //Shuts it all down.

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

#define MAX_TEMPERATURE 90
#define MIN_TEMPERATURE -40

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm
	name = "alarm"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm"
	anchored = 1
	idle_power_usage = 80 WATTS
	active_power_usage = 1 KILO WATT //For heating/cooling rooms. 1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
	power_channel = STATIC_ENVIRON
	req_one_access = list(access_atmospherics, access_engine_equip)
	clicksound = SFX_USE_BUTTON
	clickvol = 30

	layer = ABOVE_WINDOW_LAYER

	var/alarm_id = null
	var/breach_detection = 1 // Whether to use automatic breach detection or not
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = 0
	var/rcon_setting = 2
	var/rcon_time = 0
	var/locked = 1
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/shorted = 0

	var/datum/wires/alarm/wires

	var/mode = AALARM_MODE_SCRUBBING
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/area/alarm_area
	var/buildstage = 2 //2 is built, 1 is building, 0 is frame.

	var/target_temperature = 20 CELSIUS
	var/regulating_temperature = 0

	var/datum/frequency/radio_connection

	var/list/TLV = list()
	var/list/DEFAULT_TLV = list()

	var/danger_level = 0
	var/pressure_dangerlevel = 0
	var/oxygen_dangerlevel = 0
	var/co2_dangerlevel = 0
	var/temperature_dangerlevel = 0
	var/other_dangerlevel = 0

	var/report_danger_level = 1

	var/static/status_overlays = FALSE
	var/static/list/alarm_overlays
	var/previous_controls_open = FALSE
	var/controls_open = FALSE
	var/list/tgui_remote_sessions = list()

/obj/machinery/alarm/cold
	target_temperature = 4 CELSIUS

/obj/machinery/alarm/nobreach
	breach_detection = 0

/obj/machinery/alarm/monitor
	report_danger_level = 0
	breach_detection = 0

/obj/machinery/alarm/server/New()
	..()
	req_access = list(access_rd, access_atmospherics, access_engine_equip)
	TLV["temperature"] =	list(-26 CELSIUS, 0 CELSIUS, 30 CELSIUS, 40 CELSIUS)
	DEFAULT_TLV["temperature"] =	list(-26 CELSIUS, 0 CELSIUS, 30 CELSIUS, 40 CELSIUS)
	target_temperature = 10 CELSIUS

/obj/machinery/alarm/Destroy()
	GLOB.alarm_list -= src
	SSradio.remove_object(src, frequency)
	QDEL_NULL(wires)
	if(tgui_remote_sessions)
		for(var/user_ref in tgui_remote_sessions)
			var/list/session = tgui_remote_sessions[user_ref]
			if(!islist(session))
				continue
			var/datum/topic_state/remoter_state = session["state"]
			if(remoter_state)
				qdel(remoter_state)
		tgui_remote_sessions.Cut()
	if(alarm_area && alarm_area.master_air_alarm == src)
		alarm_area.master_air_alarm = null
		elect_master(exclude_self = TRUE)
	ClearOverlays()
	return ..()

/obj/machinery/alarm/New(loc, dir, atom/frame)
	GLOB.alarm_list += src
	..(loc)

	if(dir)
		src.set_dir(dir)

	if(istype(frame))
		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		update_icon()
		frame.transfer_fingerprints_to(src)

/obj/machinery/alarm/Initialize()
	. = ..()
	alarm_area = get_area(src)
	area_uid = alarm_area.uid
	if (name == "alarm")
		SetName("[alarm_area.name] Air Alarm")

	if(!wires)
		wires = new(src)

	// breathable air according to human/Life()
	TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	TLV["plasma"] =			list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["carbon dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	TLV["temperature"] =	list(-26 CELSIUS, 0 CELSIUS, 40 CELSIUS, 66 CELSIUS)
	DEFAULT_TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	DEFAULT_TLV["plasma"] =			list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	DEFAULT_TLV["carbon dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	DEFAULT_TLV["other"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	DEFAULT_TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	DEFAULT_TLV["temperature"] =	list(-26 CELSIUS, 0 CELSIUS, 40 CELSIUS, 66 CELSIUS)
	set_frequency(frequency)
	if (!master_is_operating())
		elect_master()

	update_icon()

/obj/machinery/alarm/Process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != 2)
		return

	var/turf/simulated/location = loc
	if(!istype(location))
		return PROCESS_KILL // returns if loc is not simulated

	var/datum/gas_mixture/environment = location.return_air()

	//Handle temperature adjustment here.
	handle_heating_cooling(environment)

	var/old_level = danger_level
	var/old_pressurelevel = pressure_dangerlevel
	OVERALL_DANGER_LEVEL(danger_level, environment)

	if(old_level != danger_level)
		apply_danger_level(danger_level)

	if(old_pressurelevel != pressure_dangerlevel)
		if(breach_detected())
			mode = AALARM_MODE_OFF
			apply_mode()

	if(mode == AALARM_MODE_CYCLE && environment.return_pressure() < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_FILL
		apply_mode()

	//atmos computer remote controll stuff
	switch(rcon_setting)
		if(RCON_NO)
			remote_control = 0
		if(RCON_AUTO)
			if(danger_level == 2)
				remote_control = 1
			else
				remote_control = 0
		if(RCON_YES)
			remote_control = 1

	if(controls_open)
		if(!length(SStgui.get_all_open_uis(src)))
			controls_open = FALSE
			update_icon()

	return

/obj/machinery/alarm/proc/handle_heating_cooling(datum/gas_mixture/environment)
	if(!regulating_temperature)
		if(abs(environment.temperature - target_temperature) > 2.0)
			var/danger_check
			GET_DANGER_LEVEL(danger_check, target_temperature, TLV["temperature"])
			if(!danger_check)
				update_use_power(POWER_USE_ACTIVE)
				regulating_temperature = 1
				visible_message("\The [src] clicks as it starts [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",\
								"You hear a click and a faint electronic hum.")
	else
		var/should_disable_regulating = FALSE
		if(abs(environment.temperature - target_temperature) <= 0.5)
			should_disable_regulating = TRUE
			goto nodeDisableRegulating
		var/danger_check
		GET_DANGER_LEVEL(danger_check, target_temperature, TLV["temperature"])
		if(danger_check)
			should_disable_regulating = TRUE

		nodeDisableRegulating
		if(should_disable_regulating)
			update_use_power(POWER_USE_IDLE)
			regulating_temperature = 0
			visible_message("\The [src] clicks quietly as it stops [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",\
							"You hear a click as a faint electronic humming stops.")

	if (regulating_temperature)
		target_temperature = Clamp(target_temperature, CONV_CELSIUS_KELVIN(MIN_TEMPERATURE), CONV_CELSIUS_KELVIN(MAX_TEMPERATURE))

		var/datum/gas_mixture/gas
		gas = environment.remove(0.25*environment.total_moles)
		if(gas)

			if (gas.temperature <= target_temperature)	//gas heating
				var/energy_used = min( gas.get_thermal_energy_change(target_temperature) , active_power_usage)

				gas.add_thermal_energy(energy_used)
			else	//gas cooling
				var/heat_transfer = min(abs(gas.get_thermal_energy_change(target_temperature)), active_power_usage)

				//Assume the heat is being pumped into the hull which is fixed at 20 C
				//none of this is really proper thermodynamics but whatever

				var/cop = gas.temperature / (20 CELSIUS)	//coefficient of performance -> power used = heat_transfer/cop

				heat_transfer = min(heat_transfer, cop * active_power_usage)	//this ensures that we don't use more than active_power_usage amount of power

				heat_transfer = -gas.add_thermal_energy(-heat_transfer)	//get the actual heat transfer

			environment.merge(gas)

// Returns whether this air alarm thinks there is a breach, given the sensors that are available to it.
/obj/machinery/alarm/proc/breach_detected()
	var/turf/simulated/location = loc

	if(!istype(location))
		return 0

	if(breach_detection	== 0)
		return 0

	var/datum/gas_mixture/environment = location.return_air()
	var/environment_pressure = environment.return_pressure()
	var/pressure_levels = TLV["pressure"]

	if (environment_pressure <= pressure_levels[1])		//low pressures
		if (!(mode == AALARM_MODE_PANIC || mode == AALARM_MODE_CYCLE))
			playsound(src.loc, 'sound/machines/airalarm.ogg', 25, 0, 4)
			return 1

	return 0


/obj/machinery/alarm/proc/master_is_operating()
	return alarm_area.master_air_alarm && !(alarm_area.master_air_alarm.stat & (NOPOWER|BROKEN))


/obj/machinery/alarm/proc/elect_master(exclude_self = FALSE)
	for (var/obj/machinery/alarm/AA in alarm_area)
		if(exclude_self && AA == src)
			continue
		if (!(AA.stat & (NOPOWER|BROKEN)))
			alarm_area.master_air_alarm = AA
			return 1
	return 0

#define ALARM_OVERLAY_NORMAL          1
#define ALARM_OVERLAY_WARNING         2
#define ALARM_OVERLAY_DANGER          3
#define ALARM_OVERLAY_EA              4
#define ALARM_OVERLAY_WIRES           5

/obj/machinery/alarm/on_update_icon()
	if(!status_overlays)
		status_overlays = TRUE
		generate_overlays()

	ClearOverlays()

	if(controls_open && !previous_controls_open)
		previous_controls_open = TRUE
		flick("alarm-open", src)
	else if(!controls_open && previous_controls_open)
		previous_controls_open = FALSE
		flick("alarm-close", src)

	icon_state = controls_open ? "alarm-opened" : "alarm"

	if(wiresexposed)
		AddOverlays(alarm_overlays[ALARM_OVERLAY_WIRES])
		set_light(0)
		return

	if((stat & (NOPOWER|BROKEN)) || shorted)
		set_light(0)
		return

	var/icon_level = danger_level
	if(alarm_area.atmosalm)
		icon_level = max(icon_level, 1)	//if there's an atmos alarm but everything is okay locally, no need to go past yellow

	var/new_color = null
	switch(icon_level)
		if(0)
			new_color = COLOR_LIME
		if(1)
			new_color = COLOR_SUN
		if(2)
			new_color = COLOR_RED_LIGHT

	AddOverlays(alarm_overlays[icon_level+1])
	AddOverlays(alarm_overlays[ALARM_OVERLAY_EA])

	set_light(0.65, 0.1, 1, 2, new_color)

/obj/machinery/alarm/proc/generate_overlays()
	alarm_overlays = new
	alarm_overlays.len = 7
	alarm_overlays[ALARM_OVERLAY_NORMAL]  = image(icon, "alarm_over0")
	alarm_overlays[ALARM_OVERLAY_WARNING] = image(icon, "alarm_over1")
	alarm_overlays[ALARM_OVERLAY_DANGER]  = image(icon, "alarm_over2")
	alarm_overlays[ALARM_OVERLAY_NORMAL].alpha  = 200
	alarm_overlays[ALARM_OVERLAY_WARNING].alpha = 200
	alarm_overlays[ALARM_OVERLAY_DANGER].alpha  = 200

	alarm_overlays[ALARM_OVERLAY_EA] = emissive_appearance(icon, "alarm_ea", cache = FALSE)

	alarm_overlays[ALARM_OVERLAY_WIRES] = image(icon, "alarm-wires")

#undef ALARM_OVERLAY_NORMAL
#undef ALARM_OVERLAY_WARNING
#undef ALARM_OVERLAY_DANGER
#undef ALARM_OVERLAY_EA
#undef ALARM_OVERLAY_WIRES

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if (alarm_area.master_air_alarm != src)
		if (master_is_operating())
			return
		elect_master()
		if (alarm_area.master_air_alarm != src)
			return
	if(!signal || signal.encryption)
		return
	var/id_tag = signal.data["tag"]
	if (!id_tag)
		return
	if (signal.data["area"] != area_uid)
		return
	if (signal.data["sigtype"] != "status")
		return

	var/dev_type = signal.data["device"]
	if(!(id_tag in alarm_area.air_scrub_names) && !(id_tag in alarm_area.air_vent_names))
		register_env_machine(id_tag, dev_type)
	if(dev_type == "AScr")
		alarm_area.air_scrub_info[id_tag] = signal.data
	else if(dev_type == "AVP")
		alarm_area.air_vent_info[id_tag] = signal.data

/obj/machinery/alarm/proc/register_env_machine(m_id, device_type)
	var/new_name
	if (device_type=="AVP")
		new_name = "[alarm_area.name] Vent Pump #[alarm_area.air_vent_names.len+1]"
		alarm_area.air_vent_names[m_id] = new_name
	else if (device_type=="AScr")
		new_name = "[alarm_area.name] Air Scrubber #[alarm_area.air_scrub_names.len+1]"
		alarm_area.air_scrub_names[m_id] = new_name
	else
		return
	spawn (10)
		send_signal(m_id, list("init" = new_name) )

/obj/machinery/alarm/proc/refresh_all()
	for(var/id_tag in alarm_area.air_vent_names)
		var/list/I = alarm_area.air_vent_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in alarm_area.air_scrub_names)
		var/list/I = alarm_area.air_scrub_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )

/obj/machinery/alarm/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(target, list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new()
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
//			log_debug(text("Signal [] Broadcasted to []", command, target))

	return 1

/obj/machinery/alarm/proc/apply_mode()
	//propagate mode to other air alarms in the area
	//TODO: make it so that players can choose between applying the new mode to the room they are in (related area) vs the entire alarm area
	for (var/obj/machinery/alarm/AA in alarm_area)
		AA.mode = mode

	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "co2_scrub"= 1, "scrubbing"= 1, "panic_siphon"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_PANIC, AALARM_MODE_CYCLE)
			playsound(src.loc, 'sound/signals/alarm14.ogg', 25)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

		if(AALARM_MODE_REPLACEMENT)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_FILL)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_OFF)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

/obj/machinery/alarm/proc/apply_danger_level(new_danger_level)
	if (report_danger_level && alarm_area.atmosalert(new_danger_level, src))
		post_alert(new_danger_level)

	update_icon()

/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/frequency/frequency = SSradio.return_frequency(alarm_frequency)
	if(!frequency)
		return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.data["zone"] = alarm_area.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/attack_ai(mob/user)
	clear_remote_tgui_session(user)
	tgui_interact(user)

/obj/machinery/alarm/attack_hand(mob/user)
	. = ..()
	if (.)
		return
	return interact(user)

/obj/machinery/alarm/interact(mob/user)
	clear_remote_tgui_session(user)
	tgui_interact(user)
	wires.Interact(user)

	controls_open = TRUE
	update_icon()

/obj/machinery/alarm/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "AirAlarm", name)
		ui.set_autoupdate(TRUE)

	ui.open()

/obj/machinery/alarm/tgui_state(mob/user)
	return GLOB.remote_control_state

/obj/machinery/alarm/proc/set_remote_tgui_session(mob/user, datum/remoter, datum/topic_state/remoter_state)
	if(!user || !remoter || !remoter_state)
		return FALSE

	var/user_ref = "\ref[user]"
	var/list/current_session = tgui_remote_sessions[user_ref]
	if(islist(current_session))
		var/datum/topic_state/current_state = current_session["state"]
		if(current_state && current_state != remoter_state)
			qdel(current_state)

	tgui_remote_sessions[user_ref] = list(
		"remoter" = remoter,
		"state" = remoter_state
	)
	return TRUE

/obj/machinery/alarm/proc/clear_remote_tgui_session(mob/user)
	if(!user || !tgui_remote_sessions || !tgui_remote_sessions.len)
		return

	var/user_ref = "\ref[user]"
	var/list/session = tgui_remote_sessions[user_ref]
	if(islist(session))
		var/datum/topic_state/remoter_state = session["state"]
		if(remoter_state)
			qdel(remoter_state)

	tgui_remote_sessions -= user_ref

/obj/machinery/alarm/proc/_get_remote_tgui_status(mob/user)
	if(!user || !tgui_remote_sessions || !tgui_remote_sessions.len)
		return UI_CLOSE

	var/user_ref = "\ref[user]"
	var/list/session = tgui_remote_sessions[user_ref]
	if(!islist(session))
		tgui_remote_sessions -= user_ref
		return UI_CLOSE

	var/datum/remoter = session["remoter"]
	var/datum/topic_state/remoter_state = session["state"]
	if(!remoter || !remoter_state || QDELETED(remoter) || QDELETED(remoter_state))
		clear_remote_tgui_session(user)
		return UI_CLOSE

	var/status = remoter.CanUseTopic(user, remoter_state)
	if(status <= UI_CLOSE)
		clear_remote_tgui_session(user)
		return UI_CLOSE

	return status

/obj/machinery/alarm/proc/tgui_remote_control_status(mob/user)
	var/local_status = GLOB.tgui_default_state.can_use_topic(src, user)
	var/remote_status = _get_remote_tgui_status(user)
	return max(local_status, remote_status)

/obj/machinery/alarm/ui_close(mob/user)
	clear_remote_tgui_session(user)
	return ..()

/obj/machinery/alarm/tgui_data(mob/user)
	var/list/data = list()

	var/remote_status = _get_remote_tgui_status(user)
	var/remote_connection = remote_status > UI_CLOSE
	var/remote_access = remote_status >= UI_INTERACTIVE
	var/remote_lock_bypass = remote_access

	data["remote_connection"] = remote_connection
	data["remote_access"] = remote_access

	data["locked"] = locked && !issilicon(user) && !remote_lock_bypass
	data["rcon"] = rcon_setting
	data["screen"] = screen
	data["mode"] = mode

	var/current_ui_status = tgui_remote_control_status(user)
	data["can_control"] = (current_ui_status == UI_INTERACTIVE && (!locked || issilicon(user) || remote_lock_bypass)) ? TRUE : FALSE

	var/list/t_sel = TLV["temperature"]
	var/max_temperature_c = min(CONV_KELVIN_CELSIUS(t_sel[3]), MAX_TEMPERATURE)
	var/min_temperature_c = max(CONV_KELVIN_CELSIUS(t_sel[2]), MIN_TEMPERATURE)
	data["min_temp_c"] = min_temperature_c
	data["max_temp_c"] = max_temperature_c
	data["target_temp_c"] = round(CONV_KELVIN_CELSIUS(target_temperature), 0.1)

	populate_status(data)
	populate_controls(data)
	populate_thresholds(data)
	return data

/obj/machinery/alarm/proc/_tgui_can_control(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(shorted || buildstage != 2)
		return FALSE
	if(locked && !issilicon(user) && _get_remote_tgui_status(user) < UI_INTERACTIVE)
		return FALSE
	return TRUE


/obj/machinery/alarm/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .

	if(buildstage != 2)
		return FALSE
	if(aidisabled && isAI(usr))
		to_chat(usr, "<span class='warning'>AI control for \the [src] interface has been disabled.</span>")
		return FALSE
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(shorted)
		return FALSE

	switch(action)

		if("atmos_alarm")
			if(!_tgui_can_control(usr))
				return FALSE
			alarm_area.atmosalert(2, src)
			update_icon()
			return TRUE

		if("atmos_reset")
			if(!_tgui_can_control(usr))
				return FALSE
			alarm_area.atmosalert(0, src)
			update_icon()
			return TRUE

		if("fire_alarm")
			if(!_tgui_can_control(usr))
				return FALSE
			if(alarm_area)
				for(var/obj/machinery/firealarm/FA in alarm_area)
					FA.alarm()
					break;
			update_icon()
			return TRUE

		if("fire_reset")
			if(!_tgui_can_control(usr))
				return FALSE
			if(alarm_area)
				for(var/obj/machinery/firealarm/FA in alarm_area)
					FA.reset()
					break;
			update_icon()
			return TRUE

		if("set_screen")
			var/new_screen = text2num(params["screen"])
			if(!new_screen)
				return FALSE
			screen = new_screen
			return TRUE

		if("set_rcon")
			var/v = text2num(params["value"])
			if(!v)
				return FALSE
			switch(v)
				if(RCON_NO, RCON_AUTO, RCON_YES)
					rcon_setting = v
					return TRUE
			return FALSE

		if("set_mode")
			if(!_tgui_can_control(usr))
				return FALSE

			var/m = text2num(params["mode"])
			if(!m)
				return FALSE

			switch(m)
				if(AALARM_MODE_SCRUBBING, AALARM_MODE_REPLACEMENT, AALARM_MODE_PANIC, AALARM_MODE_CYCLE, AALARM_MODE_FILL, AALARM_MODE_OFF)
					mode = m
					apply_mode()
					return TRUE

			return FALSE

		if("set_target_temp")
			if(!_tgui_can_control(usr))
				return FALSE

			var/temp_c = text2num(params["temp_c"])
			if(!isnum(temp_c))
				return FALSE

			var/list/t_sel = TLV["temperature"]
			var/max_temperature_c = min(CONV_KELVIN_CELSIUS(t_sel[3]), MAX_TEMPERATURE)
			var/min_temperature_c = max(CONV_KELVIN_CELSIUS(t_sel[2]), MIN_TEMPERATURE)

			if(temp_c > max_temperature_c) temp_c = max_temperature_c
			if(temp_c < min_temperature_c) temp_c = min_temperature_c

			target_temperature = CONV_CELSIUS_KELVIN(temp_c)
			return TRUE

		if("device_command")
			if(!_tgui_can_control(usr))
				return FALSE

			var/device_id = params["id_tag"]
			var/cmd = params["cmd"]
			if(!device_id || !cmd)
				return FALSE

			if(cmd == "set_external_pressure")
				var/input_pressure = text2num(params["val"])
				if(!isnum(input_pressure))
					return FALSE
				send_signal(device_id, list("set_external_pressure" = input_pressure))
				return TRUE

			if(cmd == "reset_external_pressure")
				send_signal(device_id, list("set_external_pressure" = ONE_ATMOSPHERE))
				return TRUE

			var/numval = text2num(params["val"])
			if(!isnum(numval))
				return FALSE

			switch(cmd)
				if("power", "checks", "adjust_external_pressure")
					send_signal(device_id, list("[cmd]" = numval))
					return TRUE

				if("panic_siphon", "scrubbing",
					"o2_scrub", "n2_scrub", "co2_scrub", "tox_scrub", "n2o_scrub")
					send_signal(device_id, list("[cmd]" = numval))
					return TRUE

			return FALSE

		if("set_threshold")
			if(!_tgui_can_control(usr))
				return FALSE

			var/env = params["env"]
			var/idx = text2num(params["idx"])
			if(!env || idx < 1 || idx > 4)
				return FALSE

			if(!(env in TLV))
				return FALSE

			var/list/selected = TLV[env]

			var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")

			var/max_value = 200
			if(env == "temperature")
				max_value = 5000
			else if(env == "pressure")
				max_value = 50 * ONE_ATMOSPHERE

			var/min_value = -1

			var/newval = tgui_input_number(
				usr,
				"Enter [thresholds[idx]] for [env]",
				"Alarm triggers",
				DEFAULT_TLV[env][idx],
				max_value,
				min_value,
				round_value = FALSE
			)

			if(isnull(newval))
				return TRUE

			if(newval < 0)
				selected[idx] = -1.0
			else if(env == "temperature" && newval > 5000)
				selected[idx] = 5000
			else if(env == "pressure" && newval > 50*ONE_ATMOSPHERE)
				selected[idx] = 50*ONE_ATMOSPHERE
			else if(env != "temperature" && env != "pressure" && newval > 200)
				selected[idx] = 200
			else
				newval = round(newval, 0.01)
				selected[idx] = newval

			if(idx == 1)
				if(selected[1] > selected[2]) selected[2] = selected[1]
				if(selected[1] > selected[3]) selected[3] = selected[1]
				if(selected[1] > selected[4]) selected[4] = selected[1]
			if(idx == 2)
				if(selected[1] > selected[2]) selected[1] = selected[2]
				if(selected[2] > selected[3]) selected[3] = selected[2]
				if(selected[2] > selected[4]) selected[4] = selected[2]
			if(idx == 3)
				if(selected[1] > selected[3]) selected[1] = selected[3]
				if(selected[2] > selected[3]) selected[2] = selected[3]
				if(selected[3] > selected[4]) selected[4] = selected[3]
			if(idx == 4)
				if(selected[1] > selected[4]) selected[1] = selected[4]
				if(selected[2] > selected[4]) selected[2] = selected[4]
				if(selected[3] > selected[4]) selected[3] = selected[4]

			apply_mode()
			return TRUE

	return FALSE


/obj/machinery/alarm/proc/populate_thresholds(list/data)
	var/list/thresholds[0]
	var/list/selected

	var/list/gas_names = list(
		"oxygen"         = "O₂",
		"carbon dioxide" = "CO₂",
		"plasma"         = "Toxin",
		"other"          = "Other")

	for (var/g in gas_names)
		thresholds[++thresholds.len] = list("name" = gas_names[g], "settings" = list())
		selected = TLV[g]
		for(var/i = 1, i <= 4, i++)
			thresholds[thresholds.len]["settings"] += list(list(
				"env" = g,
				"val" = i,
				"selected" = selected[i]
			))

	// Pressure
	selected = TLV["pressure"]
	thresholds[++thresholds.len] = list("name" = "Pressure", "settings" = list())
	for(var/i = 1, i <= 4, i++)
		thresholds[thresholds.len]["settings"] += list(list(
			"env" = "pressure",
			"val" = i,
			"selected" = selected[i]
		))

	// Temperature
	selected = TLV["temperature"]
	thresholds[++thresholds.len] = list("name" = "Temperature", "settings" = list())
	for(var/i = 1, i <= 4, i++)
		thresholds[thresholds.len]["settings"] += list(list(
			"env" = "temperature",
			"val" = i,
			"selected" = selected[i]
		))

	data["thresholds"] = thresholds

/obj/machinery/alarm/proc/populate_status(data)
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.total_moles

	var/list/environment_data = new
	data["has_environment"] = total
	if(total)
		var/pressure = environment.return_pressure()
		environment_data[++environment_data.len] = list("name" = "Pressure", "value" = pressure, "unit" = "kPa", "danger_level" = pressure_dangerlevel)
		environment_data[++environment_data.len] = list("name" = "Oxygen", "value" = environment.gas["oxygen"] / total * 100, "unit" = "%", "danger_level" = oxygen_dangerlevel)
		environment_data[++environment_data.len] = list("name" = "Nitrogen", "value" = environment.gas["nitrogen"] / total * 100, "unit" = "%", "danger_level" = oxygen_dangerlevel)
		environment_data[++environment_data.len] = list("name" = "Carbon dioxide", "value" = environment.gas["carbon_dioxide"] / total * 100, "unit" = "%", "danger_level" = co2_dangerlevel)

		var/other_moles = total - (environment.gas["oxygen"] + environment.gas["nitrogen"] + environment.gas["carbon_dioxide"])
		environment_data[++environment_data.len] = list("name" = "Other Gases", "value" = other_moles / total * 100, "unit" = "%", "danger_level" = other_dangerlevel)

		environment_data[++environment_data.len] = list("name" = "Temperature", "value" = environment.temperature, "unit" = "K ([round(CONV_KELVIN_CELSIUS(environment.temperature), 0.1)]C)", "danger_level" = temperature_dangerlevel)
	data["total_danger"] = danger_level
	data["environment"] = environment_data
	data["atmos_alarm"] = alarm_area.atmosalm
	data["fire_alarm"] = alarm_area.fire != null ? alarm_area.fire : 0
	data["target_temperature"] = "[CONV_KELVIN_CELSIUS(target_temperature)]C"

/obj/machinery/alarm/proc/populate_controls(list/data)
	switch(screen)
		if(AALARM_SCREEN_MAIN)
			data["mode"] = mode
		if(AALARM_SCREEN_VENT)
			var/vents[0]
			for(var/id_tag in alarm_area.air_vent_names)
				var/long_name = alarm_area.air_vent_names[id_tag]
				var/list/info = alarm_area.air_vent_info[id_tag]
				if(!info)
					continue
				vents[++vents.len] = list(
						"id_tag"	= id_tag,
						"long_name" = sanitize(long_name),
						"power"		= info["power"],
						"checks"	= info["checks"],
						"direction"	= info["direction"],
						"external"	= info["external"]
					)
			data["vents"] = vents
		if(AALARM_SCREEN_SCRUB)
			var/scrubbers[0]
			for(var/id_tag in alarm_area.air_scrub_names)
				var/long_name = alarm_area.air_scrub_names[id_tag]
				var/list/info = alarm_area.air_scrub_info[id_tag]
				if(!info)
					continue
				scrubbers[++scrubbers.len] = list(
						"id_tag"	= id_tag,
						"long_name" = sanitize(long_name),
						"power"		= info["power"],
						"scrubbing"	= info["scrubbing"],
						"panic"		= info["panic"],
						"filters"	= list()
					)
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Oxygen",			"command" = "o2_scrub",	"val" = info["filter_o2"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Nitrogen",		"command" = "n2_scrub",	"val" = info["filter_n2"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Carbon Dioxide", "command" = "co2_scrub","val" = info["filter_co2"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Toxin"	, 		"command" = "tox_scrub","val" = info["filter_plasma"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Nitrous Oxide",	"command" = "n2o_scrub","val" = info["filter_n2o"]))
			data["scrubbers"] = scrubbers
		if(AALARM_SCREEN_MODE)
			var/modes[0]
			modes[++modes.len] = list("name" = "Filtering - Scrubs out contaminants", 			"mode" = AALARM_MODE_SCRUBBING,		"selected" = mode == AALARM_MODE_SCRUBBING, 	"danger" = 0)
			modes[++modes.len] = list("name" = "Replace Air - Siphons out air while replacing", "mode" = AALARM_MODE_REPLACEMENT,	"selected" = mode == AALARM_MODE_REPLACEMENT,	"danger" = 0)
			modes[++modes.len] = list("name" = "Panic - Siphons air out of the room", 			"mode" = AALARM_MODE_PANIC,			"selected" = mode == AALARM_MODE_PANIC, 		"danger" = 1)
			modes[++modes.len] = list("name" = "Cycle - Siphons air before replacing", 			"mode" = AALARM_MODE_CYCLE,			"selected" = mode == AALARM_MODE_CYCLE, 		"danger" = 1)
			modes[++modes.len] = list("name" = "Fill - Shuts off scrubbers and opens vents", 	"mode" = AALARM_MODE_FILL,			"selected" = mode == AALARM_MODE_FILL, 			"danger" = 0)
			modes[++modes.len] = list("name" = "Off - Shuts off vents and scrubbers", 			"mode" = AALARM_MODE_OFF,			"selected" = mode == AALARM_MODE_OFF, 			"danger" = 0)
			data["modes"] = modes
			data["mode"] = mode

/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob)
	switch(buildstage)
		if(2)
			if(isScrewdriver(W))  // Opening that Air Alarm up.
//				to_chat(user, "You pop the Air Alarm's maintence panel open.")
				wiresexposed = !wiresexposed
				to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
				update_icon()
				return

			if (wiresexposed && isWirecutter(W))
				user.visible_message("<span class='warning'>[user] has cut the wires inside \the [src]!</span>", "You have cut the wires inside \the [src].")
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				new /obj/item/stack/cable_coil(get_turf(src), 5)
				buildstage = 1
				update_icon()
				return

			if (istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					to_chat(user, "It does nothing")
					return
				else
					if(check_access(usr) && !wires.IsIndexCut(AALARM_WIRE_IDSCAN))
						playsound(src.loc, 'sound/signals/warning10.ogg', 25)
						locked = !locked
						to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the Air Alarm interface.</span>")
					else
						playsound(src.loc, 'sound/signals/error21.ogg', 25)
						to_chat(user, "<span class='warning'>Access denied.</span>")
			return

		if(1)
			if(isCoil(W))
				var/obj/item/stack/cable_coil/C = W
				if (C.use(5))
					to_chat(user, "<span class='notice'>You wire \the [src].</span>")
					buildstage = 2
					update_icon()
					return
				else
					to_chat(user, "<span class='warning'>You need 5 pieces of cable to do wire \the [src].</span>")
					return

			else if(isCrowbar(W))
				to_chat(user, "You start prying out the circuit.")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG) && !QDELETED(src))
					to_chat(user, "You pry out the circuit!")
					var/obj/item/airalarm_electronics/circuit = new /obj/item/airalarm_electronics()
					circuit.dropInto(user.loc)
					buildstage = 0
					update_icon()
				return
		if(0)
			if(istype(W, /obj/item/airalarm_electronics))
				to_chat(user, "You insert the circuit!")
				qdel(W)
				buildstage = 1
				update_icon()
				return

			else if(isWrench(W))
				to_chat(user, "You remove the fire alarm assembly from the wall!")
				new /obj/item/frame/air_alarm(get_turf(user))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				qdel(src)

	return ..()

/obj/machinery/alarm/examine(mob/user, infix)
	. = ..()

	if(buildstage < 2)
		. += "It is not wired."
	if(buildstage < 1)
		. += "The circuit is missing."
/*
AIR ALARM CIRCUIT
Just a object used in constructing air alarms
*/
/obj/item/airalarm_electronics
	name = "air alarm electronics"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)

#undef GET_DANGER_LEVEL
#undef OVERALL_DANGER_LEVEL
