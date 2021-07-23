/datum/wizard
	/// A path of wizard's class datum.
	var/class = null
	/// Points that a wizard spends to buy artifacts or spells.
	var/points = 0

/datum/wizard/proc/set_class(datum/wizard_class/path)
	class = path
	points = initial(path.points)
	feedback_add_details("wizard_class_selected", initial(path.feedback_tag))
