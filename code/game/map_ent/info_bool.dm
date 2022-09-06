/obj/map_ent/info_bool
	name = "info_bool"
	icon_state = "info_bool"

	var/ev_value = FALSE

/obj/map_ent/info_bool/activate()
	ev_value = !ev_value
