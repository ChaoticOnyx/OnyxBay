
/datum/changeling_power/toggled/sting/silence
	name = "Silence Sting"
	desc = "We make our prey less noisy."
	icon_state = "ling_sting_silence"
	required_chems = 20

/datum/changeling_power/toggled/sting/silence/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!..())
		return FALSE

	target.silent += 30

	feedback_add_details("changeling_powers", "SS")
