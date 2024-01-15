
//heal spell of magical magical boy
/mob/living/carbon/human/proc/wizard_heal(datum/spell/targeted/heal)
	if(!heal)
		return
	radiation += heal.amt_radiation
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
			E.mend_fracture()
			E.stage = 0

		if(heal.removes_embeded)
			for(var/obj/implanted_object in E.implants)
				implanted_object.dropInto(get_turf(loc))
				E.implants -= implanted_object
				if(istype(implanted_object, /obj/item/implant))
					var/obj/item/implant/removed_implant = implanted_object
					removed_implant.removed()
				for(var/datum/wound/wound in E.wounds)
					if(implanted_object in wound.embedded_objects)
						wound.embedded_objects -= implanted_object
						break

	for(var/A in internal_organs)
		var/obj/item/organ/internal/E = A
		if(BP_IS_ROBOTIC(E))
			continue
		E.damage = max(0, E.damage - heal.amt_organ)
