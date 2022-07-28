/obj/map_ent/func_teleport
	name = "func_teleport"
	icon_state = "func_teleport"

	var/ev_tag
	var/ev_dest_tag

/obj/map_ent/func_teleport/activate()
	var/atom/movable/M = locate(ev_tag)

	if(!istype(M))
		crash_with("ev_tag is invalid")
		return
	
	var/atom/A = locate(ev_dest_tag)

	if(!istype(A))
		crash_with("ev_dest_tag is invalid")
		return
	
	M.forceMove(get_turf(A))
