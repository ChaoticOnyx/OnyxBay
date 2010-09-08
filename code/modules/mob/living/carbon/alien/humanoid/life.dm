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