/mob/living/carbon/human/handle_regular_hud_updates()

	if (src.stat == 2 || src.mutations & 4)
		src.sight |= SEE_TURFS
		src.sight |= SEE_MOBS
		src.sight |= SEE_OBJS
		src.see_in_dark = 8
		src.see_invisible = 2
	else if (src.zombie)
		src.sight |= SEE_MOBS
		src.see_in_dark = 4
		src.see_invisible = 2
	else if (istype(src.glasses, /obj/item/clothing/glasses/meson))
		src.sight |= SEE_TURFS
		src.see_in_dark = 3
		src.see_invisible = 0
	else if (istype(src.glasses, /obj/item/clothing/glasses/thermal))
		src.sight |= SEE_MOBS
		src.see_in_dark = 4
		src.see_invisible = 2
	else if (src.stat != 2)
		src.sight &= ~SEE_TURFS
		src.sight &= ~SEE_MOBS
		src.sight &= ~SEE_OBJS
		if (src.mutantrace == "lizard")
			src.see_in_dark = 3
			src.see_invisible = 1
		else
			src.see_in_dark = 2
			src.see_invisible = 0

	if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
	if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

	if (src.healths)
		if (src.stat != 2)
			switch(health)
				if(100 to INFINITY)
					src.healths.icon_state = "health0"
				if(80 to 100)
					src.healths.icon_state = "health1"
				if(60 to 80)
					src.healths.icon_state = "health2"
				if(40 to 60)
					src.healths.icon_state = "health3"
				if(20 to 40)
					src.healths.icon_state = "health4"
				if(0 to 20)
					src.healths.icon_state = "health5"
				else
					src.healths.icon_state = "health6"
		else
			src.healths.icon_state = "health7"

	if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"


	if (src.toxin)	src.toxin.icon_state = "tox[src.toxins_alert ? 1 : 0]"
	if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
	if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	switch(src.bodytemperature) //310.055 optimal body temp

		if(370 to INFINITY)
			src.bodytemp.icon_state = "temp4"
		if(350 to 370)
			src.bodytemp.icon_state = "temp3"
		if(335 to 350)
			src.bodytemp.icon_state = "temp2"
		if(320 to 335)
			src.bodytemp.icon_state = "temp1"
		if(300 to 320)
			src.bodytemp.icon_state = "temp0"
		if(295 to 300)
			src.bodytemp.icon_state = "temp-1"
		if(280 to 295)
			src.bodytemp.icon_state = "temp-2"
		if(260 to 280)
			src.bodytemp.icon_state = "temp-3"
		else
			src.bodytemp.icon_state = "temp-4"

	src.client.screen -= src.hud_used.blurry
	src.client.screen -= src.hud_used.druggy
	src.client.screen -= src.hud_used.vimpaired

	if ((src.blind && src.stat != 2))
		if ((src.blinded))
			src.blind.layer = 18
		else
			src.blind.layer = 0

			if (src.disabilities & 1 && !istype(src.glasses, /obj/item/clothing/glasses/regular) )
				src.client.screen += src.hud_used.vimpaired

			if (src.eye_blurry)
				src.client.screen += src.hud_used.blurry

			if (src.druggy)
				src.client.screen += src.hud_used.druggy

	if (src.stat != 2)
		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				src.reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/human/handle_regular_status_updates()
	health = 100 - (oxyloss + toxloss + fireloss + bruteloss + halloss)

	if(oxyloss > 50) paralysis = max(paralysis, 3)

	if(src.sleeping)
		src.paralysis = max(src.paralysis, 3)
		if (prob(10) && health) spawn(0) emote("snore")
		src.sleeping--

	if(src.resting)
		src.weakened = max(src.weakened, 5)

	if(health < -100 || src.brain_op_stage == 4.0)
		if(!src.zombie|| (src.toxloss +src.fireloss) > 100)
			death()
	else if(src.health < 0)
		if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

		//if(!src.rejuv) src.oxyloss++
		if(!src.reagents.has_reagent("inaprovaline")) src.oxyloss++

		if(src.stat != 2)	src.stat = 1
		src.paralysis = max(src.paralysis, 5)

	if (src.stat != 2) //Alive.

		if (src.paralysis || src.stunned || src.weakened || changeling_fakedeath) //Stunned etc.
			if (src.stunned > 0)
				src.stunned--
				src.stat = 0
			if (src.weakened > 0)
				src.weakened--
				src.lying = 1
				src.stat = 0
			if (src.paralysis > 0)
				src.paralysis--
				src.blinded = 1
				src.lying = 1
				src.stat = 1
			var/h = src.hand
			src.hand = 0
			drop_item()
			src.hand = 1
			drop_item()
			src.hand = h

		else	//Not stunned.
			src.lying = 0
			src.stat = 0

	else //Dead.
		src.lying = 1
		src.blinded = 1
		src.stat = 2

	if (src.stuttering) src.stuttering--
	if (src.intoxicated) src.intoxicated--

	if (src.eye_blind)
		src.eye_blind--
		src.blinded = 1

	if (src.ear_deaf > 0) src.ear_deaf--
	if (src.ear_damage < 25)
		src.ear_damage -= 0.05
		src.ear_damage = max(src.ear_damage, 0)

	src.density = !( src.lying )

	if ((src.sdisabilities & 1 || istype(src.glasses, /obj/item/clothing/glasses/blindfold)))
		src.blinded = 1
	if ((src.sdisabilities & 4 || istype(src.ears, /obj/item/clothing/ears/earmuffs)))
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		src.eye_blurry--
		src.eye_blurry = max(0, src.eye_blurry)

	if (src.druggy > 0)
		src.druggy--
		src.druggy = max(0, src.druggy)

	return 1

