
// Dominate a victim, using single word.
/datum/vampire_power/order
	name = "Order"
	desc = "Order the mind of a victim, make them obey your will."
	icon_state = "vamp_order"
	blood_cost = 20

/datum/vampire_power/order/activate()
	if(!..())
		return
	if(!vampire.vampire_dominate_handler("order"))
		return
	use_blood()
	set_cooldown(60 SECONDS)
