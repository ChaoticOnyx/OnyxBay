/datum/event/prison_break/polar/announce()
	if(areas && areas.len > 0)
		command_announcement.Announce(
			"[pick("Gr3y.T1d3 virus","Malignant trojan")] detected in [location_name()] [(eventDept == "Security")? "imprisonment":"containment"] subroutines. Secure any compromised areas immediately. [location_name()] AI involvement is recommended.",
			"[eventDept] Alert",
			zlevels = affecting_z,
			new_sound = 'sound/AI/polar/prison_break_announce.ogg'
		)
