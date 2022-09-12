/datum/event/biohazard_outbreak
	id = "biohazard_outbreak"
	name = "Biohazard Outbreak"
	description = "A blob appears at a random place at the station"

	mtth = 3 HOURS
	fire_only_once = TRUE

/datum/event/biohazard_outbreak/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (5 MINUTES))
	. = max(1 HOUR, .)

/datum/event/biohazard_outbreak/on_fire()
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

	addtimer(CALLBACK(null, /proc/level_seven_announcement), 30 SECONDS)
