
/mob/proc/prepare_changeling_vomit_sting()
	set category = "Changeling"
	set name = "Vomit Sting (15)"
	set desc = "Urges target to vomit."
	if(is_regenerating())
		return
	change_ctate(/datum/click_handler/changeling/changeling_vomit_sting)
	return

/mob/proc/changeling_vomit_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_vomit_sting, T, 15)
	if(!target)
		return FALSE
	spawn(1 SECOND)
		target.vomit()
	feedback_add_details("changeling_powers","VS")
	return TRUE
