//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/update_health()
	var/previous_health = health
	if(status_flags & GODMODE)
		health = maxHealth
		set_stat(CONSCIOUS)
		if(health != previous_health)
			update_health_slowdown()
		return

	health = maxHealth - getBrainLoss()

	if(health != previous_health)
		update_health_slowdown()

	//TODO: fix husking
	if(((maxHealth - getFireLoss()) < config.health.health_threshold_dead) && is_ic_dead())
		ChangeToHusk()
	return

/mob/living/carbon/human/adjustBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	if(should_have_organ(BP_BRAIN))
		if(amount > 0)
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					amount *= M.incoming_damage_percent
				if(!isnull(M.incoming_hal_damage_percent))
					amount *= M.incoming_hal_damage_percent
				if(!isnull(M.disable_duration_percent))
					amount *= M.incoming_hal_damage_percent
		else if(amount < 0)
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_healing_percent))
					amount *= M.incoming_healing_percent
		var/obj/item/organ/internal/cerebrum/brain/sponge = internal_organs_by_name[BP_BRAIN]
		if(sponge)
			sponge.take_internal_damage(amount)

/mob/living/carbon/human/setBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	if(should_have_organ(BP_BRAIN))
		var/obj/item/organ/internal/cerebrum/brain/sponge = internal_organs_by_name[BP_BRAIN]
		if(sponge)
			sponge.damage = min(max(amount, 0),sponge.species.total_health)
			update_health()

/mob/living/carbon/human/getBrainLoss()
	if(status_flags & GODMODE)
		return 0
	if(should_have_organ(BP_BRAIN))
		var/obj/item/organ/internal/cerebrum/brain/sponge = internal_organs_by_name[BP_BRAIN]
		if(sponge)
			if(sponge.status & ORGAN_DEAD)
				return sponge.species.total_health
			else
				return sponge.damage
		else
			return species.total_health
	return 0

//Straight pain values, not affected by painkillers etc
/mob/living/carbon/human/getHalLoss()
	return full_pain

/mob/living/carbon/human/setHalLoss(amount)
	adjustHalLoss(getHalLoss() - amount)

/mob/living/carbon/human/adjustHalLoss(amount)
	if(!amount || no_pain)
		return
	var/list/pick_organs = external_organs.Copy()

	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.incoming_damage_percent))
			amount *= M.incoming_damage_percent
		if(!isnull(M.incoming_hal_damage_percent))
			amount *= M.incoming_hal_damage_percent
		if(!isnull(M.disable_duration_percent))
			amount *= M.incoming_hal_damage_percent

	while(amount != 0 && pick_organs.len)
		var/obj/item/organ/external/E = pick(pick_organs)
		pick_organs -= E
		if(!istype(E))
			continue
		amount -= E.adjust_pain(amount)

	BITSET(hud_updateflag, HEALTH_HUD)

//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in external_organs)
		if(BP_IS_ROBOTIC(O) && !O.vital)
			continue //robot limbs don't count towards shock and crit
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in external_organs)
		if(BP_IS_ROBOTIC(O) && !O.vital)
			continue //robot limbs don't count towards shock and crit
		amount += O.burn_dam
	return amount

/mob/living/carbon/human/adjustBruteLoss(amount)
	amount = amount*species.brute_mod
	if(amount > 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_damage_percent))
				amount *= M.incoming_damage_percent
			if(!isnull(M.incoming_brute_damage_percent))
				amount *= M.incoming_brute_damage_percent
		take_overall_damage(amount, 0)
	else
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_healing_percent))
				amount *= M.incoming_healing_percent
		heal_overall_damage(-amount, 0)
	BITSET(hud_updateflag, HEALTH_HUD)

/mob/living/carbon/human/adjustFireLoss(amount)
	amount = amount*species.burn_mod
	if(amount > 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_damage_percent))
				amount *= M.incoming_damage_percent
			if(!isnull(M.incoming_fire_damage_percent))
				amount *= M.incoming_fire_damage_percent
		take_overall_damage(0, amount)
	else
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_healing_percent))
				amount *= M.incoming_healing_percent
		heal_overall_damage(0, -amount)
	BITSET(hud_updateflag, HEALTH_HUD)

/mob/living/carbon/human/Stun(amount)
	if((MUTATION_HULK in mutations) || (MUTATION_STRONG in mutations))
		return
	..()

