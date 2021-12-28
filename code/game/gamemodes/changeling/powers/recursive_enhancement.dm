
// Aghanim's shard of ours. Improves some abilities.
/datum/changeling_power/passive/recursive_enhancement
	name = "Recursive Enhancement"
	desc = "Empowers our abilities."

/datum/changeling_power/passive/recursive_enhancement/activate()
	changeling.recursive_enhancement = TRUE
	for(var/datum/changeling_power/CP in changeling.available_powers)
		CP.update_recursive_enhancement()
	to_chat(my_mob, SPAN("changeling", "We empower ourselves. Our abilities will now be extra potent."))
	feedback_add_details("changeling_powers", "RE")

/datum/changeling_power/passive/recursive_enhancement/deactivate()
	changeling.recursive_enhancement = FALSE
	for(var/datum/changeling_power/CP in changeling.available_powers)
		CP.update_recursive_enhancement()
