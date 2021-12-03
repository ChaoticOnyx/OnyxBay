
//Boosts the range of our stings by 1, but also increases required chems by 10.
/datum/changeling_power/toggle/boost_range
	name = "Ranged Stinger"
	desc = desc = "Our sting abilities can be used against targets 2 squares away, but require additional 10 chemicals."
	icon_state = "ling_boost_range"
	required_chems = 0
	power_processing = FALSE

	text_activate = "Our stinger adjusts to launch stings further."
	text_deactivate = "Our stinger returns to a normal state."

/datum/changeling_power/toggle/boost_range/activate()
	if(!..())
		return
	changeling.boost_sting_range = TRUE
	for(var/datum/changeling_power/toggled/sting/S in available_powers)
		S.update_required_chems()
	feedback_add_details("changeling_powers","RS")

/datum/changeling_power/toggle/boost_range/deactivate()
	if(!..())
		return
	changeling.boost_sting_range = FALSE
	for(var/datum/changeling_power/toggled/sting/S in available_powers)
		S.update_required_chems()
