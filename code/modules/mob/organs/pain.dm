/mob/proc/flash_pain(target)
	if(pain)
		animate(pain, alpha = target, time = 15, easing = ELASTIC_EASING)
		animate(pain, alpha = 0, time = 20)

// message is the custom message to be displayed
// power decides how much painkillers will stop the message
// force means it ignores anti-spam timer
/mob/living/carbon/proc/custom_pain(message, power, force, obj/item/organ/external/affecting, nohalloss)
	if(stat || !can_feel_pain() || chem_effects[CE_PAINKILLER] > power)
		return 0

	power -= chem_effects[CE_PAINKILLER] / 2 //Take the edge off.

	if(!message)
		if(affecting)
			message = affecting.get_default_pain_message(power)
		else
			message = "You suddenly feel pain!"

	// Excessive halloss is horrible, just give them enough to make it visible.
	if(!nohalloss && power)
		if(affecting)
			affecting.adjust_pain(ceil(power / 2))
		else
			adjustHalLoss(ceil(power / 2))

	flash_pain(min(round(2 * power) + 55, 255))

	// Anti message spam checks
	if(force || (message != last_pain_message) || (world.time >= next_pain_time))
		last_pain_message = message
		if(power >= 70)
			to_chat(src, SPAN("danger", "<font size=3>[message]</font>"))
		else if(power >= 40)
			to_chat(src, SPAN("danger", "<font size=2>[message]</font>"))
		else if(power >= 10)
			to_chat(src, SPAN("danger", "[message]"))
		else
			to_chat(src, SPAN("warning", "[message]"))
	next_pain_time = world.time + (100 - power)

/mob/living/carbon/human/proc/handle_pain()
	if(stat)
		return
	if(!can_feel_pain())
		return
	if(world.time < next_pain_time)
		return

	var/maxdam = 0
	var/obj/item/organ/external/damaged_organ = null
	for(var/obj/item/organ/external/E in organs)
		if(!E.can_feel_pain())
			continue
		var/dam = E.get_damage()
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam > maxdam && (maxdam == 0 || prob(70)))
			damaged_organ = E
			maxdam = dam

	if(damaged_organ && chem_effects[CE_PAINKILLER] < maxdam)
		if(maxdam > 10 && paralysis)
			paralysis = max(0, paralysis - round(maxdam/10))
		if(maxdam > 50 && prob(maxdam / 5))
			if(prob(50))
				drop_active_hand()
			else
				drop_inactive_hand()
		custom_pain(null, maxdam, prob(10), damaged_organ, TRUE)

	// Damage to internal organs hurts a lot.
	for(var/obj/item/organ/internal/I in internal_organs)
		if(prob(1) && !((I.status & ORGAN_DEAD) || BP_IS_ROBOTIC(I)) && I.damage > 5)
			var/obj/item/organ/external/parent = get_organ(I.parent_organ)
			var/pain = 10
			var/message = "You feel a dull pain in your [parent.name]"
			if(I.is_bruised())
				pain = 25
				message = "You feel a pain in your [parent.name]"
			if(I.is_broken())
				pain = 50
				message = "You feel a sharp pain in your [parent.name]"
			custom_pain(message, pain, affecting = parent)

	if(prob(1))
		switch(getToxLoss())
			if(5 to 17)
				custom_pain("Your body stings slightly.", getToxLoss())
			if(17 to 35)
				custom_pain("Your body stings.", getToxLoss())
			if(35 to 60)
				custom_pain("Your body stings strongly.", getToxLoss())
			if(60 to 100)
				custom_pain("Your whole body hurts badly.", getToxLoss())
			if(100 to INFINITY)
				custom_pain("Your body aches all over, it's driving you mad.", getToxLoss())
