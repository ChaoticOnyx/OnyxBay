/*
 WARRANTY VOID IF CODE USED
*/

/datum/legacy_events
	var/list/events

/datum/legacy_events/New()
		..()
		events = new

/datum/legacy_events/proc/addEventType(event_type)
	if(!(event_type in events) || !islist(events[event_type]))
		events[event_type] = list()
		return 1
	return


// Arguments: event_type as text, proc_holder as datum, proc_name as text
// Returns: New event, null on error.
/datum/legacy_events/proc/addEvent(event_type, proc_holder, proc_name)
	if(!event_type || !proc_holder || !proc_name)
		return
	addEventType(event_type)
	var/list/event = events[event_type]
	var/datum/legacy_event/E = new /datum/legacy_event(proc_holder, proc_name)
	event += E
	return E

// Arguments: event_type as text, any number of additional arguments to pass to event handler
// Returns: null
/datum/legacy_events/proc/fireEvent()
	var/list/event = listgetindex(events, args[1])
	if(istype(event))
		spawn(-1)
			for(var/datum/legacy_event/E in event)
				if(!E.Fire(arglist(args.Copy(2))))
					clearEvent(args[1],E)
	return

// Arguments: event_type as text, E as /datum/legacy_event
// Returns: 1 if event cleared, null on error
/datum/legacy_events/proc/clearEvent(event_type, datum/legacy_event/E)
	if(!event_type || !E)
		return
	var/list/event = listgetindex(events, event_type)
	event -= E
	return 1

/datum/legacy_event
	var/listener
	var/proc_name

/datum/legacy_event/New(tlistener, tprocname)
	listener = tlistener
	proc_name = tprocname
	return ..()

/datum/legacy_event/proc/Fire()
	if(listener)
		call(listener, proc_name)(arglist(args))
		return 1
	return
