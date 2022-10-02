/obj/map_ent/func_sparks
	name = "func_sparks"
	icon_state = "func_sparks"

	var/ev_count = 3
	var/ev_cardinal = FALSE

/obj/map_ent/func_sparks/activate()
	var/datum/effect/effect/system/spark_spread/spark = new()
	spark.set_up(ev_count, ev_cardinal, get_turf(src))
	spark.start()