/mob/living/carbon/human/handle_disabilities()
	if(src.zombie == 1)
		return

	if(src.hallucination > 0)
		if(src.hallucinations.len == 0 && src.hallucination >= 20 && src.health > 0)
			if(prob(5))
				fake_attack(src)
		src.hallucination -= 1
		if(src.health < 0)
			for(var/obj/a in hallucinations)
				del a
	else
		src.halloss = 0
		for(var/obj/a in hallucinations)
			del a


	if (src.disabilities & 2)
		if ((prob(1) && src.paralysis < 1 && src.r_epil < 1))
			src << "\red You have a seizure!"
			for(var/mob/O in viewers(src, null))
				if(O == src)
					continue
				O.show_message(text("\red <B>[src] starts having a seizure!"), 1)
			src.paralysis = max(10, src.paralysis)
			src.make_jittery(1000)
	if (src.disabilities & 4)
		if ((prob(5) && src.paralysis <= 1 && src.r_ch_cou < 1))
			src.drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (src.disabilities & 8)
		if ((prob(10) && src.paralysis <= 1 && src.r_Tourette < 1))
			src.stunned = max(10, src.stunned)
			spawn( 0 )
				switch(rand(1, 3))
					if(1)
						emote("twitch")
					if(2 to 3)
						say("[prob(50) ? ";" : ""][pick("DWARFS","MAGMA","ARMOK")]!")
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-2,2)
				src.pixel_y += rand(-1,1)
				sleep(2)
				src.pixel_x = old_x
				src.pixel_y = old_y
				return
	if (src.disabilities & 16)
		if (prob(10))
			src.stuttering = max(10, src.stuttering)
//	if (src.brainloss >= 60 && src.stat != 2)

/mob/living/carbon/human/handle_chemicals_in_body()
	if(reagents) reagents.metabolize(src)

	for(var/obj/item/I in src)
		if(I.contaminated) toxloss += vsc.plc.CONTAMINATION_LOSS

	if(src.nutrition > 400 && !(src.mutations & 32))
		if(prob(5 + round((src.nutrition - 200) / 2)))
			src << "\red You suddenly feel blubbery!"
			src.mutations |= 32
			update_body()
	if (src.nutrition < 100 && src.mutations & 32)
		if(prob(round((50 - src.nutrition) / 100)))
			src << "\blue You feel fit again!"
			src.mutations &= ~32
			update_body()
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

