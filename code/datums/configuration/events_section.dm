/datum/configuration_section/events
	name = "events"

	var/list/preset

/datum/configuration_section/events/load_data(list/data)
	preset = data["preset"]
