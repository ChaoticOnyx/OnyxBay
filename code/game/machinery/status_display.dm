#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Small Fonts"
#define SCROLL_SPEED 2

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer
/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	layer = ABOVE_WINDOW_LAYER
	anchored = 1
	density = 0
	idle_power_usage = 10 WATTS
	var/mode = 1	// 0 = Blank
					// 1 = Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Supply shuttle timer

	var/picture_state = "blank" // icon_state of alert picture
	var/message1 = ""           // message line 1
	var/message2 = ""           // message line 2
	var/index1                  // display index for scrolling messages or 0 if non-scrolling
	var/index2
	var/image/picture = null
	var/static/icon/static_overlay = null
	var/static/mutable_appearance/ea_overlay = null

	var/frequency = 1435		// radio frequency

	var/friendc = 0      // track if Friend Computer mode
	var/ignore_friendc = 0

	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

	var/const/CHARS_PER_LINE = 8
	var/const/STATUS_DISPLAY_BLANK = 0
	var/const/STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME = 1
	var/const/STATUS_DISPLAY_MESSAGE = 2
	var/const/STATUS_DISPLAY_ALERT = 3
	var/const/STATUS_DISPLAY_TIME = 4
	var/const/STATUS_DISPLAY_IMAGE = 5
	var/const/STATUS_DISPLAY_CUSTOM = 99

	var/last_stat = 0

/obj/machinery/status_display/Destroy()
	GLOB.ai_status_display_list -= src
	SSradio.remove_object(src, frequency)
	ClearOverlays()
	QDEL_NULL(picture)
	return ..()

// register for radio system
/obj/machinery/status_display/Initialize()
	. = ..()
	GLOB.ai_status_display_list += src
	SSradio.add_object(src, frequency)

	if(!picture)
		picture = image('icons/obj/status_display.dmi', icon_state = "blank")
		picture.maptext_height = maptext_height
		picture.maptext_width = maptext_width
		picture.maptext_y = maptext_y

	if(!static_overlay)
		var/image/SO = image(icon, "static")
		SO.alpha = 64
		static_overlay = SO

	if(!ea_overlay)
		ea_overlay = emissive_appearance(icon, "outline")

// timed process
/obj/machinery/status_display/Process()
	if(stat & NOPOWER)
		last_stat = stat
		if(overlays.len)
			ClearOverlays()
		if(picture.maptext)
			picture.maptext = ""
		set_light(0)
		return
	if(stat == last_stat)
		update()
	else
		last_stat = stat
		update(TRUE)

/obj/machinery/status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

// set what is displayed
/obj/machinery/status_display/proc/update(force_update = FALSE)
	if(friendc && !ignore_friendc)
		set_picture("ai_friend")
		return 1

	switch(mode)
		if(STATUS_DISPLAY_BLANK)	//blank
			remove_display()
			return 1
		if(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)				//emergency shuttle timer
			if(evacuation_controller.is_prepared())
				message1 = "-ETD-"
				if (evacuation_controller.waiting_to_leave())
					message2 = "Launch"
				else
					message2 = get_evac_shuttle_timer()
					if(length(message2) > CHARS_PER_LINE)
						message2 = "Error"
				update_display(message1, message2, force_update)
			else if(evacuation_controller.has_eta())
				message1 = "-ETA-"
				message2 = get_evac_shuttle_timer()
				if(length(message2) > CHARS_PER_LINE)
					message2 = "Error"
				update_display(message1, message2, force_update)
			return 1
		if(STATUS_DISPLAY_MESSAGE)	//custom messages
			var/line1
			var/line2

			if(!index1)
				line1 = message1
			else
				line1 = copytext(message1+"|"+message1, index1, index1+CHARS_PER_LINE)
				var/message1_len = length(message1)
				index1 += SCROLL_SPEED
				if(index1 > message1_len)
					index1 -= message1_len

			if(!index2)
				line2 = message2
			else
				line2 = copytext(message2+"|"+message2, index2, index2+CHARS_PER_LINE)
				var/message2_len = length(message2)
				index2 += SCROLL_SPEED
				if(index2 > message2_len)
					index2 -= message2_len
			update_display(line1, line2, force_update)
			return 1
		if(STATUS_DISPLAY_ALERT)
			display_alert(force_update)
			return 1
		if(STATUS_DISPLAY_TIME)
			message1 = "TIME"
			message2 = stationtime2text()
			update_display(message1, message2, force_update)
			return 1
		if(STATUS_DISPLAY_IMAGE)
			set_picture(picture_state, force_update)
			return 1
	return 0

