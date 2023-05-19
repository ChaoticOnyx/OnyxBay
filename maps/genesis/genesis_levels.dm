/datum/space_level/genesis_1
	path = 'genesis-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 15

/datum/space_level/genesis_2
	path = 'genesis-2.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/genesis_3
	path = 'genesis-3.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_SEALED,
		ZTRAIT_CONTACT
	)

/datum/space_level/genesis_4
	path = 'genesis-4.dmm'
	travel_chance = 15
	traits = list(
		ZTRAIT_CONTACT
	)

/datum/space_level/genesis_4/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)
