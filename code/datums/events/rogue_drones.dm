/datum/event/rogue_drones
	id = "rogue_drones"
	name = "Rogue Drones"
	description = "A group of hostile drones will fly into the area of the station"

	mtth = 2 HOURS
	difficulty = 60


	var/list/drones_list = list()
	var/list/affecting_z = list()

/datum/event/rogue_drones/New()
	. = ..()

	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

/datum/event/rogue_drones/get_conditions_description()
	. = "<em>Rogue Drones</em> should not be <em>running</em>.<br>"

/datum/event/rogue_drones/check_conditions()
	. = SSevents.evars["rogue_drones_running"] != TRUE

/datum/event/rogue_drones/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Security"] * (13 MINUTES))
	. = max(1 HOUR, .)

/datum/event/rogue_drones/on_fire()
	SSevents.evars["rogue_drones_running"] = TRUE
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	spawn_drones()
	announce()

	set_next_think_ctx("end", world.time + (10 MINUTES))

/datum/event/rogue_drones/proc/spawn_drones()
	// Spawn them at the same place as carp
	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/C in GLOB.landmarks_list)
		if(C.name == "Drone Swarm")
			possible_spawns.Add(C)

	// 25% chance for this to be a false alarm
	var/num = 0
	if(length(possible_spawns) && prob(75))
		num = rand(2, 6)

	for(var/i = 0, i < num, i++)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(weakref(D))

		if(prob(25))
			D.disabled = rand(15, 60)

/datum/event/rogue_drones/proc/announce()
	var/msg
	if(prob(33))
		msg = "Attention: unidentified patrol drones detected within proximity to the [station_name()]"
	else if(prob(50))
		msg = "Unidentified Unmanned Drones approaching the [station_name()]. All hands take notice."
	else
		msg = "Class II Laser Fire detected nearby the [station_name()]."

	SSannounce.play_station_announce(/datum/announce/rogue_drones_start, msg)

/datum/event/rogue_drones/proc/end()
	SSevents.evars["rogue_drones_running"] = FALSE
	for(var/weakref/thing in drones_list)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = thing.resolve()
		if(!istype(D))
			continue

		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, D.loc)
		sparks.start()
		D.z = GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)[1]
		D.has_loot = 0

		qdel(D)

	SSannounce.play_station_announce(/datum/announce/rogue_drones_end)
