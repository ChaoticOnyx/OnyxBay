/obj/map_ent/func_gib
	name = "func_gib"
	icon_state = "func_gib"

	var/ev_tag

/obj/map_ent/func_gib/activate()
	var/mob/M = locate(ev_tag)

	if(!istype(M))
		crash_with("ev_tag is null or contains invalid object: `[ev_tag]`")
		return
	
	M.gib()
