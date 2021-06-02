
/mob/proc/changeling_hivedownload()
	set category = "Changeling"
	set name = "Hive Absorb (20)"
	set desc = "Allows us to absorb DNA that is being channeled in the airwaves."

	var/datum/changeling/changeling = changeling_power(20, 1)
	if(!changeling)
		return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in hivemind_bank)
		if(!(changeling.GetDNA(DNA.name)))
			names[DNA.name] = DNA

	if(names.len <= 0)
		to_chat(src, SPAN("changeling", "There's no new DNA to absorb from the air."))
		return

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)
		return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	changeling.chem_charges -= 20
	absorbDNA(chosen_dna)
	to_chat(src, SPAN("changeling", "We absorb the DNA of [S] from the air."))

	feedback_add_details("changeling_powers", "HD")
