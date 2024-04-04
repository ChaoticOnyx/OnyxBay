
/datum/changeling_power/toggled/sting/deaf
	name = "Deaf Sting"
	desc = "We make our prey go deaf."
	icon_state = "ling_sting_deaf"
	required_chems = 10

/datum/changeling_power/toggled/sting/deaf/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!..())
		return FALSE

	to_chat(target, SPAN("danger", "Your ears pop and begin ringing loudly!"))

	target.sdisabilities |= DEAF
	target.set_next_think_ctx("remove_deaf", world.time + 30 SECONDS)

	feedback_add_details("changeling_powers", "DS")
