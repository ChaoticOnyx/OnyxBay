/datum/antagonist/proc/get_starting_locations()
	if(landmark_id)
		starting_locations = list()
		for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
			if(sloc.name == landmark_id)
				starting_locations |= get_turf(sloc)

/datum/antagonist/proc/announce_antagonist_spawn()
	if(spawn_announcement_l)
		if(announced)
			return
		announced = 1
		spawn(0)
			if(spawn_announcement_delay)
				sleep(spawn_announcement_delay)
			if(spawn_announcement_sound)
				command_announcement.AnnounceLocalizeable(
					TR_DATA(spawn_announcement_l, null, list("station_name" = station_name())),
					TR_DATA(spawn_announcement_title_l ? spawn_announcement_title_l : L10N_ANNOUNCE_PRIORITY_ALERT, null, null),
					new_sound = spawn_announcement_sound
				)
			else
				command_announcement.AnnounceLocalizeable(
					TR_DATA(spawn_announcement_l, null, list("station_name" = station_name())),
					TR_DATA(spawn_announcement_title_l ? spawn_announcement_title_l : L10N_ANNOUNCE_PRIORITY_ALERT, null, null)
				)

	return

/datum/antagonist/proc/place_mob(mob/living/mob)
	if(!starting_locations || !starting_locations.len)
		return
	var/turf/T = pick_mobless_turf_if_exists(starting_locations)
	mob.forceMove(T)