/mob/living/carbon/human/handle_mutations_and_radiation()
	if(src.zombifying)
		src.zombietime -= 1
		if(src.zombietime <= 0)
			src.zombify()

		if(prob(5))
			src << pick("\red You feel very slow","\red You feel hungry", "\red You start drooling")


	if(src.zombie)
		src.stunned = 0
		src.paralysis = 0
		src.handcuffed = 0
		src.oxyloss = 0
		if(l_hand)
		//	u_equip(l_hand)
			if (src.client)
				src.client.screen -= l_hand
			if (l_hand)
				l_hand.loc = src.loc
				l_hand.dropped(src)
				l_hand.layer = initial(r_hand.layer)
				l_hand = null
		if(r_hand)
		//	u_equip(r_hand)
			if (src.client)
				src.client.screen -= r_hand
			if (r_hand)
				r_hand.loc = src.loc
				r_hand.dropped(src)
				r_hand.layer = initial(r_hand.layer)
				r_hand = null
		src.machine = null


	if(src.fireloss)
		if(src.mutations & 2 || prob(50))
			switch(src.fireloss)
				if(1 to 50)
					src.fireloss--
				if(51 to 100)
					src.fireloss -= 5

	if (src.mutations & 8 && src.health <= 25)
		src.mutations &= ~8
		src << "\red You suddenly feel very weak."
		src.weakened = 3
		emote("collapse")

	if (src.radiation)
		if (src.radiation > 100)
			src.radiation = 100
			src.weakened = 10
			src << "\red You feel weak."
			emote("collapse")

		if (src.radiation < 0)
			src.radiation = 0

		switch(src.radiation)
			if(1 to 49)
				src.radiation--
				if(prob(25))
					src.toxloss++
					src.updatehealth()

			if(50 to 74)
				src.radiation -= 2
				src.toxloss++
				if(prob(5))
					src.radiation -= 5
					src.weakened = 3
					src << "\red You feel weak."
					emote("collapse")
				src.updatehealth()

			if(75 to 100)
				src.radiation -= 3
				src.toxloss += 3
				if(prob(1))
					src << "\red You mutate!"
					randmutb(src)
					domutcheck(src,null)
					emote("gasp")
				src.updatehealth()

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	var/loc_temp = T0C
	if(istype(loc, /turf/space))
		environment_heat_capacity = loc:heat_capacity
		loc_temp = 2.7
	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		loc_temp = loc:air_contents.temperature
	else
		loc_temp = environment.temperature

	var/thermal_protection = get_thermal_protection()
	if(stat != 2 && abs(src.bodytemperature - 310.15) < 50)
		src.bodytemperature += adjust_body_temperature(src.bodytemperature, 310.15, thermal_protection)
	if(loc_temp < 310.15) // a cold place -> add in cold protection
		src.bodytemperature += adjust_body_temperature(src.bodytemperature, loc_temp, 1/thermal_protection)
	else // a hot place -> add in heat protection
		thermal_protection += add_fire_protection(loc_temp)
		src.bodytemperature += adjust_body_temperature(src.bodytemperature, loc_temp, 1/thermal_protection)

	var/turf/simulated/T = loc
	if(istype(T))
		if(T.active_hotspot)
			var/volume_coefficient = T.active_hotspot.volume / CELL_VOLUME
			var/resistance_coefficient = 1/max(add_fire_protection(T.active_hotspot.temperature),0.5)

			FireBurn(volume_coefficient*resistance_coefficient)

	if(environment.toxins > 0.01)
		contaminate()
		pl_effects()




	// lets give them a fair bit of leeway so they don't just start dying
	//as that may be realistic but it's no fun
	if((src.bodytemperature > (T0C + 50)) || (src.bodytemperature < (T0C + 10)) && (!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))) // Last bit is just disgusting, i know
		if(environment.temperature > (T0C + 50) || (environment.temperature < (T0C + 10)))
			var/transfer_coefficient

			transfer_coefficient = 1
			if(head && (head.body_parts_covered & HEAD) && (environment.temperature < head.protective_temperature))
				transfer_coefficient *= head.heat_transfer_coefficient
			if(wear_mask && (wear_mask.body_parts_covered & HEAD) && (environment.temperature < wear_mask.protective_temperature))
				transfer_coefficient *= wear_mask.heat_transfer_coefficient
			if(wear_suit && (wear_suit.body_parts_covered & HEAD) && (environment.temperature < wear_suit.protective_temperature))
				transfer_coefficient *= wear_suit.heat_transfer_coefficient

			handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

			transfer_coefficient = 1
			if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO) && (environment.temperature < wear_suit.protective_temperature))
				transfer_coefficient *= wear_suit.heat_transfer_coefficient
			if(w_uniform && (w_uniform.body_parts_covered & UPPER_TORSO) && (environment.temperature < w_uniform.protective_temperature))
				transfer_coefficient *= w_uniform.heat_transfer_coefficient

			handle_temperature_damage(UPPER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

			transfer_coefficient = 1
			if(wear_suit && (wear_suit.body_parts_covered & LOWER_TORSO) && (environment.temperature < wear_suit.protective_temperature))
				transfer_coefficient *= wear_suit.heat_transfer_coefficient
			if(w_uniform && (w_uniform.body_parts_covered & LOWER_TORSO) && (environment.temperature < w_uniform.protective_temperature))
				transfer_coefficient *= w_uniform.heat_transfer_coefficient

			handle_temperature_damage(LOWER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

			transfer_coefficient = 1
			if(wear_suit && (wear_suit.body_parts_covered & LEGS) && (environment.temperature < wear_suit.protective_temperature))
				transfer_coefficient *= wear_suit.heat_transfer_coefficient
			if(w_uniform && (w_uniform.body_parts_covered & LEGS) && (environment.temperature < w_uniform.protective_temperature))
				transfer_coefficient *= w_uniform.heat_transfer_coefficient

			handle_temperature_damage(LEGS, environment.temperature, environment_heat_capacity*transfer_coefficient)

			transfer_coefficient = 1
			if(wear_suit && (wear_suit.body_parts_covered & ARMS) && (environment.temperature < wear_suit.protective_temperature))
				transfer_coefficient *= wear_suit.heat_transfer_coefficient
			if(w_uniform && (w_uniform.body_parts_covered & ARMS) && (environment.temperature < w_uniform.protective_temperature))
				transfer_coefficient *= w_uniform.heat_transfer_coefficient

			handle_temperature_damage(ARMS, environment.temperature, environment_heat_capacity*transfer_coefficient)

			transfer_coefficient = 1
			if(wear_suit && (wear_suit.body_parts_covered & HANDS) && (environment.temperature < wear_suit.protective_temperature))
				transfer_coefficient *= wear_suit.heat_transfer_coefficient
			if(gloves && (gloves.body_parts_covered & HANDS) && (environment.temperature < gloves.protective_temperature))
				transfer_coefficient *= gloves.heat_transfer_coefficient

			handle_temperature_damage(HANDS, environment.temperature, environment_heat_capacity*transfer_coefficient)

			transfer_coefficient = 1
			if(wear_suit && (wear_suit.body_parts_covered & FEET) && (environment.temperature < wear_suit.protective_temperature))
				transfer_coefficient *= wear_suit.heat_transfer_coefficient
			if(shoes && (shoes.body_parts_covered & FEET) && (environment.temperature < shoes.protective_temperature))
				transfer_coefficient *= shoes.heat_transfer_coefficient

			handle_temperature_damage(FEET, environment.temperature, environment_heat_capacity*transfer_coefficient)

	/*if(stat==2) //Why only change body temp when they're dead? That makes no sense!!!!!!
		bodytemperature += 0.8*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)
	*/

	//Account for massive pressure differences
	return //TODO: DEFERRED

/mob/living/carbon/human/handle_virus_updates()
	..("Human")

/mob/living/carbon/human/breathe()
	if(src.reagents.has_reagent("lexorin")) return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

	var/datum/gas_mixture/environment = loc.return_air(1)
	var/datum/gas_mixture/breath
	// HACK NEED CHANGING LATER
	if(src.health < 0 && !src.zombie)
		src.losebreath++

	//var/halfmask = 0

	//if(wear_mask && internal)
	//	if(wear_mask.flags & 4)
	//		halfmask = 1

	if(losebreath > 10) //Suffocating so do not take a breath
		src.losebreath--
		if (prob(75)) //High chance of gasping for air
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	/*else if(halfmask)
		var/datum/gas_mixture/breath2

		breath = get_breath_from_internal(BREATH_VOLUME/2)

		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			breath2 = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME/2)
		else if(istype(loc, /turf/))
			var/breath_moles = 0
			/*if(environment.return_pressure() > ONE_ATMOSPHERE)
				// Loads of air around (pressure effects will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
				breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else*/
				// Not enough air around, take a percentage of what's there to model this properly
			breath_moles = environment.total_moles()*((BREATH_VOLUME/2)/CELL_VOLUME)

			breath2 = loc.remove_air(breath_moles)

		breath.merge(breath2)*/
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME)

		//No breath from internal atmosphere so suffocate if wearing them, otherwise try and breathe external atmosphere
		if(!breath && !internal)
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(istype(loc, /turf/))
				var/breath_moles = 0
				/*if(environment.return_pressure() > ONE_ATMOSPHERE)
					// Loads of air around (pressure effects will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
					breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else*/
					// Not enough air around, take a percentage of what's there to model this properly
				breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/human
	proc
		handle_breath(datum/gas_mixture/breath)
			if(src.nodamage)
				return
			if(src.zombie)
				src.oxyloss = 0
				var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
				var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
				if(Toxins_pp > 0.5)
					src.toxloss += 5
				var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
				if(O2_pp > 16)
					src.bruteloss -= 8
					src.bruteloss = max(100,src.bruteloss)
					src.oxyloss = 0

			if(!breath || (breath.total_moles() == 0))
				oxyloss += 14*vsc.OXYGEN_LOSS

				oxygen_alert = max(oxygen_alert, 1)

				return 0

			var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
			//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
			var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
			var/safe_toxins_max = 0.5
			var/SA_para_min = 1
			var/SA_sleep_min = 5
			var/oxygen_used = 0
			var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

			//Partial pressure of the O2 in our breath
			var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
			// Same, but for the toxins
			var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
			// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
			var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure

			if(O2_pp < safe_oxygen_min) 			// Too little oxygen
				if(prob(20))
					spawn(0) emote("gasp")
				if(O2_pp > 0)
					var/ratio = safe_oxygen_min/O2_pp
					oxyloss += min(5*ratio, 7) // Don't fuck them up too fast (space only does 7 after all!)
					oxygen_used = breath.oxygen*ratio/6
				else
					oxyloss += 7*vsc.OXYGEN_LOSS
				oxygen_alert = max(oxygen_alert, 1)
			/*else if (O2_pp > safe_oxygen_max) 		// Too much oxygen (commented this out for now, I'll deal with pressure damage elsewhere I suppose)
				spawn(0) emote("cough")
				var/ratio = O2_pp/safe_oxygen_max
				oxyloss += 5*ratio
				oxygen_used = breath.oxygen*ratio/6
				oxygen_alert = max(oxygen_alert, 1)*/
			else 									// We're in safe limits
				oxyloss = max(oxyloss-5, 0)
				oxygen_used = breath.oxygen/6
				oxygen_alert = 0

			breath.oxygen -= oxygen_used
			breath.carbon_dioxide += oxygen_used

			if(CO2_pp > safe_co2_max)
				if(!co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
					co2overloadtime = world.time
				else if(world.time - co2overloadtime > 120)
					src.paralysis = max(src.paralysis, 3)
					oxyloss += 3*vsc.OXYGEN_LOSS // Lets hurt em a little, let them know we mean business
					if(world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
						oxyloss += 8*vsc.OXYGEN_LOSS
				if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
					spawn(0) emote("cough")

			else
				co2overloadtime = 0

			if(Toxins_pp > safe_toxins_max) // Too much toxins
				var/ratio = breath.toxins/safe_toxins_max
				toxloss += min(ratio*vsc.plc.PLASMA_DMG, 10*vsc.plc.PLASMA_DMG)	//Limit amount of damage toxin exposure can do per second
				toxins_alert = max(toxins_alert, 1)
				if(vsc.plc.PLASMA_HALLUCINATION)
					hallucination += 8
			else
				toxins_alert = 0

			if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
				for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
					var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
					if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
						src.paralysis = max(src.paralysis, 3) // 3 gives them one second to wake up and run away a bit!
						if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
							src.sleeping = max(src.sleeping, 2)
						if(vsc.plc.N2O_HALLUCINATION) hallucination += 12
					else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
						if(prob(20))
							spawn(0) emote(pick("giggle", "laugh"))
						if(vsc.plc.N2O_HALLUCINATION) hallucination += 8


			if(breath.temperature > (T0C+66) && !(src.mutations & 2)) // Hot air hurts :(
				if(prob(20))
					src << "\red You feel a searing heat in your lungs!"
				fire_alert = max(fire_alert, 1)
			else
				fire_alert = 0

			if(oxyloss > 10)
				losebreath++
			//Temporary fixes to the alerts.

			return 1

		adjust_body_temperature(current, loc_temp, boost)
			var/temperature = current
			var/difference = abs(current-loc_temp)	//get difference
			var/increments// = difference/10			//find how many increments apart they are
			if(difference > 50)
				increments = difference/5
			else
				increments = difference/10
			var/change = increments*boost	// Get the amount to change by (x per increment)
			var/temp_change
			if(current < loc_temp)
				temperature = min(loc_temp, temperature+change)
			else if(current > loc_temp)
				temperature = max(loc_temp, temperature-change)
			temp_change = (temperature - current)
			return temp_change

		get_thermal_protection()
			var/thermal_protection = 1.0
			//Handle normal clothing
			if(head && (head.body_parts_covered & HEAD))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO))
				thermal_protection += 0.5
			if(w_uniform && (w_uniform.body_parts_covered & UPPER_TORSO))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & LEGS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & ARMS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & HANDS))
				thermal_protection += 0.2
			if(shoes && (shoes.body_parts_covered & FEET))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.flags & SUITSPACE))
				thermal_protection += 3
			if(head && (head.flags & HEADSPACE))
				thermal_protection += 1
			if(src.mutations & 2)
				thermal_protection += 5

			return thermal_protection

		add_fire_protection(var/temp)
			var/fire_prot = 0
			if(head)
				if(head.protective_temperature > temp)
					fire_prot += (head.protective_temperature/10)
			if(wear_mask)
				if(wear_mask.protective_temperature > temp)
					fire_prot += (wear_mask.protective_temperature/10)
			if(glasses)
				if(glasses.protective_temperature > temp)
					fire_prot += (glasses.protective_temperature/10)
			if(ears)
				if(ears.protective_temperature > temp)
					fire_prot += (ears.protective_temperature/10)
			if(wear_suit)
				if(wear_suit.protective_temperature > temp)
					fire_prot += (wear_suit.protective_temperature/10)
			if(w_uniform)
				if(w_uniform.protective_temperature > temp)
					fire_prot += (w_uniform.protective_temperature/10)
			if(gloves)
				if(gloves.protective_temperature > temp)
					fire_prot += (gloves.protective_temperature/10)
			if(shoes)
				if(shoes.protective_temperature > temp)
					fire_prot += (shoes.protective_temperature/10)

			return fire_prot

		handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
			if(src.nodamage)
				return
			var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0) * vsc.TEMP_DMG

			switch(body_part)
				if(HEAD)
					TakeDamage("head", 0, 2.5*discomfort)
				if(UPPER_TORSO)
					TakeDamage("chest", 0, 2.5*discomfort)
				if(LOWER_TORSO)
					TakeDamage("groin", 0, 2.0*discomfort)
				if(LEGS)
					TakeDamage("l_leg", 0, 0.6*discomfort)
					TakeDamage("r_leg", 0, 0.6*discomfort)
				if(ARMS)
					TakeDamage("l_arm", 0, 0.4*discomfort)
					TakeDamage("r_arm", 0, 0.4*discomfort)
				if(FEET)
					TakeDamage("l_foot", 0, 0.25*discomfort)
					TakeDamage("r_foot", 0, 0.25*discomfort)
				if(HANDS)
					TakeDamage("l_hand", 0, 0.25*discomfort)
					TakeDamage("r_hand", 0, 0.25*discomfort)

		handle_random_events()
			if (prob(1) && prob(2))
				spawn(0)
					emote("sneeze")
					return
