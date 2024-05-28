// Atmos types used for planetary airs
/datum/atmosphere/lavaland
	id = LAVALAND_DEFAULT_ATMOS

	base_gases = list(
		"oxygen" = 5,
		"nitrogen" = 10,
	)
	normal_gases = list(
		"oxygen" = 10,
		"nitrogen" = 10,
		"carbon_dioxide" = 10,
	)
	restricted_gases = list(
		"plasma" = 0.1,
	)
	restricted_chance = 50

	minimum_pressure = WARNING_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	// temperature range USED to be 100-140 C. this was bad, because
	// fires start at 100C; occasionally, there would be a perma-plasmafire, too tiny to notice.
	// even worse, occasionally there would be a perma-TRITFIRE, if oxygen
	// concentration was high enough. this caused a bunch of lag and added nothing to the game whatsoever
	// thus, the temperatures were reduced to 70-90 C
	minimum_temp = 20 CELSIUS + 50
	maximum_temp = 20 CELSIUS + 70

/datum/atmosphere/icemoon
	id = ICEMOON_DEFAULT_ATMOS

	base_gases = list(
		"oxygen" = 5,
		"nitrogen" = 10,
	)
	normal_gases = list(
		"oxygen" = 10,
		"nitrogen" = 10,
		"carbon_dioxide" = 10,
	)
	restricted_gases = list(
		"plasma" = 0.1,
	)
	restricted_chance = 50

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = 180
	maximum_temp = 180

/datum/atmosphere/gas_giant
	id = GAS_GIANT_ATMOS

	base_gases = list(
		"nitrogen"=10,
	)
	normal_gases = list(
		"oxygen"=5,
		"nitrogen"=5,
		"carbon_dioxide"=5,
	)
	restricted_gases = list()
	restricted_chance = 1

	minimum_pressure = WARNING_HIGH_PRESSURE + 175
	maximum_pressure = HAZARD_HIGH_PRESSURE + 1000

	minimum_temp = 30 //number i pulled out of my ass
	maximum_temp = 120

/datum/atmosphere/gas_giant/plasma
	id = PLASMA_GIANT_ATMOS

	base_gases = list(
		"plasma" = 10,
	)
	normal_gases = list(
		"plasma" = 10,
		"carbon_dioxide" = 5,
	)
	restricted_gases = list(
		"plasma" = 0.1,
	)
	restricted_chance = 1

/datum/atmosphere/wasteplanet
	id = WASTEPLANET_DEFAULT_ATMOS


	base_gases = list(
		"oxygen" = 7,
		"nitrogen" = 10,
	)
	normal_gases = list(
		"oxygen" = 7,
		"oxygen" = 3,
		"nitrogen" = 5,
		"nitrogen" = 2
	)
	restricted_gases = list()
	restricted_chance = 10

	minimum_pressure = ONE_ATMOSPHERE - 30
	maximum_pressure = ONE_ATMOSPHERE + 100

	minimum_temp = 20 CELSIUS + 1
	maximum_temp = 20 CELSIUS + 80
