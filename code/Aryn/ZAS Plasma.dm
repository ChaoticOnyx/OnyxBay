pl_control/var
	PLASMA_DMG = 3
	PLASMA_DMG_DESC = "Multiplier on how much damage inhaling plasma can do."

	CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.
	CLOTH_CONTAMINATION_RANDOM = 60
	CLOTH_CONTAMINATION_METHOD = "Toggle"
	CLOTH_CONTAMINATION_DESC = "If set to nonzero, plasma will contaminate cloth items (uniforms, backpacks, etc.)\
	and cause a small amount of damage over time to anyone carrying or wearing them. Contamination can be detected\
	with a Health Analyzer, and washed off in the washer."

	ALL_ITEM_CONTAMINATION = 0 //If this is on, any item can be contaminated, so suits and tools must be discarded or
										  //decontaminated.
	ALL_ITEM_CONTAMINATION_RANDOM = 10
	ALL_ITEM_CONTAMINATION_METHOD = "Toggle"
	ALL_ITEM_CONTAMINATION_DESC = "Like CLOTH_CONTAMINATION, but all item types are susceptible."

	PLASMAGUARD_ONLY = 0
	PLASMAGUARD_ONLY_RANDOM = 20
	PLASMAGUARD_ONLY_METHOD = "Toggle"
	PLASMAGUARD_ONLY_DESC = "If on, any suits that are not biosuits or space suits will not protect against contamination."

	//CANISTER_CORROSION = 0         //If this is on, plasma must be stored in orange tanks and canisters,
	//CANISTER_CORROSION_RANDOM = 20 //or it will corrode the tank.
	//CANISTER_CORROSION_METHOD = "Toggle"

	GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 10,000.
	GENETIC_CORRUPTION_RANDOM = "PROB10/3d6"
	GENETIC_CORRUPTION_METHOD = "Numeric"
	GENETIC_CORRUPTION_DESC = "When set to a probability in 1000, any humans in plasma will have this chance to develop a random mutation."

	SKIN_BURNS = 0       //Plasma has an effect similar to mustard gas on the un-suited.
	SKIN_BURNS_RANDOM = 10
	SKIN_BURNS_METHOD = "Toggle"
	SKIN_BURNS_DESC = "When toggled, humans with exposed skin will suffer burns (similar to mustard gas) in plasma."

	//PLASMA_INJECTS_TOXINS = 0         //Plasma damage injects the toxins chemical to do damage over time.
	//PLASMA_INJECTS_TOXINS_RANDOM = 30
	//PLASMA_INJECTS_TOXINS_METHOD = "Toggle"

	EYE_BURNS = 0 //Plasma burns the eyes of anyone not wearing eye protection.
	EYE_BURNS_RANDOM = 30
	EYE_BURNS_METHOD = "Toggle"
	EYE_BURNS_DESC = "When toggled, humans without masks that cover the eyes will suffer temporary blurriness and sight loss,\
	and may need glasses to see again if exposed for long durations."

	//N2O_REACTION = 0 //Plasma can react with N2O, making sparks and starting a fire if levels are high.
	//N2O_REACTION_RANDOM = 5

	//PLASMA_COLOR = "onturf" //Plasma can change colors yaaaay!
	//PLASMA_COLOR_RANDOM = "PICKonturf,onturf"

	//PLASMA_DMG_OFFSET = 1
	//PLASMA_DMG_OFFSET_RANDOM = "1d5"
	//PLASMA_DMG_QUOTIENT = 10
	//PLASMA_DMG_QUOTIENT_RANDOM = "1d10+4"

	CONTAMINATION_LOSS = 0.01
	CONTAMINATION_LOSS_DESC = "A number representing the damage done per life cycle by contaminated items."
	PLASMA_HALLUCINATION = 0
	PLASMA_HALLUCINATION_METHOD = "Toggle"
	PLASMA_HALLUCINATION_DESC = "If toggled, uses the remnants of the hallucination code to induce visions in those\
	who breathe plasma."
	N2O_HALLUCINATION = 0
	N2O_HALLUCINATION_METHOD = "Toggle"
	N2O_HALLUCINATION_DESC = "If toggled, uses the remnants of the hallucination code to induce visions in those\
	who breathe N2O."
	//CONTAMINATION_LOSS_RANDOM = "5d5"
