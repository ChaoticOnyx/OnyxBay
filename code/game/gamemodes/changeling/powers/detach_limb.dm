
/mob/proc/changeling_detach_limb()
	set category = "Changeling"
	set name = "Detach Limb (10)"
	set desc = "We tear off our limb, turning it into an aggressive biomass."
	if(is_regenerating())
		return
	var/datum/changeling/changeling = changeling_power(10, max_stat = DEAD)
	if(!changeling)	return
	if(changeling.isdetachingnow)	return
	var/mob/living/carbon/T = src
	T.faction = "biomass"
	var/list/detachable_limbs = T.organs.Copy()
	for (var/obj/item/organ/external/E in detachable_limbs)
		if (E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.organ_tag == BP_CHEST || E.organ_tag == BP_GROIN || E.is_stump())
			detachable_limbs -= E
	changeling.isdetachingnow = TRUE
	var/obj/item/organ/external/organ_to_remove = input(T, "Which organ do you want to detach?") as null|anything in detachable_limbs
	if(!organ_to_remove)
		changeling.isdetachingnow = FALSE
		return 0
	if(!T.organs.Find(organ_to_remove))
		changeling.isdetachingnow = FALSE
		to_chat(T,"<span class='notice'>We don't have this limb!</span>")
		return 0

	src.visible_message("<span class='danger'>\the [organ_to_remove] ripping off from [src].</span>", \
					"<span class='danger'>We begin ripping our \the [organ_to_remove].</span>")
	if(!do_after(src,10,can_move = 1,needhand = 0,incapacitation_flags = INCAPACITATION_NONE))
		src.visible_message("<span class='notice'>\the [organ_to_remove] connecting back to [src].</span>", \
					"<span class='danger'>We were interrupted.</span>")
		changeling.isdetachingnow = FALSE
		return 0
	playsound(loc, 'sound/effects/bonebreak1.ogg', 100, 1)
	T.mind.changeling.chem_charges -= 10
	var/mob/living/L

	if(organ_to_remove.organ_tag == BP_L_LEG || organ_to_remove.organ_tag == BP_R_LEG)
		L = new /mob/living/simple_animal/hostile/little_changeling/leg_chan(get_turf(T))
	else if(organ_to_remove.organ_tag == BP_L_ARM || organ_to_remove.organ_tag == BP_R_ARM)
		L = new /mob/living/simple_animal/hostile/little_changeling/arm_chan(get_turf(T))
	else if(organ_to_remove.organ_tag == BP_HEAD)
		L = new /mob/living/simple_animal/hostile/little_changeling/head_chan(get_turf(T))

	var/obj/item/organ/internal/biostructure/BIO = T.internal_organs_by_name[BP_CHANG]
	if (organ_to_remove.organ_tag == BIO.parent_organ)
		changeling_transfer_mind(L)

	organ_to_remove.droplimb(1)
	qdel(organ_to_remove)

	var/mob/living/carbon/human/H = T
	if(istype(H))
		H.regenerate_icons()

	changeling.isdetachingnow = FALSE
