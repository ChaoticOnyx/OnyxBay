/mob/living/carbon/alien/update_canmove()
	if(paralysis || stunned || weakened || buckled) canmove = 0
	else canmove = 1

/mob/living/carbon/alien/check_if_buckled()
	if (buckled)
		lying = (istype(buckled, /obj/stool/bed) ? 1 : 0)
		if(lying)
			drop_item()
		density = 1
	else
		density = !lying

/mob/living/carbon/alien/handle_chemicals_in_body()
	if(reagents) reagents.metabolize(src)

	/*
	if(nutrition > 400 && !(mutations & 32))
		if(prob(5 + round((nutrition - 200) / 2)))
			src << "\red You suddenly feel blubbery!"
			mutations |= 32
				//update_body()
	if (nutrition < 100 && mutations & 32)
		if(prob(round((50 - nutrition) / 100)))
			src << "\blue You feel fit again!"
			mutations &= ~32
				//update_body()
	*/
	if (nutrition > 0)
		nutrition--

	if (drowsyness)
		drowsyness--
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			sleeping = 1
			paralysis = 5

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

	updatehealth()

	return //TODO: DEFERRED


/mob/living/carbon/alien/breathe()
	// Aliens right now do not breathe at all, only absorb the plasma around them and let oxygen out

	// if(mutations & mNobreath) return  // TODO: Mutations maybe? Make them absorb more stuff? - Abi

	// if(reagents.has_reagent("lexorin")) return // TODO: Give aliens chemical interaction, but give them other effects and keep it secret from the players.
												// Promote catching aliens and research - Abi

	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

	var/datum/gas_mixture/environment = loc.return_air(1)
	var/datum/air_group/breath

	if(istype(loc, /obj/))
		var/obj/location_as_object = loc
		breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
	else if (istype(loc, /turf/))
		var/breath_moles = 0
		breath_moles = environment.total_moles()*BREATH_PERCENTAGE
		breath = loc.remove_air(breath_moles)

	handle_breath(breath)

	if(breath)
		loc.assume_air(breath)


/mob/living/carbon/alien/handle_breath(datum/gas_mixture/breath)
	if(nodamage)
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

	if(breath.temperature > (T0C+66) && !(mutations & 2)) // Hot air hurts :(
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
			if(toxloss + toxgain <= toxgainmax)
				toxloss += toxgain
		else
			bruteloss -= 5
			fireloss -= 5