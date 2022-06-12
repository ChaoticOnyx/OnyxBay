/datum/event/infestation/polar/announce()
	command_announcement.Announce(
		"Bioscans indicate that [vermstring] have been breeding in \the [location]. Clear them out, before this starts to affect productivity.",
		"Major Bill's Shipping Critter Sensor",
		zlevels = affecting_z,
		new_sound = 'sound/AI/polar/infestation_announce.ogg'
	)
