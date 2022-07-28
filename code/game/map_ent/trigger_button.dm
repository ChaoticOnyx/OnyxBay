/obj/map_ent/trigger_button
	name = "trigger_button"
	icon_state = "trigger_button"

	var/ev_button_tag
	var/ev_tag
	var/ev_triggered
	var/ev_enabled = TRUE

	var/weakref/_button

/obj/map_ent/trigger_button/Initialize(mapload)
	. = ..()
	
	var/obj/machinery/button/B
	if(!ev_button_tag)
		B = locate(/obj/machinery/button) in get_turf(src)

		if(!istype(B))
			crash_with("button not found")
			return INITIALIZE_HINT_QDEL
	else
		B = locate(ev_button_tag)
		if(!istype(B))
			crash_with("ev_button_tag is invalid")
			return INITIALIZE_HINT_QDEL

	_button = weakref(B)
	register_signal(B, SIGNAL_BUTTON_ACTIVATED, .proc/_on_button_activate)

/obj/map_ent/trigger_button/Destroy()
	var/obj/machinery/button/B = _button.resolve()
	unregister_signal(B, SIGNAL_BUTTON_ACTIVATED)

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
