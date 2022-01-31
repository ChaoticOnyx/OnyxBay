/*
Contains most of the procs that are called when a mob is attacked by something
bullet_act
ex_act
meteor_act
*/


/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)

	def_zone = check_zone(def_zone)
	if(!has_organ(def_zone))
		return PROJECTILE_FORCE_MISS //if they don't have the organ in question then the projectile just passes by.

	//Shields
	var/shield_check = check_shields(P.damage, P, null, def_zone, "the [P.name]")
	if(shield_check)
		if(shield_check < 0)
			return shield_check
		else
			P.on_hit(src, 100, def_zone)
			return 100

	var/obj/item/organ/external/organ = get_organ(def_zone)
	var/armor = getarmor_organ(organ, P.check_armour)
	var/penetrating_damage = ((P.damage + P.armor_penetration) * P.penetration_modifier) - armor

	//Organ damage
	if(organ.internal_organs.len && prob(35 + max(penetrating_damage, -12.5)))
		var/damage_amt = min((P.damage * P.penetration_modifier), penetrating_damage) //So we don't factor in armor_penetration as additional damage
		if(damage_amt > 0)
		// Damage an internal organ
			var/list/victims = list()
			var/list/possible_victims = shuffle(organ.internal_organs.Copy())
			for(var/obj/item/organ/internal/I in possible_victims)
				if(I.damage < I.max_damage && (prob((I.relative_size) * (1 / max(1, victims.len)))))
					victims += I
			if(victims.len)
				for(var/obj/item/organ/internal/victim in victims)
					damage_amt /= 2
					victim.take_internal_damage(damage_amt)

	//Embed or sever artery
	if(P.can_embed() && !(species.species_flags & SPECIES_FLAG_NO_EMBED) && prob(22.5 + max(penetrating_damage, -10)) && !(prob(50) && (organ.sever_artery())))
		var/obj/item/material/shard/shrapnel/SP = new()
		SP.SetName((P.name != "shrapnel")? "[P.name] shrapnel" : "shrapnel")
		SP.desc = "[SP.desc] It looks like it was fired from [P.shot_from]."
		SP.loc = organ
		organ.embed(SP)

	//Tase effect
	if(P.tasing)
		handle_tase(P.agony)

	var/blocked = ..(P, def_zone)

	projectile_hit_bloody(P, P.damage*blocked_mult(blocked), def_zone)

	return blocked

/mob/living/carbon/human/stun_effect_act(stun_amount, agony_amount, def_zone, used_weapon = null)
	var/obj/item/organ/external/affected = get_organ(check_zone(def_zone))
	if(!affected)
		return

	var/siemens_coeff = get_siemens_coefficient_organ(affected)
	stun_amount *= siemens_coeff
	agony_amount *= siemens_coeff
	agony_amount *= affected.get_agony_multiplier()

	affected.stun_act(stun_amount, agony_amount)

	..(stun_amount, agony_amount, def_zone)



//////////////////////
///		ARMOR	//////
//////////////////////

//Tis but a placeholder for now. Gonna change it later. Much later. Mucho later. Muchacho later. ~Toby
/mob/living/carbon/human/run_armor_check(def_zone = null, attack_flag = "melee", armor_pen = 0, absorb_text = null, soften_text = null, aforce = 0)
	var/effective_armor = getarmor(def_zone, attack_flag) - armor_pen

	if(effective_armor <= 0)
		return 0

	return effective_armor

/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/total = 0

	if(def_zone)
		if(isorgan(def_zone))
			return getarmor_organ(def_zone, type)
		var/obj/item/organ/external/affecting = get_organ(def_zone)
		if(affecting)
			return getarmor_organ(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/organ_name in organs_by_name)
		if (organ_name in organ_rel_size)
			var/obj/item/organ/external/organ = organs_by_name[organ_name]
			if(organ)
				var/weight = organ_rel_size[organ_name]
				armorval += (getarmor_organ(organ, type) * weight) //use plain addition here because we are calculating an average
				total += weight
	return (armorval/max(total, 1))

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(obj/item/organ/external/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = max(species.siemens_coefficient,0)

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(obj/item/organ/external/def_zone, type)
	if(!type || !def_zone) return 0
	if(!istype(def_zone))
		def_zone = get_organ(check_zone(def_zone))
	if(!def_zone)
		return 0
	var/protection = 0
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/obj/item/clothing/gear in protective_gear)
		if(gear.body_parts_covered & def_zone.body_part)
			protection = add_armor(protection, gear.armor[type])
		if(gear.accessories.len)
			for(var/obj/item/clothing/accessory/bling in gear.accessories)
				if(bling.body_parts_covered & def_zone.body_part)
					protection = add_armor(protection, bling.armor[type])
	return protection

