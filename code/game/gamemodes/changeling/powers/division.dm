
/datum/changeling_power/division
	name = "Division"
	desc = "We infest a humanoid with a clone of our true body, making them the same as we are."
	icon_state = "ling_division"
	required_chems = 40
	required_dna = 2

/datum/changeling_power/division/activate()
	. = ..()
	if(!.)
		return

	var/obj/item/grab/G = my_mob.get_active_hand()
	if(!istype(G))
		to_chat(my_mob, SPAN("changeling", "We must be grabbing a creature with our active hand to divide."))
		return

	if(!G.can_absorb())
		to_chat(my_mob, SPAN("changeling", "We must have a tighter grip to absorb this creature."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T) || isMonkey(T) || T.isSynthetic() || (T.species.species_flags & SPECIES_FLAG_NO_SCAN))
		to_chat(my_mob, SPAN("changeling", "[T] is not compatible with our biology."))
		return

	if(MUTATION_HUSK in T.mutations)
		to_chat(my_mob, SPAN("changeling", "This creature's DNA is ruined!"))
		return

	if(changeling.using_proboscis)
		to_chat(my_mob, SPAN("changeling", "Our proboscis is already in use!"))
		return

	var/obj/item/organ/external/affecting = T.get_organ(my_mob.zone_sel.selecting)
	if(!affecting)
		to_chat(my_mob, SPAN("changeling", "They are missing that body part!"))

	var/obj/item/organ/internal/brain/B = T.internal_organs_by_name[BP_BRAIN]
	if(!B || B.status == DEAD)
		to_chat(my_mob, SPAN("changeling", "[T] is dead. We need a living creature to divide."))
		return

	if(T.mind?.changeling)
		to_chat(my_mob, SPAN("changeling", "[T] is of our kind, we cannot transfuse another core into them."))
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
			to_chat(my_mob, SPAN("changeling", "Transfusion of new core into [T] has been interrupted!"))
			changeling.using_proboscis = FALSE
			return


	my_mob.visible_message(SPAN("danger", "[my_mob] transfuses something into [T] through their proboscis!"), \
		 				   SPAN("changeling", "We have transfused a new core into [T]!"))
	to_chat(T, SPAN("changeling", "You... We... Feel like something new..."))

	use_chems()
	changeling.geneticpoints -= 2

	changeling.using_proboscis = FALSE
	var/datum/mind/M = T.mind
	var/datum/antagonist/changeling/CH = GLOB.all_antag_types_[MODE_CHANGELING]
	CH.add_antagonist(M, ignore_role = TRUE, do_not_equip = TRUE, max_stat = UNCONSCIOUS)

	M.changeling.geneticpoints = 7
	M.changeling.chem_charges = 40

	T.death(0)
