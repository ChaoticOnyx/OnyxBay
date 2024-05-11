
/datum/changeling_power/toggled/sting/hallucination
	name = "Hallucination Sting"
	desc = "Causes terror in the target."
	icon_state = "ling_sting_hallucination"
	required_chems = 30

/datum/changeling_power/toggled/sting/hallucination/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!..())
		return FALSE

	target.set_next_think_ctx("delayed_hallucinations", (rand(30, 60) SECONDS))

	feedback_add_details("changeling_powers", "HS")
