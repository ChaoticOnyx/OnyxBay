
/mob/proc/prepare_changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc = "Our target goes blind."

	if(changeling_is_incapacitated())
		return

	change_ctate(/datum/click_handler/changeling/changeling_blind_sting)

/mob/proc/changeling_blind_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_blind_sting, T, 20)
	if(!target)
		return
	to_chat(target, SPAN("danger", "Your eyes burn horrificly!"))

	target.disabilities |= NEARSIGHTED
	spawn(300)
		target.disabilities &= ~NEARSIGHTED
	target.eye_blind = 10
	target.eye_blurry = 20

	feedback_add_details("changeling_powers", "BS")
