#define WHITESANDS_WALL_ENV "rock"
#define WHITESANDS_SAND_ENV "sand"
#define WHITESANDS_DRIED_ENV "dried_up"
#define WHITESANDS_ATMOS "ws_atmos"

/datum/atmosphere/whitesands
	id = WHITESANDS_ATMOS

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
	maximum_pressure = WARNING_LOW_PRESSURE + 30

	minimum_temp = 180
	maximum_temp = 180
