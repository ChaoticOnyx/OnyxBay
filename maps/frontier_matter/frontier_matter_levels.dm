/datum/space_level/frontier_matter_1
	path = 'frontier_matter-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10

/datum/space_level/frontier_matter_1/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 300, 300)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 300, 300)
