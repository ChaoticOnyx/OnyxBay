/obj/map_ent/logic_once
	name = "logic_once"
	icon_state = "logic_once"

	var/ev_tag

/obj/map_ent/logic_once/activate()
	var/obj/map_ent/E = locate(ev_tag)

	if(!istype(E))
		crash_with("ev_tag is invalid")
		return
	
	E.activate()
	qdel(src)
