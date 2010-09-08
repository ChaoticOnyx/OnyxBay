/mob/living/carbon/alien/handle_regular_hud_updates()
	if (stat == 2 || mutations & 4)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = 2
	else if (stat != 2)
		sight |= SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
		see_in_dark = 4
		see_invisible = 2

	if (sleep) sleep.icon_state = text("sleep[]", sleeping)
	if (rest) rest.icon_state = text("rest[]", resting)

	if (healths)
		if (stat != 2)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(75 to 100)
					healths.icon_state = "health1"
				if(50 to 75)
					healths.icon_state = "health2"
				if(25 to 50)
					healths.icon_state = "health3"
				if(0 to 25)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"


	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	client.screen -= hud_used.blurry
	client.screen -= hud_used.druggy
	client.screen -= hud_used.vimpaired

	if ((blind && stat != 2))
		if ((blinded))
			blind.layer = 18
		else
			blind.layer = 0

			if (disabilities & 1)
				client.screen += hud_used.vimpaired

			if (eye_blurry)
				client.screen += hud_used.blurry

			if (druggy)
				client.screen += hud_used.druggy

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1

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

/*
			if (radiation > 100)
				radiation = 100
			if ((prob(1) && (radiation >= 75)))
				randmutb(src)
				src << "\red High levels of Radiation cause you to spontaneously mutate."
				domutcheck(src,null)
			if ((prob(7) && (radiation >= 75)))
				if (paralysis < 3)
					paralysis = 3
				src << "\red You feel weak!"
				emote("collapse")
				updatehealth()
				radiation -= 5
			else if ((prob(7) && ((radiation > 50)&&(radiation < 75))))
				updatehealth()
				radiation -= 5
				emote("gasp")
			else
				if (prob(7) && (radiation > 1))
					if (radiation >= 10)
						radiation -= 10
						toxloss += 5
						updatehealth()
					else
						radiation = 0
			if (disabilities & 2)
				if ((prob(1) && paralysis < 10 && r_epil < 1))
					src << "\red You have a seizure!"
					paralysis = max(10, paralysis)
			if (disabilities & 4)
				if ((prob(5) && paralysis <= 1 && r_ch_cou < 1))
					drop_item()
					spawn( 0 )
						emote("cough")
						return
			if (disabilities & 8)
				if ((prob(10) && paralysis <= 1 && r_Tourette < 1))
					stunned = max(10, stunned)
					spawn( 0 )
						emote("twitch")
						return
			if (disabilities & 16)
				if (prob(10))
					stuttering = max(10, stuttering)
			if (prob(1) && prob(2))
				spawn(0)
					emote("sneeze")
					return
*/

		//This is fine for the alien
		handle_virus_updates()
			if(bodytemperature > 406)
				resistances += virus
				virus = null

			if(!virus)
				if(prob(40))
					for(var/mob/living/carbon/M in range(4, src))
						if(M.virus && M.virus.spread == "Airborne")
							if(M.virus.affected_species.Find("Alien"))
								if(M.virus.type in resistances)
									continue
								contract_disease(new M.virus.type)
					for(var/obj/decal/cleanable/blood/B in range(4, src))
						if(B.virus && B.virus.spread == "Airborne")
							if(B.virus.affected_species.Find("Alien"))
								if(B.virus.type in resistances)
									continue
								contract_disease(new B.virus.type)
			else
				virus.stage_act()
/*
snippets

	if (mach)
		if (machine)
			mach.icon_state = "mach1"
		else
			mach.icon_state = null

	if (!m_flag)
		moved_recently = 0
	m_flag = null



		if ((istype(loc, /turf/space) && !( locate(/obj/movable, loc) )))
			var/layers = 20
			// ******* Check
			if (((istype(head, /obj/item/clothing/head) && head.flags & 4) || (istype(wear_mask, /obj/item/clothing/mask) && (!( wear_mask.flags & 4 ) && wear_mask.flags & 8))))
				layers -= 5
			if (istype(w_uniform, /obj/item/clothing/under))
				layers -= 5
			if ((istype(wear_suit, /obj/item/clothing/suit) && wear_suit.flags & 8))
				layers -= 10
			if (layers > oxcheck)
				oxcheck = layers


				if(bodytemperature < 282.591 && (!firemut))
					if(bodytemperature < 250)
						fireloss += 4
						updatehealth()
						if(paralysis <= 2)	paralysis += 2
					else if(prob(1) && !paralysis)
						if(paralysis <= 5)	paralysis += 5
						emote("collapse")
						src << "\red You collapse from the cold!"
				if(bodytemperature > 327.444  && (!firemut))
					if(bodytemperature > 345.444)
						if(!eye_blurry)	src << "\red The heat blurs your vision!"
						eye_blurry = max(4, eye_blurry)
						if(prob(3))	fireloss += rand(1,2)
					else if(prob(3) && !paralysis)
						paralysis += 2
						emote("collapse")
						src << "\red You collapse from heat exaustion!"
				plcheck = t_plasma
				oxcheck = t_oxygen
				G.turf_add(T, G.total_moles())
*/
*/