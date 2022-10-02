/obj/map_ent/info_counter
	name = "info_counter"
	icon_state = "info_counter"

	var/ev_value = 0
	var/ev_step = 1

/obj/map_ent/info_counter/activate()
	ev_value += ev_step
