/datum/space_level/frontier_SCP_1
	path = 'frontier-SCP-1.dmm'
	travel_chance = 10
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)

/datum/space_level/frontier_SCP_1/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 300, 300)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 300, 300)

/datum/space_level/frontier_SCP_2
	path = 'frontier-SCP-2.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT
	)
