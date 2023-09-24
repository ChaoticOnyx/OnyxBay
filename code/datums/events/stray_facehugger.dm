/datum/event/stray_facehugger
	id = "stray_facehugger"
	name = "Stray Facehugger"
	description = "Facehugger will appear somewhere in the technical rooms"

	mtth = 3 HOURS
	difficulty = 60
	fire_only_once = TRUE

/datum/event/stray_facehugger/check_conditions()
	. = config.misc.aliens_allowed

/datum/event/stray_facehugger/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Security"] * (20 MINUTES))
	. = max(1 HOUR, .)

/datum/event/stray_facehugger/on_fire()
	var/turf/T = pick_subarea_turf(/area/maintenance, list(/proc/is_station_turf), /proc/not_turf_contains_dense_objects)

	if(!T)
		log_debug("Facehugger event failed to find a proper spawn point. Aborting.")
		return

	spawn()
		log_and_message_admins("Stray facehugger spawned in \the [T.loc]")
		new /mob/living/simple_animal/hostile/facehugger(T)
