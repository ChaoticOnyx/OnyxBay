
//Boosts the range of your next sting attack by 1
/mob/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc = "Our next sting ability can be used against targets 2 squares away."

	var/datum/changeling/changeling = changeling_power(10)
	if(!changeling)
		return

	changeling.chem_charges -= 10
	to_chat(src, SPAN("changeling", "Our throat adjusts to launch a sting."))
	changeling.sting_range = 2
	verbs -= /mob/proc/changeling_boost_range
	spawn(5)
		verbs += /mob/proc/changeling_boost_range
	feedback_add_details("changeling_powers","RS")
