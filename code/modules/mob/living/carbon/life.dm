/mob/var/lastbreathT = 0
/mob/living/carbon/var/lyingcheck = 0

/mob/living/carbon/Life()
	set background = 1

	if (monkeyizing)
		return

	if (stat != 2) //still breathing
		if(lastbreathT <= world.timeofday - 40)
			//Only try to take a breath every 4 seconds, unless suffocating
			lastbreathT = world.timeofday
			breathe()
			if(lastbreathT > world.timeofday)	//Midnight rollover check
				lastbreathT = 0
		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

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

	handle_pain()

	// Update clothing
	//update_clothing()		Strumpet - Removing this to see if it's really necessary.  Could save some processing.
	if(lyingcheck != lying)		//This is a fix for falling down / standing up not updating icons.  Instead of going through and changing every
		update_clothing()		//instance in the code where lying is modified, I've just added a new variable "lyingcheck" which will be compared
		lyingcheck = lying		//to lying, so if lying ever changes, update_clothing() will run like normal.

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
	if(reagents.has_reagent("lexorin")) return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

	var/datum/gas_mixture/environment = loc.return_air(1)
	var/datum/air_group/breath
	// HACK NEED CHANGING LATER
	if(health < 0)
		losebreath++

	if(losebreath > 10) //Suffocating so do not take a breath
		losebreath--
		if (prob(75)) //High chance of gasping for air
			emote("gasp")
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
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS))
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return null

/mob/living/carbon/proc/handle_virus_updates()
	if(bodytemperature > 406)
		resistances += virus
		virus = null

	if(!virus)
		if(prob(40))
			for(var/mob/living/carbon/M in oviewers(4, src))
				if(M.virus && M.virus.spread == "Airborne")
					if(M.virus.affected_species.Find(species))
						if(resistances.Find(M.virus.type))
							continue
						var/datum/disease/D = new M.virus.type //Making sure strain_data is preserved
						D.strain_data = M.virus.strain_data
						contract_disease(D)
			for(var/obj/decal/cleanable/blood/B in view(4, src))
				if(B.virus && B.virus.spread == "Airborne")
					if(B.virus.affected_species.Find(species))
						if(resistances.Find(B.virus.type))
							continue
						var/datum/disease/D = new B.virus.type
						D.strain_data = B.virus.strain_data
						contract_disease(D)
	else
		virus.stage_act()


	if(!reagents.has_reagent("spaceacillin"))
		if(!virus2)
			for(var/obj/decal/cleanable/blood/B in view(4, src))
				if(B.virus2)
					infect_virus2(src,B.virus2)
			for(var/obj/virus/V in src.loc)
				infect_virus2(src,V.D)
		else if(get_infection_chance())
			virus2.activate(src)
			if(virus2)	//activate can sometimes remove the virus i think ~mini
				var/obj/virus/V = new(src.loc)
				V.D = virus2.getcopy()
//VIRUS FIX THESES


