/mob/living/carbon/alien/handle_regular_hud_updates()
	if (src.stat == 2 || src.mutations & 4)
		src.sight |= SEE_TURFS
		src.sight |= SEE_MOBS
		src.sight |= SEE_OBJS
		src.see_in_dark = 8
		src.see_invisible = 2
	else if (src.stat != 2)
		src.sight |= SEE_MOBS
		src.sight &= ~SEE_TURFS
		src.sight &= ~SEE_OBJS
		src.see_in_dark = 4
		src.see_invisible = 2

	if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
	if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

	if (src.healths)
		if (src.stat != 2)
			switch(health)
				if(100 to INFINITY)
					src.healths.icon_state = "health0"
				if(75 to 100)
					src.healths.icon_state = "health1"
				if(50 to 75)
					src.healths.icon_state = "health2"
				if(25 to 50)
					src.healths.icon_state = "health3"
				if(0 to 25)
					src.healths.icon_state = "health4"
				else
					src.healths.icon_state = "health5"
		else
			src.healths.icon_state = "health6"

	if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"


	if (src.toxin)	src.toxin.icon_state = "tox[src.toxins_alert ? 1 : 0]"
	if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
	if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	src.client.screen -= src.hud_used.blurry
	src.client.screen -= src.hud_used.druggy
	src.client.screen -= src.hud_used.vimpaired

	if ((src.blind && src.stat != 2))
		if ((src.blinded))
			src.blind.layer = 18
		else
			src.blind.layer = 0

			if (src.disabilities & 1)
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

/mob/living/carbon/alien/humanoid/handle_regular_status_updates()
	health = 100 - (oxyloss + fireloss + bruteloss)

	if(oxyloss > 50) paralysis = max(paralysis, 3)

	if(src.sleeping)
		src.paralysis = max(src.paralysis, 3)
		if (prob(10) && health) spawn(0) emote("snore")
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

	if ((src.sdisabilities & 1))
		src.blinded = 1
	if ((src.sdisabilities & 4))
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		src.eye_blurry--
		src.eye_blurry = max(0, src.eye_blurry)

	if (src.druggy > 0)
		src.druggy--
		src.druggy = max(0, src.druggy)

	return 1

/mob/living/carbon/alien/humanoid/handle_mutations_and_radiation()
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

/mob/living/carbon/alien/humanoid/handle_environment()
	//If there are alien weeds on the ground then heal if needed or give some toxins
	if(locate(/obj/alien/weeds) in loc)
		if(health >= 100)
			toxloss += 5
		else
			bruteloss -= 5
			fireloss -= 5

/mob/living/carbon/alien/humanoid
	proc
		handle_breath(datum/gas_mixture/breath)
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
			if(wear_suit && (wear_suit.body_parts_covered & LEGS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & ARMS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & HANDS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.flags & SUITSPACE))
				thermal_protection += 3
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
			if(wear_suit)
				if(wear_suit.protective_temperature > temp)
					fire_prot += (wear_suit.protective_temperature/10)


			return fire_prot

