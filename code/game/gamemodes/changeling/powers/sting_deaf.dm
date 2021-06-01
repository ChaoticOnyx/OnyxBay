
/mob/proc/prepare_changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc = "Sting target"
	if(is_regenerating())
		return
	change_ctate(/datum/click_handler/changeling/changeling_deaf_sting)
	return

/mob/proc/changeling_deaf_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_deaf_sting, T, 5)
	if(!target)
		return FALSE
	to_chat(target, "<span class='danger'>Your ears pop and begin ringing loudly!</span>")
	target.sdisabilities |= DEAF
	spawn(30 SECONDS)
		target.sdisabilities &= ~DEAF
	feedback_add_details("changeling_powers","DS")
	return TRUE