/mob/living/carbon/human/Weaken(amount)
	if((MUTATION_HULK in mutations) || (MUTATION_STRONG in mutations))
		return
	..()

/mob/living/carbon/human/Paralyse(amount)
	if((MUTATION_HULK in mutations) || (MUTATION_STRONG in mutations))
		return

	// Notify our AI if they can now control the suit.
	if(wearing_rig && !stat && paralysis < amount) //We are passing out right this second.
		wearing_rig.notify_ai("<span class='danger'>Warning: user consciousness failure. Mobility control passed to integrated intelligence system.</span>")

	..()

/mob/living/carbon/human/getCloneLoss()
	var/amount = 0
	for(var/obj/item/organ/external/E in external_organs)
		amount += E.get_genetic_damage()
	return amount

/mob/living/carbon/human/setCloneLoss(amount)
	adjustCloneLoss(getCloneLoss()-amount)

/mob/living/carbon/human/adjustCloneLoss(amount)
	var/heal = amount < 0
	amount = abs(amount)
	if(amount > 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_damage_percent))
				amount *= M.incoming_damage_percent
			if(!isnull(M.incoming_hal_damage_percent))
				amount *= M.incoming_hal_damage_percent
			if(!isnull(M.disable_duration_percent))
				amount *= M.incoming_hal_damage_percent
	else if(amount < 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_healing_percent))
				amount *= M.incoming_healing_percent
	var/list/pick_organs = external_organs.Copy()
	while(amount > 0 && pick_organs.len)
		var/obj/item/organ/external/E = pick(pick_organs)
		pick_organs -= E
		if(heal)
			amount -= E.remove_genetic_damage(amount)
		else
			amount -= E.add_genetic_damage(amount)
	BITSET(hud_updateflag, HEALTH_HUD)

// Defined here solely to take species flags into account without having to recast at mob/living level.
/mob/living/carbon/human/getOxyLoss()
	if(!need_breathe())
		return 0
	else
		var/obj/item/organ/internal/lungs/breathe_organ = internal_organs_by_name[species.breathing_organ]
		if(!breathe_organ)
			return maxHealth
		return breathe_organ.get_oxygen_deprivation()

/mob/living/carbon/human/setOxyLoss(amount)
	if(!need_breathe())
		return 0
	else
		adjustOxyLoss(getOxyLoss()-amount)

/mob/living/carbon/human/adjustOxyLoss(amount)
	if(!need_breathe())
		return
	var/heal = amount < 0
	amount = abs(amount*species.oxy_mod)
	if(amount > 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_damage_percent))
				amount *= M.incoming_damage_percent
			if(!isnull(M.incoming_tox_damage_percent))
				amount *= M.incoming_tox_damage_percent
				heal = istype(M, TRAIT_TOXINLOVER)

	else if(amount < 0)
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_healing_percent))
				amount *= M.incoming_healing_percent
	var/obj/item/organ/internal/lungs/breathe_organ = internal_organs_by_name[species.breathing_organ]
	if(breathe_organ)
		if(heal)
			breathe_organ.remove_oxygen_deprivation(amount)
		else
			breathe_organ.add_oxygen_deprivation(amount)
	BITSET(hud_updateflag, HEALTH_HUD)

/mob/living/carbon/human/getToxLoss()
	if(isSynthetic() || isundead(src))
		return 0
	return toxic_severity

/mob/living/carbon/human/setToxLoss(amount)
	if(isSynthetic() || isundead(src))
		return
	toxic_buildup = amount

/mob/living/carbon/human/adjustToxPercent(amount)
	if(status_flags & GODMODE)
		return 0
	amount = round(amount * ((species ? (species.blood_volume * 0.05) : 280) / 100))
	adjustToxLoss(amount)
	toxic_severity = round(toxic_buildup / (species ? (species.blood_volume * 0.05) : 280) * 100)

/mob/living/carbon/human/adjustToxLoss(amount, bypass_liver = FALSE)
	if(isSynthetic() || isundead(src))
		return

	var/heal = amount < 0 || HAS_TRAIT(src, TRAIT_TOXINLOVER)
	amount = abs(amount)

	// Liver is buffering some toxic damage, unless it's too busy. And unless the damage bypasses the liver (i.e. damage caused by liver failure).
	var/obj/item/organ/internal/liver/liver = internal_organs_by_name[BP_LIVER]
	if(liver && !bypass_liver && !heal)
		amount = liver.store_tox(amount)
		if(amount <= 0)
			return // Try to store toxins in the liver; stop right here if it sponges all the damage

	if(heal)
		toxic_buildup = max(0, toxic_buildup - amount)
	else
		toxic_buildup += amount

