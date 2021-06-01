
/mob/proc/changeling_gib_self()
	set category = "Changeling"
	set name = "Body Disjunction (40)"
	set desc = "Tear apart your human disguise, revealing your little form."
	if(is_regenerating())
		return
	var/datum/changeling/changeling = changeling_power(40,0,0,DEAD)
	if(!changeling)	return 0


	var/mob/living/carbon/M = src

	M.visible_message("<span class='danger'>You hear a loud cracking sound coming from \the [M].</span>", \
						"<span class='danger'>We begin disjunction of our body to form a pack of autonomous organisms.</span>")

	if(!do_after(src,60,needhand = 0,incapacitation_flags = INCAPACITATION_NONE))
		M.visible_message("<span class='danger'>[M]'s transformation abruptly reverts itself!</span>", \
							"<span class='danger'>Our transformation has been interrupted!</span>")
		return 0
	src.mind.changeling.chem_charges -= 40
	M.visible_message("<span class='danger'>[M] falls apart, their limbs formed a gross monstrosities!</span>")
	playsound(loc, 'sound/hallucinations/far_noise.ogg', 100, 1)
	spawn(8)
		playsound(loc, 'sound/effects/bonebreak1.ogg', 100, 1)
	spawn(5)
		playsound(loc, 'sound/effects/bonebreak3.ogg', 100, 1)
	playsound(loc, 'sound/effects/bonebreak4.ogg', 100, 1)
	var/obj/item/organ/internal/biostructure/BIO = M.internal_organs_by_name[BP_CHANG]
	var/organ_chang_type = BIO.parent_organ

	var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling
	var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling
	var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling2
	var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling2
	var/mob/living/simple_animal/hostile/little_changeling/head_chan/head_ling
	if (M.has_limb(BP_L_LEG))
		leg_ling = new (get_turf(M))
		if(organ_chang_type == BP_L_LEG)
			changeling_transfer_mind(leg_ling)
	if (M.has_limb(BP_R_LEG))
		leg_ling2 = new (get_turf(M))
		if(organ_chang_type == BP_R_LEG)
			changeling_transfer_mind(leg_ling2)
	if (M.has_limb(BP_L_ARM))
		arm_ling = new (get_turf(M))
		if(organ_chang_type == BP_L_ARM)
			changeling_transfer_mind(arm_ling)
	if (M.has_limb(BP_R_ARM))
		arm_ling2 = new (get_turf(M))
		if(organ_chang_type == BP_R_ARM)
			changeling_transfer_mind(arm_ling2)
	if (M.has_limb(BP_HEAD))
		head_ling = new (get_turf(M))
		if(organ_chang_type == BP_HEAD)
			changeling_transfer_mind(head_ling)
	var/mob/living/simple_animal/hostile/little_changeling/chest_chan/chest_ling = new (get_turf(M))
	if(organ_chang_type == BP_CHEST || organ_chang_type == BP_GROIN)
		changeling_transfer_mind(chest_ling)

	gibs(loc, dna)
	if(istype(M,/mob/living/carbon/human))
		for(var/obj/item/I in M.contents)
			if(isorgan(I))
				continue
			M.drop_from_inventory(I)

	var/atom/movable/overlay/effect = new /atom/movable/overlay(get_turf(M))

	effect.density = 0
	effect.anchored = 1
	effect.icon = 'icons/effects/effects.dmi'
	effect.layer = 3
	flick("summoning",effect)
	QDEL_IN(effect, 10)

	qdel(M)
