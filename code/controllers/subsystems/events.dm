#define EVENT_PRESETS_FILE "config/event_presets.toml"

SUBSYSTEM_DEF(events)
	name = "Events"
	wait = 1 MINUTE
	priority = SS_PRIORITY_EVENT

	var/paused = FALSE
	/// list(/datum/event)
	var/list/scheduled_events = list()
	/// list("id" = /datum/event)
	var/list/total_events = list()
	/// list("id" = boolean)
	var/list/disabled_events = list()
	/// list("name" = list("id" = boolean))
	var/list/event_presets = list()

	var/list/evars = list()
	var/datum/event_triggers/triggers = new

	var/list/processing_events = list()

	var/event_fired = FALSE

/datum/controller/subsystem/events/Initialize(start_timeofday)
	. = ..()

	for(var/path in subtypesof(/datum/event))
		var/datum/event/E = new path()

		if(GLOB.using_map.type in E.blacklisted_maps)
			qdel(E)
			continue

		if(!E.triggered_only)
			scheduled_events += E

		total_events["[E.id]"] = E
		disabled_events["[E.id]"] = FALSE

	__populate_presets()

	if(config.game.events_preset)
		apply_events_preset(config.game.events_preset)

/datum/controller/subsystem/events/proc/apply_events_preset(preset)
	if(!(preset in event_presets))
		CRASH("Invalid events preset [preset]")

	var/event_state = event_presets[preset]
	var/default_state = event_state["default"]

	if(default_state == null)
		default_state = FALSE

	for(var/event_id in total_events)
		// Special variable
		if(event_id == "default")
			continue

		// Some events may be blacklisted
		if(!(event_id in disabled_events))
			continue

		if(!(event_id in event_state))
			disabled_events[event_id] = !default_state
		else
			disabled_events[event_id] = !event_state[event_id]

/datum/controller/subsystem/events/proc/enable_all_events()
	for(var/event_id in total_events)
		disabled_events[event_id] = FALSE

/datum/controller/subsystem/events/proc/disable_all_events()
	for(var/event_id in total_events)
		disabled_events[event_id] = TRUE

/datum/controller/subsystem/events/proc/__populate_presets()
	event_presets = list()

	if(fexists(EVENT_PRESETS_FILE))
		event_presets = rustg_read_toml_file(EVENT_PRESETS_FILE)

	log_debug("Loaded [length(event_presets)] event presets")

/datum/controller/subsystem/events/fire(resumed)
	if(GAME_STATE < RUNLEVEL_GAME || paused)
		return

	if(!resumed)
		update_triggers()
		processing_events = scheduled_events.Copy()
		event_fired = FALSE

	while(processing_events.len)
		var/datum/event/E = processing_events[processing_events.len]
		processing_events.len--

		if(disabled_events[E.id])
			continue

		if(E.fire_only_once && E.fired)
			scheduled_events -= E

		if(E._waiting_option > 0)
			if(world.time < E._waiting_option)
				continue
			else
				E.ai_choose()

		if(!E.check_conditions())
			E._mtth_passed = 0
			continue

		if((!event_fired || SSstoryteller.character.simultaneous_event_fire) && prob(SSstoryteller.character.calc_event_chance(E)))
			event_fired = TRUE
			E.fire()

			for(var/datum/event/E2 in scheduled_events)
				E2._mtth_passed -= (E2._mtth_passed * abs(SSstoryteller.character.quantity_ratio - 1))
				E2._mtth_passed = max(0, E2._mtth_passed)
		else
			E._mtth_passed += wait

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/events/proc/update_triggers()
	triggers.players_count = length(GLOB.player_list)
	triggers.death_players_count = 0
	triggers.living_players_count = 0
	triggers.roles_count = list()

	for(var/mob/M in GLOB.player_list)
		if(M.is_ooc_dead())
			triggers.death_players_count += 1
		else
			triggers.living_players_count += 1

			if(M.mind.assigned_role != null)
				triggers.roles_count[M.mind.assigned_role] += 1

/datum/controller/subsystem/events/proc/fire_event_with_type(ty)
	for(var/event_id in total_events)
		var/datum/event/E = total_events[event_id]

		if(E.type == ty)
			E.fire()
			return

	CRASH("event with type '[ty]' not found")

#undef EVENT_PRESETS_FILE
