
/datum/spell/healthy_sleep
	name = "Take a nap"
	desc = "Healthy sleep is a basic need that is closely tied to health and wellbeing."
	spell_flags = INCLUDEUSER
	charge_max = 120 SECONDS
	duration = 30 SECONDS

	invocation = "lies down and falls asleep immediately."
	invocation_type = SPI_EMOTE

	range = 0
	icon_state = "wiz_sleep"

/datum/spell/healthy_sleep/cast(list/targets, mob/user)
	user.sleeping = max(30, user.sleeping)
	addtimer(CALLBACK(src, nameof(.proc/wakethefuckup), user), duration)

/datum/spell/healthy_sleep/proc/wakethefuckup(mob/user)
	if(QDELETED(user) || user.is_ic_dead())
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	H.restore_blood()
	H.adjustToxLoss(H.getToxLoss() * -1)
	H.adjustOxyLoss(H.getOxyLoss() * -1)
	H.adjustBrainLoss(H.getBrainLoss() * -1)
	H.heal_overall_damage(H.getBruteLoss(), H.getFireLoss())

	var/list/organs = H.get_damaged_organs(1, 1)
	for(var/A in organs)
		var/obj/item/organ/external/E = A
		if(E.status & ORGAN_ARTERY_CUT)
			E.status &= ~ORGAN_ARTERY_CUT
		if(E.status & ORGAN_TENDON_CUT)
			E.status &= ~ORGAN_TENDON_CUT
		if(E.status & ORGAN_BROKEN)
			E.mend_fracture()
			E.stage = 0

	H.updatehealth()
	user.sleeping = 0
	to_chat(H, SPAN("notice", "<b>You've had a good rest. Now you absolutely need to munch on something.</b>"))
	H.remove_nutrition(H.nutrition)
