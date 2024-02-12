/datum/storyteller_character
	var/name = "Unknown Storyteller character"
	var/desc = ""

	/// The higher the value - the more dangerous options in the events will be chosen by the storyteller.
	var/aggression_ratio = 0.50
	/// The higher the value - the more MTTH of events.
	var/rarity_ratio = 0.30
	/// The higher the value, the lower time between events.
	var/quantity_ratio = 0.50
	var/event_chance_multiplier = 10
	/// If set to TRUE, multiple events *may* fire at the same time.
	var/simultaneous_event_fire = FALSE
	/// Events' chances to fire decrease after reaching soft cap and become 0 after reaching hard cap. TODO: Make it dynamic?
	var/difficulty_soft_cap = 50
	var/difficulty_hard_cap = 100

	var/can_be_voted_for = TRUE       // Whether this character can be picked via public vote before roundstart.

	var/__metrics
	var/__debug = TRUE                // print debug logs

// returns time for next cycle
/datum/storyteller_character/proc/process_round_start()
	_log_debug("Round start processing begins")

	var/minutes_to_first_cycle = 9 + rand(0, 10)
	_log_debug("Time to first cycle: [minutes_to_first_cycle] minutes" )

	return minutes_to_first_cycle MINUTES

/datum/storyteller_character/proc/process_new_cycle_start()
	_log_debug("New cycle processing begins")

	USE_METRIC(/storyteller_metric/station_characters_count, station_characters_count)
	USE_METRIC(/storyteller_metric/security_manpower, security_manpower)
	USE_METRIC(/storyteller_metric/time_of_day, time_of_day)
	USE_METRIC(/storyteller_metric/antagonists_danger, antagonists_danger)
	USE_METRIC(/storyteller_metric/ghosts_count, ghosts_count)
	USE_METRIC(/storyteller_metric/injuries_score, injuries_score)

	_log_debug("station_characters_count [station_characters_count]")
	_log_debug("security_manpower [security_manpower]")
	_log_debug("time_of_day [time_of_day]")
	_log_debug("antagonists_danger [antagonists_danger]")
	_log_debug("ghosts_count [ghosts_count]")
	_log_debug("injuries_score [injuries_score]")

	var/security_advantage = security_manpower - antagonists_danger

	_log_debug("Security Advantage: [security_advantage]")
	var/balancing_is_needed = security_advantage > 5

	var/minutes_to_next_cycle = 15 + rand(0, 10)

	if(balancing_is_needed)
		_log_debug("Balancing is needed due to high security advantage")
		minutes_to_next_cycle = 1

		var/list/triggers = new
		triggers[/storyteller_trigger/spawn_antagonist/traitor] = 65
		triggers[/storyteller_trigger/spawn_antagonist/vampire] = 10
		triggers[/storyteller_trigger/spawn_antagonist/borer] = 5

		if(security_advantage > 10)
			triggers[/storyteller_trigger/spawn_antagonist/changeling] = 40
		else
			triggers[/storyteller_trigger/spawn_antagonist/changeling] = 10

		if(security_advantage > 20)
			triggers[/storyteller_trigger/spawn_antagonist/ninja] = 80
			triggers[/storyteller_trigger/spawn_antagonist/wizard] = 80

		var/choosen_trigger
		var/result
		do
			choosen_trigger = util_pick_weight(triggers)
			result = _run_trigger(choosen_trigger)
			triggers.Remove(choosen_trigger)
		while(!result && length(triggers))

		if(!result)
			_log_debug("Triggers don't work! We can't fix the balance :(")

	_log_debug("Time to next cycle: [minutes_to_next_cycle] minutes" )

	return minutes_to_next_cycle MINUTES

/datum/storyteller_character/proc/get_params_for_ui()
	var/list/data = list(
		"type" = type,
		"name" = name,
		"description" = desc,
		"aggression_ratio" = aggression_ratio * 100,
		"rarity_ratio" = rarity_ratio * 100,
		"quantity_ratio" = quantity_ratio * 100,
		"event_chance_multiplier" = event_chance_multiplier
	)
	return data

/datum/storyteller_character/proc/_log_debug(text, verbose = FALSE)
	if (!__debug)
		return
	var/string_to_log = "\[Storyteller Character]: [text]"
	if (!verbose)
		log_debug(string_to_log)
	else
		log_debug_verbose(string_to_log)

/datum/storyteller_character/proc/_get_metric(type)
	return SSstoryteller.get_metric(type)

/datum/storyteller_character/proc/_run_trigger(type)
	return SSstoryteller.run_trigger(type)

/datum/storyteller_character/proc/get_available_vacancies()
	return round(round_duration_in_ticks/JOB_VACANCIES_SLOT_PER_TIME) + JOB_VACANCIES_SLOTS_AVAILABLE_AT_ROUNDSTART

/datum/storyteller_character/proc/calc_event_chance(datum/event/E)
	ASSERT(E)
	. = E.calc_chance() * event_chance_multiplier
	if((E.difficulty > difficulty_soft_cap) && difficulty_hard_cap)
		. *= 1 - min(1, E.difficulty / (difficulty_hard_cap - difficulty_soft_cap))
