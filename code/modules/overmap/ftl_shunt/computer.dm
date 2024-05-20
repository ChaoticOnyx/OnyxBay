/obj/machinery/computer/ship
	var/obj/structure/overmap/linked

/obj/machinery/computer/ship/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/LateInitialize()
	has_overmap()

/obj/machinery/computer/ship/proc/has_overmap()
	linked = get_overmap()
	if(linked)
		set_position(linked)

	return linked

/obj/machinery/computer/ship/proc/set_position()
	pass()
