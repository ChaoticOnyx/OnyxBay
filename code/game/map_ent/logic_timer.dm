/obj/map_ent/logic_timer
	name = "logic_timer"
	icon_state = "logic_timer"

	ev_activate_at_startup = TRUE

	var/ev_tag
	var/ev_wait
	var/ev_once = FALSE
	var/ev_enabled = FALSE

/obj/map_ent/logic_timer/proc/_add_timer()
	if(!ev_enabled)
		return

	if(ev_wait <= 0)
		crash_with("ev_wait should be greather than zero")

	addtimer(CALLBACK(src, .proc/_timer_callback), ev_wait, TIMER_OVERRIDE | TIMER_UNIQUE)

	if(ev_once)
		ev_enabled = FALSE

/obj/map_ent/logic_timer/activate()
	ev_enabled = !ev_enabled
	_add_timer()

/obj/map_ent/logic_timer/proc/_timer_callback()
	var/obj/map_ent/E = locate(ev_tag)

	if(!istype(E))
		crash_with("ev_tag is invalid")
		return

	E.activate()
	_add_timer()
