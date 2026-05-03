/datum/computer_file/program/atmos_control
	filename = "atmoscontrol"
	filedesc = "Atmosphere Control"
	nanomodule_path = /datum/nano_module/atmos_control
	program_icon_state = "atmos_control"
	program_key_state = "atmos_key"
	program_menu_icon = "shuffle"
	program_light_color = "#0099FF"
	extended_desc = "This program allows remote control of air alarms. This program can not be run on tablet computers."
	required_access = access_atmospherics
	requires_ntnet = 1
	network_destination = "atmospheric control system"
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	usage_flags = PROGRAM_LAPTOP | PROGRAM_CONSOLE
	size = 17
	category = PROG_ENG

/datum/nano_module/atmos_control
	name = "Atmospherics Control"
	var/obj/access = new()
	var/emagged = 0
	var/ui_ref
	var/list/monitored_alarms = list()

/datum/nano_module/atmos_control/New(atmos_computer, list/req_access, list/req_one_access, monitored_alarm_ids)
	..()

	access.req_access = req_access
	access.req_one_access = req_one_access

	if(monitored_alarm_ids)
		for(var/obj/machinery/alarm/alarm in GLOB.alarm_list)
			if(!(alarm.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
				continue
			if(alarm.alarm_id && (alarm.alarm_id in monitored_alarm_ids))
				monitored_alarms += alarm
		// machines may not yet be ordered at this point
		monitored_alarms = dd_sortedObjectList(monitored_alarms)

/datum/nano_module/atmos_control/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["alarm"])
		if(ui_ref)
			var/obj/machinery/alarm/alarm = locate(href_list["alarm"]) in (monitored_alarms.len ? monitored_alarms : GLOB.alarm_list)
			if(istype(alarm))
				var/datum/topic_state/air_alarm/state = generate_state(alarm)
				alarm.set_remote_tgui_session(usr, src, state)
				alarm.tgui_interact(usr)
		return 1

/datum/nano_module/atmos_control/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, master_ui = null, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()
	var/alarms[0]
	var/alarmsAlert[0]
	var/alarmsDanger[0]

	// TODO: Move these to a cache, similar to cameras
	for(var/obj/machinery/alarm/alarm in (monitored_alarms.len ? monitored_alarms : GLOB.alarm_list))
		var/Z = get_host_z()
		if ((!monitored_alarms.len) && (!Z || !AreConnectedZLevels(Z, alarm.z)))
			continue
		var/danger_level = max(alarm.danger_level, alarm.alarm_area.atmosalm)
		if(danger_level == 2)
			alarmsAlert[++alarmsAlert.len] = list("name" = sanitize(alarm.name), "ref"= "\ref[alarm]", "danger" = danger_level)
		else if(danger_level == 1)
			alarmsDanger[++alarmsDanger.len] = list("name" = sanitize(alarm.name), "ref"= "\ref[alarm]", "danger" = danger_level)
		else
			alarms[++alarms.len] = list("name" = sanitize(alarm.name), "ref"= "\ref[alarm]", "danger" = danger_level)

	data["alarms"] = sortByKey(alarms, "name")
	data["alarmsAlert"] = sortByKey(alarmsAlert, "name")
	data["alarmsDanger"] = sortByKey(alarmsDanger, "name")

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_control.tmpl", src.name, 625, 625, state = state)
		if(host.update_layout()) // This is necessary to ensure the status bar remains updated along with rest of the UI.
			ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
	ui_ref = ui

/datum/nano_module/atmos_control/proc/generate_state(air_alarm)
	var/datum/topic_state/air_alarm/state = new()
	state.atmos_control = src
	state.air_alarm = air_alarm
	return state

/datum/topic_state/air_alarm
	var/datum/nano_module/atmos_control/atmos_control	= null
	var/obj/machinery/alarm/air_alarm					= null

/datum/topic_state/air_alarm/can_use_topic(src_object, mob/user)
	if(!atmos_control)
		return STATUS_CLOSE

	var/controller_status = atmos_control.CanUseTopic(user)
	if(controller_status <= STATUS_CLOSE)
		return controller_status

	var/access_status = has_access(user) ? STATUS_INTERACTIVE : STATUS_UPDATE
	return min(controller_status, access_status)

/datum/topic_state/air_alarm/href_list(mob/user)
	var/list/extra_href = list()
	extra_href["remote_connection"] = 1
	extra_href["remote_access"] = has_access(user)

	return extra_href

/datum/topic_state/air_alarm/proc/has_access(mob/user)
	if(!user || !air_alarm || !atmos_control)
		return FALSE

	if(atmos_control.emagged)
		return TRUE

	// Remote control follows the alarm's computed remote state.
	// This keeps remote UI interactivity aligned with rcon_setting + alarm danger logic.
	if(!air_alarm.remote_control)
		return FALSE

	return isAI(user) || atmos_control.access.check_access(user)
