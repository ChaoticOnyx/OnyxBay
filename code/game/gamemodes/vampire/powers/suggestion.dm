
// Dominate a victim, imbed a thought into their mind.
/datum/vampire_power/order
	name = "Suggestion"
	desc = "Dominate the mind of a victim, make them obey your will."
	icon_state = "vamp_suggestion"
	blood_cost = 50

/datum/vampire_power/order/activate()
	if(!..())
		return
	if(!vampire.vampire_dominate_handler("suggestion"))
		return
	use_blood()
	set_cooldown(120 SECONDS)