/*
snippets

	if (src.mach)
		if (src.machine)
			src.mach.icon_state = "mach1"
		else
			src.mach.icon_state = null

	if (!src.m_flag)
		src.moved_recently = 0
	src.m_flag = null



		if ((istype(src.loc, /turf/space) && !( locate(/obj/movable, src.loc) )))
			var/layers = 20
			// ******* Check
			if (((istype(src.head, /obj/item/clothing/head) && src.head.flags & 4) || (istype(src.wear_mask, /obj/item/clothing/mask) && (!( src.wear_mask.flags & 4 ) && src.wear_mask.flags & 8))))
				layers -= 5
			if (istype(src.w_uniform, /obj/item/clothing/under))
				layers -= 5
			if ((istype(src.wear_suit, /obj/item/clothing/suit) && src.wear_suit.flags & 8))
				layers -= 10
			if (layers > oxcheck)
				oxcheck = layers


				if(src.bodytemperature < 282.591 && (!src.firemut))
					if(src.bodytemperature < 250)
						src.fireloss += 4
						src.updatehealth()
						if(src.paralysis <= 2)	src.paralysis += 2
					else if(prob(1) && !src.paralysis)
						if(src.paralysis <= 5)	src.paralysis += 5
						emote("collapse")
						src << "\red You collapse from the cold!"
				if(src.bodytemperature > 327.444  && (!src.firemut))
					if(src.bodytemperature > 345.444)
						if(!src.eye_blurry)	src << "\red The heat blurs your vision!"
						src.eye_blurry = max(4, src.eye_blurry)
						if(prob(3))	src.fireloss += rand(1,2)
					else if(prob(3) && !src.paralysis)
						src.paralysis += 2
						emote("collapse")
						src << "\red You collapse from heat exaustion!"
				plcheck = src.t_plasma
				oxcheck = src.t_oxygen
				G.turf_add(T, G.total_moles())
*/