
/datum/changeling_power/passive/hive_download
	name = "Hive Absorb"
	desc = "Allows us to absorb DNA that is being channeled in the airwaves."
	required_chems = 40

/datum/changeling_power/passive/hive_download/activate()
	my_mob.verbs += /datum/changeling/proc/hive_download

/datum/changeling_power/passive/hive_download/deactivate()
	my_mob.verbs -= /datum/changeling/proc/hive_download

/datum/changeling/proc/hive_download()
	set category = "Changeling"
	set name = "Hive Absorb (40)"
	set desc = "Allows us to absorb DNA that is being channeled in the airwaves."

	if(!usr?.mind?.changeling)
		return
	src = usr.mind.changeling

	if(usr != my_mob)
		return

	var/datum/changeling_power/source_power = get_changeling_power_by_name("Hive Absorb")
	if(!source_power)
		my_mob.verbs -= /datum/changeling/proc/hive_download
		return

	if(!source_power.is_usable())
		return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in hivemind_bank)
		if(!GetDNA(DNA.name))
			names[DNA.name] = DNA

	if(names.len <= 0)
		to_chat(my_mob, SPAN("changeling", "There's no new DNA to absorb from the air."))
		return

	var/S = input("Select a DNA to absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)
		return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	source_power.use_chems()
	absorbDNA(chosen_dna)
	to_chat(my_mob, SPAN("changeling", "We absorb the DNA of [S] from the air."))

	feedback_add_details("changeling_powers", "HD")
