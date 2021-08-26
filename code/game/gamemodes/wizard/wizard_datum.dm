/datum/wizard
	/// An instance of /datum/wizard_class.
	/// Not intedend to change instance's values.
	var/datum/wizard_class/class = null
	/// Points that a wizard spends to buy artifacts or spells.
	var/points = 0
	var/can_reset_class = TRUE

/datum/wizard/proc/reset()
	class = null
	points = 0
	can_reset_class = FALSE

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

