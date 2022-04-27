/datum/event/carp_migration
	announceWhen	= 50
	endWhen 		= 900

	var/list/spawned_carp = list()

/datum/event/carp_migration/setup()
	announceWhen = rand(40, 60)
	endWhen = rand(600,1200)

/datum/event/carp_migration/announce()
	var/announcement = ""
	if(severity == EVENT_LEVEL_MAJOR)
		announcement = "Massive migration of unknown biological entities has been detected near the [location_name()], please stand-by."
	else
		announcement = "Unknown biological [spawned_carp.len == 1 ? "entity has" : "entities have"] been detected near the [location_name()], please stand-by."
	command_announcement.Announce(announcement, "[location_name()] Sensor Array", zlevels = affecting_z)

/datum/event/carp_migration/start()
	if(severity == EVENT_LEVEL_MAJOR)
		spawn_fish(length(GLOB.landmarks_list))
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_fish(rand(4, 6)) 			//12 to 30 carp, in small groups
	else
		spawn_fish(rand(1, 3), 1, 2)	//1 to 6 carp, alone or in pairs

/datum/event/carp_migration/proc/spawn_fish(num_groups, group_size_min=3, group_size_max=5)
	var/list/spawn_locations = list()

	for(var/obj/effect/landmark/C in GLOB.landmarks_list)
		if(C.name == "Carp Pack")
			spawn_locations.Add(C.loc)
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, spawn_locations.len)

	var/i = 1
	while (i <= num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		if(prob(96))
			for(var/j = 1, j <= group_size, j++)
				var/mob/living/simple_animal/hostile/carp/C = new(spawn_locations[i])
				spawned_carp.Add(weakref(C))
			i++
		else
			group_size = max(1,round(group_size/6))
			group_size = min(spawn_locations.len-i+1,group_size)
			for(var/j = 1, j <= group_size, j++)
				var/mob/living/simple_animal/hostile/carp/pike/P = new(spawn_locations[i+j])
				spawned_carp.Add(weakref(P))
			i += group_size

/datum/event/carp_migration/end()
	for(var/weakref/thing in spawned_carp)
		var/mob/living/simple_animal/hostile/C = thing.resolve()
		if(!C?.stat)
			var/turf/T = get_turf(C)
			if(istype(T, /turf/space))
				qdel(C)