/mob/living/carbon/human/proc/check_head_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & HEAD)
				return 1
	return 0

//Used to check if they can be fed food/drinks/pills
/mob/living/carbon/human/check_mouth_coverage()
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform)
	for(var/obj/item/gear in protective_gear)
		if(istype(gear) && (gear.body_parts_covered & FACE))
			return gear
	return null

/mob/living/carbon/human/proc/check_shields(var/damage = 0, var/atom/damage_source = null, var/mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	for(var/obj/item/shield in list(l_hand, r_hand, wear_suit))
		if(!shield) continue
		. = shield.handle_shield(src, damage, damage_source, attacker, def_zone, attack_text)
		if(.) return
	return 0

///////////////////////
///		ATTACKS		///
///////////////////////

/mob/living/carbon/human/proc/bodypart_miss_chance(zone, mob/target, miss_chance_mod = 1, ranged_attack=0, reach = 0)
	zone = check_zone(zone)

	if(!ranged_attack)
		// you cannot miss if your target is prone or restrained
		if(target.buckled || target.lying)
			return zone
		// if your target is being grabbed aggressively by someone you cannot miss either
		for(var/obj/item/grab/G in target.grabbed_by)
			if(G.stop_move())
				return zone

	var/miss_chance = 10
	if (zone in base_miss_chance)
		miss_chance = base_miss_chance[zone]

		//visible_message("Debug \[MISS\]: zone in base_miss_chance [zone] | [miss_chance]") // Debug Message

	miss_chance = miss_chance*miss_chance_mod
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(reach < 0.7 && (zone == BP_L_FOOT || zone == BP_R_FOOT)) // No pyatkoboevka for short (i.e. your dick) items.

			//visible_message("Debug \[MISS\]: pyatka") // Debug Message

			miss_chance = 100
		var/obj/item/organ/external/O = H.organs_by_name[zone]
		if(prob(miss_chance))

			//visible_message("Debug \[MISS\]: miss [miss_chance]") // Debug Message

			if(prob(60) && H.get_organ(O.parent_organ))
				var/reszone = H.get_organ(O.parent_organ).organ_tag

				//visible_message("Debug \[MISS\]: reszone - [reszone] | organ - [organs_by_name[zone]]") // Debug Message

				return reszone
			else
				return null
		else
			return zone
	if(prob(miss_chance))
		if(prob(0))
			return null
		return pick(base_miss_chance)
	return zone

/mob/living/carbon/human/resolve_item_attack(obj/item/I, mob/living/user, var/target_zone)

	for (var/obj/item/grab/G in grabbed_by)
		if(G.resolve_item_attack(user, I, target_zone))
			return null

	if(user == src) // Attacking yourself can't miss
		return target_zone

	var/hit_zone = get_zone_with_miss_chance(target_zone, src)

	if(!hit_zone)
		visible_message("<span class='danger'>\The [user] misses [src] with \the [I]!</span>")
		return null

	if(check_shields(I.force, I, user, target_zone, "the [I.name]"))
		return null

	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if (!affecting || affecting.is_stump())
		to_chat(user, "<span class='danger'>They are missing that limb!</span>")
		return null

	return hit_zone

/mob/living/carbon/human/hit_with_weapon(obj/item/I, mob/living/user, var/effective_force, var/hit_zone)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return //should be prevented by attacked_with_item() but for sanity.

	visible_message("<span class='danger'>[src] has been [I.attack_verb.len? pick(I.attack_verb) : "attacked"] in the [affecting.name] with [I.name] by [user]!</span>")

	var/blocked = run_armor_check(hit_zone, "melee", I.armor_penetration, "Your armor has protected your [affecting.name].", "Your armor has softened the blow to your [affecting.name].")
	standard_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)

	return blocked

