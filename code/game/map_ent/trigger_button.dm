/obj/map_ent/trigger_button
	name = "trigger_button"
	icon_state = "trigger_button"

	var/ev_button_tag
	var/ev_tag
	var/ev_triggered
	var/ev_enabled = TRUE

	var/obj/machinery/button/_button

/obj/map_ent/trigger_button/Initialize(mapload)
	. = ..()
	
	if(!ev_button_tag)
		_button = locate(/obj/machinery/button) in get_turf(src)

		if(!istype(_button))
			crash_with("button not found")
			return INITIALIZE_HINT_QDEL
	else
		_button = locate(ev_button_tag)
		if(!istype(_button))
			crash_with("ev_button_tag is invalid")
			return INITIALIZE_HINT_QDEL

	register_signal(_button, SIGNAL_BUTTON_ACTIVATED, .proc/_on_button_activate)

/obj/map_ent/trigger_button/Destroy()
	unregister_signal(_button, SIGNAL_BUTTON_ACTIVATED)

	. = ..()

/obj/map_ent/trigger_button/proc/_on_button_activate(obj/machinery/button/B, mob/M)
	if(!ev_enabled)
		return

	var/obj/map_ent/E = locate(ev_tag)
	
	if(!istype(E))
		crash_with("ev_tag is invalid")
		return

	ev_triggered = "\ref[M]"
	E.activate()
