
/datum/event/stray_facehugger
	endWhen = 1

/datum/event/stray_facehugger/start()
	var/turf/T = pick_subarea_turf(/area/maintenance, list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))

	if(!T)
		log_debug("Facehugger event failed to find a proper spawn point. Aborting.")
		kill()

	spawn()
		log_and_message_admins("Stray facehugger spawned in \the [T.loc]")
		new /mob/living/simple_animal/hostile/facehugger(T)
