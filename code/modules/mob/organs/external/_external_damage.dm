/****************************************************
			   DAMAGE PROCS
****************************************************/

obj/item/organ/external/take_general_damage(amount, silent = FALSE)
	take_external_damage(amount)

// Deals blunt damage, distributes 50% of the damage between cut and pierce if there's excessive damage.
/obj/item/organ/external/proc/_take_blunt_damage(brute)
	if(owner && (owner.status_flags & GODMODE))
		return

	// The maximum amount of damage of each type we can physically inflict.
	var/max_blunt_damage = brute
	var/max_cut_damage = brute * 0.25
	var/max_pierce_damage = brute * 0.25

	// The amount of damage we'd like to inflict.
	var/potential_blunt_damage = brute
	var/potential_cut_damage = 0
	var/potential_pierce_damage = 0

	var/damage_potential = 0

	if(blunt_dam < max_damage)
		damage_potential = max_damage - blunt_dam
		max_blunt_damage = min(brute, damage_potential)
		if(damage_potential < potential_blunt_damage)
			potential_cut_damage += potential_blunt_damage - damage_potential
			potential_pierce_damage += potential_blunt_damage - damage_potential
	else
		max_blunt_damage = 0
		potential_cut_damage += potential_blunt_damage * 0.25
		potential_pierce_damage += potential_blunt_damage * 0.25

	var/final_blunt_damage = min(potential_blunt_damage, max_blunt_damage)
	blunt_dam = min(blunt_dam + final_blunt_damage, max_damage)

	var/final_cut_damage = min(potential_cut_damage, max_cut_damage)
	if(final_cut_damage >= 1.25)
		cut_dam = min(cut_dam + final_cut_damage, max_damage)

	var/final_pierce_damage = min(potential_pierce_damage, max_pierce_damage)
	if(final_pierce_damage >= 1.25)
		pierce_dam = min(pierce_dam + final_pierce_damage, max_damage)

	return

// Deals 75% of the amount as cut damage and 25% as pierce damage, deals up to 50% as blunt if excessive.
/obj/item/organ/external/proc/_take_cut_damage(brute)
	if(owner && (owner.status_flags & GODMODE))
		return

	// The maximum amount of damage of each type we can physically inflict.
	var/max_pierce_damage = brute
	var/max_cut_damage = brute
	var/max_blunt_damage = brute * 0.5

	// The amount of damage we'd like to inflict.
	var/potential_pierce_damage = brute * 0.25
	var/potential_cut_damage = brute * 0.75

	var/damage_potential = 0

	if(cut_dam < max_damage)
		damage_potential = max_damage - cut_dam
		max_cut_damage = min(brute, damage_potential)
		if(damage_potential < potential_cut_damage)
			potential_pierce_damage += potential_cut_damage - damage_potential
	else
		max_cut_damage = 0
		potential_pierce_damage += potential_cut_damage

	if(pierce_dam < max_damage)
		damage_potential = max_damage - pierce_dam
		max_pierce_damage = min(brute, damage_potential)
		if(damage_potential < potential_pierce_damage)
			potential_cut_damage += potential_pierce_damage - damage_potential
	else
		max_pierce_damage = 0
		potential_cut_damage += potential_pierce_damage

	var/final_cut_damage = min(potential_cut_damage, max_cut_damage)
	cut_dam = min(cut_dam + final_cut_damage, max_damage)

	var/final_pierce_damage = min(potential_pierce_damage, max_pierce_damage)
	pierce_dam = min(pierce_dam + final_pierce_damage, max_damage)

	var/final_blunt_damage = clamp((brute - final_pierce_damage - final_cut_damage) * 0.5, 0, max_blunt_damage)
	blunt_dam = min(blunt_dam + final_blunt_damage, max_damage)

	return

