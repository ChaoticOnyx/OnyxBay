/datum/configuration_section/random_events
	name = "random-events"

	var/allow_random_events = TRUE
	var/expected_round_length = 180
	var/list/event_first_run = list(EVENT_LEVEL_MUNDANE = null, EVENT_LEVEL_MODERATE = null, EVENT_LEVEL_MAJOR = list("lower" = 48000, "upper" = 60000))
	var/event_delay_lower = list(10, 30, 50)
	var/event_delay_upper = list(15, 45, 70)
	var/event_custom_start_mundane = list(10, 15)
	var/event_custom_start_moderate = list(30, 45)
	var/event_custom_start_major = list(80, 100)

/datum/configuration_section/random_events/load_data(list/data)
	CONFIG_LOAD_BOOL(allow_random_events, data["allow_random_events"])
	CONFIG_LOAD_NUM(expected_round_length, data["expected_round_length"])
	CONFIG_LOAD_LIST(event_delay_lower, data["event_delay_lower"])
	CONFIG_LOAD_LIST(event_delay_upper, data["event_delay_upper"])
	CONFIG_LOAD_LIST(event_custom_start_mundane, data["event_custom_start_mundane"])
	
	if(event_custom_start_mundane)
		event_first_run[EVENT_LEVEL_MUNDANE] = list("lower" = MinutesToTicks(event_custom_start_mundane[1]), "upper" = MinutesToTicks(event_custom_start_mundane[2]))

	CONFIG_LOAD_LIST(event_custom_start_moderate, data["event_custom_start_moderate"])

	if(event_custom_start_moderate)
		event_first_run[EVENT_LEVEL_MODERATE] = list("lower" = MinutesToTicks(event_custom_start_moderate[1]), "upper" = MinutesToTicks(event_custom_start_moderate[2]))

	CONFIG_LOAD_LIST(event_custom_start_major, data["event_custom_start_major"])

	if(event_custom_start_major)
		event_first_run[EVENT_LEVEL_MAJOR] = list("lower" = MinutesToTicks(event_custom_start_major[1]), "upper" = MinutesToTicks(event_custom_start_major[2]))