//Plasma has a chance to be a different color.

obj/var/contaminated = 0

obj/item/proc
	can_contaminate()
		if(flags & PLASMAGUARD) return 0
		if((flags & SUITSPACE) && !vsc.plc.PLASMAGUARD_ONLY) return 1
		if(vsc.plc.ALL_ITEM_CONTAMINATION) return 1
		else if(istype(src,/obj/item/clothing)) return 1
		else if(istype(src,/obj/item/weapon/storage/backpack)) return 1

mob/living/carbon/human/proc
	contaminate()

		if(!pl_suit_protected())
			suit_contamination()
		else if(vsc.plc.PLASMAGUARD_ONLY)
			if(!wear_suit.flags & PLASMAGUARD) wear_suit.contaminated = 1



		if(!pl_head_protected())
			if(wear_mask) wear_mask.contaminated = 1
			if(prob(1)) suit_contamination() //Plasma can sometimes get through such an open suit.
		else if(vsc.plc.PLASMAGUARD_ONLY)
			if(!head.flags & PLASMAGUARD) head.contaminated = 1

		if(istype(back,/obj/item/weapon/storage/backpack) || vsc.plc.ALL_ITEM_CONTAMINATION)
			back.contaminated = 1

		if(l_hand)
			if(l_hand.can_contaminate()) l_hand.contaminated = 1
		if(r_hand)
			if(r_hand.can_contaminate()) r_hand.contaminated = 1
		if(belt)
			if(belt.can_contaminate()) belt.contaminated = 1
		if(wear_id && !pl_suit_protected())
			if(wear_id.can_contaminate()) wear_id.contaminated = 1
		if(ears && !pl_head_protected())
			if(ears.can_contaminate()) ears.contaminated = 1

	suit_interior()
		. = list()
		if(!pl_suit_protected())
			for(var/obj/item/I in src)
				. += I
			return .
		. += wear_mask
		. += w_uniform
		. += shoes
		. += gloves
		if(!pl_head_protected())
			. += head

	pl_head_protected()
		if(head)
			if(head.flags & PLASMAGUARD || head.flags & HEADSPACE) return 1
		return 0
	pl_suit_protected()
		if(wear_suit)
			if(wear_suit.flags & PLASMAGUARD || wear_suit.flags & SUITSPACE) return 1
		return 0

	suit_contamination()
		if(vsc.plc.ALL_ITEM_CONTAMINATION)
			for(var/obj/item/I in src)
				I.contaminated = 1
		else
			if(wear_suit) wear_suit.contaminated = 1
			if(w_uniform) w_uniform.contaminated = 1
			if(shoes) shoes.contaminated = 1
			if(gloves) gloves.contaminated = 1
			if(wear_mask) wear_mask.contaminated = 1

	pl_effects()
		if(vsc.plc.SKIN_BURNS)
			if(!pl_head_protected() || !pl_suit_protected())
				burn_skin(0.75)
				if (coughedtime != 1)
					coughedtime = 1
					emote("gasp")
					spawn (20)
						coughedtime = 0
				updatehealth()
		if(vsc.plc.EYE_BURNS && !pl_head_protected())
			if(!wear_mask)
				if(prob(20)) usr << "\red Your eyes burn!"
				eye_stat += 2.5
				eye_blurry += 1.5
				if (eye_stat >= 20 && !(disabilities & 1))
					src << "\red Your eyes start to burn badly!"
					disabilities |= 1
				if (prob(max(0,eye_stat - 20) + 1))
					src << "\red You are blinded!"
					eye_blind += 20
					eye_stat = max(eye_stat-25,0)
			else
				if(!(wear_mask.flags & MASKCOVERSEYES))
					if(prob(20)) usr << "\red Your eyes burn!"
					eye_stat += 2.5
					eye_blurry = min(eye_blurry+1.5,50)
					if (eye_stat >= 20 && !(disabilities & 1))
						src << "\red Your eyes start to burn badly!"
						disabilities |= 1
					if (prob(max(0,eye_stat - 20) + 1) &&!eye_blind)
						src << "\red You are blinded!"
						eye_blind += 20
						eye_stat = 0
		if(vsc.plc.GENETIC_CORRUPTION)
			if(rand(1,1000) < vsc.plc.GENETIC_CORRUPTION)
				randmutb(src)
				src << "\red High levels of toxins cause you to spontaneously mutate."
				domutcheck(src,null)


	FireBurn(mx as num)

		//NO! NOT INTO THE PIT! IT BURRRRRNS!

		mx *= vsc.BURN_DMG

		var
			head_exposure = 1
			chest_exposure = 1
			groin_exposure = 1
			legs_exposure = 1
			feet_exposure = 1
			arms_exposure = 1
			hands_exposure = 1
		for(var/obj/item/clothing/C in src)
			if(l_hand == C || r_hand == C) continue
			if(C.body_parts_covered & HEAD)
				head_exposure *= C.heat_transfer_coefficient
			if(C.body_parts_covered & UPPER_TORSO)
				chest_exposure *= C.heat_transfer_coefficient
			if(C.body_parts_covered & LOWER_TORSO)
				groin_exposure *= C.heat_transfer_coefficient
			if(C.body_parts_covered & LEGS)
				legs_exposure *= C.heat_transfer_coefficient
			if(C.body_parts_covered & FEET)
				feet_exposure *= C.heat_transfer_coefficient
			if(C.body_parts_covered & ARMS)
				arms_exposure *= C.heat_transfer_coefficient
			if(C.body_parts_covered & HANDS)
				arms_exposure *= C.heat_transfer_coefficient

		mx *= 10

		TakeDamage("head", 0, 2.5*mx*head_exposure)
		TakeDamage("chest", 0, 2.5*mx*chest_exposure)
		TakeDamage("groin", 0, 2.0*mx*groin_exposure)
		TakeDamage("l_leg", 0, 0.6*mx*legs_exposure)
		TakeDamage("r_leg", 0, 0.6*mx*legs_exposure)
		TakeDamage("l_arm", 0, 0.4*mx*arms_exposure)
		TakeDamage("r_arm", 0, 0.4*mx*arms_exposure)
		TakeDamage("l_foot", 0, 0.25*mx*feet_exposure)
		TakeDamage("r_foot", 0, 0.25*mx*feet_exposure)
		TakeDamage("l_hand", 0, 0.25*mx*hands_exposure)
		TakeDamage("r_hand", 0, 0.25*mx*hands_exposure)

