/****************************************************
			   DAMAGE PROCS
****************************************************/

/obj/item/organ/external/proc/is_damageable(additional_damage = 0)
	//Continued damage to vital organs can kill you, and robot organs don't count towards total damage so no need to cap them.
	return (BP_IS_ROBOTIC(src) || brute_dam + burn_dam + additional_damage < max_damage * 4)

obj/item/organ/external/take_general_damage(amount, silent = FALSE)
	take_external_damage(amount)

/obj/item/organ/external/proc/take_external_damage(brute, burn, damage_flags, used_weapon = null)
	if(owner && owner.status_flags & GODMODE)
		return 0
	brute = round(brute * brute_mod, 0.1)
	burn = round(burn * burn_mod, 0.1)
	if((brute <= 0) && (burn <= 0))
		return 0

	var/sharp = (damage_flags & DAM_SHARP)
	var/edge  = (damage_flags & DAM_EDGE)
	var/laser = (damage_flags & DAM_LASER)
	var/blunt = brute && !sharp && !edge

	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)

	if(owner) // No need to report damage inflicted on severed limbs
		if(brute)
			SSstoryteller.report_wound(owner, BRUTE, brute)
		if(burn)
			SSstoryteller.report_wound(owner, BURN, burn)

	var/can_cut = (!BP_IS_ROBOTIC(src) && (sharp || prob(brute*2)))
	var/spillover = 0
	var/pure_brute = brute
	if(!is_damageable(brute + burn))
		spillover =  brute_dam + burn_dam + brute - max_damage
		if(spillover > 0)
			brute -= spillover
		else
			spillover = brute_dam + burn_dam + brute + burn - max_damage
			if(spillover > 0)
				burn -= spillover

	if(owner && loc == owner)
		owner.updatehealth() //droplimb will call updatehealth() again if it does end up being called
		if(!is_stump() && (limb_flags & ORGAN_FLAG_CAN_AMPUTATE) && config.health.limbs_can_break)
			if((brute_dam + burn_dam + brute + burn + spillover) >= (max_damage * config.health.organ_health_multiplier))
				var/force_droplimb = 0
				if((brute_dam + burn_dam + brute + burn + spillover) >= (max_damage * config.health.organ_health_multiplier * 4))
					force_droplimb = 1
				//organs can come off in three cases
				//1. If the damage source is edge_eligible and the brute damage dealt exceeds the edge threshold, then the organ is cut off.
				//2. If the damage amount dealt exceeds the disintegrate threshold, the organ is completely obliterated.
				//3. If the organ has already reached or would be put over it's max damage amount (currently redundant),
				//   and the brute damage dealt exceeds the tearoff threshold, the organ is torn off.
				//Check edge eligibility
				var/edge_eligible = 0
				if(edge)
					if(istype(used_weapon, /obj/item))
						var/obj/item/I = used_weapon
						if(I.w_class >= w_class)
							edge_eligible = 1
					else
						edge_eligible = 1
				brute = pure_brute
				if(edge_eligible && brute >= max_damage / DROPLIMB_THRESHOLD_EDGE)
					if(prob(brute) || force_droplimb)
						droplimb(0, DROPLIMB_EDGE)
						return
				else if(burn >= max_damage / DROPLIMB_THRESHOLD_DESTROY)
					if(prob(burn/3) || force_droplimb)
						droplimb(0, DROPLIMB_BURN)
						return
				else if(brute >= max_damage / DROPLIMB_THRESHOLD_DESTROY)
					if(prob(brute) || force_droplimb)
						droplimb(0, DROPLIMB_BLUNT)
						return
				else if(brute >= max_damage / DROPLIMB_THRESHOLD_TEAROFF)
					if(prob(brute/3) || force_droplimb)
						droplimb(0, DROPLIMB_EDGE)
						return
				else if(force_droplimb)
					if(edge_eligible)
						droplimb(0, DROPLIMB_EDGE)
						return
					else if(burn)
						droplimb(0, DROPLIMB_BURN)
						return
					else if(prob(25)) // A chance for a limb to be torn off instead of getting gibbed
						droplimb(0, DROPLIMB_EDGE)
					else
						droplimb(0, DROPLIMB_BLUNT)
					return

	// High brute damage or sharp objects may damage internal organs
	if(!istype(used_weapon, /obj/item/projectile)) // Projectiles organ damage is being processed in human_defense.dm
		var/damage_amt = brute
		var/cur_damage = brute_dam
		if(laser)
			damage_amt += burn
			cur_damage += burn_dam
		var/organ_damage_threshold = 5
		if(sharp)
			organ_damage_threshold *= 0.5
		var/organ_damage_prob = 6.25 * damage_amt/organ_damage_threshold //more damage, higher chance to damage
		if(sharp)
			organ_damage_prob *= 1.5
		if(cur_damage >= 15)
			organ_damage_prob *= cur_damage/15
		if(encased && !(status & ORGAN_BROKEN)) //ribs and skulls protect
			organ_damage_prob *= 0.5
		if(internal_organs && internal_organs.len && (cur_damage + damage_amt >= max_damage || damage_amt >= organ_damage_threshold) && prob(organ_damage_prob))
			// Damage an internal organ
			var/list/victims = list()
			for(var/obj/item/organ/internal/I in internal_organs)
				if(I.damage < I.max_damage && prob(I.relative_size))
					victims += I
			if(!victims.len)
				victims += pick(internal_organs)
			for(var/obj/item/organ/internal/victim in victims)
				brute /= 2
				if(laser)
					burn /= 3
				damage_amt /= 2
				victim.take_internal_damage(damage_amt)

	if(status & ORGAN_BROKEN && brute)
		jostle_bone(brute)
		if(owner && can_feel_pain() && prob(40))
			owner.emote("scream")	//getting hit on broken hand hurts

	if(brute_dam > min_broken_damage && prob(brute_dam + brute * (1+blunt)) ) //blunt damage is gud at fracturing
		fracture()

	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	var/datum/wound/created_wound
	var/block_cut = !(brute > 15 || !(species.species_flags & SPECIES_FLAG_NO_MINOR_CUT))

	if(brute)
		var/to_create = BRUISE
		if(can_cut)
			if(!block_cut)
				to_create = CUT
			//need to check sharp again here so that blunt damage that was strong enough to break skin doesn't give puncture wounds
			if(sharp && !edge)
				to_create = PIERCE
		created_wound = createwound(to_create, brute)

	if(burn)
		if(laser)
			createwound(LASER, burn)
			if(prob(40))
				owner.IgniteMob()
		else
			createwound(BURN, burn)

	adjust_pain(0.6*burn + 0.4*brute)
	//If there are still hurties to dispense
	if (spillover)
		owner.shock_stage += spillover * config.health.organ_damage_spillover_multiplier

	// sync the organ's damage with its wounds
	update_damages()
	if(owner)
		owner.updatehealth()
		if(update_damstate())
			owner.UpdateDamageIcon()

	return created_wound

