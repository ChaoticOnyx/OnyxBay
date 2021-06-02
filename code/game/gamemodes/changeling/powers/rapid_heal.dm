
/mob/proc/changeling_rapid_heal()
	set category = "Changeling"
	set name = "Passive Regeneration (10)"
	set desc = "Allows us to passively regenerate while active."

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.mind.changeling.heal)
			H.mind.changeling.heal = !H.mind.changeling.heal
			to_chat(H, SPAN("changeling", "We inactivate our stemocyte pool and stop intensive fleshmending."))
			return

		var/datum/changeling/changeling = changeling_power(10, 0, 0, DEAD)
		if(!changeling)
			return

		H.mind.changeling.heal = !H.mind.changeling.heal
		to_chat(H, SPAN("changeling", "We activate our stemocyte pool and begin intensive fleshmending."))

		spawn(0)
			while(H && H.mind && H.mind.changeling.heal && H.mind.changeling.damaged && !is_regenerating())
				H.mind.changeling.chem_charges = max(H.mind.changeling.chem_charges - 1, 0)
				if(H.getBruteLoss())
					H.adjustBruteLoss(-15 * config.organ_regeneration_multiplier) // Heal brute better than other ouchies.
				if(H.getFireLoss())
					H.adjustFireLoss(-10 * config.organ_regeneration_multiplier)
				if(H.getToxLoss())
					H.adjustToxLoss(-15 * config.organ_regeneration_multiplier)

				if(prob(15) && !H.getBruteLoss() && !H.getFireLoss())
					var/obj/item/organ/external/head/D = H.organs_by_name[BP_HEAD]
					if(D.status & ORGAN_DISFIGURED)
						D.status &= ~ORGAN_DISFIGURED

				for(var/bpart in shuffle(H.internal_organs_by_name))
					var/obj/item/organ/internal/regen_organ = H.internal_organs_by_name[bpart]
					if(BP_IS_ROBOTIC(regen_organ))
						continue
					if(istype(regen_organ))
						if(regen_organ.damage > 0 && !(regen_organ.status & ORGAN_DEAD))
							regen_organ.damage = max(regen_organ.damage - 5, 0)
							if(prob(5))
								to_chat(H, SPAN("changeling", "We feel a soothing sensation as our [regen_organ] mends..."))
						if(regen_organ.status & ORGAN_DEAD)
							regen_organ.status &= ~ORGAN_DEAD

				if(prob(50))
					for(var/limb_type in H.species.has_limbs)
						if(H.restore_limb(limb_type, 1))
							break
					for(var/organ_type in H.species.has_organ)
						if(H.restore_organ(organ_type))
							break

				if(H.mind.changeling.chem_charges == 0)
					H.mind.changeling.heal = !H.mind.changeling.heal
					to_chat(H, SPAN("changeling", "We inactivate our stemocyte pool and stop intensive fleshmending because we run out of chemicals."))
				sleep(40)
