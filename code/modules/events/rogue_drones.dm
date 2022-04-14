/datum/event/rogue_drone
	endWhen = 1000
	var/list/drones_list = list()

/datum/event/rogue_drone/start()
	//spawn them at the same place as carp
	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/C in GLOB.landmarks_list)
		if(C.name == "Drone Swarm")
			possible_spawns.Add(C)

	//25% chance for this to be a false alarm
	var/num = 0
	if(length(possible_spawns) && prob(75))
		num = rand(2, 6)

	for(var/i=0, i<num, i++)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(D)
		if(prob(25))
			D.disabled = rand(15, 60)

/datum/event/rogue_drone/announce()
	var/msg
	if(prob(33))
		msg = TR_DATA(L10N_ANNOUNCE_ROGUE_DRONE_01, null, list("location_name" = location_name()))
	else if(prob(50))
		msg = TR_DATA(L10N_ANNOUNCE_ROGUE_DRONE_02, null, list("location_name" = location_name()))
	else
		msg = TR_DATA(L10N_ANNOUNCE_ROGUE_DRONE_03, null, list("location_name" = location_name()))

	command_announcement.AnnounceLocalizeable(
		msg,
		TR_DATA(L10N_ANNOUNCE_ROGUE_DRONE_TITLE, null, list("location_name" = location_name())),
		zlevels = affecting_z
	)

/datum/event/rogue_drone/end()
	for(var/mob/living/simple_animal/hostile/retaliate/malf_drone/D in drones_list)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, D.loc)
		sparks.start()
		D.z = GLOB.using_map.admin_levels[1]
		D.has_loot = 0

		qdel(D)

	command_announcement.AnnounceLocalizeable(
		TR_DATA(L10N_ANNOUNCE_ROGUE_DRONE_END, null, list("location_name" = location_name())),
		TR_DATA(L10N_ANNOUNCE_ROGUE_DRONE_TITLE, null, list("location_name" = location_name())),
		zlevels = affecting_z
	)