/*
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// OLD ALIEN LIFE CODE ////////////////////////////////////////////////
/mob/living/carbon/alien/humanoid
	proc

		handle_breath(datum/gas_mixture/breath)
			//Aliens can breathe in any atmosphere
			var/toxins_used = 0

			if(breath.toxins > ((ONE_ATMOSPHERE*BREATH_VOLUME*0.15)/(T20C*R_IDEAL_GAS_EQUATION)))
				var/available_ratio = breath.toxins/((ONE_ATMOSPHERE*BREATH_VOLUME*0.15)/(T20C*R_IDEAL_GAS_EQUATION))
				toxins_used = breath.toxins*available_ratio/6
				toxloss += 7*(1-available_ratio)
			else
				toxloss = max(toxloss-5, 0)
				toxins_used = breath.oxygen/6

			breath.toxins -= toxins_used
			breath.oxygen += toxins_used

			if(breath.temperature > (T0C+66))
				fire_alert = max(fire_alert, 1)

			return 1

		handle_environment(datum/gas_mixture/environment)
			if(!environment)
				return
			var/environment_heat_capacity = environment.heat_capacity()
			if(istype(loc, /turf/space))
				environment_heat_capacity = loc:heat_capacity

			//If there are alien weeds on the ground then heal if needed or give some toxins
			if(locate(/obj/alien/weeds) in loc)
				if(health >= 100)
					toxloss += 2
				else
					health += 5

			if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
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

				handle_temperature_damage(UPPER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

				transfer_coefficient = 1
				if(wear_suit && (wear_suit.body_parts_covered & LOWER_TORSO) && (environment.temperature < wear_suit.protective_temperature))
					transfer_coefficient *= wear_suit.heat_transfer_coefficient

				handle_temperature_damage(LOWER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

				transfer_coefficient = 1
				if(wear_suit && (wear_suit.body_parts_covered & LEGS) && (environment.temperature < wear_suit.protective_temperature))
					transfer_coefficient *= wear_suit.heat_transfer_coefficient

				handle_temperature_damage(LEGS, environment.temperature, environment_heat_capacity*transfer_coefficient)

				transfer_coefficient = 1
				if(wear_suit && (wear_suit.body_parts_covered & ARMS) && (environment.temperature < wear_suit.protective_temperature))
					transfer_coefficient *= wear_suit.heat_transfer_coefficient

				handle_temperature_damage(ARMS, environment.temperature, environment_heat_capacity*transfer_coefficient)

				transfer_coefficient = 1
				if(wear_suit && (wear_suit.body_parts_covered & HANDS) && (environment.temperature < wear_suit.protective_temperature))
					transfer_coefficient *= wear_suit.heat_transfer_coefficient

				handle_temperature_damage(HANDS, environment.temperature, environment_heat_capacity*transfer_coefficient)

				transfer_coefficient = 1
				if(wear_suit && (wear_suit.body_parts_covered & FEET) && (environment.temperature < wear_suit.protective_temperature))
					transfer_coefficient *= wear_suit.heat_transfer_coefficient

				handle_temperature_damage(FEET, environment.temperature, environment_heat_capacity*transfer_coefficient)

			if(stat==2)
				bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

			//Account for massive pressure differences
			return //TODO: DEFERRED

		handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
			var/discomfort = abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000

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

		handle_chemicals_in_body()
			return //TODO: DEFERRED

		handle_regular_status_updates()
			//No toxloss because aliens breathe in toxins
			health = 100 - (oxyloss + fireloss + bruteloss)

			if(oxyloss > 25)
				paralysis = max(paralysis, 3)

			if(health < -100)
				death()

			return 1

		handle_regular_hud_updates()
		//Aliens can't have internals
			if(internal)
				internals.icon_state = "internal1"
			else
				internals.icon_state = "internal0"
		//Aliens can breathe any atmosphere
			if(oxygen_alert > 0)
				oxygen_alert -= 1
				oxygen.icon_state = "oxy1"
			else
				oxygen.icon_state = "oxy0"
		//Aliens like toxins :)
			if(toxins_alert > 0)
				toxins_alert -= 1
				toxin.icon_state = "tox1"
			else
				toxin.icon_state = "tox0"
		//This makes sense, aliens hate fire
			if(fire_alert > 0)
				fire_alert -= 1
				fire.icon_state = "fire1"
			else
				fire.icon_state = "fire0"

			return 1

		//Should aliens have DNA?
		//Figure it out and come back here.
		//Nannek
		//As a note, the toxloss for radiation should be changed as the alien uses toxloss as a fuel

		handle_random_events()
			return

/*
			if (src.radiation > 100)
				src.radiation = 100
			if ((prob(1) && (src.radiation >= 75)))
				randmutb(src)
				src << "\red High levels of Radiation cause you to spontaneously mutate."
				domutcheck(src,null)
			if ((prob(7) && (src.radiation >= 75)))
				if (src.paralysis < 3)
					src.paralysis = 3
				src << "\red You feel weak!"
				emote("collapse")
				src.updatehealth()
				src.radiation -= 5
			else if ((prob(7) && ((src.radiation > 50)&&(src.radiation < 75))))
				src.updatehealth()
				src.radiation -= 5
				emote("gasp")
			else
				if (prob(7) && (src.radiation > 1))
					if (src.radiation >= 10)
						src.radiation -= 10
						src.toxloss += 5
						src.updatehealth()
					else
						src.radiation = 0
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
			if (prob(1) && prob(2))
				spawn(0)
					emote("sneeze")
					return
*/

		//This is fine for the alien
		handle_virus_updates()
			if(src.bodytemperature > 406)
				src.resistances += src.virus
				src.virus = null

			if(!src.virus)
				if(prob(40))
					for(var/mob/living/carbon/M in range(4, src))
						if(M.virus && M.virus.spread == "Airborne")
							if(M.virus.affected_species.Find("Alien"))
								if(M.virus.type in src.resistances)
									continue
								src.contract_disease(new M.virus.type)
					for(var/obj/decal/cleanable/blood/B in range(4, src))
						if(B.virus && B.virus.spread == "Airborne")
							if(B.virus.affected_species.Find("Alien"))
								if(B.virus.type in src.resistances)
									continue
								src.contract_disease(new B.virus.type)
			else
				src.virus.stage_act()
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
*/