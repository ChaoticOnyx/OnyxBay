/datum/space_level/sunset_1
	path = 'sunset-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10

/datum/space_level/sunset_1/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 200, 200)
	new /datum/random_map/noise/ore(null, 1, 1, z, 64, 64)

/datum/space_level/sunset_2
	path = 'sunset-2.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10

/datum/space_level/sunset_3
	path = 'sunset-3.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10

/datum/space_level/sunset_4
	path = 'sunset-4.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
