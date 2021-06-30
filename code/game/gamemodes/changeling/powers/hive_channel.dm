
/mob/proc/changeling_hiveupload()
	set category = "Changeling"
	set name = "Hive Channel (10)"
	set desc = "Allows us to channel DNA in the airwaves to allow other changelings to absorb it."

	var/datum/changeling/changeling = changeling_power(10, 1)
	if(!changeling)
		return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		var/valid = TRUE
		for(var/datum/absorbed_dna/DNB in hivemind_bank)
			if(DNA.name == DNB.name)
				valid = FALSE
				break
		if(valid)
			names += DNA.name

	if(names.len <= 0)
		to_chat(src, SPAN("changeling", "The airwaves already have all of our DNA."))
		return

	var/S = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/datum/species/spec = all_species[chosen_dna.speciesName]

	if(spec && spec.species_flags & SPECIES_FLAG_NEED_DIRECT_ABSORB)
		to_chat(src, SPAN("changeling", "That species must be absorbed directly."))
		return

	changeling.chem_charges -= 10
	hivemind_bank += chosen_dna
	to_chat(src, SPAN("changeling", "We channel the DNA of [S] to the air."))

	feedback_add_details("changeling_powers","HU")
