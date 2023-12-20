
/datum/changeling_power/passive/hive_upload
	name = "Hive Channel"
	desc = "Allows us to channel DNA in the airwaves to allow other changelings to absorb it."
	required_chems = 20

/datum/changeling_power/passive/hive_upload/activate()
	my_mob.verbs += /datum/changeling/proc/hive_upload

/datum/changeling_power/passive/hive_upload/deactivate()
	my_mob.verbs -= /datum/changeling/proc/hive_upload

/datum/changeling/proc/hive_upload()
	set category = "Changeling"
	set name = "Hive Channel (20)"
	set desc = "Allows us to channel DNA in the airwaves to allow other changelings to absorb it."

	if(!usr?.mind?.changeling)
		return
	src = usr.mind.changeling

	if(usr != my_mob)
		return

	var/datum/changeling_power/source_power = get_changeling_power_by_name("Hive Channel")
	if(!source_power)
		my_mob.verbs -= /datum/changeling/proc/hive_upload
		return

	if(!source_power.is_usable())
		return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in absorbed_dna)
		var/valid = TRUE
		for(var/datum/absorbed_dna/DNB in hivemind_bank)
			if(DNA.name == DNB.name)
				valid = FALSE
				break
		if(valid)
			names += DNA.name

	if(names.len <= 0)
		to_chat(my_mob, SPAN("changeling", "The airwaves already have all of our DNA."))
		return

	var/S = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/absorbed_dna/chosen_dna = GetDNA(S)
	if(!chosen_dna)
		return

	var/datum/species/spec = all_species[chosen_dna.speciesName]

	if(spec && (spec.species_flags & SPECIES_FLAG_NEED_DIRECT_ABSORB))
		to_chat(my_mob, SPAN("changeling", "That species must be absorbed directly."))
		return

	source_power.use_chems()
	hivemind_bank += chosen_dna
	to_chat(my_mob, SPAN("changeling", "We channel the DNA of [S] to the air."))

	feedback_add_details("changeling_powers","HU")
