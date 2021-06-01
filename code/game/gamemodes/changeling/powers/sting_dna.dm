
/mob/proc/prepare_changeling_extract_dna_sting()
	set category = "Changeling"
	set name = "Extract DNA Sting (40)"
	set desc="Stealthily sting a target to extract their DNA."
	if(is_regenerating())
		return
	change_ctate(/datum/click_handler/changeling/changeling_extract_dna_sting)
	return

/mob/proc/changeling_extract_dna_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_extract_dna_sting, T, 40)
	if(!target)
		return FALSE
	if((MUTATION_HUSK in target.mutations) || (target.species.species_flags & SPECIES_FLAG_NO_SCAN))
		to_chat(src, "<span class='warning'>We cannot extract DNA from this creature!</span>")
		return FALSE
	if(target.species.species_flags & SPECIES_FLAG_NEED_DIRECT_ABSORB)
		to_chat(src, "<span class='notice'>That species must be absorbed directly.</span>")
		return

	var/datum/absorbed_dna/newDNA = new(target.real_name, target.dna, target.species.name, target.languages, target.modifiers, target.flavor_texts)
	absorbDNA(newDNA)

	feedback_add_details("changeling_powers","ED")
	return TRUE