/mob/living/carbon/human/standard_weapon_hit_effects(obj/item/I, mob/living/user, var/effective_force, var/blocked, var/hit_zone)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return 0

	// Handle striking to cripple.
	if(user.a_intent == I_DISARM)
		effective_force *= 0.66 //reduced effective force...
		if(!..(I, user, effective_force, blocked, hit_zone))
			return 0

		//set the dislocate mult less than the effective force mult so that
		//dislocating limbs on disarm is a bit easier than breaking limbs on harm
		attack_joint(affecting, I, effective_force, 0.5, blocked) //...but can dislocate joints
	else if(!..())
		return 0

	if(effective_force > 10 || effective_force >= 5 && prob(33))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already
	if((I.damtype == BRUTE || I.damtype == PAIN) && prob(25 + (effective_force * 2)))
		if(!stat)
			if(headcheck(hit_zone))
				//Harder to score a stun but if you do it lasts a bit longer
				if(prob(effective_force))
					visible_message("<span class='danger'>[src] [species.knockout_message]</span>")
					apply_effect(20, PARALYZE, blocked)
			else
				//Easier to score a stun but lasts less time
				if(prob(effective_force + 10))
					visible_message("<span class='danger'>[src] has been knocked down!</span>")
					apply_effect(6, WEAKEN, blocked)

		//Apply blood
		attack_bloody(I, user, effective_force, hit_zone)

	return 1


/mob/living/carbon/human/proc/attack_bloody(obj/item/W, mob/living/attacker, effective_force, hit_zone)
	if(W.damtype != BRUTE)
		return

	//make non-sharp low-force weapons less likely to be bloodied
	if(W.sharp || prob(effective_force*4))
		if(!(W.atom_flags & ATOM_FLAG_NO_BLOOD))
			W.add_blood(src)
	else
		return //if the weapon itself didn't get bloodied than it makes little sense for the target to be bloodied either

	//getting the weapon bloodied is easier than getting the target covered in blood, so run prob() again
	if(prob(33 + W.sharp*10))
		var/turf/location = loc
		if(istype(location, /turf/simulated))
			location.add_blood(src)
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
				H.bloody_body(src)
				H.bloody_hands(src)

		switch(hit_zone)
			if(BP_HEAD)
				if(wear_mask)
					wear_mask.add_blood(src)
					update_inv_wear_mask(0)
				if(head)
					head.add_blood(src)
					update_inv_head(0)
				if(glasses && prob(33))
					glasses.add_blood(src)
					update_inv_glasses(0)
			if(BP_CHEST)
				bloody_body(src)

/mob/living/carbon/human/proc/projectile_hit_bloody(obj/item/projectile/P, effective_force, hit_zone)
	if(P.damage_type != BRUTE || P.nodamage)
		return
	if(!(P.sharp || prob(effective_force*4)))
		return
	if(prob(effective_force))
		var/turf/location = loc
		if(istype(location, /turf/simulated))
			location.add_blood(src)

		switch(hit_zone)
			if(BP_HEAD)
				if(wear_mask)
					wear_mask.add_blood(src)
					update_inv_wear_mask(0)
				if(head)
					head.add_blood(src)
					update_inv_head(0)
				if(glasses && prob(33))
					glasses.add_blood(src)
					update_inv_glasses(0)
			if(BP_CHEST)
				bloody_body(src)

/mob/living/carbon/human/proc/attack_joint(obj/item/organ/external/organ, obj/item/W, effective_force, dislocate_mult, blocked)
	if(!organ || (organ.dislocated == 2) || (organ.dislocated == -1) || blocked >= 100)
		return 0
	if(W.damtype != BRUTE)
		return 0

	//want the dislocation chance to be such that the limb is expected to dislocate after dealing a fraction of the damage needed to break the limb
	var/dislocate_chance = effective_force/(dislocate_mult * organ.min_broken_damage * config.organ_health_multiplier)*100
	if(prob(dislocate_chance * blocked_mult(blocked)))
		visible_message(SPAN("danger", "[src]'s [organ.joint] [pick("gives way","caves in","crumbles","collapses")]!"))
		organ.dislocate(1)
		return 1
	return 0

