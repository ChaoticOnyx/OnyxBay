/datum/build_mode/move_into
	name = "Move Into"
	icon_state = "buildmode7"

	var/atom/destination

/datum/build_mode/move_into/Destroy()
	ClearDestination()
	. = ..()

/datum/build_mode/move_into/Help()
	to_chat(user, "<span class='notice'>***********************************************************</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>Left Click                  = Select destination</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>Right Click on Movable Atom = Move target into destination</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>***********************************************************</span>", confidential = TRUE)

/datum/build_mode/move_into/OnClick(atom/movable/A, list/parameters)
	if(parameters["left"])
		SetDestination(A)
	if(parameters["right"])
		if(!destination)
			to_chat(user, "<span class='warning'>No target destination.</span>", confidential = TRUE)
		else if(!ismovable(A))
			to_chat(user, "<span class='warning'>\The [A] must be of type /atom/movable.</span>", confidential = TRUE)
		else
			to_chat(user, "<span class='notice'>Moved \the [A] into \the [destination].</span>", confidential = TRUE)
			Log("Moved '[log_info_line(A)]' into '[log_info_line(destination)]'.")
			A.forceMove(destination)

/datum/build_mode/move_into/proc/SetDestination(atom/A)
	if(A == destination)
		return
	ClearDestination()

	destination = A
	GLOB.destroyed_event.register(destination, src, /datum/build_mode/move_into/proc/ClearDestination)
	to_chat(user, "<span class='notice'>Will now move targets into \the [destination].</span>", confidential = TRUE)

/datum/build_mode/move_into/proc/ClearDestination(feedback)
	if(!destination)
		return

	GLOB.destroyed_event.unregister(destination, src, /datum/build_mode/move_into/proc/ClearDestination)
	destination = null
	if(feedback)
		Warn("The selected destination was deleted.")
