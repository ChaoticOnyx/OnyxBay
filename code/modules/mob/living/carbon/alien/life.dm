/mob/living/carbon/alien/update_canmove()
	if(paralysis || stunned || weakened || buckled) canmove = 0
	else canmove = 1

/mob/living/carbon/alien/check_if_buckled()
	if (src.buckled)
		src.lying = (istype(src.buckled, /obj/stool/bed) ? 1 : 0)
		if(src.lying)
			src.drop_item()
		src.density = 1
	else
		src.density = !src.lying

/mob/living/carbon/alien/handle_chemicals_in_body()
	if(reagents) reagents.metabolize(src)

	if(src.nutrition > 400 && !(src.mutations & 32))
		if(prob(5 + round((src.nutrition - 200) / 2)))
			src << "\red You suddenly feel blubbery!"
			src.mutations |= 32
//					update_body()
	if (src.nutrition < 100 && src.mutations & 32)
		if(prob(round((50 - src.nutrition) / 100)))
			src << "\blue You feel fit again!"
			src.mutations &= ~32
//					update_body()
	if (src.nutrition > 0)
		src.nutrition--

	if (src.drowsyness)
		src.drowsyness--
		src.eye_blurry = max(2, src.eye_blurry)
		if (prob(5))
			src.sleeping = 1
			src.paralysis = 5

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

	src.updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/alien/handle_breath(datum/gas_mixture/breath)
	if(src.nodamage)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure

	if(Toxins_pp) // Detect toxins in air

		toxloss += breath.toxins*250
		toxins_alert = max(toxins_alert, 1)

		toxins_used = breath.toxins

	else
		toxins_alert = 0

	//Breathe in toxins and out oxygen
	breath.toxins -= toxins_used
	breath.oxygen += toxins_used

	if(breath.temperature > (T0C+66) && !(src.mutations & 2)) // Hot air hurts :(
		if(prob(20))
			src << "\red You feel a searing heat in your lungs!"
		fire_alert = max(fire_alert, 1)
	else
		fire_alert = 0

	//Temporary fixes to the alerts.

	if(oxyloss > 10)
		losebreath++

	return 1

/mob/living/carbon/alien/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)

/mob/living/carbon/alien/handle_random_events()

/mob/living/carbon/alien/handle_environment()
	//If there are alien weeds on the ground then heal if needed or give some toxins
	if(locate(/obj/alien/weeds) in loc)
		if(health >= health_full)
			toxloss += toxgain
		else
			bruteloss -= 5
			fireloss -= 5