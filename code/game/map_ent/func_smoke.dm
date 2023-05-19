/obj/map_ent/func_smoke
	name = "func_smoke"
	icon_state = "func_smoke"

	var/ev_count = 3
	var/ev_cardinal = FALSE
	var/ev_direction = SOUTH

/obj/map_ent/func_smoke/activate()
	var/datum/effect/effect/system/smoke_spread/smoke = new()
	smoke.set_up(ev_count, ev_cardinal, get_turf(src), ev_direction)
	smoke.start()
