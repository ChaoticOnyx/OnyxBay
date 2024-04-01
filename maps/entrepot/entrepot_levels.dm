/datum/space_level/entrepot_1
	path = 'entrepot-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10

/datum/space_level/entrepot_1/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 200, 200)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 200, 200)

/datum/space_level/entrepot_2
	path = 'entrepot-2.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10

/datum/space_level/entrepot_2/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 200, 200)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 200, 200)

/datum/space_level/entrepot_3
	path = 'entrepot-3.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