/mob/living/carbon/human/getInternalLoss() // In the year 2025, we finally have separate toxLoss and internalLoss. Awe.
	if(isSynthetic() || isundead(src))
		return 0
	var/amount = 0
	for(var/obj/item/organ/internal/I in internal_organs)
		amount += I.damage
	return amount

/mob/living/carbon/human/setInternalLoss(amount)
	if(!isSynthetic() && !isundead(src))
		adjustInternalLoss(getInternalLoss() - amount)

/mob/living/carbon/human/adjustInternalLoss(amount, toxic = FALSE)
	if(isSynthetic() || isundead(src))
		return

	var/heal = amount < 0 || (toxic && HAS_TRAIT(src, TRAIT_TOXINLOVER))
	amount = abs(amount)

	var/list/pick_organs = shuffle(internal_organs.Copy())

	// Prioritize damaging our *working* filtration organs first if it's toxic damage.
	if(toxic)
		var/obj/item/organ/internal/kidneys/kidneys = internal_organs_by_name[BP_KIDNEYS]
		if(kidneys && !kidneys.is_broken())
			pick_organs -= kidneys
			pick_organs.Insert(1, kidneys)

		var/obj/item/organ/internal/liver/liver = internal_organs_by_name[BP_LIVER]
		if(liver && !liver.is_broken())
			pick_organs -= liver
			pick_organs.Insert(1, liver)

	// Move the brain to the very end since damage to it is vastly more dangerous
	// (and isn't technically counted as toxloss) than general organ damage.
	var/obj/item/organ/internal/cerebrum/brain/brain = internal_organs_by_name[BP_BRAIN]
	if(brain)
		pick_organs -= brain
		pick_organs += brain

	for(var/obj/item/organ/internal/I in pick_organs)
		if(toxic && BP_IS_ROBOTIC(I))
			continue

		if(amount <= 0)
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_healing_percent))
					amount *= M.incoming_healing_percent
			break
		for(var/datum/modifier/M in modifiers)
			if(!isnull(M.incoming_damage_percent))
				amount *= M.incoming_damage_percent
			if(!isnull(M.incoming_tox_damage_percent))
				amount *= M.incoming_tox_damage_percent

		if(heal)
			if(I.damage < amount)
				amount -= I.damage
				I.damage = 0
			else
				I.damage -= amount
				amount = 0
		else
			var/cap_dam = I.max_damage - I.damage
			if(amount >= cap_dam)
				I.take_internal_damage(cap_dam, silent=TRUE)
				amount -= cap_dam
			else
				I.take_internal_damage(amount, silent=TRUE)
				amount = 0

////////////////////////////////////////////

//Returns a list of damaged organs
/mob/living/carbon/human/proc/get_damaged_organs(brute, burn)
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in external_organs)
		if((brute && O.brute_dam) || (burn && O.burn_dam))
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(brute, burn)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)	return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.heal_damage(brute,burn))
		BITSET(hud_updateflag, HEALTH_HUD)
	update_health()


//TODO reorganize damage procs so that there is a clean API for damaging living mobs

/*
In most cases it makes more sense to use apply_damage() instead! And make sure to check armour if applicable.
*/
//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(brute, burn, sharp = 0, edge = 0)
	if(!length(external_organs))
		return

	var/obj/item/organ/external/picked = pick(external_organs)
	var/damage_flags = (sharp? DAM_SHARP : 0)|(edge? DAM_EDGE : 0)

	if(picked.take_external_damage(brute, burn, damage_flags))
		BITSET(hud_updateflag, HEALTH_HUD)

	update_health()

