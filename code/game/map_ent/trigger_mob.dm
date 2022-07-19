/obj/map_ent/trigger_mob
	name = "trigger_mob"
	icon_state = "trigger_mob"

	var/ev_tag
	var/ev_with_client = TRUE
	var/ev_ignore_ghosts = TRUE
	var/ev_triggered
	var/ev_enabled = TRUE

/obj/map_ent/trigger_mob/Initialize()
	. = ..()

	var/turf/T = get_turf(src)
	register_signal(T, SIGNAL_ENTERED, .proc/_on_enter)

/obj/map_ent/trigger_mob/Destroy()
	var/turf/T = get_turf(src)
	unregister_signal(T, SIGNAL_ENTERED)
	
	. = ..()

/obj/map_ent/trigger_mob/proc/_on_enter(turf/T, mob/M)
	if(!ev_enabled)
		return

	if(!istype(M))
		return

	if(isghost(M) && ev_ignore_ghosts)
		return
	
	if(ev_with_client && !M.client)
		return

	ev_triggered = "\ref[M]"

	var/obj/map_ent/E = locate(ev_tag)
	
	if(!istype(E))
		crash_with("ev_tag is invalid")
		return

	E.activate()
