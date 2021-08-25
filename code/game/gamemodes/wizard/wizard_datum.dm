#define INVESTING_DURATION 15 MINUTES

/datum/wizard
	/// An instance of /datum/wizard_class.
	/// Not intedend to change instance's values.
	var/datum/wizard_class/class = null
	/// Points that a wizard spends to buy artifacts or spells.
	var/points = 0
	var/can_reset_class = TRUE
	var/datum/timedevent/investing_timer = null
	var/sacrificed = FALSE

/datum/wizard/proc/can_invest()
	return !investing_timer && can_spend(1) && class?.investable

/datum/wizard/proc/is_investing()
	return !!investing_timer

/datum/wizard/proc/can_sacrifice()
	return investing_timer && !sacrificed

/datum/wizard/proc/sacrifice()
	var/spend = world.time - investing_timer.startTime
	var/new_time = max(INVESTING_DURATION - spend - 10 MINUTES, 1)
	sacrificed = TRUE
	deltimer(investing_timer)
	investing_timer = null
	invest_begin(new_time)

/datum/wizard/proc/invest_begin(custom_time = null)
	if(investing_timer)
		return FALSE

	investing_timer = gettimer(addtimer(CALLBACK(src, .proc/invest_end), custom_time || INVESTING_DURATION, TIMER_STOPPABLE))

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
		sacrificed = FALSE
		deltimer(investing_timer.id)
		investing_timer = null

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

#undef INVESTING_DURATION
