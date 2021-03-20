
//heal spell of magical magical boy
/mob/living/carbon/human/proc/wizard_heal(spell/targeted/heal)
	if(!heal)
		return
	radiation += min(radiation, heal.amt_radiation)
	regenerate_blood(heal.amt_blood)
	adjustBrainLoss(heal.amt_brain)
	for(var/A in organs)
		var/obj/item/organ/external/E = A

		if(E.status & ORGAN_ARTERY_CUT && heal.heals_internal_bleeding)
			E.status &= ~ORGAN_ARTERY_CUT
		if(E.status & ORGAN_BLEEDING && heal.heals_external_bleeding)
			E.status &= ~ORGAN_BLEEDING
			for(var/datum/wound/W in E.wounds)
				W.clamped = 1
		if(E.status & ORGAN_TENDON_CUT && heal.heal_bones)
			E.status &= ~ORGAN_TENDON_CUT
		if(E.status & ORGAN_BROKEN && heal.heal_bones) // some calcium
			E.status &= ~ORGAN_BROKEN
			E.stage = 0
	for(var/A in internal_organs)
		var/obj/item/organ/internal/E = A
		if(BP_IS_ROBOTIC(E))
			continue
		E.damage = max(0, E.damage - heal.amt_organ)
