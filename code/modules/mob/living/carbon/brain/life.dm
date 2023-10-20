/mob/living/carbon/brain/handle_breathing()
	return

/mob/living/carbon/brain/handle_mutations_and_radiation()
	if(!radiation)
		return

	if(radiation > 100)
		radiation = 100
		if(!container) //If it's not in an MMI
			to_chat(src, SPAN_NOTICE("You feel weak."))
		else //Fluff-wise, since the brain can't detect anything itself, the MMI handles thing like that
			to_chat(src, SPAN_WARNING("STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED."))
	switch(radiation)
		if(1 to 49)
			radiation--
			if(prob(25))
				adjustToxLoss(1)
				updatehealth()

		if(50 to 74)
			radiation -= 2
			adjustToxLoss(1)
			if(prob(5))
				radiation -= 5
				if(!container)
					to_chat(src, SPAN_WARNING("You feel weak."))
				else
					to_chat(src, SPAN_WARNING("STATUS: DANGEROUS LEVELS OF RADIATION DETECTED."))
			updatehealth()

		if(75 to 100)
			radiation -= 3
			adjustToxLoss(3)
			updatehealth()

/mob/living/carbon/brain/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if((environment.temperature > (50 CELSIUS)) || (environment.temperature < (10 CELSIUS)))
		var/transfer_coefficient = 1

		handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat==2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	// Account for massive pressure differences

	return //TODO: DEFERRED

/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE) return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		//adjustFireLoss(2.5*discomfort)
		//adjustFireLoss(5.0*discomfort)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		//adjustFireLoss(2.5*discomfort)
		adjustFireLoss(5.0*discomfort)


/mob/living/carbon/brain/handle_chemicals_in_body()
	chem_effects.Cut()

	if(touching) touching.metabolize()
	var/datum/reagents/metabolism/ingested = get_ingested_reagents()
	if(istype(ingested)) ingested.metabolize()
	if(bloodstr) bloodstr.metabolize()

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
	else
		dizziness = max(0, dizziness - 1)

	updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/brain/handle_regular_status_updates()	//TODO: comment out the unused bits >_>
	updatehealth()

	if(is_ooc_dead())	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if(!container && ((health < config.health.health_threshold_dead) || (world.time - timeofhostdeath > config.revival.revival_brain_life) && (config.revival.revival_brain_life >= 0)))
			death()
			blinded = 1
			silent = 0
			return 1

		//Handling EMP effect in the Life(), it's made VERY simply, and has some additional effects handled elsewhere
		if(emp_damage)			//This is pretty much a damage type only used by MMIs, dished out by the emp_act
			if(!(container && istype(container, /obj/item/organ/internal/cerebrum/mmi)))
				emp_damage = 0
			else
				emp_damage = round(emp_damage,1) //Let's have some nice numbers to work with
			switch(emp_damage)
				if(31 to INFINITY)
					emp_damage = 30 //Let's not overdo it
				if(21 to 30) //High level of EMP damage, unable to see, hear, or speak
					eye_blind = 1
					blinded = 1
					ear_deaf = 1
					silent = 1
					if(!alert) //Sounds an alarm, but only once per 'level'
						emote("alarm")
						to_chat(src, SPAN_WARNING("Major electrical distruption detected: System rebooting."))
						alert = 1
					if(prob(75))
						emp_damage -= 1
				if(20)
					alert = 0
					blinded = 0
					eye_blind = 0
					ear_deaf = 0
					silent = 0
					emp_damage -= 1
				if(11 to 19) //Moderate level of EMP damage, resulting in nearsightedness and ear damage
					eye_blurry = 1
					ear_damage = 1
					if(!alert)
						emote("alert")
						to_chat(src, SPAN_WARNING("Primary systems are now online."))
						alert = 1
					if(prob(50))
						emp_damage -= 1
				if(10)
					alert = 0
					eye_blurry = 0
					ear_damage = 0
					emp_damage -= 1
				if(2 to 9) //Low level of EMP damage, has few effects(handled elsewhere)
					if(!alert)
						emote("notice")
						to_chat(src, SPAN_WARNING("System reboot nearly complete."))
						alert = 1
					if(prob(25))
						emp_damage -= 1
				if(1)
					alert = 0
					to_chat(src, SPAN_WARNING("All systems restored."))
					emp_damage -= 1

	return 1

/mob/living/carbon/brain/handle_regular_hud_updates()
	update_sight()

	if(!is_ooc_dead())
		if(blinded)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")
			set_fullscreen(disabilities & NEARSIGHTED, "impaired", /obj/screen/fullscreen/impaired, 1)
			set_renderer_filter(eye_blurry, GAME_RENDERER, EYE_BLURRY_FILTER, 0, list(type="blur",size=clamp(eye_blurry/2, 0, 2)))
			set_fullscreen(druggy, "high", /obj/screen/fullscreen/high)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1
