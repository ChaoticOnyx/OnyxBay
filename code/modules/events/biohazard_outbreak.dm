/datum/event/biohazard_outbreak
	announceWhen = 30

/datum/event/biohazard_outbreak/start()
	var/counts = 0
	var/turf/T = null
	pick_subarea_turf(/area/maintenance, list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))

	while(!T || counts < 5)
		counts++
		T = pick_subarea_turf(/area/maintenance, list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))

	if(!T)
		log_and_message_admins("Blob didn't found a space for spawning.")
		return

	new /obj/structure/blob/core(T.loc)
	log_and_message_admins("Blob spawned in \the [get_area(T)]", location = T.loc)

/datum/event/biohazard_outbreak/announce()
	level_seven_announcement()
