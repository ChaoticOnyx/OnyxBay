
/datum/changeling_power/toggled/sting/blind
	name = "Blind Sting"
	desc = "Our target goes blind."
	icon_state = "ling_sting_blind"
	required_chems = 40

/datum/changeling_power/toggled/sting/blind/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!..())
		return FALSE

	to_chat(target, SPAN("danger", "Your eyes burn horrifically!"))

	target.sdisabilities |= NEARSIGHTED
	addtimer(CALLBACK(target, /mob/living/carbon/human/proc/remove_nearsighted), 30 SECONDS)

	target.eye_blind += 10
	target.eye_blurry += 20

	feedback_add_details("changeling_powers", "BS")