// Deals 25% of the amount as cut damage and 75% as pierce damage, deals up to 50% as blunt if excessive.
/obj/item/organ/external/proc/_take_pierce_damage(brute)
	if(owner && (owner.status_flags & GODMODE))
		return

	// The maximum amount of damage of each type we can physically inflict.
	var/max_blunt_damage = brute * 0.5
	var/max_cut_damage = brute
	var/max_pierce_damage = brute

	// The amount of damage we'd like to inflict.
	var/potential_cut_damage = brute * 0.25
	var/potential_pierce_damage = brute * 0.75

	var/damage_potential = 0

	if(pierce_dam < max_damage)
		damage_potential = max_damage - pierce_dam
		max_pierce_damage = min(brute, damage_potential)
		if(damage_potential < potential_pierce_damage)
			potential_cut_damage += potential_pierce_damage - damage_potential
	else
		max_pierce_damage = 0
		potential_cut_damage += potential_pierce_damage

	if(cut_dam < max_damage)
		damage_potential = max_damage - cut_dam
		max_cut_damage = min(brute, damage_potential)
		if(damage_potential < potential_cut_damage)
			potential_pierce_damage += potential_cut_damage - damage_potential
	else
		max_cut_damage = 0
		potential_pierce_damage += potential_cut_damage

	var/final_pierce_damage = min(potential_pierce_damage, max_pierce_damage)
	pierce_dam = min(pierce_dam + final_pierce_damage, max_damage)

	var/final_cut_damage = min(potential_cut_damage, max_cut_damage)
	cut_dam = min(cut_dam + final_cut_damage, max_damage)

	var/final_blunt_damage = clamp((brute - final_pierce_damage - final_cut_damage) * 0.5 , 0, max_blunt_damage)
	blunt_dam = min(blunt_dam + final_blunt_damage, max_damage)

	return

/obj/item/organ/external/proc/_take_burn_damage(burn)
	if(owner && (owner.status_flags & GODMODE))
		return
	burn_dam = min(max_damage * 2.0, burn_dam + burn)
	return

/obj/item/organ/external/proc/cache_last_damage()
	blunt_last = blunt_dam
	cut_last = cut_dam
	pierce_last = pierce_dam

	brute_last = brute_dam
	burn_last = burn_dam