mob/monkey/proc
	contaminate()
	pl_effects()

turf/Entered(obj/item/I)
	. = ..()
	if(istype(I))
		var/datum/gas_mixture/env = return_air(1)
		if(env.toxins > 0.01)
			if(I.can_contaminate())
				I.contaminated = 1

turf/simulated/var
	//current_toxins = 0
	graphic = null
	graphic_archived = null
	tox_level_calculated = 0
	list/tox_unblocked
	archived_check_directions = 0
	//list/current_trace_gases = list()

turf/simulated/proc
	toxins_flow()
		if(tox_level_calculated) return
		if(!zone) return
		if(!tox_unblocked || (air_check_directions != archived_check_directions))
			tox_unblocked = get_update_turfs(src)
			//world.log << "Running toxin flows..."
			/*
			var/total_toxins = 0//current_toxins
			var/list/total_trace = list()//current_trace_gases.Copy()

			for(var/turf/simulated/T in tox_unblocked)
				total_toxins += T.air.toxins
				for(var/datum/gas/G in T.air.trace_gases)
					var/datum/gas/N = locate(G.type) in total_trace
					if(N)
						N.moles += G.moles
					else
						N = new G.type()
						N.moles = G.moles
						total_trace += N

			//world.log << "Total toxins: [total_toxins]"

			var
				average_toxins = total_toxins / length(tox_unblocked)+1
				list/average_trace = total_trace.Copy()

			for(var/datum/gas/G in average_trace)
				G.moles /= length(tox_unblocked) + 1

			//world.log << "Average toxins: [average_toxins]"

			for(var/turf/simulated/T in tox_unblocked)
				T.air.toxins = average_toxins
				T.air.trace_gases = average_trace.Copy()

			air.toxins = average_toxins
			air.trace_gases = average_trace.Copy()*/

		zone_share_gases()

		for(var/turf/T in tox_unblocked)
			if(istype(T,/turf/simulated))
				var/turf/simulated/S = T
				if(S.air.toxins || air.toxins || S.air.trace_gases.len || air.trace_gases.len)
					air.share(S.air)
				else
					if(abs(air.temperature - S.air.temperature) > 0.1) air.temperature_share(S.air,OPEN_HEAT_TRANSFER_COEFFICIENT)
			else
				air.mimic(T)

		graphic_archived = graphic
		graphic = null

		if(air.toxins > MOLES_PLASMA_VISIBLE)
			graphic = "plasma"
		else
			var/datum/gas/sleeping_agent = locate(/datum/gas/sleeping_agent) in air.trace_gases
			if(sleeping_agent && (sleeping_agent.moles > 1))
				graphic = "sleeping_agent"
			else
				graphic = null

		if(graphic != graphic_archived)
			overlays.len = 0
			switch(graphic)
				if("plasma")
					overlays += plmaster
				if("sleeping_agent")
					overlays += slmaster

		//if(air.temperature)
		//	var

		if(length(tox_unblocked))

			var/list/possible_fire_spreads = tox_unblocked.Copy()

			var/turf/simulated/above = get_step_3d(src,UP)
			if(istype(above,/turf/simulated/floor/open) && active_hotspot)
				possible_fire_spreads += above
			if(istype(src,/turf/simulated/floor/open))
				if(active_hotspot && istype(src:floorbelow,/turf/simulated))
					possible_fire_spreads += src:floorbelow

			//var
			//	oxygen_supply = zone.air.oxygen
			//	co2_supply = zone.air.carbon_dioxide
			//	nitrogen_supply = zone.air.nitrogen

			//air.oxygen += oxygen_supply
		//	air.nitrogen += nitrogen_supply
		//	air.carbon_dioxide += co2_supply

			air.react()

			//air.oxygen = max(0,air.oxygen - oxygen_supply)
			//air.nitrogen = max(0,air.nitrogen - nitrogen_supply)
		//	air.carbon_dioxide = max(0,air.carbon_dioxide - co2_supply)

			if(active_hotspot)
				active_hotspot.process(possible_fire_spreads)

			if(air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION)
				consider_superconductivity(starting = 1)

			if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
				hotspot_expose(air.temperature, CELL_VOLUME)
				for(var/atom/movable/item in src)
					item.temperature_expose(air, air.temperature, CELL_VOLUME)
				temperature_expose(air, air.temperature, CELL_VOLUME)



proc
	add_trace_gases(gases1,gases2)
		for(var/datum/gas/G in gases2)
			var/datum/gas/N = locate(G.type) in gases1
			if(N)
				N.moles += G.moles
			else
				N = new G.type()
				N.moles = G.moles
				gases1 += N
		return gases1
	subtract_trace_gases(gases1,gases2)
		for(var/datum/gas/G in gases2)
			var/datum/gas/N = locate(G.type) in gases1
			if(N)
				N.moles = max(0,N.moles - G.moles)
				if(N.moles <= 0)
					gases1 -= N
		return gases1

	multiply_trace_gases(gases,multiplier)
		for(var/datum/gas/G in gases)
			G.moles *= multiplier
		return gases

	divide_trace_gases(gases,multiplier)
		for(var/datum/gas/G in gases)
			G.moles /= multiplier
		return gases

			//else
			//	N = new G.type()
			//	N.moles = G.moles
			//	gases1 -= N

turf/simulated/proc/zone_share_gases()
	if(zone)
		zone.air.share_with = air
		zone.air.sharing_with = 1+2+4
		air.share_with = zone.air
		air.sharing_with = 8+16+32