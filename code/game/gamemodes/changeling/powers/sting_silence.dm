
/mob/proc/prepare_changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc = "Sting target"

	if(is_regenerating())
		return

	change_ctate(/datum/click_handler/changeling/changeling_silence_sting)
	return

/mob/proc/changeling_silence_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_silence_sting, T, 10)
	if(!target)
		return FALSE
	target.silent += 30
	feedback_add_details("changeling_powers","SS")
	return TRUE
