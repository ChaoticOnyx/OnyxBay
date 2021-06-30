
//Absorbs the victim's DNA making them uncloneable. Requires a strong grip on the victim.
//Doesn't cost anything as it's the most basic ability.
/mob/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return

	var/obj/item/grab/G = get_active_hand()
	if(!istype(G))
		to_chat(src, SPAN("changeling", "We must be grabbing a creature with our active hand to absorb them."))
		return

	if(!G.can_absorb())
		to_chat(src, SPAN("changeling", "We must have a tighter grip to absorb this creature."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T) || isMonkey(T) || T.isSynthetic())
		to_chat(src, SPAN("changeling", "[T] is not compatible with our biology."))
		return

	if(T.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(src, SPAN("changeling", "We cannot extract DNA from this creature!"))
		return

	if(MUTATION_HUSK in T.mutations)
		to_chat(src, SPAN("changeling", "This creature's DNA is ruined beyond useability!"))
		return

	if(changeling.isabsorbing)
		to_chat(src, SPAN("changeling", "Our proboscis is already in use!"))
		return

	var/obj/item/organ/external/affecting = T.get_organ(zone_sel.selecting)
	if(!affecting)
		to_chat(src, SPAN("changeling", "They are missing that body part!"))

	changeling.isabsorbing = TRUE
	for(var/stage = 1 to 3)
		switch(stage)
			if(1)
				to_chat(src, SPAN("changeling", "This creature is compatible. We must hold still..."))
			if(2)
				to_chat(src, SPAN("changeling", "We extend a proboscis."))
				visible_message(SPAN("danger", "[src] extends a proboscis!"))
			if(3)
				to_chat(src, SPAN("changeling", "We stab [T] with the proboscis."))
				visible_message(SPAN("danger", "[src] stabs [T] with the proboscis!"))
				to_chat(T, SPAN("danger", "You feel a sharp stabbing pain!"))
				affecting.take_external_damage(39, 0, DAM_SHARP, "large organic needle")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, SPAN("changeling", "Our absorption of [T] has been interrupted!"))
			changeling.isabsorbing = FALSE
			return

	to_chat(src, SPAN("changeling", "<b>We have absorbed [T]!</b>"))
	src.visible_message(SPAN("danger", "[src] sucks the fluids from [T]!"))
	to_chat(T, SPAN("danger", "You have been absorbed by the changeling!"))
	changeling.chem_charges += 10
	changeling.geneticpoints += 2

	//Steal all of their languages!
	for(var/language in T.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	changeling_update_languages(changeling.absorbed_languages)

	if(T.reagents)
		T.reagents.trans_to(reagents, T.reagents.total_volume)
	if(T.vessel)
		T.vessel.remove_any(T.vessel.total_volume)

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.name, T.languages, T.modifiers, T.flavor_texts)
	absorbDNA(newDNA)
	if(mind && T.mind)
		mind.store_memory("[T.real_name]'s memories:")
		mind.store_memory(T.mind.memory)
		mind.store_memory("<hr>")

	if(T.mind?.changeling)
		if(T.mind.changeling.absorbed_dna)
			for(var/datum/absorbed_dna/dna_data in T.mind.changeling.absorbed_dna)	// steal all their loot
				if(changeling.GetDNA(dna_data.name))
					continue
				absorbDNA(dna_data)
				changeling.absorbedcount++
			T.mind.changeling.absorbed_dna.len = 1

		if(T.mind.changeling.purchasedpowers)
			for(var/datum/power/changeling/T_power in T.mind.changeling.purchasedpowers)
				if(T_power in changeling.purchasedpowers)
					continue
				else
					changeling.purchasedpowers += T_power

					if(!T_power.isVerb)
						call(T_power.verbpath)()
					else
						make_changeling()

		changeling.chem_charges += T.mind.changeling.chem_charges
		changeling.geneticpoints += T.mind.changeling.geneticpoints
		T.mind.changeling.chem_charges = 0
		T.mind.changeling.geneticpoints = 0
		T.mind.changeling.absorbedcount = 0

	changeling.absorbedcount++
	changeling.isabsorbing = FALSE

	T.death(0)
	T.Drain()
