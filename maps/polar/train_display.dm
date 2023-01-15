/obj/machinery/status_display/train_display
	mode = STATUS_DISPLAY_CUSTOM

/obj/machinery/status_display/train_display
	ignore_friendc = 1

/obj/machinery/status_display/train_display/update()
	if(..())
		return TRUE

	message1 = "TRAIN"
	message2 = ""

	var/datum/shuttle/autodock/ferry/train/T

	for(var/name in SSshuttle.shuttles)
		var/datum/shuttle/autodock/ferry/train/train = SSshuttle.shuttles[name]

		if(istype(train))
			T = train
			break

	if(!T)
		message2 = "Error"
		update_display(message1, message2)
		return TRUE

	if(T.has_arrive_time())
		message2 = get_shuttle_timer(T)
		if(length(message2) > CHARS_PER_LINE)
			message2 = "Error"
	else if(T.is_launching())
		message2 = "Launch"
	else
		if(!T.location)
			message2 = "Pathos"
		else
			message2 = "LZ"

	update_display(message1, message2)

	return TRUE
