/datum/build_mode/move_into
	name = "Move Into"
	icon_state = "buildmode7"

	var/atom/destination

/datum/build_mode/move_into/Destroy()
	ClearDestination()
	. = ..()

/datum/build_mode/move_into/Help()
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Click                  = Select destination</span>")
	to_chat(user, "<span class='notice'>Right Click on Movable Atom = Move target into destination</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/build_mode/move_into/OnClick(atom/movable/A, list/parameters)
	if(parameters["left"])
		SetDestination(A)
	if(parameters["right"])
		if(!destination)
			to_chat(user, "<span class='warning'>No target destination.</span>")
		else if(!ismovable(A))
			to_chat(user, "<span class='warning'>\The [A] must be of type /atom/movable.</span>")
		else
			to_chat(user, "<span class='notice'>Moved \the [A] into \the [destination].</span>")
			Log("Moved '[log_info_line(A)]' into '[log_info_line(destination)]'.")
			A.forceMove(destination)

/datum/build_mode/move_into/proc/SetDestination(atom/A)
	if(A == destination)
		return
	ClearDestination()

	destination = A
	
	register_signal(destination, SIGNAL_QDELETING, /datum/build_mode/move_into/proc/ClearDestination)
	to_chat(user, "<span class='notice'>Will now move targets into \the [destination].</span>")

/datum/build_mode/move_into/proc/ClearDestination(feedback)
	if(!destination)
		return

	unregister_signal(destination, SIGNAL_QDELETING)
	destination = null
	if(feedback)
		Warn("The selected destination was deleted.")
