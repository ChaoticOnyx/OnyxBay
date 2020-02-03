/datum/event/borer_infection
	announceWhen	= 0
	var/num_borers = 1

	var/list/spawned_borers = list()

/datum/event/borer_infection/setup()
	announceWhen = rand(40, 100)

/datum/event/borer_infection/announce()
	var/announcement = ""
	if(severity == EVENT_LEVEL_MAJOR)
		announcement = "Unknown biological entities has been detected near the [location_name()], please stand-by."
	else
		announcement = "Unknown biological [spawned_borers.len == 1 ? "entity has" : "entities have"] been detected near the [location_name()], please stand-by."
	command_announcement.Announce(announcement, "[location_name()] Sensor Array", zlevels = affecting_z)

/datum/event/borer_infection/start()
	if(severity == EVENT_LEVEL_MAJOR)
		spawn_borer(landmarks_list.len)
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_borer(rand(1, landmarks_list.len))

/datum/event/borer_infection/proc/spawn_borer()
	var/list/spawn_locations = list()

	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "borerspawn")
			spawn_locations.Add(C.loc)
	spawn_locations = shuffle(spawn_locations)

	var/i = 1
	while (i <= num_borers)
		for (var/j in 1 to num_borers)
			spawned_borers.Add(new /mob/living/simple_animal/borer(spawn_locations[i]))
		i++

