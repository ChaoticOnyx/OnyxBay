
// Makes us completely immune to pain.
/datum/changeling_power/toggled/regeneration
	name = "Passive Regeneration"
	desc = "Allows us to passively regenerate while active."
	icon_state = "ling_regeneration"
	power_processing = TRUE
	max_stat = UNCONSCIOUS
	required_chems = 20
	chems_drain = 1

	text_activate = "We activate our stemocyte pool and begin intensive fleshmending."
	text_deactivate = "We inactivate our stemocyte pool and stop intensive fleshmending."
	text_nochems = "We inactivate our stemocyte pool and stop intensive fleshmending because we run out of chemicals."

/datum/changeling_power/toggled/regeneration/activate()
	if(!..())
		return
	use_chems()

/datum/changeling_power/toggled/regeneration/think()
	. = ..()
	if(!.)
		return
	var/any_effect = FALSE
	var/mob/living/carbon/human/H = my_mob

	if(H.getBruteLoss())
		H.adjustBruteLoss(-5.0 * config.health.organ_regeneration_multiplier) // Heal brute better than other ouchies.
		any_effect = TRUE
	if(H.getFireLoss())
		H.adjustFireLoss(-3.5 * config.health.organ_regeneration_multiplier)
		any_effect = TRUE
	if(H.getToxLoss())
		H.adjustToxLoss(-5.0)
		any_effect = TRUE

	if(prob(15) && !H.getBruteLoss() && !H.getFireLoss())
		var/obj/item/organ/external/head/D = H.organs_by_name[BP_HEAD]
		if(D?.status & ORGAN_DISFIGURED)
			D.status &= ~ORGAN_DISFIGURED
			any_effect = TRUE

	for(var/obj/item/organ/internal/regen_organ in shuffle(H.internal_organs))
		if(BP_IS_ROBOTIC(regen_organ))
			continue
		if(istype(regen_organ))
			if(regen_organ.damage > 0 && !(regen_organ.status & ORGAN_DEAD))
				regen_organ.damage = max(regen_organ.damage - 5, 0)
				if(prob(5))
					to_chat(H, SPAN("changeling", "We feel a soothing sensation as our [regen_organ] mends..."))
				any_effect = TRUE
			if(regen_organ.status & ORGAN_DEAD)
				regen_organ.status &= ~ORGAN_DEAD
				to_chat(H, SPAN("changeling", "Our [regen_organ] is functioning again."))
				any_effect = TRUE

	if(prob(10))
		for(var/limb_type in shuffle(H.species.has_limbs))
			if(H.restore_limb(limb_type, 1))
				any_effect = TRUE
				break
		for(var/organ_type in shuffle(H.species.has_organ))
			if(H.restore_organ(organ_type))
				any_effect = TRUE
				break

	if(!any_effect)
		use_chems(-chems_drain) // Healed nothing, giving the spent chems back.
