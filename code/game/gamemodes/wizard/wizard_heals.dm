
//heal spell of magical magical boy
/mob/living/carbon/human/proc/wizard_heal(datum/spell/targeted/heal)
	if(!heal)
		return
	radiation += heal.amt_radiation
	regenerate_blood(heal.amt_blood)
	adjustBrainLoss(heal.amt_brain)
	for(var/A in external_organs)
		var/obj/item/organ/external/E = A

		if(E.status & ORGAN_ARTERY_CUT && heal.heals_internal_bleeding)
			E.status &= ~ORGAN_ARTERY_CUT
		if(E.status & ORGAN_BLEEDING && heal.heals_external_bleeding)
			E.status &= ~ORGAN_BLEEDING
			E.scabbed = E.max_bleeding
		if(E.status & ORGAN_TENDON_CUT && heal.heal_bones)
			E.status &= ~ORGAN_TENDON_CUT
		if(E.status & ORGAN_BROKEN && heal.heal_bones) // some calcium
			E.mend_fracture()

		if(heal.removes_embeded)
			E.drop_embedded_objects()

	for(var/A in internal_organs)
		var/obj/item/organ/internal/E = A
		if(BP_IS_ROBOTIC(E))
			continue
		E.damage = max(0, E.damage - heal.amt_organ)
