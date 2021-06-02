
/mob/proc/prepare_changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc = "We make our prey go deaf."

	if(changeling_is_incapacitated())
		return

	change_ctate(/datum/click_handler/changeling/changeling_deaf_sting)

/mob/proc/changeling_deaf_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_deaf_sting, T, 5)
	if(!target)
		return

	to_chat(target, SPAN("danger", "Your ears pop and begin ringing loudly!"))
	target.sdisabilities |= DEAF
	spawn(30 SECONDS)
		target.sdisabilities &= ~DEAF

	feedback_add_details("changeling_powers", "DS")
