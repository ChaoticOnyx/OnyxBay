SUBSYSTEM_DEF(storyteller)
	name = "Storyteller"
	wait = 20 // changes with round story progress
	priority = SS_PRIORITY_STORYTELLER
	init_order = SS_INIT_STORYTELLER

	var/__was_character_choosen_by_random = FALSE

	var/__storyteller_tick = -1 // updates on every fire
	var/datum/storyteller_character/__character = null

	var/list/__metrics = new
	var/list/__triggers = new

/datum/controller/subsystem/storyteller/Initialize(timeofday)
	if (config.storyteller)
		return ..()
	flags = SS_NO_FIRE

// called on round setup, after players spawn and mode setup
/datum/controller/subsystem/storyteller/proc/setup()
	if (!config.storyteller)
		return
	_log_debug("Setup called")

	__create_character()
	_log_debug("Chosen character is '[__character]'")

	_log_debug("Process round start")
	var/time_to_first_cycle = __character.process_round_start()
	ASSERT(time_to_first_cycle)
	wait = time_to_first_cycle

/datum/controller/subsystem/storyteller/fire(resumed = FALSE)
	if (GAME_STATE < RUNLEVEL_GAME)
		return
	if (__storyteller_tick == -1) // first tick is called with default 'wait', we need our tick with our value of 'wait'
		__storyteller_tick = 0
		return
	__storyteller_tick++
	_log_debug("Process new cycle start")
	var/time_to_next_cycle = __character.process_new_cycle_start()
	ASSERT(time_to_next_cycle)
	wait = time_to_next_cycle

/datum/controller/subsystem/storyteller/proc/get_metric(type)
	if (!(type in __metrics))
		__metrics[type] = new type
	return __metrics[type]

/datum/controller/subsystem/storyteller/proc/run_trigger(type)
	if (!(type in __triggers))
		__triggers[type] = new type
	var/storyteller_trigger/trigger = __triggers[type]
	return trigger.invoke()

/datum/controller/subsystem/storyteller/proc/get_tick()
	return __storyteller_tick

/datum/controller/subsystem/storyteller/proc/was_character_choosen_with_random()
	return __was_character_choosen_by_random

/datum/controller/subsystem/storyteller/proc/__create_character()
	__character = new /datum/storyteller_character/support

