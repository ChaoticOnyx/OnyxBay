
/datum/changeling_power/disjunction
	name = "Body Disjunction"
	desc = "We tear our body apart, transforming our limbs into aggressive critters."
	icon_state = "ling_gibself"
	required_chems = 80
	max_stat = DEAD

	var/detaching_now = FALSE

/datum/changeling_power/disjunction/is_usable(no_message = FALSE)
	if(!..())
		return FALSE

	if(detaching_now)
		return FALSE

	var/mob/living/carbon/human/H = my_mob

	if(H.is_ventcrawling)
		return FALSE

	return TRUE

/datum/changeling_power/disjunction/activate()
	if(!..())
		return

	var/mob/living/carbon/human/H = my_mob

	H.visible_message(SPAN("danger", "You hear a loud cracking sound coming from \the [H]."), \
					  SPAN("changeling", "We begin disjunction of our body."))

	detaching_now = TRUE
	if(!do_after(H, 60, needhand = 0, incapacitation_flags = INCAPACITATION_NONE))
		H.visible_message(SPAN("danger", "[H]'s transformation abruptly reverts itself!"), \
						  SPAN("changeling", "Our transformation has been interrupted!"))
		detaching_now = FALSE
		return

	detaching_now = FALSE
	use_chems()

	H.visible_message(SPAN("danger", "[H] falls apart as their limbs transform into gross monstrosities!"))

	playsound(H.loc, 'sound/hallucinations/far_noise.ogg', 100, 1)
	spawn(8)
		playsound(H.loc, 'sound/effects/bonebreak1.ogg', 100, 1)
	spawn(5)
		playsound(H.loc, 'sound/effects/bonebreak3.ogg', 100, 1)
	playsound(H.loc, 'sound/effects/bonebreak4.ogg', 100, 1)

	var/obj/item/organ/internal/biostructure/BIO = H.internal_organs_by_name[BP_CHANG]
	var/mob_to_receive_mind

	var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling
	var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling
	var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling2
	var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling2
	var/mob/living/simple_animal/hostile/little_changeling/head_chan/head_ling

	if(H.has_limb(BP_L_LEG))
		leg_ling = new (get_turf(H))
		if(BIO.parent_organ == BP_L_LEG)
			mob_to_receive_mind = leg_ling

	if(H.has_limb(BP_R_LEG))
		leg_ling2 = new (get_turf(H))
		if(BIO.parent_organ == BP_R_LEG)
			mob_to_receive_mind = leg_ling2

	if(H.has_limb(BP_L_ARM))
		arm_ling = new (get_turf(H))
		if(BIO.parent_organ == BP_L_ARM)
			mob_to_receive_mind = arm_ling

	if(H.has_limb(BP_R_ARM))
		arm_ling2 = new (get_turf(H))
		if(BIO.parent_organ == BP_R_ARM)
			mob_to_receive_mind = arm_ling2

	if(H.has_limb(BP_HEAD))
		head_ling = new (get_turf(H))
		if(BIO.parent_organ == BP_HEAD)
			mob_to_receive_mind = head_ling

	var/mob/living/simple_animal/hostile/little_changeling/chest_chan/chest_ling = new (get_turf(H))
	if(BIO.parent_organ == BP_CHEST || BIO.parent_organ == BP_GROIN)
		mob_to_receive_mind = chest_ling

	if(mob_to_receive_mind)
		H.mind.transfer_to(mob_to_receive_mind)
		BIO.parent_organ = BP_CHEST

	gibs(H.loc, H.dna)
	for(var/obj/item/I in H.contents)
		if(isorgan(I))
			continue
		if(I in H.contents) // Since things may actually be dropped upon removing other things (i.e. removing uniform first causes belts to drop)
			H.drop(I, force = TRUE)

	var/atom/movable/fake_overlay/effect = new /atom/movable/fake_overlay(get_turf(H))

	effect.density = FALSE
	effect.anchored = TRUE
	effect.icon = 'icons/effects/effects.dmi'
	effect.layer = 3
	flick("summoning", effect)
	QDEL_IN(effect, 10)

	qdel(H)