// All-in-one external damage proc
// 'brute' - amount of brute damage to inflict
// 'burn' - amount of burn damage to inflict
// 'damage_flags' - additional damage tags, such as DAM_SHARP, DAM_EDGE, or DAM_LASER
// 'used_weapon' - what we'll add to the autopsy data
// 'clean' - if TRUE, doesn't cause "extra" effects such as dismemberment or blood evaporation, used for surgical cuts and vacuum damage
/obj/item/organ/external/proc/take_external_damage(brute, burn, damage_flags = 0, used_weapon = null)
	if(owner && (owner.status_flags & GODMODE))
		return 0

	brute = round(brute * brute_mod, 0.1)
	burn = round(burn * burn_mod, 0.1)

	if(brute <= 0 && burn <= 0)
		return 0

	var/clean = (damage_flags & DAM_CLEAN)
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

	cache_last_damage()

	if(brute)
		if(blunt)
			_take_blunt_damage(brute)
		else if(edge)
			_take_cut_damage(brute)
		else if(sharp)
			_take_pierce_damage(brute)
		brute_dam = blunt_dam + cut_dam + pierce_dam
		brute_ratio = brute_dam / max_damage
		blunt_ratio = blunt_dam / max_damage
		cut_ratio = cut_dam / max_damage
		pierce_ratio = pierce_dam / max_damage

	if(burn)
		_take_burn_damage(burn)
		burn_ratio = burn_dam / max_damage
		if(laser && prob(40))
			owner?.IgniteMob()

	// Dismemberment stuff
	if(!isnull(owner) && loc == owner && !clean)
		owner.update_health()
		if(try_to_dismember(brute, burn, damage_flags))
			return

	// High brute damage, sharp objects or deep-frying may damage internal organs
	if(!istype(used_weapon, /obj/item/projectile) && !clean && LAZYLEN(internal_organs)) // Projectiles organ damage is being processed in human_defense.dm
		var/damage_amt = brute
		var/cur_damage = brute_last
		if(laser || (burn_last + burn >= max_damage))
			damage_amt += burn
			cur_damage += burn_last
		var/organ_damage_threshold = 5
		if(sharp)
			organ_damage_threshold *= 0.5
		if(burn_ratio >= 1.0)
			organ_damage_threshold *= 2.01 - burn_ratio

		var/organ_damage_prob = 6.25 * damage_amt/organ_damage_threshold //more damage, higher chance to damage
		if(sharp)
			organ_damage_prob *= 1.5
		if(cur_damage >= 15)
			organ_damage_prob *= cur_damage/15
		if(encased && !(status & ORGAN_BROKEN)) //ribs and skulls protect
			organ_damage_prob *= 0.5
		if((cur_damage + damage_amt >= max_damage || damage_amt >= organ_damage_threshold) && prob(organ_damage_prob))
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
				victim.take_internal_damage(damage_amt, is_traumatic = TRUE)

	if(!BP_IS_ROBOTIC(src))
		// Painful stuff
		if(blunt)
			adjust_pain(brute * (1 + (blunt_last / max_damage)))
		else if(sharp || edge)
			adjust_pain(brute * 0.5) // Not as painful as blunt right away, hurts a lot later.

		if(laser)
			adjust_pain(burn * 0.5)
		else if(burn)
			adjust_pain(burn * 0.25) // First, you don't realize what happened, next, it hurts like a bitch.

		// Bones stuff
		if(brute >= (blunt ? 5.0 : 10.0) && !clean)
			if(status & ORGAN_BROKEN)
				jostle_bone(brute)
				if(owner && prob(40) && can_feel_pain())
					owner.emote("scream") // Getting hit on a broken hand hurts
			else
				var/should_fracture = FALSE
				if(blunt_last >= max_damage && (blunt || prob(brute_dam + brute)))
					should_fracture = TRUE
				else if(blunt_dam >= min_broken_damage && prob(brute_dam + brute * (1 + blunt))) // blunt damage is gud at fracturing
					should_fracture = TRUE

				if(should_fracture)
					fracture()

		// Bloody stuff
		if(brute)
			if(edge)
				bandaged -= brute
				scabbed -= brute
			else
				bandaged -= brute * 0.5
				scabbed -= brute * 0.5

		if(burn)
			bandaged -= burn
			scabbed += burn // Cauterization

			// Burn damage can cause fluid loss due to blistering and cook-off.
			// Smaller limbs and existing bloodloss reduce the amount of fluid loss.
			if(owner && (burn_dam >= min_broken_damage) && !clean)
				var/fluid_loss = ceil((damage/(owner.maxHealth - config.health.health_threshold_dead)) * owner.species.blood_volume * (max_damage / 100) * (min(10, owner.get_blood_volume()) / 100))
				owner.remove_blood(fluid_loss  * (laser ? FLUIDLOSS_CONC_BURN : FLUIDLOSS_WIDE_BURN))

		// Arteries+Tendons stuff
		if(brute > 15 && max(cut_dam, pierce_dam) > min_broken_damage && !clean)
			var/internal_damage
			if(prob(ceil(damage/2)) && sever_artery())
				internal_damage = TRUE
			if(prob(ceil(damage/4)) && sever_tendon())
				internal_damage = TRUE
			if(internal_damage)
				owner.custom_pain("You feel something rip in your [name]!", 50, affecting = src)

		salved = FALSE

		if(clamped && !clean)
			clamped = FALSE
			owner?.update_surgery()

	// Sync the organ's damage with its wounds
	update_damages()

	if(owner)
		owner.update_health()
		if(update_damstate())
			owner.update_damage_overlays()
		else if(status & ORGAN_BLEEDING)
			owner.update_bandages() // TODO: Rework bandages
	return

// Shortcuts for damage types
/obj/item/organ/external/proc/take_blunt_damage(amount, used_weapon = null, clean = FALSE)
	return take_external_damage(amount, 0, (clean ? DAM_CLEAN : 0), used_weapon)

/obj/item/organ/external/proc/take_pierce_damage(amount, used_weapon = null, clean = FALSE)
	return take_external_damage(amount, 0, (clean ? (DAM_SHARP|DAM_CLEAN) : DAM_SHARP), used_weapon)

