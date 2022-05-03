/datum/configuration_section/random_events
	name = "random-events"

	var/enable = TRUE
	var/expected_round_length = 180
	var/list/first_run = list(EVENT_LEVEL_MUNDANE = null, EVENT_LEVEL_MODERATE = null, EVENT_LEVEL_MAJOR = list("lower" = 48000, "upper" = 60000))
	var/list/delay_lower = list(10, 30, 50)
	var/list/delay_upper = list(15, 45, 70)
	var/list/custom_start_mundane = list(10, 15)
	var/list/custom_start_moderate = list(30, 45)
	var/list/custom_start_major = list(80, 100)

/datum/configuration_section/random_events/load_data(list/data)
	CONFIG_LOAD_BOOL(enable, data["enable"])
	CONFIG_LOAD_NUM(expected_round_length, data["expected_round_length"])
	CONFIG_LOAD_LIST(delay_lower, data["delay_lower"])

	if(delay_lower)
		delay_lower[EVENT_LEVEL_MUNDANE] = MinutesToTicks(delay_lower[1])
		delay_lower[EVENT_LEVEL_MODERATE] = MinutesToTicks(delay_lower[2])
		delay_lower[EVENT_LEVEL_MAJOR] = MinutesToTicks(delay_lower[3])

	CONFIG_LOAD_LIST(delay_upper, data["delay_upper"])

	if(delay_upper)
		delay_upper[EVENT_LEVEL_MUNDANE] = MinutesToTicks(delay_upper[1])
		delay_upper[EVENT_LEVEL_MODERATE] = MinutesToTicks(delay_upper[2])
		delay_upper[EVENT_LEVEL_MAJOR] = MinutesToTicks(delay_upper[3])

	CONFIG_LOAD_LIST(custom_start_mundane, data["custom_start_mundane"])
	
	if(custom_start_mundane)
		first_run[EVENT_LEVEL_MUNDANE] = list("lower" = MinutesToTicks(custom_start_mundane[1]), "upper" = MinutesToTicks(custom_start_mundane[2]))

	CONFIG_LOAD_LIST(custom_start_moderate, data["custom_start_moderate"])

	if(custom_start_moderate)
		first_run[EVENT_LEVEL_MODERATE] = list("lower" = MinutesToTicks(custom_start_moderate[1]), "upper" = MinutesToTicks(custom_start_moderate[2]))

	CONFIG_LOAD_LIST(custom_start_major, data["custom_start_major"])

	if(custom_start_major)
		first_run[EVENT_LEVEL_MAJOR] = list("lower" = MinutesToTicks(custom_start_major[1]), "upper" = MinutesToTicks(custom_start_major[2]))