/mob/living/carbon/human/emag_act(remaining_charges, mob/user, emag_source)
	var/obj/item/organ/external/affecting = get_organ(user.zone_sel.selecting)
	if(!affecting || !BP_IS_ROBOTIC(affecting))
		to_chat(user, SPAN("warning", "That limb isn't robotic."))
		return -1
	if(affecting.status & ORGAN_SABOTAGED)
		to_chat(user, SPAN("warning", "[src]'s [affecting.name] is already sabotaged!"))
		return -1
	to_chat(user, SPAN("notice", "You sneakily slide [emag_source] into the dataport on [src]'s [affecting.name] and short out the safeties."))
	affecting.status |= ORGAN_SABOTAGED
	return 1

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM, speed = THROWFORCE_SPEED_DIVISOR)
	if(isobj(AM))
		var/obj/O = AM
		if(in_throw_mode && !get_active_hand() && speed <= THROWFORCE_SPEED_DIVISOR)	//empty active hand and we're in throw mode
			if(!incapacitated())
				if(isturf(O.loc))
					put_in_active_hand(O)
					visible_message(SPAN("warning", "[src] catches [O]!"))
					throw_mode_off()
					return

		var/dtype = O.damtype
		var/throw_damage = O.throwforce * (speed / THROWFORCE_SPEED_DIVISOR)

		var/zone = BP_CHEST
		if(isliving(O.thrower))
			var/mob/living/L = O.thrower
			zone = check_zone(L.zone_sel.selecting)
		else
			zone = ran_zone(BP_CHEST, 75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		var/miss_chance = 15
		if(O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			miss_chance = max(15 * (distance - 2), 0)
		zone = get_zone_with_miss_chance(zone, src, miss_chance, ranged_attack=1)

		if(zone && O.thrower != src)
			var/shield_check = check_shields(throw_damage, O, thrower, zone, "[O]")
			if(shield_check == PROJECTILE_FORCE_MISS)
				zone = null
			else if(shield_check)
				return

		if(!zone)
			visible_message(SPAN("notice", "\The [O] misses [src] narrowly!"))
			return

		O.throwing = 0		//it hit, so stop moving

		var/obj/item/organ/external/affecting = get_organ(zone)
		var/hit_area = affecting.name
		var/datum/wound/created_wound

		visible_message(SPAN("warning", "\The [src] has been hit in the [hit_area] by \the [O]."))
		play_hitby_sound(AM)

		var/armor
		if(istype(O, /obj/item))
			var/obj/item/I = O
			armor = run_armor_check(affecting, I.check_armour, O.armor_penetration, "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].")
		else
			armor = run_armor_check(affecting, "melee", O.armor_penetration, "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].") //I guess "melee" is the best fit here

		if(armor < 100)
			var/damage_flags = O.damage_flags()
			if(prob(armor))
				damage_flags &= ~(DAM_SHARP|DAM_EDGE)
			created_wound = apply_damage(throw_damage, dtype, zone, armor, damage_flags, O)

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				admin_attack_log(M, src, "Threw \an [O] at their victim.", "Had \an [O] thrown at them", "threw \an [O] at")

		//thrown weapon embedded object code.
		if(dtype == BRUTE && istype(O, /obj/item))
			var/obj/item/I = O
			if(!is_robot_module(I))
				var/sharp = is_sharp(I)
				var/damage = throw_damage //the effective damage used for embedding purposes, no actual damage is dealt here
				if(armor)
					damage *= blocked_mult(armor)

				//blunt objects should really not be embedding in things unless a huge amount of force is involved
				var/embed_chance = sharp? (damage / I.w_class) : (damage / (I.w_class * 3))
				var/embed_threshold = sharp? (5 * I.w_class) : (15 * I.w_class)

				//Sharp objects will always embed if they do enough damage.
				//Thrown sharp objects have some momentum already and have a small chance to embed even if the damage is below the threshold
				if((sharp && prob(damage / (10 * I.w_class) * 100)) || (damage > embed_threshold && prob(embed_chance)))
					affecting.embed(I, supplied_wound = created_wound)

		// Begin BS12 momentum-transfer code.
		var/mass = 1.5
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class / THROWNOBJ_KNOCKBACK_DIVISOR
		var/momentum = speed * mass

		if(O.throw_source && momentum >= THROWNOBJ_KNOCKBACK_SPEED)
			var/dir = get_dir(O.throw_source, src)

			visible_message(SPAN("warning", "\The [src] staggers under the impact!"), SPAN("warning", "You stagger under the impact!"))
			throw_at(get_edge_target_turf(src, dir), 1, momentum)

			if(!O || !src)
				return

			if(O.loc == src && O.sharp) //Projectile is embedded and suitable for pinning.
				var/turf/T = near_wall(dir, 2)

				if(T)
					loc = T
					visible_message(SPAN("warning", "[src] is pinned to the wall by [O]!"), SPAN("warning", "You are pinned to the wall by [O]!"))
					anchored = 1
					pinned += O

/mob/living/carbon/human/embed(obj/O, def_zone=null, datum/wound/supplied_wound)
	if(!def_zone) ..()

	var/obj/item/organ/external/affecting = get_organ(def_zone)
	if(affecting)
		affecting.embed(O, supplied_wound = supplied_wound)

/mob/living/carbon/human/proc/bloody_hands(mob/living/source, amount = 2)
	if(gloves)
		gloves.add_blood(source)
		gloves:transfer_blood = amount
		gloves:bloody_hands_mob = source
	else
		add_blood(source)
		bloody_hands = amount
		bloody_hands_mob = source
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(mob/living/source)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(0)
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(0)

/mob/living/carbon/human/proc/handle_suit_punctures(damtype, damage, def_zone)

	// Tox and oxy don't matter to suits.
	if(damtype != BURN && damtype != BRUTE) return

	// The rig might soak this hit, if we're wearing one.
	if(back && istype(back,/obj/item/rig))
		var/obj/item/rig/rig = back
		rig.take_hit(damage)

	// We may also be taking a suit breach.
	if(!wear_suit) return
	if(!istype(wear_suit,/obj/item/clothing/suit/space)) return
	var/obj/item/clothing/suit/space/SS = wear_suit
	SS.create_breaches(damtype, damage)

/mob/living/carbon/human/reagent_permeability()
	var/perm = 0

	var/list/perm_by_part = list(
		"head" = THERMAL_PROTECTION_HEAD,
		"upper_torso" = THERMAL_PROTECTION_UPPER_TORSO,
		"lower_torso" = THERMAL_PROTECTION_LOWER_TORSO,
		"legs" = THERMAL_PROTECTION_LEG_LEFT + THERMAL_PROTECTION_LEG_RIGHT,
		"feet" = THERMAL_PROTECTION_FOOT_LEFT + THERMAL_PROTECTION_FOOT_RIGHT,
		"arms" = THERMAL_PROTECTION_ARM_LEFT + THERMAL_PROTECTION_ARM_RIGHT,
		"hands" = THERMAL_PROTECTION_HAND_LEFT + THERMAL_PROTECTION_HAND_RIGHT
		)

	for(var/obj/item/clothing/C in src.get_equipped_items())
		if(C.permeability_coefficient == 1 || !C.body_parts_covered)
			continue
		if(C.body_parts_covered & HEAD)
			perm_by_part["head"] *= C.permeability_coefficient
		if(C.body_parts_covered & UPPER_TORSO)
			perm_by_part["upper_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LOWER_TORSO)
			perm_by_part["lower_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LEGS)
			perm_by_part["legs"] *= C.permeability_coefficient
		if(C.body_parts_covered & FEET)
			perm_by_part["feet"] *= C.permeability_coefficient
		if(C.body_parts_covered & ARMS)
			perm_by_part["arms"] *= C.permeability_coefficient
		if(C.body_parts_covered & HANDS)
			perm_by_part["hands"] *= C.permeability_coefficient

	for(var/part in perm_by_part)
		perm += perm_by_part[part]

	return perm
