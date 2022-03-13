
//Change our DNA to that of somebody we've absorbed.
/datum/changeling_power/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	icon_state = "ling_transform"
	required_chems = 10
	required_dna = 1
	max_genetic_damage = 0

/datum/changeling_power/transform/activate()
	if(!..())
		return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		names += "[DNA.name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	use_chems()
	changeling.geneticdamage += 30

	var/S_name = chosen_dna.speciesName
	var/datum/species/S_dat = all_species[S_name]

	var/change_time = 2 SECONDS
	if(my_mob.mob_size != S_dat.mob_size)
		my_mob.visible_message(SPAN("warning", "[my_mob]'s body begins to twist, their mass changing rapidly!"))
		change_time = 8 SECONDS
	else
		my_mob.visible_message(SPAN("warning", "[my_mob]'s body begins to twist, changing rapidly!"))

	if(!do_after(my_mob, change_time, can_move = 1))
		to_chat(my_mob, SPAN("changeling", "We fail to change shape."))
		return

	handle_transformation(chosen_dna)

	changeling.last_transformation_at = world.time
	changeling.update_languages()

	feedback_add_details("changeling_powers","TR")

/datum/changeling_power/transform/proc/handle_transformation(datum/absorbed_dna/chosen_dna)
	my_mob.visible_message(SPAN("warning", "[my_mob] transforms!"), \
						   SPAN("changeling", "We change our shape."))

	my_mob.dna = chosen_dna.dna
	my_mob.real_name = chosen_dna.name
	my_mob.flavor_text = ""

	if(ishuman(my_mob))
		var/mob/living/carbon/human/H = my_mob
		var/newSpecies = chosen_dna.speciesName
		H.modifiers = chosen_dna.modifiers
		H.flavor_texts = chosen_dna.flavor_texts
		var/datum/species/newS_dat = all_species[newSpecies]
		if(H.mob_size != newS_dat.mob_size)
			for (var/obj/item/underwear/U in H.worn_underwear)
				H.worn_underwear -= U
				H.drop_from_inventory(U)
			H.update_underwear()
		H.set_species(newSpecies, 1)
		H.b_type = chosen_dna.dna.b_type
		H.sync_organ_dna()
		H.make_changeling()
	domutcheck(my_mob, null)
	my_mob.UpdateAppearance()
