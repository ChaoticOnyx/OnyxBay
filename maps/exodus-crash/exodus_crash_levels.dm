/datum/space_level/exodus_crash_1
	path = 'exodus_crash-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/exodus_crash_2
	path = 'exodus_crash-2.dmm'
	traits = list(
		ZTRAIT_CONTACT
	)
	travel_chance = 10

/datum/space_level/exodus_crash_2/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	new /datum/random_map/automata/cave_system/prison(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/exodus_crash_3
	path = 'exodus_crash-3.dmm'
	travel_chance = 10
	traits = list(
		ZTRAIT_CONTACT
	)

/datum/space_level/exodus_crash_3/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	new /datum/random_map/automata/cave_system/prison(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/exodus_crash_4
	path = 'exodus_crash-4.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
