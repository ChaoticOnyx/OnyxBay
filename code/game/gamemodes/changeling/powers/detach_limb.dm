
/datum/changeling_power/detach_limb
	name = "Detach Limb"
	desc = "We tear off our limb, turning it into an aggressive biomass."
	icon_state = "ling_detach_limb"
	required_chems = 20
	max_stat = DEAD

	var/detaching_now = FALSE

/datum/changeling_power/detach_limb/activate()
	if(!..())
		return

	if(detaching_now)
		to_chat(my_mob, SPAN("changeling", "We must focus on detaching one limb at a time."))
		return

	var/mob/living/carbon/human/H = my_mob

	var/list/detachable_limbs = H.organs.Copy()
	for(var/obj/item/organ/external/E in detachable_limbs)
		if(E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.organ_tag == BP_CHEST || E.organ_tag == BP_GROIN || E.is_stump())
			detachable_limbs -= E

	detaching_now = TRUE
	var/obj/item/organ/external/organ_to_remove = input(H, "Which limb do we want to detach?") as null|anything in detachable_limbs
	if(!organ_to_remove)
		detaching_now = FALSE
		return
	if(!H.organs.Find(organ_to_remove))
		detaching_now = FALSE
		to_chat(H, SPAN("changeling", "We don't have this limb!"))
		return

	H.visible_message(SPAN("danger", "\The [organ_to_remove] is ripping off from [H]!"), \
					  SPAN("changeling", "We begin detaching our \the [organ_to_remove]."))
	if(!do_after(H, 10, can_move = TRUE, needhand = FALSE, incapacitation_flags = INCAPACITATION_NONE))
		H.visible_message(SPAN("danger", "\The [organ_to_remove] is connecting back to [H]."), \
						  SPAN("changeling", "We were interrupted."))
		detaching_now = FALSE
		return

	playsound(H.loc, 'sound/effects/bonebreak1.ogg', 100, 1)
	use_chems()
	var/mob/living/L

	if(organ_to_remove.organ_tag == BP_L_LEG || organ_to_remove.organ_tag == BP_R_LEG)
		L = new /mob/living/simple_animal/hostile/little_changeling/leg_chan(get_turf(H))
	else if(organ_to_remove.organ_tag == BP_L_ARM || organ_to_remove.organ_tag == BP_R_ARM)
		L = new /mob/living/simple_animal/hostile/little_changeling/arm_chan(get_turf(H))
	else if(organ_to_remove.organ_tag == BP_HEAD)
		L = new /mob/living/simple_animal/hostile/little_changeling/head_chan(get_turf(H))

	var/obj/item/organ/internal/biostructure/BIO = H.internal_organs_by_name[BP_CHANG]
	if(organ_to_remove.organ_tag == BIO.parent_organ)
		H.mind.transfer_to(L)
	BIO.parent_organ = BP_CHEST

	organ_to_remove.droplimb(TRUE)
	qdel(organ_to_remove)
	H.regenerate_icons()

	detaching_now = FALSE