/obj/item/organ/external/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(BP_IS_ROBOTIC(src) && !robo_repair)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		// heal brute damage
		if(W.damage_type == BURN && (burn_ratio < 1 || vital))
			burn = W.heal_damage(burn)
		else if(brute_ratio < 1 || vital)
			brute = W.heal_damage(brute)

	if(internal)
		mend_fracture(TRUE)

	//Sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	return update_damstate()

// Brute/burn
/obj/item/organ/external/proc/get_brute_damage()
	return brute_dam

/obj/item/organ/external/proc/get_burn_damage()
	return burn_dam

// Geneloss/cloneloss.
/obj/item/organ/external/proc/get_genetic_damage()
	return (BP_IS_ROBOTIC(src) || (species?.species_flags & SPECIES_FLAG_NO_SCAN)) ? 0 : genetic_degradation

/obj/item/organ/external/proc/remove_genetic_damage(amount)
	if((species.species_flags & SPECIES_FLAG_NO_SCAN) || BP_IS_ROBOTIC(src))
		genetic_degradation = 0
		status &= ~ORGAN_MUTATED
		return
	var/last_gene_dam = genetic_degradation
	genetic_degradation = min(100,max(0,genetic_degradation - amount))
	if(genetic_degradation <= 30)
		if(status & ORGAN_MUTATED)
			unmutate()
			to_chat(src, "<span class = 'notice'>Your [name] is shaped normally again.</span>")
	return -(genetic_degradation - last_gene_dam)

