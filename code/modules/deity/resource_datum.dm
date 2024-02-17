/datum/deity_resource
	var/name = "resource"
	var/name_color = COLOR_WHITE
	var/amount = 0

/datum/deity_resource/proc/has_amount(amt)
	return amt <= get_amount()

/datum/deity_resource/proc/use_amount(amt)
	if(amt <= amount)
		amount -= amt
		return TRUE
	return FALSE

/datum/deity_resource/proc/get_amount()
	return amount

/datum/deity_resource/proc/add_amount(amt)
	amount += amt
	return TRUE

/datum/deity_resource/proc/printed_cost(minimum = FALSE)
	return "<font color=\"[name_color]\">[minimum ? copytext(name, 1, 2) : name]</font>"
