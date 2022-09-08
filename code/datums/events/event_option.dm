/datum/event_option
	var/datum/event/_event
	var/id = null
	var/name = "OPTION_NAME"
	var/description = "OPTION_DESCRIPTION"
	var/weight = 0
	var/event_id = null

/datum/event_option/New()
	ASSERT(id != null)

/datum/event_option/Destroy()
	_event = null

	. = ..()

/datum/event_option/proc/get_description()
	return description

/datum/event_option/proc/choose()
	var/datum/event/E = SSevents.total_events[event_id]

	if(event_id != null && E == null)
		CRASH("option '[name]' ([id]) has invalid event_id: '[event_id]'")

	on_choose()

	if(E)
		E.fire()

	_event.after_fire()

/datum/event_option/proc/on_choose()
	return

/datum/event_option/proc/get_weight()
	return weight
