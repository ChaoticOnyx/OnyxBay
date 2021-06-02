
/mob/proc/prepare_changeling_lsdsting()
	set category = "Changeling"
	set name = "Hallucination Sting (15)"
	set desc = "Causes terror in the target."

	if(changeling_is_incapacitated())
		return

	change_ctate(/datum/click_handler/changeling/changeling_lsdsting)

/mob/proc/changeling_lsdsting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_lsdsting, T, 15)
	if(!target)
		return

	spawn(rand(300, 600))
		if(target)
			target.hallucination(400, 80)

	feedback_add_details("changeling_powers", "HS")