/obj/machinery/status_display/_examine_text(mob/user)
	. = ..()
	switch(mode)
		if(STATUS_DISPLAY_BLANK)
			return
		if(STATUS_DISPLAY_ALERT)
			var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
			. += "\nThe current alert level is [security_state.current_security_level.name]."
		if(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			. += "\nTime until the shuttle arives: [get_evac_shuttle_timer()]."
		if(STATUS_DISPLAY_IMAGE)
			. += "\nThere is a picture on the display."
		else
			. += "\nThe display says:<br>\t[sanitize(message1)]<br>\t[sanitize(message2)]"

/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length(m1) > CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length(m2) > CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

/obj/machinery/status_display/proc/display_alert(force_update = FALSE)
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	var/decl/security_level/sl = security_state.current_security_level

	set_picture(sl.overlay_status_display, force_update)
	set_light(sl.light_max_bright, sl.light_inner_range, sl.light_outer_range, 2, sl.light_color_alarm)

/obj/machinery/status_display/proc/set_picture(state, force_update = FALSE)
	if(state == "ai_off")
		remove_display()
		return

	if(picture_state != state || force_update)
		remove_display(force_update)
		picture_state = state
		picture.icon_state = "[picture_state]"

		AddOverlays(picture)
		AddOverlays(static_overlay)
		AddOverlays(ea_overlay)

		set_light(0.5, 0.1, 1, 2, COLOR_WHITE)

/obj/machinery/status_display/proc/update_display(line1, line2, force_update = FALSE)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(picture.maptext != new_text || force_update)
		remove_display(force_update)
		picture.icon_state = "blank"
		picture.maptext = new_text
		AddOverlays(picture)
		AddOverlays(static_overlay)
		AddOverlays(ea_overlay)
		set_light(0.5, 0.1, 1, 2, COLOR_WHITE)

/obj/machinery/status_display/proc/get_evac_shuttle_timer()
	var/timeleft = evacuation_controller.get_eta()
	if(timeleft < 0)
		return ""
	return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"

/obj/machinery/status_display/proc/get_shuttle_timer(datum/shuttle/autodock/ferry/supply/shuttle)
	if (!shuttle)
		return "Error"

	if(shuttle.has_arrive_time())
		var/timeleft = round((shuttle.arrive_time - world.time) / 10,1)
		if(timeleft < 0)
			return "Late"
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/status_display/proc/remove_display(update_light = TRUE)
	picture_state = ""
	ClearOverlays()
	if(picture.maptext)
		picture.maptext = ""
	if(update_light)
		set_light(0)

/obj/machinery/status_display/receive_signal(datum/signal/signal)
	switch(signal.data["command"])
		if("blank")
			mode = STATUS_DISPLAY_BLANK

		if("shuttle")
			mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME

		if("message")
			mode = STATUS_DISPLAY_MESSAGE
			set_message(signal.data["msg1"], signal.data["msg2"])

		if("alert")
			mode = STATUS_DISPLAY_ALERT

		if("time")
			mode = STATUS_DISPLAY_TIME

		if("image")
			mode = STATUS_DISPLAY_IMAGE
			set_picture(signal.data["picture_state"])
	update()

#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED
