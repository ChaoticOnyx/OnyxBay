
/mob/proc/prepare_changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc = "Sting target"

	if(is_regenerating())
		return

	change_ctate(/datum/click_handler/changeling/changeling_blind_sting)
	return

/mob/proc/changeling_blind_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_blind_sting, T, 20)
	if(!target)
		return FALSE
	to_chat(target, "<span class='danger'>Your eyes burn horrificly!</span>")
	target.disabilities |= NEARSIGHTED
	spawn(300)
		target.disabilities &= ~NEARSIGHTED
	target.eye_blind = 10
	target.eye_blurry = 20
	feedback_add_details("changeling_powers","BS")
	return TRUE