// damage ONE organic external organ, organ gets randomly selected from all damagable
/mob/living/carbon/human/proc/take_organic_organ_damage(brute, burn)
	var/list/organic_organs = list()

	for(var/obj/item/organ/external/organ in external_organs)
		if(!BP_IS_ROBOTIC(organ))
			organic_organs += organ

	if(!length(organic_organs))
		return

	var/obj/item/organ/external/damaged_organ = pick(organic_organs)
	if(damaged_organ.take_external_damage(brute, burn))
		BITSET(hud_updateflag, HEALTH_HUD)

	update_health()

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, obj/used_weapon = null)
	if(status_flags & GODMODE)
		return FALSE

	var/obj/item/organ/external/organ
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		organ = get_organ(check_zone(def_zone))

	//Handle other types of damage
	if(!(damagetype in list(BRUTE, BURN, PAIN, CLONE)))
		..(damage, damagetype, def_zone, blocked)
		return TRUE

	if(!istype(organ))
		return FALSE

	handle_suit_punctures(damagetype, damage, def_zone)

	if(blocked >= 100)
		return FALSE

	if(blocked)
		damage *= blocked_mult(blocked)

	damageoverlaytemp = 20
	if(getHalLoss() < last_body_response_to_pain)
		last_body_response_to_pain = getHalLoss()
	if(can_feel_pain() && damage > 5)
		make_adrenaline(round(damage)/10)
		last_body_response_to_pain = getHalLoss()
	else if(can_feel_pain() && getHalLoss() - last_body_response_to_pain > 5)
		make_adrenaline(round(getHalLoss() - last_body_response_to_pain)/10)
		last_body_response_to_pain = getHalLoss()

	switch(damagetype)
		if(BRUTE)
			damage = damage*species.brute_mod
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					damage *= M.incoming_damage_percent
				if(!isnull(M.incoming_brute_damage_percent))
					damage *= M.incoming_brute_damage_percent
			organ.take_external_damage(damage, 0, damage_flags, used_weapon)
		if(BURN)
			damage = damage*species.burn_mod
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					damage *= M.incoming_damage_percent
				if(!isnull(M.incoming_fire_damage_percent))
					damage *= M.incoming_fire_damage_percent
			organ.take_external_damage(0, damage, damage_flags, used_weapon)
		if(PAIN)
			organ.adjust_pain(damage)
		if(CLONE)
			for(var/datum/modifier/M in modifiers)
				if(!isnull(M.incoming_damage_percent))
					damage *= M.incoming_damage_percent
				if(!isnull(M.incoming_clone_damage_percent))
					damage *= M.incoming_clone_damage_percent
			organ.add_genetic_damage(damage)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	update_health()
	species.handle_damage(src)
	BITSET(hud_updateflag, HEALTH_HUD)
	return TRUE

//Heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(brute, burn)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)
	var/should_update_damage_icon = FALSE

	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		if(picked.heal_damage(brute,burn, update_damage_icon = FALSE))
			should_update_damage_icon = TRUE

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	update_health()
	if(should_update_damage_icon)
		update_damage_overlays()

	BITSET(hud_updateflag, HEALTH_HUD)

// Deals brute and/or burn damage to all external organs.
// 'spread_damage' defines whether to spread the damage evenly across the organs or to deal the same amount of damage to each one.
/mob/living/carbon/human/take_overall_damage(brute, burn, damage_flags = 0, used_weapon = null, spread_damage = TRUE, check_armor = null)
	if(status_flags & GODMODE)
		return

	var/organs_count = length(external_organs)
	if(!organs_count)
		return

	var/brute_to_deal = brute
	var/burn_to_deal = burn
	if(spread_damage)
		brute_to_deal /= organs_count
		burn_to_deal /= organs_count

	var/blocked = 0
	for(var/obj/item/organ/external/E in external_organs)
		if(QDELETED(E))
			continue // A slime hand gibbed because of the damage to the arm, or something.
		if(check_armor)
			blocked = get_organ_armor(E, check_armor)
		if(brute_to_deal)
			apply_damage(brute_to_deal, BRUTE, E, blocked, damage_flags, used_weapon)
		if(burn_to_deal)
			apply_damage(burn_to_deal, BURN, E, blocked, damage_flags, used_weapon)

	update_health()
	BITSET(hud_updateflag, HEALTH_HUD)


////////////////////////////////////////////
/*
This function restores all organs.
*/
/mob/living/carbon/human/restore_all_organs(ignore_prosthetic_prefs = FALSE)
	for(var/bodypart in BP_BY_DEPTH)
		var/obj/item/organ/external/current_organ = external_organs_by_name[bodypart]
		if(istype(current_organ))
			current_organ.rejuvenate(ignore_prosthetic_prefs)

	// And restore all internal organs...
	for (var/obj/item/organ/internal/I in internal_organs)
		I.rejuvenate()

	if(mind?.vampire)
		var/datum/vampire/V = mind.vampire
		V.set_up_organs()

	full_pain = 0
	update_organ_movespeed()

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/organ/external/E = get_organ(zone)
	if(istype(E, /obj/item/organ/external))
		if (E.heal_damage(brute, burn))
			BITSET(hud_updateflag, HEALTH_HUD)
	else
		return 0
	return


