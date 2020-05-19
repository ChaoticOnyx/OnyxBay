/datum/storyteller_character/support
	name = "Support"
	desc = "Simple storyteller for main mode support with additional roles and events"

/datum/storyteller_character/support/process_round_start()
	..()

	var/minutes_to_first_cycle = 9 + rand(0, 10)
	_log_debug("Time to first cycle: [minutes_to_first_cycle] minutes" )

	return minutes_to_first_cycle MINUTES

/datum/storyteller_character/support/process_new_cycle_start()
	..()
	USE_METRIC(/storyteller_metric/station_characters_count, station_characters_count)
	USE_METRIC(/storyteller_metric/security_manpower, security_manpower)
	USE_METRIC(/storyteller_metric/is_storyteller_random, is_storyteller_random)
	USE_METRIC(/storyteller_metric/time_of_day, time_of_day)
	USE_METRIC(/storyteller_metric/antagonists_danger, antagonists_danger)
	USE_METRIC(/storyteller_metric/ghosts_count, ghosts_count)

	_log_debug("station_characters_count [station_characters_count]")
	_log_debug("security_manpower [security_manpower]")
	_log_debug("is_storyteller_random [is_storyteller_random]")
	_log_debug("time_of_day [time_of_day]")
	_log_debug("antagonists_danger [antagonists_danger]")
	_log_debug("ghosts_count [ghosts_count]")

	var/security_advantage = security_manpower - antagonists_danger

	_log_debug("Security Advantage: [security_advantage]")
	var/balancing_is_needed = security_advantage > 5
	if (balancing_is_needed)
		_log_debug("Balancing is needed due high security advantage")

	while (balancing_is_needed) // balancing
		var/list/triggers = new
		triggers[/storyteller_trigger/spawn_antagonist/traitor] = 2

		if (security_advantage > 10)
			triggers[/storyteller_trigger/spawn_antagonist/changeling] = 4
		else
			triggers[/storyteller_trigger/spawn_antagonist/changeling] = 1

		var/choosen_trigger
		var/result
		do
			choosen_trigger = pickweight(triggers)
			result = _run_trigger(choosen_trigger)
			triggers.Remove(choosen_trigger)
		while (!result && triggers.len)

		if(!result) // no one of our triggers works, we can't do anything with balance :(
			break

		if (choosen_trigger == /storyteller_trigger/spawn_antagonist/traitor)
			security_advantage -= 4
		else
			security_advantage -= 8

	if (balancing_is_needed)
		_log_debug("Security Advantage after balancing: [security_advantage]")

	var/minutes_to_next_cycle = 15 + rand(0, 10)
	_log_debug("Time to next cycle: [minutes_to_next_cycle] minutes" )

	return minutes_to_next_cycle MINUTES
