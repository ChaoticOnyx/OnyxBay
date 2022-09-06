/obj/map_ent/func_sfx
	name = "func_sfx"
	icon_state = "func_sfx"

	var/ev_sound
	var/ev_volume = 30
	var/ev_vary = FALSE
	var/ev_extrarange = 0
	var/ev_falloff = 3
	var/ev_global = FALSE

/obj/map_ent/func_sfx/activate()
	playsound(
		get_turf(src),
		ev_sound,
		ev_volume,
		ev_vary,
		ev_extrarange,
		ev_falloff,
		ev_global
	)