/mob/living/carbon/human/proc/get_organ(zone)
	return external_organs_by_name[check_zone(zone)]

// Find out in how much pain the mob is at the moment.
/mob/living/carbon/human/proc/get_shock()
	if(!can_feel_pain())
		return 0

	var/traumatic_shock = getHalLoss()                 // Pain.
	traumatic_shock -= chem_effects[CE_PAINKILLER] // TODO: check what is actually stored here.

	if(stat == UNCONSCIOUS)
		traumatic_shock *= 0.6
	return max(0, traumatic_shock)

/mob/living/carbon/human/handle_pull_damage(mob/living/puller)
	if(!lying)
		return FALSE

	if(species && (species.species_flags & SPECIES_FLAG_NO_MINOR_CUT))
		return FALSE

	if(!length(bad_external_organs))
		return FALSE

	if(!has_gravity())
		return FALSE

	var/has_blood = TRUE
	if(species && (species.species_flags & SPECIES_FLAG_NO_BLOOD))
		has_blood = FALSE
	else if(!vessel.has_reagent(/datum/reagent/blood))
		has_blood = FALSE

	var/damage_message = ""
	var/turf/location = get_turf(src)
	for(var/obj/item/organ/external/E in shuffle(bad_external_organs))
		if(E.is_stump())
			continue

		var/should_take_damage = max(E.cut_dam, E.burn_dam) >= E.min_broken_damage * (E.bleeding ? 0.75 : 1.25)
		if(should_take_damage)
			if(max(E.cut_ratio, E.burn_ratio) >= 0.9)
				if(BP_IS_ROBOTIC(E))
					damage_message = "Damage to [src]'s [E] worsens terribly from being dragged!"
				else
					damage_message = "Wounds on [src]'s [E] worsen terribly from being dragged!"
					if(has_blood && prob(75))
						var/obj/effect/decal/cleanable/blood/B = location.add_blood(src)
						if(istype(B))
							B.Crossed(src)
						vessel.remove_reagent(/datum/reagent/blood, 30)
			else
				if(BP_IS_ROBOTIC(E))
					damage_message = "Damage to [src]'s [E] worsens from being dragged!"
				else
					damage_message = "Wounds on [src]'s [E] open more from being dragged!"
					if(has_blood && prob(25))
						var/obj/effect/decal/cleanable/blood/B = location.add_blood(src)
						if(istype(B))
							B.Crossed(src)
						vessel.remove_reagent(/datum/reagent/blood, 10)

			if(E.last_pull_damage_time < world.time - 3 SECONDS  || E.last_pull_damage_message != damage_message)
				visible_message(SPAN("danger", damage_message))
				E.last_pull_damage_message = damage_message
				E.last_pull_damage_time = world.time

			E.take_cut_damage(3, "Friction")
			return TRUE // Let's not make floors a tiled god of death, one proc per move is more than enough.

		should_take_damage = !BP_IS_ROBOTIC(E) && E.is_broken()
		if(should_take_damage)
			if(E.blunt_ratio >= 0.9)
				damage_message = "Broken bones in [src]'s [E] shred through the skin from being dragged!"
				E.take_pierce_damage(3, "Bone Shards")
				if(has_blood && prob(50))
					var/obj/effect/decal/cleanable/blood/B = location.add_blood(src)
					if(istype(B))
						B.Crossed(src)
					vessel.remove_reagent(/datum/reagent/blood, 20)
			else
				damage_message = "Broken bones in [src]'s [E] jostle badly from being dragged!"
				E.take_blunt_damage(3, "Broken Bone Movement")

			if(E.last_pull_damage_time < world.time - 3 SECONDS  || E.last_pull_damage_message != damage_message)
				visible_message(SPAN("danger", damage_message))
				E.last_pull_damage_message = damage_message
				E.last_pull_damage_time = world.time

			return TRUE

	return FALSE

/mob/living/carbon/human/pull_damage()
	if(!lying || getBruteLoss() + getFireLoss() < 100)
		return 0
	for(var/thing in external_organs)
		var/obj/item/organ/external/e = thing
		if(!e || e.is_stump())
			continue
		if((e.status & ORGAN_BROKEN) && !e.splinted)
			return 1
		if(e.status & ORGAN_BLEEDING)
			return 1
	return 0
