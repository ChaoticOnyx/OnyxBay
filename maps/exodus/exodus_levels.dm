/datum/space_level/exodus_1
	path = 'exodus-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/exodus_2
	path = 'exodus-2.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/exodus_5
	path = 'exodus-5.dmm'
	travel_chance = 10
	traits = list(
		ZTRAIT_CONTACT
	)

/datum/space_level/exodus_5/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/exodus_6
	path = 'exodus-6.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
