/datum/antagonist/proc/get_starting_locations()
	if(landmark_id)
		starting_locations = list()
		for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
			if(sloc.name == landmark_id)
				starting_locations |= get_turf(sloc)

/datum/antagonist/proc/announce_antagonist_spawn()

	if(spawn_announcement)
		if(announced)
			return
		announced = 1
		spawn(0)
			if(spawn_announcement_delay)
				sleep(spawn_announcement_delay)
			SSannounce.play_station_announce(spawn_announcement)
	return

/datum/antagonist/proc/place_mob(mob/living/mob)
	if(!starting_locations || !starting_locations.len)
		return
	var/turf/T = pick_mobless_turf_if_exists(starting_locations)
	mob.forceMove(T)
