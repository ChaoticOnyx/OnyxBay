/datum/space_level/elpaso_1
	path = 'elpaso_1.dmm'
	travel_chance = 5
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
/datum/space_level/elpaso_1/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system/air(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 150, 150)

/datum/space_level/elpaso_2
	path = 'elpaso_2.dmm'
	travel_chance = 5
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)

/datum/space_level/elpaso_2/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system/air(null, 1, 1, z, 150, 150)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 150, 150)

/datum/space_level/elpaso_3
	path = 'elpaso_3.dmm'
	travel_chance = 5
	traits = list(
		ZTRAIT_CONTACT
	)

/datum/space_level/elpaso_4
	path = 'elpaso_4.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
