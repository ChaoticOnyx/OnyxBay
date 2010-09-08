/mob/living/carbon/Life()
	set background = 1

	if (src.monkeyizing)
		return

	if (src.stat != 2) //still breathing

		if(air_master.current_cycle%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			spawn(0) breathe()
		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	//Disease Check
	handle_virus_updates()

	//Handle temperature/pressure differences between body and environment
	var/datum/gas_mixture/environment = loc.return_air(1)
	handle_environment(environment)

	//Mutations and radiation
	handle_mutations_and_radiation()

	//Chemicals in the body
	handle_chemicals_in_body()

	//stuff in the stomach
	handle_stomach()

	//Disabilities
	handle_disabilities()

	//Status updates, death etc.
	handle_regular_status_updates()

	// Update clothing
	update_clothing()

	if(client)
		handle_regular_hud_updates()

	//Being buckled to a chair or bed
	check_if_buckled()

	// Yup.
	update_canmove()

	clamp_values()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

/mob/living/carbon/proc/breathe()
	if(src.reagents.has_reagent("lexorin")) return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

	var/datum/gas_mixture/environment = loc.return_air(1)
	var/datum/air_group/breath
	// HACK NEED CHANGING LATER
	if(src.health < 0)
		src.losebreath++

	if(losebreath > 10) //Suffocating so do not take a breath
		src.losebreath--
		if (prob(75)) //High chance of gasping for air
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME)

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(istype(loc, /turf/))
				var/breath_moles = 0
				breath_moles = environment.total_moles()*BREATH_PERCENTAGE
				breath = loc.remove_air(breath_moles)

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(src.internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS))
			internal = null
		if(internal)
			if (src.internals)
				src.internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (src.internals)
				src.internals.icon_state = "internal0"
	return null

/mob/living/carbon/proc/handle_virus_updates(species)
	if(src.bodytemperature > 406)
		src.resistances += src.virus
		src.virus = null

	if(!src.virus)
		if(prob(40))
			for(var/mob/living/carbon/M in oviewers(4, src))
				if(M.virus && M.virus.spread == "Airborne")
					if(M.virus.affected_species.Find(species))
						if(src.resistances.Find(M.virus.type))
							continue
						var/datum/disease/D = new M.virus.type //Making sure strain_data is preserved
						D.strain_data = M.virus.strain_data
						src.contract_disease(D)
			for(var/obj/decal/cleanable/blood/B in view(4, src))
				if(B.virus && B.virus.spread == "Airborne")
					if(B.virus.affected_species.Find(species))
						if(src.resistances.Find(B.virus.type))
							continue
						var/datum/disease/D = new B.virus.type
						D.strain_data = B.virus.strain_data
						src.contract_disease(D)
	else
		src.virus.stage_act()

/mob/living/carbon/proc/handle_environment(datum/gas_mixture/environment)
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

	if(stat==2) //Why only change body temp when they're dead? That makes no sense!!!!!!
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences
	return //TODO: DEFERRED

/mob/living/carbon/proc/handle_mutations_and_radiation()
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

/mob/living/carbon/proc/handle_chemicals_in_body()
	return

/mob/living/carbon/proc/handle_stomach()
	for(var/mob/M in stomach_contents)
		if(M.loc != src)
			stomach_contents.Remove(M)
			continue
		if(istype(M, /mob/living/carbon) && src.stat != 2)
			if(M.stat == 2)
				M.death(1)
				stomach_contents.Remove(M)
				if(M.client)
					var/mob/dead/observer/newmob = new(M)
					M:client:mob = newmob
					M.mind.transfer_to(newmob)
					newmob.reset_view(null)
				del(M)
				continue
			if(air_master.current_cycle%3==1)
				if(!M.nodamage)
					M.bruteloss += 5
				src.nutrition += 10

/mob/living/carbon/proc/handle_disabilities()
	if (src.disabilities & 2)
		if ((prob(1) && src.paralysis < 10 && src.r_epil < 1))
			src << "\red You have a seizure!"
			src.paralysis = max(10, src.paralysis)
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
				emote("twitch")
				return
	if (src.disabilities & 16)
		if (prob(10))
			src.stuttering = max(10, src.stuttering)

/mob/living/carbon/proc/handle_regular_status_updates()
	updatehealth()

	if(oxyloss > oxylossparalysis) paralysis = max(paralysis, 3)

	if(src.sleeping)
		src.paralysis = max(src.paralysis, 5)
		if (prob(1) && health) spawn(0) emote("snore")
		src.sleeping--

	if(src.resting)
		src.weakened = max(src.weakened, 5)

	if(health < -100 || src.brain_op_stage == 4.0)
		death()
	else if(src.health < 0)
		if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

		//if(!src.rejuv) src.oxyloss++
		if(!src.reagents.has_reagent("inaprovaline")) src.oxyloss++

		if(src.stat != 2)	src.stat = 1
		src.paralysis = max(src.paralysis, 5)

	if (src.stat != 2) //Alive.

		if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
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

	if (src.sdisabilities & 1)
		src.blinded = 1
	if (src.sdisabilities & 4)
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		src.eye_blurry--
		src.eye_blurry = max(0, src.eye_blurry)

	if (src.druggy > 0)
		src.druggy--
		src.druggy = max(0, src.druggy)

	return 1

/mob/living/carbon/proc/handle_regular_hud_updates()
	return

/mob/living/carbon/proc/check_if_buckled()
	if (src.buckled)
		src.lying = istype(src.buckled, /obj/stool/bed) || istype(src.buckled, /obj/machinery/conveyor)
		if(src.lying)
			src.drop_item()
		src.density = 1
		if(istype(src.buckled,/obj/stool/chair)) dir = buckled.dir
	else
		src.density = !src.lying

/mob/living/carbon/proc/update_canmove()
	if(paralysis || stunned || weakened || buckled || changeling_fakedeath) canmove = 0
	else canmove = 1


/mob/living/carbon/proc/clamp_values()
	stunned = max(min(stunned, 20),0)
	paralysis = max(min(paralysis, 20), 0)
	weakened = max(min(weakened, 20), 0)
	sleeping = max(min(sleeping, 20), 0)
	bruteloss = max(bruteloss, 0)
	toxloss = max(toxloss, 0)
	oxyloss = max(oxyloss, 0)
	fireloss = max(fireloss, 0)

/mob/living/carbon/proc/handle_breath(datum/gas_mixture/breath)
	if(src.nodamage)
		return

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

/mob/living/carbon/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
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

/mob/living/carbon/proc/handle_random_events()
	if (random_events.len && prob(1) && prob(2))
		emote(pick(random_events))
		return

/mob/living/carbon/proc/adjust_body_temperature(current, loc_temp, boost)
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

/mob/living/carbon/proc/get_thermal_protection()
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

/mob/living/carbon/proc/add_fire_protection(var/temp)
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