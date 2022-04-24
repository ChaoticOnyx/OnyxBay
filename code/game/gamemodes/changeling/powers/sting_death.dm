
/datum/changeling_power/toggled/sting/death
	name = "Death Sting"
	desc = "We stuff our prey with cyanide."
	icon_state = "ling_sting_death"
	required_chems = 80

/datum/changeling_power/toggled/sting/death/sting_target(mob/living/carbon/human/target, loud = TRUE)
	if(!..())
		return FALSE

	to_chat(target, SPAN("danger", "You feel a small prick and your chest becomes tight."))

	target.make_jittery(400)
	if(target.reagents)
		spawn(10 SECONDS)
			target.reagents.add_reagent(/datum/reagent/toxin/cyanide, 1)
		spawn(20 SECONDS)
			target.reagents.add_reagent(/datum/reagent/toxin/cyanide, 1)
		spawn(30 SECONDS)
			target.reagents.add_reagent(/datum/reagent/toxin/cyanide, 3)

	feedback_add_details("changeling_powers", "DTHS")
