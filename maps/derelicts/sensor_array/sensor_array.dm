/datum/space_level/sensor_array
	path = 'sensor_array.dmm'
	travel_chance = 5

/area/sensor_array
	name = "Sensor Array"
	icon_state = "sensor_array"

	requires_power = TRUE
	always_unpowered = FALSE

	ambient_music_tags = list(MUSIC_TAG_SPACE, MUSIC_TAG_MYSTIC)

/area/sensor_array/security_checkpoint
	name = "Sensor Array - Security Checkpoint"
	icon_state = "sensor_array_security_checkpoint"

/area/sensor_array/security_storage
	name = "Sensor Array - Security Storage"
	icon_state = "sensor_array_security_storage"

/area/sensor_array/security_holding_cell
	name = "Sensor Array - Security Holding Cell"
	icon_state = "sensor_array_security_holding_cell"

/area/turret_protected/sensor_array_foyer
	name = "Sensor Array - Foyer"
	icon_state = "sensor_array_foyer"

	ambient_music_tags = list(MUSIC_TAG_SPACE, MUSIC_TAG_MYSTIC)

/area/sensor_array/comms
	name = "Sensor Array - Communications"
	icon_state = "sensor_array_communications"

/area/sensor_array/restroom
	name = "Sensor Array - Restroom"
	icon_state = "sensor_array_restroom"

/area/sensor_array/bedroom
	name = "Sensor Array - Bedroom"
	icon_state = "sensor_array_bedroom"

/area/sensor_array/maintenance
	name = "Sensor Array - Maintenance"
	icon_state = "sensor_array_maintenance"

/area/sensor_array/solars
	name = "Sensor Array - Solars"
	icon_state = "sensor_array_solars"

/area/sensor_array/tech_storage
	name = "Sensor Array - Tech Storage"
	icon_state = "sensor_array_tech_storage"

/obj/machinery/computer/sensor_array
	var/used = FALSE
	var/servers = list()

	var/title = ""
	var/crash_report_time = 0
	var/hello_text = ""

/obj/machinery/computer/sensor_array/Initialize()
	. = ..()
	
	title = "Sensor Array - \"<em>Oerlikon</em>\" serial no. [rand(1, 1000)]"
	hello_text += "<h3>Welcome, [random_name(pick(list(FEMALE, MALE)))]!</h3>"
	hello_text += "<em>You are was inactive for [rand(60, 300)] days.</em><br><br>"
	crash_report_time = rand(120, 600)

	for(var/obj/machinery/telecomms/server/S in world)
		servers += S

/obj/machinery/computer/sensor_array/proc/_get_comm_logs()
	var/list/logs = list()

	for(var/obj/machinery/telecomms/server/S in servers)
		if(!length(S.log_entries))
			continue

		for(var/i = max(1, length(S.log_entries) - 10); i <= length(S.log_entries); i++)
			if(length(logs) >= 60)
				return logs
			
			var/datum/comm_log_entry/E = S.log_entries[i]
			var/sender = E.parameters["realname"] || E.parameters["name"]
			var/msg = E.parameters["message"]

			if(!length(msg) || !length(sender))
				continue
			
			logs += "[sender]: [msg]"

	return logs

/obj/machinery/computer/sensor_array/proc/_get_content()
	var/content = ""
	
	if(emagged)
		content += "<h2>PWNED by \"__S33nD1cK@__\"</h2>"
		content += "<em>THE NAN07RAS3N 1S <strike>WATCHING</strike> HEARING YOU</em><br><br>"
		content += "<a href='?src=\ref[src];show_interceptions=1'>HERE 1S YOUR SWEET SECRETS</a>"
	else if(!used)
		content += hello_text
		content += "<a href='?src=\ref[src];show_interceptions=1'>Print Intercepted Communications</a><br>"
		content += "<a href='?src=\ref[src];logout=1'>Logout</a>"
	else
		content += "<h2>Unexpected exception raised: \"Undefined procedure: `logout`\":</h2>"
		content += "<code>SET ENVIRONMENT VARIABLE 'NT_TRACER=1' TO SHOW STACKTRACE</code><br><br>"
		content += "<em>Crash report was send to an IT department in the nearest star system. Estimated time to response: [crash_report_time] years. Please, standby.</em>"

	return content

/obj/machinery/computer/sensor_array/Topic(href, href_list, datum/topic_state/state)
	if(..())
		return TRUE
	
	if(isghost(usr))
		return TRUE
	
	if(stat & (BROKEN|NOPOWER))
		return TRUE

	if(href_list["logout"])
		used = TRUE
		playsound(src, 'sound/signals/error2.ogg', 50, FALSE)

		return TRUE
	if(href_list["show_interceptions"])
		if(used && !emagged)
			playsound(src, 'sound/signals/error2.ogg', 50, FALSE)
			return TRUE
		
		used = TRUE

		var/obj/item/paper/P = new(get_turf(src))
		var/text = "<code>"

		for(var/line in _get_comm_logs())
			text += "[line]<br>"
		
		text += "</code>"

		P.info = text
		P.SetName("communications report")

		return TRUE

	return FALSE

/obj/machinery/computer/sensor_array/emag_act(remaining_charges, mob/user, emag_source)
	if(emagged)
		return 0
	
	if (do_after(user, 6, src))
		playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
		emagged = TRUE
		to_chat(user, SPAN("notice", "You emag \the [src]."))

		return 1

	return 0

/obj/machinery/computer/sensor_array/attack_hand(mob/user)
	..()
	
	if(stat & (BROKEN|NOPOWER))
		return

	var/datum/browser/popup = new(user, "sensor_array", title, 700, 500, src)
	popup.set_content(_get_content())
	popup.open()
