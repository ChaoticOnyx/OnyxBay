
/mob/proc/changeling_division()
	set category = "Changeling"
	set name = "Division (20)"
	set desc = "We give them a gift they cannot refuse."

	var/datum/changeling/changeling = changeling_power(20, 2)
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
	if(!istype(T) || isMonkey(T) || T.isSynthetic() || (T.species.species_flags & SPECIES_FLAG_NO_SCAN))
		to_chat(src, SPAN("changeling", "[T] is not compatible with our biology."))
		return

	if(MUTATION_HUSK in T.mutations)
		to_chat(src, SPAN("changeling", "This creature's DNA is ruined!"))
		return

	if(changeling.isabsorbing)
		to_chat(src, SPAN("changeling", "Our proboscis is already in use!"))
		return

	var/obj/item/organ/external/affecting = T.get_organ(zone_sel.selecting)
	if(!affecting)
		to_chat(src, SPAN("changeling", "They are missing that body part!"))

	var/obj/item/organ/internal/brain/B = T.internal_organs_by_name[BP_BRAIN]
	if(!B || B.status == DEAD)
		to_chat(src, SPAN("changeling", "[T] is dead. We need a living creature to divide."))
		return

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
			to_chat(src, SPAN("changeling", "Transfusion of new core into [T] has been interrupted!"))
			changeling.isabsorbing = FALSE
			return

	to_chat(src, SPAN("changeling", "We successfully transfused new core into [T]!"))
	src.visible_message(SPAN("danger", "[src] transfused something into [T] through their proboscis!"))
	to_chat(T, SPAN("changeling", "You... We... Feel like something new..."))

	changeling.chem_charges -= 20
	changeling.geneticpoints -= 2

	changeling.isabsorbing = FALSE
	var/datum/antagonist/changeling/a = new
	a.create_antagonist(T.mind)

	T.mind.changeling.geneticpoints = 7
	T.mind.changeling.chem_charges = 40

	T.death(0)