/obj/item/organ/external/proc/add_genetic_damage(amount)
	if(owner.status_flags & GODMODE)
		return 0
	if((species.species_flags & SPECIES_FLAG_NO_SCAN) || BP_IS_ROBOTIC(src))
		genetic_degradation = 0
		status &= ~ORGAN_MUTATED
		return
	var/last_gene_dam = genetic_degradation
	genetic_degradation = min(100,max(0,genetic_degradation + amount))
	if(genetic_degradation > 30)
		if(!(status & ORGAN_MUTATED) && prob(genetic_degradation))
			mutate()
			to_chat(owner, "<span class = 'notice'>Something is not right with your [name]...</span>")
	return (genetic_degradation - last_gene_dam)

/obj/item/organ/external/proc/mutate()
	if(BP_IS_ROBOTIC(src))
		return
	src.status |= ORGAN_MUTATED
	if(owner)
		owner.update_body()

/obj/item/organ/external/proc/unmutate()
	src.status &= ~ORGAN_MUTATED
	if(owner)
		owner.update_body()

/obj/item/organ/external/proc/update_pain()
	if(!can_feel_pain())
		pain = 0
		full_pain = 0
		return

	if(pain)
		pain -= (pain > max_damage ? 2.5 : 1) * (owner.lying ? 3 : 1) // Over-limit pain decreases faster.
		pain = max(pain, 0)

	var/lasting_pain = 0
	if(is_broken())
		lasting_pain += 10
	else if(is_dislocated())
		lasting_pain += 5

	full_pain = min(pain, max_damage) + lasting_pain + min(max_damage, 0.7 * brute_dam + 0.8 * burn_dam) + 0.5 * get_genetic_damage()

/obj/item/organ/external/proc/get_pain()
	return pain

/obj/item/organ/external/proc/adjust_pain(change)
	if(!can_feel_pain())
		return 0
	var/last_pain = pain
	pain = clamp(pain + change, 0, max_pain)
	full_pain += pain - last_pain // Updating it without waiting for the next tick for the greater good

	if(change > 0 && owner)
		owner.full_pain += pain - last_pain
		if((change > 15 && prob(20)) || (change > 30 && prob(60)))
			owner.emote("scream")

	return pain - last_pain

/obj/item/organ/external/proc/remove_all_pain()
	pain = 0
	owner?.full_pain -= full_pain
	full_pain = 0

/obj/item/organ/external/proc/get_default_pain_message(power)
	var/burning = burn_dam > brute_dam
	switch(power)
		if(1 to 5)
			return "Your [name] [burning ? "burns" : "hurts"] a bit."
		if(5 to 15)
			return "Your [name] [burning ? "burns" : "hurts"] slightly."
		if(15 to 25)
			return "Your [name] [burning ? "burns" : "hurts"]."
		if(25 to 90)
			return "Your [name] [burning ? "burns" : "hurts"] badly!"
		if(90 to INFINITY)
			return "OH GOD! Your [name] is [burning ? "on fire" : "hurting terribly"]!"

/obj/item/organ/external/proc/stun_act(stun_amount, agony_amount)
	if(owner.status_flags & GODMODE)
		return 0
	if(agony_amount > 5 && owner)

		if((limb_flags & ORGAN_FLAG_CAN_GRASP) && prob(25))
			owner.grasp_damage_disarm(src)

		if((limb_flags & ORGAN_FLAG_CAN_STAND) && prob(min(agony_amount * ((body_part == LEG_LEFT || body_part == LEG_RIGHT)? 1 : 2), 70)))
			owner.stance_damage_prone(src)

		if(vital && full_pain > 0.5 * max_damage)
			owner.visible_message("<b>[owner]</b> reels in pain!")
			if(has_genitals() || full_pain + agony_amount > max_damage)
				owner.Weaken(6)
			else
				owner.drop_l_hand()
				owner.drop_r_hand()
			owner.Stun(6)
			return 1

/obj/item/organ/external/proc/get_agony_multiplier()
	return has_genitals() ? 2 : 1

/obj/item/organ/external/proc/sever_artery()
	if(species && species.has_organ[BP_HEART])
		var/obj/item/organ/internal/heart/O = species.has_organ[BP_HEART]
		if(!BP_IS_ROBOTIC(src) && !(status & ORGAN_ARTERY_CUT) && !initial(O.open))
			status |= ORGAN_ARTERY_CUT
			return TRUE
	return FALSE

/obj/item/organ/external/proc/sever_tendon()
	if((limb_flags & ORGAN_FLAG_HAS_TENDON) && !BP_IS_ROBOTIC(src) && !(status & ORGAN_TENDON_CUT))
		status |= ORGAN_TENDON_CUT
		return TRUE
	return FALSE
