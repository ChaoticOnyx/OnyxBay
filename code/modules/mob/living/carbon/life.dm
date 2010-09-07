/mob/living/carbon/var/oxygen_alert = 0
/mob/living/carbon/var/toxins_alert = 0
/mob/living/carbon/var/fire_alert = 0
/mob/living/carbon/var/temperature_alert = 0

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