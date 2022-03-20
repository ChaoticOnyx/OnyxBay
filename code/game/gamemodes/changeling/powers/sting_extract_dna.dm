
/datum/changeling_power/toggled/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target to extract their DNA."
	icon_state = "ling_sting_dna"
	required_chems = 80

/datum/changeling_power/toggled/sting/extract_dna/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!..())
		return FALSE

	if((MUTATION_HUSK in target.mutations) || (target.species.species_flags & SPECIES_FLAG_NO_SCAN))
		to_chat(my_mob, SPAN("changeling", "We cannot extract DNA from this creature!"))
		return

	if(target.species.species_flags & SPECIES_FLAG_NEED_DIRECT_ABSORB)
		to_chat(my_mob, SPAN("changeling", "That species must be absorbed directly."))
		return

	var/datum/absorbed_dna/newDNA = new(target.real_name, target.dna, target.species.name, target.languages, target.modifiers, target.flavor_texts)
	changeling.absorbDNA(newDNA)

	feedback_add_details("changeling_powers", "ED")