/obj/item/organ/external/proc/take_cut_damage(amount, used_weapon = null, clean = FALSE)
	return take_external_damage(amount, 0, (clean ? (DAM_EDGE|DAM_CLEAN) : DAM_EDGE), used_weapon)

/obj/item/organ/external/proc/take_burn_damage(amount, used_weapon = null, clean = FALSE)
	return take_external_damage(0, amount, (clean ? DAM_CLEAN : 0), used_weapon)

#define DISMEMBER_BRUTE_TRESHOLD(x) (brute >= (max(5, x * ((3.0 - brute_ratio) / 3))))
/obj/item/organ/external/proc/try_to_dismember(brute, burn, damage_flags)
	if(!(limb_flags & ORGAN_FLAG_CAN_AMPUTATE) || !config.health.limbs_can_break  || is_stump())
		return FALSE

	var/sharp = (damage_flags & DAM_SHARP)
	var/edge  = (damage_flags & DAM_EDGE)
	var/laser = (damage_flags & DAM_LASER)
	var/blunt = brute && !sharp && !edge

	var/force_droplimb = FALSE
	if((brute >= 5.0 && (brute_last + brute >= max_damage * 3)) || (burn >= 5.0 && (burn_last + burn >= max_damage * 2)))
		force_droplimb = TRUE

	if(edge && (cut_last + brute >= max_damage))
		if(force_droplimb || DISMEMBER_BRUTE_TRESHOLD(min_broken_damage)) // Edged weapons are superior in dismemberment.
			droplimb(FALSE, DROPLIMB_EDGE)
			return TRUE

	if(sharp && !edge && (pierce_last + brute >= max_damage))
		if(force_droplimb || DISMEMBER_BRUTE_TRESHOLD(max_damage))
			droplimb(FALSE, pick(DROPLIMB_EDGE, DROPLIMB_BLUNT))
			return TRUE

	if(blunt && (blunt_last + brute >= max_damage) && (status & ORGAN_BROKEN))
		if(force_droplimb || DISMEMBER_BRUTE_TRESHOLD(max_damage))
			droplimb(FALSE, DROPLIMB_BLUNT)
			return TRUE

	if(burn >= 5.0 && (burn_last + burn >= max_damage))
		if(force_droplimb || prob(burn))
			droplimb(laser, DROPLIMB_BURN)
			return TRUE

	if(force_droplimb) // Should not happen, but let's have a plan B.
		droplimb(FALSE, DROPLIMB_BLUNT)
		return TRUE

	return FALSE
#undef DISMEMBER_BRUTE_TRESHOLD

/obj/item/organ/external/heal_damage(brute, burn, internal = 0, robo_repair = 0, update_damage_icon = TRUE)
	if(BP_IS_ROBOTIC(src) && !robo_repair)
		return FALSE

	if(burn_dam && burn)
		heal_burn_damage(burn, robo_repair, FALSE, FALSE)

	if(brute_dam && brute)
		var/blunt_heal_ratio = blunt_dam / brute_dam
		var/sharp_heal_ratio = 1 - blunt_heal_ratio

		if(blunt_heal_ratio)
			heal_blunt_damage(brute * blunt_heal_ratio, robo_repair, FALSE, FALSE)
		if(sharp_heal_ratio)
			heal_sharp_damage(brute * sharp_heal_ratio, robo_repair, FALSE, FALSE)

	if(internal)
		mend_fracture(TRUE)

	//Sync the organ's damage with its wounds
	update_damages()
	var/should_update_damstate

	if(owner)
		owner.update_health()

		should_update_damstate = update_damstate()
		if(update_damage_icon && should_update_damstate)
			owner.update_damage_overlays()

	return should_update_damstate

