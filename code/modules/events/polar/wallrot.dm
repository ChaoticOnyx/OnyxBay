/datum/event/wallrot/polar/announce()
	command_announcement.Announce(
		"Harmful fungi detected on [location_name()]. Structures may be contaminated.",
		"Biohazard Alert",
		zlevels = affecting_z,
		new_sound = 'sound/AI/polar/wallrot_announce.ogg'
	)
