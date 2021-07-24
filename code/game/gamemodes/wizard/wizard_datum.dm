/datum/wizard
	/// An instance of /datum/wizard_class.
	/// Not intedend to change instance's values.
	var/datum/wizard_class/class = null
	/// Points that a wizard spends to buy artifacts or spells.
	var/points = 0
	var/can_reset_class = TRUE
	/// Id of a timer.
	var/investing_timer = null

/datum/wizard/proc/can_invest()
	return !investing_timer && can_spend(1) && class?.investable

/datum/wizard/proc/invest_begin()
	if(investing_timer)
		return FALSE

	investing_timer = addtimer(CALLBACK(src, .proc/invest_end), 15 MINUTES, TIMER_STOPPABLE)
	return TRUE

/// Do not call this proc manually. Use invest_being instead.
/datum/wizard/proc/invest_end()
	if(!investing_timer)
		CRASH("Calling invest_end without a timer.")

	investing_timer = null
	points += 2

/datum/wizard/proc/reset()
	class = null
	points = 0
	can_reset_class = FALSE

	if(investing_timer)
		deltimer(investing_timer)

/datum/wizard/proc/set_class(datum/wizard_class/path)
	class = GLOB.wizard_classes["[path]"]
	points = class.points
	feedback_add_details("wizard_class_selected", class.feedback_tag)

/datum/wizard/proc/spend(cost)
	points -= cost

/datum/wizard/proc/can_spend(cost)
	if(points - cost < 0)
		return FALSE
	
	return TRUE
