
/mob/proc/changeling_division()
	set category = "Changeling"
	set name = "Division (20)"
	set desc = "You will be like us."
	if(is_regenerating())
		return
	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return

	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already transforming!</span>")
		return

	if(changeling.geneticpoints < 2)
		to_chat(src, "<span class='notice'>Not enough DNA.</span>")
		return

	if(changeling.chem_charges < 20)
		to_chat(src, "<span class='notice'>Not enough chemicals.</span>")
		return

	var/obj/item/grab/G = src.get_active_hand()

	if(!istype(G))
		to_chat(src, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return

	if(!G.can_absorb())
		to_chat(src, "<span class='warning'>We must have a tighter grip to create a new changelling.</span>")
		return

	var/mob/living/carbon/human/T = G.affecting

	if(!istype(T) || (T.species.species_flags & SPECIES_FLAG_NO_SCAN))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(MUTATION_HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined!</span>")
		return

	var/obj/item/organ/internal/brain/B = T.internal_organs_by_name[BP_BRAIN]
	if(!B || B.status == DEAD)
		to_chat(src, "<span class='warning'>[T] is dead. We can not create a new life.</span>")
		return

	var/obj/item/organ/external/affecting = T.get_organ(src.zone_sel.selecting)
	if(!affecting)
		to_chat(src, "<span class='warning'>They are missing that body part!</span>")
		return

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				to_chat(src, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(src, "<span class='notice'>We extend a proboscis.</span>")
				src.visible_message("<span class='warning'>[src] extends a proboscis!</span>")
			if(3)
				to_chat(src, "<span class='notice'>We stab [T] with the proboscis.</span>")
				src.visible_message("<span class='danger'>[src] stabs [T] with the proboscis!</span>")
				to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				affecting.take_external_damage(39, 0, DAM_SHARP, "large organic needle")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, "<span class='warning'>Transfusion of new core into [T] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(src, "<span class='notice'>We successfully transfused new core into [T]!</span>")
	src.visible_message("<span class='danger'>[src] transfused something into [T] through their proboscis!</span>")
	to_chat(T, "<span class='danger'>You feel like you're dying...</span>")

	changeling.chem_charges -= 20
	changeling.geneticpoints -= 2

	changeling.isabsorbing = 0
	var/datum/antagonist/changeling/a = new
	a.create_antagonist(T.mind)

	to_chat(T, "<span class='danger'>We have become!</span>") //So pretentious!
	T.mind.changeling.geneticpoints = 7
	T.mind.changeling.chem_charges = 40

	T.death(0)
	return 1
