/datum/space_level/eclipse_1
	path = 'eclipse-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/eclipse_1/generate(z)
	// Create the mining caves.
	new /datum/random_map/automata/cave_system/prison(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/eclipse_3
	path = 'eclipse-3.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)

/datum/space_level/eclipse_6
	path = 'eclipse-6.dmm'
	travel_chance = 10
	traits = list(
		ZTRAIT_CONTACT
	)

/datum/space_level/eclipse_6/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	new /datum/random_map/automata/cave_system/air(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)