#define CAN_CONTAMINATE 1.5
/mob/living/carbon/proc/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	var/loc_temp = T0C
	if(istype(loc, /turf/space))
		environment_heat_capacity = loc:heat_capacity
		loc_temp = TESPC
	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		loc_temp = loc:air_contents.temperature
	else
		loc_temp = environment.temperature

	var/thermal_protection = get_thermal_protection()
	if(stat != 2 && abs(bodytemperature - 310.15) < 50)
		bodytemperature += adjust_body_temperature(bodytemperature, 310.15, thermal_protection)
	if(loc_temp < 310.15) // a cold place -> add in cold protection
		bodytemperature += adjust_body_temperature(bodytemperature, loc_temp, 1/thermal_protection)
	else // a hot place -> add in heat protection
		thermal_protection += add_fire_protection(loc_temp)
		bodytemperature += adjust_body_temperature(bodytemperature, loc_temp, 1/thermal_protection)

	var/turf/simulated/T = loc
	if(istype(T))
		if(T.active_hotspot)
			var/volume_coefficient = T.active_hotspot.volume / CELL_VOLUME
			var/resistance_coefficient = 1/max(add_fire_protection(T.active_hotspot.temperature),0.5)

			FireBurn(volume_coefficient*resistance_coefficient)

	if(environment.toxins > CAN_CONTAMINATE)
		contaminate()
		pl_effects()

	// lets give them a fair bit of leeway so they don't just start dying
	//as that may be realistic but it's no fun
	if((bodytemperature > (T0C + 50)) || (bodytemperature < (T0C + 10)) && (!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))) // Last bit is just disgusting, i know
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

	if(stat==2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences
	return //TODO: DEFERRED

/mob/living/carbon/proc/handle_mutations_and_radiation()
	if(fireloss)
		if(mutations & 2 || prob(50))
			switch(fireloss)
				if(1 to 50)
					fireloss--
				if(51 to 100)
					fireloss -= 5

	if (mutations & 8 && health <= 25)
		mutations &= ~8
		src << "\red You suddenly feel very weak."
		weakened = 3
		emote("collapse")

	if (radiation)
		if (radiation > 100)
			radiation = 100
			weakened = 10
			src << "\red You feel weak."
			emote("collapse")

		if (radiation < 0)
			radiation = 0

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					toxloss++
					updatehealth()

			if(50 to 74)
				radiation -= 2
				toxloss++
				if(prob(5))
					radiation -= 5
					weakened = 3
					src << "\red You feel weak."
					emote("collapse")
				updatehealth()

			if(75 to 100)
				radiation -= 3
				toxloss += 3
				if(prob(1))
					src << "\red You mutate!"
					randmutb(src)
					domutcheck(src,null)
					emote("gasp")
				updatehealth()

/mob/living/carbon/proc/handle_chemicals_in_body()
	return

/mob/living/carbon/proc/handle_stomach()
	for(var/mob/M in stomach_contents)
		if(M.loc != src)
			stomach_contents.Remove(M)
			continue
		if(istype(M, /mob/living/carbon) && stat != 2)
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
				nutrition += 10

/mob/living/carbon/proc/handle_disabilities()
	if (disabilities & 2)
		if ((prob(1) && paralysis < 10 && r_epil < 1))
			src << "\red You have a seizure!"
			paralysis = max(10, paralysis)
	if (disabilities & 4)
		if ((prob(5) && paralysis <= 1 && r_ch_cou < 1))
			drop_item()
			emote("cough")
	if (disabilities & 8)
		if ((prob(10) && paralysis <= 1 && r_Tourette < 1))
			stunned = max(10, stunned)
			emote("twitch_s")
	if (disabilities & 16)
		if (prob(10))
			stuttering = max(10, stuttering)

/mob/living/carbon/proc/handle_regular_status_updates()
	for(var/datum/organ/external/E in organs)
		E.process()
	UpdateDamage()
	updatehealth()

	if(oxyloss > oxylossparalysis) paralysis = max(paralysis, 3)

	if(sleeping)
		paralysis = max(paralysis, 3)
		if (prob(1) && health)
			emote("snore")
		sleeping--

	if(resting)
		weakened = max(weakened, 1)

	if(health < -100 || brain_op_stage == 4.0)
		death()
	else if(health < 0)
		if(health <= 20 && prob(1))
			emote("gasp")

		//if(!rejuv) oxyloss++
		if(!reagents.has_reagent("inaprovaline"))
			oxyloss++

		if(stat != 2)
			stat = 1
		paralysis = max(paralysis, 5)

	if (stat != 2) //Alive.

		if (paralysis || stunned || weakened) //Stunned etc.
			if (stunned > 0)
				stunned--
				stat = 0
			if (weakened > 0)
				weakened--
				lying = 1
				stat = 0
			if (paralysis > 0)
				paralysis--
				blinded = 1
				lying = 1
				stat = 1
			var/h = hand
			hand = 0
			drop_item()
			hand = 1
			drop_item()
			hand = h
		else	//Not stunned.
			lying = 0
			stat = 0

	else //Dead.
		lying = 1
		blinded = 1
		stat = 2

	if (stuttering)
		stuttering--
	if (intoxicated)
		intoxicated--

	if (eye_blind)
		eye_blind--
		blinded = 1

	if (ear_deaf > 0)
		ear_deaf--
	if (ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	density = !(lying)

	if (sdisabilities & 1)
		blinded = 1
	if (sdisabilities & 4)
		ear_deaf = 1

	if (eye_blurry > 0)
		eye_blurry--
		eye_blurry = max(0, eye_blurry)

	if (druggy > 0)
		druggy--
		druggy = max(0, druggy)

	return 1

/mob/living/carbon/proc/handle_regular_hud_updates()
	return

/mob/living/carbon/proc/check_if_buckled()
	if (buckled)
		lying = istype(buckled, /obj/stool/bed) || istype(buckled, /obj/machinery/conveyor)
		if(lying)
			drop_item()
		density = 1
		if(istype(buckled,/obj/stool/chair))
			dir = buckled.dir
	else
		density = !lying

/mob/living/carbon/proc/update_canmove()
	if(paralysis || stunned || weakened || buckled || changeling_fakedeath)
		canmove = 0
	else
		canmove = 1


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
	if(nodamage)
		return

	if(!breath || (breath.total_moles() == 0))
		if(health > 0)
			oxyloss += 14*vsc.OXYGEN_LOSS
		else
			oxyloss += 5
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
			emote("gasp")
		if(O2_pp > 0)
			var/ratio = safe_oxygen_min/O2_pp
			oxyloss += min(5*ratio, 7)
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
			paralysis = max(paralysis, 3)
			oxyloss += 3*vsc.OXYGEN_LOSS // Lets hurt em a little, let them know we mean business
			if(world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				oxyloss += 8*vsc.OXYGEN_LOSS
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			emote("cough")

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
				paralysis = max(paralysis, 3) // 3 gives them one second to wake up and run away a bit!
				if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
					sleeping = max(sleeping, 2)
				if(vsc.plc.N2O_HALLUCINATION)
					hallucination += 12
			else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(20))
					emote(pick("giggle", "laugh"))
				if(vsc.plc.N2O_HALLUCINATION)
					hallucination += 8


	if(breath.temperature > (T0C+66) && !(mutations & 2)) // Hot air hurts :(
		if(prob(20))
			src << "\red You feel a searing heat in your lungs!"
		fire_alert = max(fire_alert, 1)
	else
		if(breath.temperature < (T0C) && !(mutations & 2))
			if(prob(20))
				src << "\blue Your throat feels like ice!"
		fire_alert = 0

	if(oxyloss > 10)
		losebreath++
	//Temporary fixes to the alerts.

	return 1

/mob/living/carbon/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(nodamage)
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
		thermal_protection += 0.1
	if(wear_suit && (wear_suit.body_parts_covered & LEGS))
		thermal_protection += 0.2
	if(wear_suit && (wear_suit.body_parts_covered & ARMS))
		thermal_protection += 0.2
	if(wear_suit && (wear_suit.body_parts_covered & HANDS))
		thermal_protection += 0.2
	if(shoes && (shoes.body_parts_covered & FEET))
		thermal_protection += 0.1
	if(wear_suit && (wear_suit.flags & SUITSPACE))
		thermal_protection += 3
	if(head && (head.flags & HEADSPACE))
		thermal_protection += 1
	if(mutations & 2)
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