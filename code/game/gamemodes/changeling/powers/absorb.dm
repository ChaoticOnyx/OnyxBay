
//Absorbs the victim's DNA making them uncloneable. Requires a strong grip on the victim.
//Doesn't cost anything as it's the most basic ability.
/datum/changeling_power/absorb
	name = "Absorb DNA"
	desc = "We absorb our prey."
	icon_state = "ling_absorb"
	required_chems = 0

/datum/changeling_power/absorb/activate()
	. = ..()
	if(!.)
		return

	var/obj/item/grab/G = my_mob.get_active_hand()
	if(!istype(G))
		to_chat(my_mob, SPAN("changeling", "We must be grabbing a creature with our active hand to absorb them."))
		return

	if(!G.can_absorb())
		to_chat(my_mob, SPAN("changeling", "We must have a tighter grip to absorb this creature."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T) || isMonkey(T) || T.isSynthetic())
		to_chat(my_mob, SPAN("changeling", "[T] is not compatible with our biology."))
		return

	if(T.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(my_mob, SPAN("changeling", "We cannot extract DNA from this creature!"))
		return

	if(MUTATION_HUSK in T.mutations)
		to_chat(my_mob, SPAN("changeling", "This creature's DNA is ruined beyond useability!"))
		return

	if(changeling.using_proboscis)
		to_chat(my_mob, SPAN("changeling", "Our proboscis is already in use!"))
		return

	var/obj/item/organ/external/affecting = T.get_organ(my_mob.zone_sel.selecting)
	if(!affecting)
		to_chat(my_mob, SPAN("changeling", "They are missing that body part!"))
		return

	for(var/datum/absorbed_dna/knownDNA in changeling.absorbed_dna)
		if(knownDNA.dna == T.dna)
			to_chat(my_mob, SPAN("changeling", "You are already have this creature's DNA!"))
			return

	changeling.using_proboscis = TRUE
	for(var/stage = 1 to 3)
		switch(stage)
			if(1)
				to_chat(my_mob, SPAN("changeling", "This creature is compatible. We must hold still..."))
			if(2)
				my_mob.visible_message(SPAN("danger", "[my_mob] extends a proboscis!"), \
					  				   SPAN("changeling", "We extend a proboscis."))
			if(3)
				my_mob.visible_message(SPAN("danger", "[my_mob] stabs [T] with the proboscis!"), \
					  				   SPAN("changeling", "We stab [T] with the proboscis."))
				to_chat(T, SPAN("danger", "You feel a sharp stabbing pain!"))
				affecting.take_external_damage(39, 0, DAM_SHARP, "large organic needle")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(my_mob, T, 150))
			to_chat(my_mob, SPAN("changeling", "Our absorption of [T] has been interrupted!"))
			changeling.using_proboscis = FALSE
			return

	my_mob.visible_message(SPAN("danger", "[my_mob] sucks the fluids from [T]!"), \
		 				   SPAN("changeling", "<b>We have absorbed [T]!</b>"))
	to_chat(T, SPAN("danger", "You have been absorbed by the changeling!"))

	changeling.chem_charges += 10
	changeling.geneticpoints += 2

	//Steal all of their languages!
	for(var/language in T.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	changeling.update_languages()

	if(T.reagents)
		T.reagents.trans_to(my_mob.reagents, T.reagents.total_volume)
	if(T.vessel)
		T.vessel.remove_any(T.vessel.total_volume)

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.name, T.languages, T.modifiers, T.flavor_texts)
	changeling.absorbDNA(newDNA)
	if(my_mob.mind && T.mind)
		my_mob.mind.store_memory("[T.real_name]'s memories:")
		my_mob.mind.store_memory(T.mind.memory)
		my_mob.mind.store_memory("<hr>")

	if(T.mind?.changeling)
		changeling.consume_changeling(T.mind.changeling)

	changeling.absorbedcount++
	changeling.using_proboscis = FALSE

	T.death(0)
	T.Drain()
