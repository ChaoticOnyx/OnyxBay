
/datum/changeling_power/toggled/sting/vomit
	name = "Vomit Sting"
	desc = "Urges target to vomit."
	icon_state = "ling_sting_vomit"
	required_chems = 30

/datum/changeling_power/toggled/sting/vomit/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!..())
		return FALSE

	spawn(1 SECOND)
		target.vomit()

	feedback_add_details("changeling_powers", "VS")