/obj/item/organ/external/proc/heal_burn_damage(amount, robo_repair = FALSE, should_update_damages = TRUE, update_damage_icon = TRUE)
	if(!amount)
		return

	if(BP_IS_ROBOTIC(src) && !robo_repair)
		return

	. = min(amount, burn_dam)
	if(!.)
		return amount

	burn_dam -= (.)

	if(burn_dam <= 0.1)
		burn_dam = 0
	else
		burn_dam = round(burn_dam, 0.01)

	owner?.heal_this_tick += (.)

	if(should_update_damages)
		update_damages()
		if(owner)
			owner.update_health()
			if(update_damage_icon && update_damstate())
				owner.update_damage_overlays()

	return (amount - (.))

/obj/item/organ/external/proc/heal_blunt_damage(amount, robo_repair = FALSE, should_update_damages = TRUE, update_damage_icon = TRUE)
	if(!amount)
		return

	if(BP_IS_ROBOTIC(src) && !robo_repair)
		return

	. = min(amount, blunt_dam)
	if(!.)
		return amount

	blunt_dam -= (.)

	if(blunt_dam <= 0.1)
		blunt_dam = 0
	else
		blunt_dam = round(blunt_dam, 0.01)

	owner?.heal_this_tick += (.)

	if(should_update_damages)
		update_damages()
		if(owner)
			owner.update_health()
			if(update_damage_icon && update_damstate())
				owner.update_damage_overlays()

	return (amount - (.))

/obj/item/organ/external/proc/heal_sharp_damage(amount, robo_repair = FALSE, should_update_damages = TRUE, update_damage_icon = TRUE)
	if(!amount)
		return

	if(BP_IS_ROBOTIC(src) && !robo_repair)
		return

	. = (cut_dam + pierce_dam)

	if(!.)
		return amount

	var/cut_to_heal = amount * (cut_dam / (.))
	var/pierce_to_heal = amount * (pierce_dam / (.))

	cut_dam -= cut_to_heal
	pierce_dam -= pierce_to_heal

	if(cut_dam <= 0.1)
		cut_dam = 0
	else
		cut_dam = round(cut_dam, 0.01)

	if(pierce_dam <= 0.1)
		pierce_dam = 0
	else
		pierce_dam = round(pierce_dam, 0.01)

	owner?.heal_this_tick += (cut_to_heal + pierce_to_heal)

	if(should_update_damages)
		update_damages()
		if(owner)
			owner.update_health()
			if(update_damstate() && update_damage_icon)
				owner.update_damage_overlays()

	return (amount - (cut_to_heal + pierce_to_heal))


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

	lasting_pain = max(blunt_dam * 0.5, cut_dam + pierce_dam, burn_dam)

	if(is_broken())
		lasting_pain += 10
	else if(is_dislocated())
		lasting_pain += 5

	lasting_pain += get_genetic_damage() * 0.5

	full_pain = min(pain, max_pain) + min(lasting_pain, max_damage)
	if(salved)
		full_pain *= 0.5 // It gets interrupted by virtually any damage, so this can't be too OP.

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
	if(status & ORGAN_ARTERY_CUT)
		return FALSE

	if(!(limb_flags & ORGAN_FLAG_HAS_ARTERY))
		return FALSE

	if(species && !species.has_organ[BP_HEART])
		return FALSE

	var/obj/item/organ/internal/heart/O = species.has_organ[BP_HEART]
	if(initial(O.open))
		return FALSE

	status |= ORGAN_ARTERY_CUT
	return TRUE

/obj/item/organ/external/proc/sever_tendon()
	if(status & ORGAN_TENDON_CUT)
		return FALSE

	if(!(limb_flags & ORGAN_FLAG_HAS_TENDON))
		return FALSE

	status |= ORGAN_TENDON_CUT
	return TRUE

/obj/item/organ/external/proc/dislocate()
	if(dislocated == -1)
		return

	dislocated = 1
	if(owner)
		owner.verbs |= /mob/living/carbon/human/proc/undislocate

/obj/item/organ/external/proc/undislocate()
	if(dislocated == -1)
		return

	dislocated = 0
	if(owner)
		owner.shock_stage += 20

		//check to see if we still need the verb
		for(var/obj/item/organ/external/limb in owner.external_organs)
			if(limb.dislocated == 1)
				return

		owner.verbs -= /mob/living/carbon/human/proc/undislocate
