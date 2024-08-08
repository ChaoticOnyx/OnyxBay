/datum/space_level/polar_1
	path = 'polar-1.dmm'
	travel_chance = 5
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	exterior_atmosphere = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	exterior_atmos_temp = -30 CELSIUS

/datum/space_level/polar_1/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system/frozen(null, 1, 1, z, 300, 300)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 300, 300)

/datum/space_level/polar_2
	path = 'polar-2.dmm'
	travel_chance = 5
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	exterior_atmosphere = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	exterior_atmos_temp = -30 CELSIUS

/datum/space_level/polar_2/generate(z)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 300, 300)

/datum/space_level/polar_3
	path = 'polar-3.dmm'
	travel_chance = 10
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT,
	)
	exterior_atmosphere = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	exterior_atmos_temp = -30 CELSIUS

/datum/space_level/polar_4
	path = 'polar-4.dmm'
	travel_chance = 15
	traits = list(
		ZTRAIT_CONTACT,
	)
	exterior_atmosphere = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	exterior_atmos_temp = -30 CELSIUS

/datum/space_level/polar_5
	path = 'polar-5.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
