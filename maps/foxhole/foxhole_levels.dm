/datum/space_level/foxhole_1
	path = 'foxhole-1.dmm'
	travel_chance = 5
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)

/datum/space_level/foxhole_1/generate(z)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/foxhole_2
	path = 'foxhole-2.dmm'
	travel_chance = 5
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)

/datum/space_level/foxhole_2/generate(z)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/foxhole_3
	path = 'foxhole-3.dmm'
	travel_chance = 10
	traits = list(
		ZTRAIT_CONTACT
	)

/datum/space_level/foxhole_3/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	new /datum/random_map/automata/cave_system/air(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/foxhole_4
	path = 'foxhole-4.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
