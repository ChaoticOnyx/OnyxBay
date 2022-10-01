/obj/map_ent/func_light
	name = "func_light"
	icon_state = "func_light"

	var/ev_max_bright = 1
	var/ev_inner_range = 0.5
	var/ev_outer_range = 1.5
	var/ev_falloff_curve = 2
	var/ev_color = COLOR_RED
	var/_toggled = FALSE

/obj/map_ent/func_light/activate()
	_toggled = !_toggled
	var/turf/T = get_turf(src)

	if(_toggled)
		T.set_light(ev_max_bright, ev_inner_range, ev_outer_range, ev_falloff_curve, ev_color)
	else
		T.set_light(0)
