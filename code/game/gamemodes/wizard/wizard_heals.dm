
//heal spell of magical magical boy
/mob/living/carbon/human/proc/shizard_heal(spell/targeted/heal)
	to_chat(src, "[src] is beign healed")
	radiation += min(radiation, heal.amt_radiation)
	regenerate_blood(heal.amt_blood)
	var/list/organs = get_damaged_organs(1, 1)
	if (organs.len)
		heal_organ_damage(heal.amt_organ,heal.amt_organ)
	for (var/A in organs)
		var/obj/item/organ/external/E = A
		if(E.status & ORGAN_ARTERY_CUT)
			E.status &= ~ORGAN_ARTERY_CUT
		if(E.status & ORGAN_BLEEDING)
			E.status &= ~ORGAN_BLEEDING
			for(var/datum/wound/W in E.wounds)
				W.clamped = 1
		if(E.status & ORGAN_TENDON_CUT && heal.heals_internal_bleeding)
			E.status &= ~ORGAN_TENDON_CUT
		if(E.status & ORGAN_BROKEN && heal.heal_bones)
			E.status &= ~ORGAN_BROKEN
			E.stage = 0
d