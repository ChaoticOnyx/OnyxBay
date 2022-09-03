SUBSYSTEM_DEF(events)
	name = "Events"
	wait = 1 MINUTE
	priority = SS_PRIORITY_EVENT

	var/list/scheduled_events = list()
	var/list/total_events = list()

	var/list/evars = list()
	var/datum/event_triggers/triggers = new

	var/list/processing_events = list()

	var/event_fired = FALSE

/datum/controller/subsystem/events/Initialize(start_timeofday)
	. = ..()

	for(var/path in subtypesof(/datum/event2))
		var/datum/event2/E = new path()

		if(GLOB.using_map.type in E.blacklisted_maps)
			qdel(E)
			continue

		if(!E.triggered_only)
			scheduled_events += E
		
		total_events["[E.id]"] = E

/datum/controller/subsystem/events/fire(resumed)
	if(GAME_STATE < RUNLEVEL_GAME)
		return

	if(!resumed)
		update_triggers()
		processing_events = scheduled_events.Copy()
		event_fired = FALSE

	while(processing_events.len)
		var/datum/event2/E = processing_events[processing_events.len]
		processing_events.len--

		if(E.fire_only_once && E.fired)
			scheduled_events -= E

		if(E._waiting_option > 0)
			if(world.time < E._waiting_option)
				continue
			else
				E.ai_choose()

		if(prob(E.calc_chance()))
			if(!E.check_conditions())
				E._mtth_passed = 0
			else
				event_fired = TRUE
				E.fire()
		else
			if(event_fired)
				E._mtth_passed -= (E._mtth_passed * 0.15)
				E._mtth_passed = max(0, E._mtth_passed)
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
		if(M.is_dead())
			triggers.death_players_count += 1
		else
			triggers.living_players_count += 1

			if(M.mind.assigned_role != null)
				triggers.roles_count[M.mind.assigned_role] += 1

/datum/controller/subsystem/events/proc/fire_event_with_type(ty)
	for(var/event_id in total_events)
		var/datum/event2/E = total_events[event_id]
		
		if(E.type == ty)
			E.fire()
			return

	CRASH("event with type '[ty]' not found")
