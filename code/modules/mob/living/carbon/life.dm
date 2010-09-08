/mob/living/carbon/var/oxygen_alert = 0
/mob/living/carbon/var/toxins_alert = 0
/mob/living/carbon/var/fire_alert = 0
/mob/living/carbon/var/temperature_alert = 0
/mob/living/carbon/var/list/random_events = new //If handle_random_events() is run, it will choose from this list. Entries are defined in /mob/living/carbon/type/New() (See Monkey and Human)

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

/mob/living/carbon/proc/handle_environment()
	return

/mob/living/carbon/proc/handle_mutations_and_radiation()
	return

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
	return

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