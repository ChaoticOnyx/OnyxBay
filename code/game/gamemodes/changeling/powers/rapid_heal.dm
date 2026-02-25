
//Starts healing you every tick for 10 ticks. Can be used whilst unconscious.
/datum/changeling_power/toggled/rapid_heal
	name = "Rapid Heal"
	desc = "We rapidly regenerate in a short amount of time. Does not affect stuns or chemicals."
	icon_state = "ling_rapid_heal"
	required_chems = 70
	power_processing = TRUE
	max_stat = UNCONSCIOUS

	text_activate = "We overdrive our stemocyte pool, causing our body to heal rapidly."
	text_deactivate = "Our stemocyte pool goes back to normal state."

	var/ticks_left = 0

/datum/changeling_power/toggled/rapid_heal/use()
	activate() // We can't manually deactivate this one.

/datum/changeling_power/toggled/rapid_heal/activate()
	if(!..())
		return
	ticks_left = 10
	use_chems()
	feedback_add_details("changeling_powers", "RR")

/datum/changeling_power/toggled/rapid_heal/deactivate(no_message = TRUE)
	if(!..())
		return
	ticks_left = 0

/datum/changeling_power/toggled/rapid_heal/think()
	if(!..())
		return

	if(ticks_left < 1)
		deactivate(FALSE)
		return

	if(!ishuman(my_mob))
		deactivate(FALSE)
		return

	ticks_left -= 1
	var/mob/living/carbon/human/H = my_mob

	H.adjustBruteLoss(-15)
	H.adjustToxLoss(-10)
	H.adjustOxyLoss(-5)
	H.adjustFireLoss(-10)

	for(var/obj/item/organ/internal/regen_organ in shuffle(H.internal_organs))
		if(BP_IS_ROBOTIC(regen_organ))
			continue
		if(istype(regen_organ))
			if(!regen_organ.damage && (regen_organ.status & ORGAN_BROKEN))
				regen_organ.status &= ~ORGAN_BROKEN
				to_chat(H, SPAN("changeling", "Our [regen_organ] regains its integrity."))
			else if(regen_organ.damage > 0 && !(regen_organ.status & ORGAN_DEAD))
				regen_organ.damage = max(regen_organ.damage - 10, 0)
				if(prob(5))
					to_chat(H, SPAN("changeling", "We feel a soothing sensation as our [regen_organ] mends..."))
			else if(regen_organ.status & ORGAN_DEAD)
				regen_organ.status &= ~ORGAN_DEAD
				to_chat(H, SPAN("changeling", "Our [regen_organ] is functioning again."))

	if(prob(50))
		for(var/limb_type in shuffle(H.species.has_limbs))
			if(H.restore_limb(limb_type, 1))
				break
		for(var/organ_type in shuffle(H.species.has_organ))
			if(H.restore_organ(organ_type))
				break
