/*
Contains most of the procs that are called when a mob is attacked by something
bullet_act
ex_act
meteor_act
*/

/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(status_flags & GODMODE)
		return 0

	// Checking for hit zone; may result in a miss
	def_zone = check_zone(def_zone)
	if(!has_organ(def_zone))
		return PROJECTILE_FORCE_MISS //if they don't have the organ in question then the projectile just passes by.

	// Checking for shields as they obviously have greater priority than armor
	var/shield_check = check_shields(P.damage, P, null, def_zone, "the [P.name]")
	if(shield_check)
		return shield_check

	var/obj/item/organ/external/organ = get_organ(def_zone)

	// Shooting peoples' hands may get them disarmed
	var/disarm_slot
	switch(def_zone)
		if(BP_L_HAND)
			disarm_slot = slot_l_hand
		if(BP_R_HAND)
			disarm_slot = slot_r_hand
	if(disarm_slot)
		var/obj/item/D = get_equipped_item(disarm_slot)
		if(D && (P.damage || P.agony))
			var/disarm_chance = sqrt(P.damage+P.agony)*10        // Agony goes into consideration because rubber bullets/stunspheres/etc. are supposed to be disabling ammunition
			disarm_chance = disarm_chance * (D.w_class/5 + 0.4)  // The bigger an item is, the higher probability of it getting shot
			if(prob(disarm_chance))
				playsound(src.loc, 'sound/effects/fighting/Genhit.ogg', 50, 1)
				D.shot_out(src, P)
				if(D.w_class > 2)
					return PROJECTILE_FORCE_BLOCK // Small items don't block the projectile while getting shot out

	// Unobviously, the external damage applies here
	var/blocked = ..(P, def_zone) // <------------'

	// Fullblock, only poise damage required
	if(blocked >= 100)
		projectile_affect_poise(P, P.poisedamage / 3, def_zone)
		return PROJECTILE_FORCE_ARMORBLOCK

	// Internal damage
	// Some day we should make internals deal with blunt and sharp damage differently, but for now it's like this, if 'blocked' is non-zero, then the projectile's already lost its SHARP/EDGE flags and thus we cut the damage accordingly
	if(length(organ.internal_organs))
		var/internal_damage_prob = 70 * blocked_mult(blocked) // 70% for a naked dude/armor fail, 35% if one armor layer's succeeded, etc.

		// If our bodypart is a pile of shredded meat then it doesn't protect organs well
		if(organ.damage > organ.max_damage)
			internal_damage_prob *= organ.damage / organ.max_damage * 2

		if(prob(internal_damage_prob))
			var/penetrating_damage = P.damage * P.penetration_modifier * PROJECTILE_INTERNAL_DAMAGE_MULT * blocked_mult(blocked)
			if(organ.encased && !(organ.status & ORGAN_BROKEN))
				penetrating_damage *= 0.75 // Ribs and skulls somewhat protect

			var/list/victims = list()
			var/list/possible_victims = shuffle(organ.internal_organs.Copy())

			for(var/obj/item/organ/internal/I in possible_victims)
				if(I.damage < I.max_damage && (prob((sqrt(I.relative_size) * 10) * (1 / max(1, victims.len)))))
					victims += I

			if(length(victims))
				for(var/obj/item/organ/internal/victim in victims)
					victim.take_internal_damage(penetrating_damage / victims.len)

	// Embed or sever artery, only happens if the projectile's successfully bypassed armor
	if(!blocked && !(species.species_flags & SPECIES_FLAG_NO_EMBED) && prob(PROJECTILE_EMBED_CHANCE))
		// Lower cal. bullets tend to embed, while higher cal. bullets are more likely to make things bloody
		var/embed_odds = P.damage * 1.3

		if(prob(embed_odds))
			organ.sever_artery()
		else if(P.can_embed())
			var/obj/item/material/shard/shrapnel/SP = new()
			SP.SetName((P.name != "shrapnel")? "[P.name] shrapnel" : "shrapnel")
			SP.desc = "[SP.desc] It looks like it was fired from [P.shot_from]."
			SP.forceMove(organ)
			organ.embed(SP)

	// Poise damage, the last actual harmful thing to happen
	projectile_affect_poise(P, P.poisedamage * blocked_mult(blocked), def_zone)
	// Spawning blood if necessary
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

// Less realistic, more combat-friendly stun handling than the proc above. Used by tasers and batons.
/mob/living/carbon/human/proc/handle_tasing(power, tasing, def_zone, used_weapon = null)
	if(status_flags & GODMODE)
		return 0	//godmode

	var/siemens_coeff = 1.0
	var/obj/item/organ/external/affected = get_organ(check_zone(def_zone))
	if(affected)
		siemens_coeff = get_siemens_coefficient_organ(affected)
	if(siemens_coeff <= 0)
		return
	flash_pain()
	forcesay(GLOB.hit_appends)

	var/reduced_power = power * siemens_coeff
	apply_damage(reduced_power, PAIN, def_zone, 0, used_weapon)
	damage_poise(reduced_power / 5) // So metazine-filled junkies are still prone to muscular cramps

	var/reduced_tasing = round(max(tasing * 0.5, tasing * siemens_coeff)) // Armor can provide up to 50% stun time reduction
	apply_effect(STUTTER, reduced_tasing)
	apply_effect(EYE_BLUR, reduced_tasing)

	if(poise <= 0 || getHalLoss() >= species.total_health || affected?.pain > species.total_health)
		if(prob(95)) // May gods decide your destiny
			if(!stunned)
				visible_message("<b>[src]</b> collapses!", SPAN("warning", "You collapse from shock!"))
			Stun(reduced_tasing)
			Weaken(reduced_tasing + 1) // Getting up after being tased is not instant, adding 1 tick of unstunned crawling


//////////////////////
///		ARMOR	//////
//////////////////////

// This one should be used for calculating armorblocks in case of "high-impact" damage, such as getting hit/shot, stepping into a beartrap, touching a force field, etc.
// Things that cause "slow" damage (getting chewed by an airlock) and/or use =unusual= damtypes (i.e. "bio", "bomb") should use get_flat_armor() instead
// Not specifying 'def_zone' (aka using the whole-body check) will call for parent 'run_armor_check' which uses get_flat_armor() as well
/mob/living/carbon/human/run_armor_check(def_zone = null, attack_flag = "melee", armor_pen = 0, absorb_text = null, soften_text = null)
	if(!def_zone)
		return ..() // Edgecase stuff, going back to the legacy armorcheck

	var/damage_ratio = 1.0
	var/list/armor = get_layered_armor(def_zone, attack_flag)

	if(!islist(armor) || !length(armor))
		return 0 // 404 no armor found

	for(var/i = 1, i <= length(armor) / 2, i++)
		// Completely ignoring this layer due to ineffective coverage %
		var/current_layer = i * 2 - 1 // Armor value is armor[current_layer] and its coverage is armor[current_layer+1]
		if(!prob(armor[current_layer+1] * 100))
			continue

		var/effective_armor = armor[current_layer] - armor_pen

		var/dice_roll = rand(0, 100)
		if(dice_roll > effective_armor)
			// Ineffective block
			armor_pen /= 2
			continue
		else if(dice_roll > effective_armor / 2)
			// Semi-successful block, halving the damage
			damage_ratio /= 2
			armor_pen /= 2
		else
			// Successful block, ignoring the damage
			damage_ratio = 0
			break

	if(!damage_ratio)
		if(absorb_text)
			to_chat(src, SPAN("notice", "<b>[absorb_text]</b>"))
		else
			to_chat(src, SPAN("notice", "<b>Your armor absorbs the blow!</b>"))
	else if(damage_ratio < 1.0)
		if(soften_text)
			to_chat(src, SPAN("notice", "<b>[soften_text]</b>"))
		else
			to_chat(src, SPAN("notice", "<b>Your armor softens the blow!</b>"))

	return round((1.0 - damage_ratio) * 100)

/mob/living/carbon/human/get_flat_armor(def_zone, type)
	var/armorval = 0
	var/total = 0

	if(def_zone)
		if(isorgan(def_zone))
			return get_organ_armor(def_zone, type)
		var/obj/item/organ/external/affecting = get_organ(def_zone)
		if(affecting)
			return get_organ_armor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/organ_name in organs_by_name)
		if(organ_name in organ_rel_size)
			var/obj/item/organ/external/organ = organs_by_name[organ_name]
			if(organ)
				var/weight = organ_rel_size[organ_name]
				armorval += (get_organ_armor(organ, type) * weight) //use plain addition here because we are calculating an average
				total += weight
	return (armorval/max(total, 1))

// Returns the armour value of a particular external organ.
/mob/living/carbon/human/proc/get_organ_armor(obj/item/organ/external/def_zone, type, layered = FALSE)
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
		if(LAZYLEN(gear.accessories))
			for(var/obj/item/clothing/accessory/bling in gear.accessories)
				if(bling.body_parts_covered & def_zone.body_part)
					protection = add_armor(protection, bling.armor[type])
	return protection

/mob/living/carbon/human/get_layered_armor(def_zone, type)
	if(!def_zone || !type)
		return null

	var/obj/item/organ/external/affecting = isorgan(def_zone) ? def_zone : get_organ(def_zone)
	if(!istype(affecting))
		return null

	. = list()

	var/list/armor_layer
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)

	// Unlike in get_flat_armor, here we iterate over everything since a piece
	// of clothing may have a bodypart coverage w/out having it in 'body_parts_covered'
	for(var/obj/item/clothing/C in protective_gear)
		if(LAZYLEN(C.accessories))
			for(var/obj/item/clothing/accessory/CA in C.accessories)
				armor_layer = CA.get_armor_coverage(affecting, type, src)
				if(islist(armor_layer))
					. += armor_layer

		armor_layer = C.get_armor_coverage(affecting, type, src)
		if(islist(armor_layer))
			. += armor_layer

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(obj/item/organ/external/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = max(species.siemens_coefficient,0)

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	for(var/datum/modifier/M in modifiers)
		siemens_coefficient *= M.siemens_coefficient
	return siemens_coefficient

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

/mob/living/carbon/human/proc/check_shields(damage = 0, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	var/obj/item/shield = null
	var/shield_mod_shield = 0
	if(istype(buckled, /obj/effect/dummy/immaterial_form))
		if(prob(80))
			return PROJECTILE_CONTINUE

	for(var/obj/item/I in list(l_hand, r_hand, wear_suit))
		if(!I) continue
		if(I.mod_shield > shield_mod_shield)
			shield = I
			shield_mod_shield = I.mod_shield
	if(QDELETED(shield))
		return 0
	. = shield.handle_shield(src, damage, damage_source, attacker, def_zone, attack_text)
	return

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

/mob/living/carbon/human/resolve_item_attack(obj/item/I, mob/living/user, target_zone)

	for (var/obj/item/grab/G in grabbed_by)
		if(G.resolve_item_attack(user, I, target_zone))
			return null

	if(user == src) // Attacking yourself can't miss
		return target_zone

	if(user.a_intent == I_GRAB)
		return target_zone

	var/handymod = round(sqrt(2-I.mod_handy), 0.01)

	//visible_message("Debug: handymod [handymod]") // Debug Message

	var/hit_zone = bodypart_miss_chance(target_zone, src, handymod, reach=I.mod_reach)

	if(!hit_zone)
		visible_message(SPAN("warning", "\The [user] misses [src] with \the [I]!"))
		return null

	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if (!affecting || affecting.is_stump())
		to_chat(user, SPAN("danger", "They are missing that limb!"))
		return null

	return hit_zone

//aka Regular Attack
//Jesus Christ what a mess I've made ~Toby
/mob/living/carbon/human/standard_weapon_hit_effects(obj/item/I, mob/living/user, effective_force, blocked, hit_zone)
	if(status_flags & GODMODE)
		return 0
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return 0

	// Poise damage part
	var/poise_damage

	visible_message(SPAN("danger", "[src] has been [I.attack_verb.len? pick(I.attack_verb) : "attacked"] in the [affecting.name] with [I.name] by [user]!"))
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		A.damage_poise(3.0 - I.mod_handy + I.mod_weight*2, TRUE)
		//visible_message("Debug \[HIT\]: [A] used [2.0+(I.mod_weight*2 + (1-I.mod_handy))] poise ([A.poise]/[A.poise_pool])") // Debug Message

	poise_damage = round(((2.5 + I.mod_weight*3 + I.mod_reach) / 1.5) + ((2.5 + I.mod_weight*3 + I.mod_reach) / 1.5 * ((100-blocked)/100)), 0.1)
	if(headcheck(hit_zone))
		poise_damage *= 1.15
	damage_poise(poise_damage)
	//visible_message("Debug \[HIT\]: [src] lost [poise_damage] poise ([src.poise]/[src.poise_pool])") // Debug Message

	////////// Here goes the REAL armor processing.
	if(MUTATION_HULK in user.mutations)
		effective_force *= 2

	if(MUTATION_STRONG in user.mutations)
		effective_force *= 2

	if(lying)
		effective_force *= 1.5 // Well it's easier to beat a lying dude to death right?

	if(!I.sharp && ishuman(user))
		var/mob/living/carbon/human/A = user
		effective_force *= A.body_build.melee_modifier

	effective_force *= round((100-blocked)/100, 0.1)

	// Apply weapon damage
	var/damage_flags = I.damage_flags()
	if(prob(blocked + 25)) // successful armorblock greatly reduces the cutties, but doesn't prevent them completely
		damage_flags &= ~(DAM_SHARP|DAM_EDGE)

	//Oh you've run outta poise? I see... You're wrecked, my boy.
	if(I.damtype == BRUTE || I.damtype == PAIN)
		if(poise <= poise_pool*0.7 && !check_poise_immunity())
			switch(hit_zone)
				if(BP_HEAD, BP_EYES, BP_MOUTH) //Knocking your enemy out or making them dizzy
					if(poise <= effective_force/3*I.mod_weight)
						visible_message(SPAN("danger", "[src] [species.knockout_message]"))
						custom_pain("Your head's definitely gonna hurt tomorrow.", 30, affecting = affecting)
						apply_effect((I.mod_weight*15), PARALYZE, (blocked/2))

					else if(prob(effective_force))
						visible_message(SPAN("danger", "[src] looks momentarily disoriented."), SPAN("danger", "You see stars."))
						apply_effect(2, EYE_BLUR, blocked)

				if(BP_CHEST, BP_GROIN, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT) //Knock down
					if(poise <= effective_force/3*I.mod_weight)
						visible_message(SPAN("danger", "[src] has been knocked down!"))
						apply_effect(min((I.mod_weight * 3), 4), WEAKEN, (blocked/2))

				if(BP_L_HAND, BP_R_HAND) //Knocking someone down by smashing their hands? Hell no.
					if(poise <= effective_force/3*I.mod_weight)
						visible_message(SPAN("danger", "[user] disarms [src] with their [I.name]!"))
						var/list/holding = list(src.get_active_hand() = 40, src.get_inactive_hand() = 20)
						for(var/obj/item/D in holding)
							drop(D)
						playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		//Apply blood
		attack_bloody(I, user, effective_force, hit_zone)

	if(effective_force <= 0)
		return 0

	apply_damage(effective_force, I.damtype, hit_zone, blocked, damage_flags, used_weapon=I)

	//////////

	if(effective_force > 10 || effective_force >= 5 && prob(33))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already

	return 1

// Well it has to look like this for the future reworks. I'm really sorry. ~Toby
// Literally 'pull punches' for weapons.
/mob/living/carbon/human/proc/alt_weapon_hit_effects(obj/item/I, mob/living/user, effective_force, blocked, hit_zone)
	if(status_flags & GODMODE)
		return 0
	var/obj/item/organ/external/affecting = get_organ(hit_zone)

	if(!affecting)
		return 0

	var/poise_damage
	var/damage_flags = I.damage_flags()
	damage_flags &= ~(DAM_SHARP|DAM_EDGE)

	visible_message(SPAN("danger", "[user] bashes [src]'s [affecting.name] with their [I.name]!"))
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		A.damage_poise(3.0 - I.mod_handy + I.mod_weight * 2, TRUE)
		//visible_message("Debug \[BASH\]: [A] used [2.0+(I.mod_weight*2 + (1-I.mod_handy))] poise ([A.poise]/[A.poise_pool])") // Debug Message

	poise_damage = round(((3.5 + I.mod_weight*3 + I.mod_reach) / 1.5) + ((3.5 + I.mod_weight*4 + I.mod_reach) / 1.5 * ((100-blocked)/100)), 0.1)
	if(headcheck(hit_zone))
		poise_damage *= 1.15
	damage_poise(poise_damage)
	//visible_message("Debug \[BASH\]: [src] lost [poise_damage] poise ([src.poise]/[src.poise_pool])") // Debug Message

	//////////
	effective_force = round(sqrt(effective_force), 0.1)*2 + I.mod_weight*4

	if(MUTATION_HULK in user.mutations)
		effective_force *= 2

	if(MUTATION_STRONG in user.mutations)
		effective_force *= 2

	if(src.lying)
		effective_force *= 1.5 // Well it's easier to beat all the shit outta lying dudes right?

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		effective_force *= A.body_build.melee_modifier

	effective_force *= round((100-blocked)/100, 0.01)

	if(poise <= poise_pool*0.7 && !check_poise_immunity())
		switch(hit_zone) // strong punches can have effects depending on where they hit
			if(BP_HEAD, BP_EYES, BP_MOUTH)
				if(poise <= effective_force/3*I.mod_weight)
					visible_message(SPAN("danger", "[src] [species.knockout_message]"))
					custom_pain("Your head's <B>definitely</B> gonna hurt tomorrow.", 30, affecting = affecting)
					apply_effect((I.mod_weight*20), PARALYZE, (blocked/2))

				else if(prob(effective_force))
					visible_message(SPAN("danger", "[src] looks momentarily disoriented."), SPAN("danger", "You see stars."))
					apply_effect(2, EYE_BLUR, blocked)

			if(BP_L_ARM)
				if(l_hand && (poise <= effective_force/3*I.mod_weight*1.5))
					visible_message(SPAN("danger", "\The [src.l_hand] was knocked right out of [src]'s grasp!"))
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					drop_l_hand()

			if(BP_R_ARM)
				if(r_hand && (poise <= effective_force/3*I.mod_weight*1.5))
					visible_message(SPAN("danger", "\The [src.l_hand] was knocked right out of [src]'s grasp!"))
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					drop_r_hand()

			if(BP_L_HAND, BP_R_HAND)
				if(poise <= effective_force*I.mod_reach)
					visible_message(SPAN("danger", "[user] disarms [src] with their [I.name]!"))
					var/list/holding = list(get_active_hand() = 40, get_inactive_hand() = 20)
					for(var/obj/item/D in holding)
						drop(D)
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

			if(BP_CHEST, BP_GROIN, BP_L_LEG, BP_R_LEG)
				if(poise <= effective_force/3*I.mod_weight)
					visible_message(SPAN("danger", "[src] has been knocked down!"))
					apply_effect((I.mod_weight*3.5), WEAKEN, (blocked/2))

				else if(prob(effective_force))
					var/turf/T = get_step(get_turf(src), get_dir(get_turf(user), get_turf(src)))
					if(prob(50))
						set_dir(GLOB.reverse_dir[src.dir])
					if(!T.density)
						step(src, get_dir(get_turf(user), get_turf(src)))
						visible_message(SPAN("danger", "[pick("[src] was sent flying backward!", "[src] staggers back from the impact!")]"))
					else
						visible_message(SPAN("danger", "[src] bumps into \the [T]!"))
						apply_effect(effective_force * 0.4, WEAKEN, (blocked/2))

			if(BP_L_FOOT, BP_R_FOOT)
				if(poise <= effective_force*I.mod_reach)
					visible_message(SPAN("danger", "[user] takes [src] down with their [I.name]!"))
					apply_effect((I.mod_reach*5), WEAKEN, blocked)

	if(effective_force <= 0)
		return 0

	apply_damage(effective_force*0.5, PAIN, hit_zone, blocked, damage_flags, used_weapon=I)
	apply_damage(effective_force*0.2, BRUTE, hit_zone, blocked, damage_flags, used_weapon=I)

	//////////

	if(effective_force > 10 || effective_force >= 5 && prob(33))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already

	return 1

//User uses I to attack src.
/mob/living/carbon/human/hit_with_weapon(obj/item/I, mob/living/user, effective_force, hit_zone, atype = 0)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return //should be prevented by attacked_with_item() but for sanity.

	var/blocked = 0

	// Getting hit by a humanoid
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		if(parrying)
			if(handle_parry(A, I))
				return
		if(blocking)
			if(handle_block_weapon(A, I))
				return
		if(!atype)
			blocked = run_armor_check(hit_zone, I.check_armour, I.armor_penetration, "Your armor has protected your [affecting.name].", "Your armor has softened the blow to your [affecting.name].")
			standard_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)
		else
			// We only check disarm attacks for melee armor since they are dealt w/ blunt parts/handles/etc.
			blocked = run_armor_check(hit_zone, "melee", I.armor_penetration, "Your armor has protected your [affecting.name].", "Your armor has softened the blow to your [affecting.name].")
			alt_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)
		return blocked

	// Getting hit by a non-humanoid
	blocked = run_armor_check(hit_zone, I.check_armour, I.armor_penetration, "Your armor has protected your [affecting.name].", "Your armor has softened the blow to your [affecting.name].")
	standard_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)

	return blocked

//User (A) uses their I to parry src's attack.
/mob/living/carbon/human/parry_with_weapon(obj/item/I, mob/living/user, effective_force, hit_zone)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		A.setClickCooldown(I.update_attack_cooldown()*2)
		A.parrying = 1
		A.visible_message(SPAN("warning", "[A] attempts to parry [src]'s attack with their [I]!"))
		//visible_message("[A] tries to parry [src]'s attack with their [I]! Parry window: [I.mod_handy*8]") //Debug message
		spawn(I.mod_handy*12)
			//visible_message("[A]'s parry window has ended.") //Debug message
			A.parrying = 0
	else
		hit_with_weapon(I, user, effective_force, blocked, hit_zone)

//User uses their I to touch src. I can't figure out how you can help anyone while holding a weapon :/
/mob/living/touch_with_weapon(obj/item/I, mob/living/user, effective_force, hit_zone)
	visible_message(SPAN("notice", "[user] touches [src] with [I.name]."))

//Src (defender) gets attacked by attacking_mob (attacker) and tries to perform parry
/mob/living/carbon/human/proc/handle_parry(mob/living/attacking_mob, obj/item/weapon_atk)
	var/mob/living/carbon/human/defender = src
	var/failing = 0
	if(istype(attacking_mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/attacker = attacking_mob
		if(defender.get_active_hand())
			var/obj/item/weapon_def = defender.get_active_hand()
			if(!weapon_def.force)
				defender.parrying = 0
				visible_message(SPAN("warning", "[defender] pointlessly attempts to parry [attacker]'s [weapon_atk.name] with their [weapon_def]."))
				return 0  //For the case of candles and dices lmao

			if(weapon_def.mod_reach > 1.25)
				if((weapon_def.mod_reach - weapon_atk.mod_reach) > 1.0)
					failing = 1
			else if(weapon_def.mod_reach < 0.75)
				if((weapon_atk.mod_reach - weapon_def.mod_reach) > 1.0)
					failing = 1
			if(failing)
				visible_message(SPAN("warning", "[defender] fails to parry [attacker]'s [weapon_atk.name] with their [weapon_def.name]."))
				defender.parrying = 0
				return 0
			defender.next_move = world.time+1 //Well I'd prefer to use setClickCooldown but it ain't gonna work here.
			defender.damage_poise(2.5 + weapon_atk.mod_weight*1.5, TRUE)
			//visible_message("Debug \[parry\]: Defender [defender] lost [2.5+(weapon_def.mod_weight*2.5)] poise ([defender.poise]/[defender.poise_pool])") // Debug Message
			attacker.setClickCooldown(weapon_atk.update_attack_cooldown()*2)
			attacker.damage_poise(17.5 + weapon_atk.mod_weight*7.5, TRUE)
			//visible_message("Debug \[parry\]: Attacker [attacker] lost [20.0+(weapon_atk.mod_weight*5.0)] poise ([defender.poise]/[defender.poise_pool])") // Debug Message
			visible_message(SPAN("warning", "[defender] parries [attacker]'s [weapon_atk.name] with their [weapon_def.name]."))

			if(attacker.poise <= 5)
				weapon_atk.knocked_out(attacker, TRUE, 3)
			else if(attacker.poise <= 20)
				weapon_atk.knocked_out(attacker)

			playsound(loc, 'sound/weapons/parry.ogg', 50, 1, -1) // You know what's gonna happen next, eh?
			defender.parrying = 0
			return 1
		else
			//visible_message("[defender] tries to parry [attacker]'s [weapon_atk] with their bare hands.") //Debug Message
			defender.parrying = 0
			return 0
	return 1

//Src (defender) blocks attacking_mob's (attacker) weapon_atk with their weapon_def
/mob/living/carbon/human/proc/handle_block_weapon(mob/living/attacking_mob, obj/item/weapon_atk)
	var/mob/living/carbon/human/defender = src
	var/d_mult = 1
	if(istype(attacking_mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/attacker = attacking_mob
		var/obj/item/weapon_def
		if(defender.blocking_hand && defender.get_inactive_hand())
			weapon_def = defender.get_inactive_hand()
		else if(defender.get_active_hand())
			weapon_def = defender.get_active_hand()
		if(weapon_def)
			if(!weapon_def.force)
				defender.useblock_off()
				visible_message(SPAN("warning", "[defender] pointlessly attempts to block [attacker]'s [weapon_atk.name] with [weapon_def]."))
				return 0 //For the case of candles and dices lmao

			if(weapon_def.mod_reach < weapon_atk.mod_reach)
				if(((weapon_atk.mod_reach + weapon_atk.mod_weight)/2 - weapon_def.mod_reach) > 0)
					d_mult = ((weapon_atk.mod_reach + weapon_atk.mod_weight)/2 - weapon_def.mod_reach)/0.25
			else if(weapon_def.mod_weight < weapon_atk.mod_weight)
				d_mult = (weapon_atk.mod_weight - weapon_def.mod_weight)/0.5

			defender.damage_poise((4.0+(weapon_atk.mod_weight*2.5 + weapon_atk.mod_reach)) + (weapon_atk.mod_weight*2.5 + weapon_atk.mod_reach)*d_mult/weapon_def.mod_shield)
			//visible_message("Debug \[block\]: [defender] lost [(4.0+(weapon_atk.mod_weight*2.5 + weapon_atk.mod_reach)) + (weapon_atk.mod_weight*2.5 + weapon_atk.mod_reach)*d_mult/weapon_def.mod_shield] poise ([defender.poise]/[defender.poise_pool])") // Debug Message
			attacker.damage_poise(2.0+(weapon_atk.mod_weight*2 + (1-weapon_atk.mod_handy)*2))
			//visible_message("Debug \[block\]: [attacker] lost [2.0+(weapon_atk.mod_weight*2 + (1-weapon_atk.mod_handy)*2)] poise ([attacker.poise]/[attacker.poise_pool])") // Debug Message
			visible_message(SPAN("warning", "[defender] blocks [attacker]'s [weapon_atk.name] with their [weapon_def.name]!"))
			defender.last_block = world.time

			if(defender.poise <= 5.0)
				weapon_def.knocked_out(defender, TRUE, 3)
			else if(defender.poise <= 12.5)
				weapon_def.knocked_out(defender)

			playsound(loc, 'sound/effects/fighting/Genhit.ogg', 50, 1, -1)
		else
			defender.damage_poise(2.5 + weapon_atk.mod_weight*10 + weapon_atk.mod_reach*5)
			attacker.damage_poise(weapon_atk.mod_weight*2 + (1-weapon_atk.mod_handy)*2)
			if((weapon_atk.sharp || weapon_atk.edge) && weapon_atk.force >= 10)
				visible_message(SPAN("warning", "[defender] blocks [attacker]'s [weapon_atk.name] with their bare hands! Ouch."))
				defender.apply_damage((weapon_atk.force*0.2), weapon_atk.damtype, BP_R_HAND, 0, 0, used_weapon=weapon_atk)
				defender.apply_damage((weapon_atk.force*0.2), weapon_atk.damtype, BP_L_HAND, 0, 0, used_weapon=weapon_atk)
			else
				visible_message(SPAN("warning", "[defender] blocks [attacker]'s [weapon_atk.name] with their bare hands!"))
			defender.last_block = world.time
			if(defender.poise <= 10.0)
				visible_message(SPAN("warning", "[defender] falls down, unable to keep balance!"))
				defender.apply_effect(3, WEAKEN, 0)
				defender.useblock_off()
	return 1

//Src (defender) blocks attacking_mob's (attacker) punch/generic attack with their weapon_def
/mob/living/carbon/human/proc/handle_block_normal(mob/living/attacking_mob, atk_dmg = 5.0)
	var/mob/living/carbon/human/defender = src
	if(istype(attacking_mob,/mob/living/carbon/human) || istype(attacking_mob,/mob/living/simple_animal))
		var/mob/living/attacker = attacking_mob
		var/obj/item/weapon_def

		if(defender.blocking_hand && defender.get_inactive_hand())
			weapon_def = defender.get_inactive_hand()
		else if(defender.get_active_hand())
			weapon_def = defender.get_active_hand()

		if(weapon_def)
			if(!weapon_def.force)
				defender.useblock_off()
				visible_message(SPAN("warning", "[defender] pointlessly attempts to block [attacker]'s attack with [weapon_def]."))
				return 0 //For the case of candles and dices lmao

			defender.damage_poise(atk_dmg / ((weapon_def.mod_handy+weapon_def.mod_reach) / 2))
			if(istype(attacker,/mob/living/carbon/human))
				var/mob/living/carbon/human/human_attacker = attacker
				human_attacker.damage_poise(5.0 + weapon_def.mod_weight*2 + weapon_def.mod_handy*3)

			visible_message(SPAN("warning", "[defender] blocks [attacker]'s attack with their [weapon_def.name]!"))
			defender.last_block = world.time

			if(defender.poise < 0)
				weapon_def.knocked_out(defender, TRUE, 3)
			else if(defender.poise < 10.0)
				weapon_def.knocked_out(defender)
			//visible_message("Debug \[block\]: [attacker] lost [5.0+weapon_def.mod_weight*2+weapon_def.mod_handy*3] poise ([attacker.poise]/[attacker.poise_pool])") // Debug Message
			playsound(loc, 'sound/effects/fighting/Genhit.ogg', 50, 1, -1)
		else
			if(istype(attacker,/mob/living/carbon/human))
				var/mob/living/carbon/human/human_attacker = attacker
				defender.damage_poise(7.5)
				human_attacker.damage_poise(5.0)
			else
				defender.damage_poise(atk_dmg)

			visible_message(SPAN("warning", "[defender] blocks [attacker]'s attack!"))
			defender.last_block = world.time

			if(defender.poise <= atk_dmg)
				visible_message(SPAN("warning", "[defender] falls down, unable to keep balance!"))
				defender.apply_effect(3, WEAKEN, 0)
				defender.useblock_off()
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

/mob/living/carbon/human/proc/projectile_affect_poise(obj/item/projectile/P, poisedamage, hit_zone)
	if(!poisedamage)
		return 0 //save a couple of nanoseconds

	if(status_flags & GODMODE)
		return 0 //godmode

	var/pd_mult = 1.0
	switch(hit_zone)
		if(BP_HEAD)
			pd_mult = 1.35
		if(BP_CHEST)
			pd_mult = 1.0
		if(BP_GROIN)
			pd_mult = 1.15
		else
			pd_mult = 0.75

	damage_poise(poisedamage * pd_mult)
	if(poise <= 25 && !prob(poise * 3))
		apply_effect(max(3, (poisedamage * pd_mult / 4)), WEAKEN)
		if(!lying)
			visible_message(SPAN("danger", "[src] goes down under the impact of \the [P]!"))

/mob/living/carbon/human/proc/attack_joint(obj/item/organ/external/organ, obj/item/W, effective_force, dislocate_mult, blocked)
	if(!organ || (organ.dislocated == 2) || (organ.dislocated == -1) || blocked >= 100)
		return 0
	if(W.damtype != BRUTE)
		return 0

	//want the dislocation chance to be such that the limb is expected to dislocate after dealing a fraction of the damage needed to break the limb
	var/dislocate_chance = effective_force/(dislocate_mult * organ.min_broken_damage * config.health.organ_health_multiplier)*100
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
	if(!aura_check(AURA_TYPE_THROWN, AM, speed))
		return

	if(isobj(AM))
		var/obj/O = AM
		if(in_throw_mode && !get_active_hand() && speed >= THROWFORCE_SPEED_DIVISOR)	//empty active hand and we're in throw mode
			if(!incapacitated() && isturf(O.loc) && put_in_active_hand(O))
				visible_message(SPAN("warning", "[src] catches [O]!"))
				throw_mode_off()
				return

		var/dtype = O.damtype
		var/throw_damage = O.throwforce / (speed * THROWFORCE_SPEED_DIVISOR)

		if(blocking)
			var/obj/item/weapon_def
			if(blocking_hand && get_inactive_hand())
				weapon_def = get_inactive_hand()
			else if(get_active_hand())
				weapon_def = get_active_hand()

			if(weapon_def)
				if(weapon_def.force && weapon_def.w_class >= O.w_class)
					var/dir = get_dir(src,O)
					O.throw_at(get_edge_target_turf(src, dir), 1)

					visible_message(SPAN("warning", "[src] blocks [O] with [weapon_def]!"))
					playsound(src, 'sound/effects/fighting/Genhit.ogg', 50, 1, -1)

					damage_poise(throw_damage / weapon_def.mod_shield)
					if(poise < throw_damage / weapon_def.mod_shield)
						visible_message(SPAN("warning", "[src] falls down, unable to keep balance!"))
						apply_effect(2, WEAKEN, 0)
						useblock_off()
					return


		var/zone = BP_CHEST
		if(isliving(O.thrower))
			var/mob/living/L = O.thrower
			if(L.zone_sel)
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
		if(!affecting)
			visible_message(SPAN("notice", "\The [O] misses [src] narrowly!"))
			return

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
		var/momentum = (1 / speed) * mass

		if(O.throw_source && momentum >= THROWNOBJ_KNOCKBACK_SPEED)
			var/dir = get_dir(O.throw_source, src)

			if(buckled)
				return

			visible_message(SPAN("warning", "\The [src] staggers under the impact!"), SPAN("warning", "You stagger under the impact!"))
			throw_at(get_edge_target_turf(src, dir), 1, (1 / momentum))

			if(!O || !src)
				return

			if(O.loc == src && O.sharp) //Projectile is embedded and suitable for pinning.
				embed(O, zone)
				var/turf/T = near_wall(dir, 2)

				if(T)
					forceMove(T)
					visible_message(SPAN("warning", "[src] is pinned to the wall by [O]!"), SPAN("warning", "You are pinned to the wall by [O]!"))
					anchored = 1
					pinned += O

/mob/living/carbon/human/embed(obj/O, def_zone=null, datum/wound/supplied_wound)
	if(!def_zone) ..()

	var/obj/item/organ/external/affecting = get_organ(def_zone)
	if(affecting)
		affecting.embed(O, supplied_wound = supplied_wound)

/mob/living/carbon/human/proc/bloody_hands(mob/living/source, amount = 2)
	var/obj/item/clothing/gloves/gloves = get_equipped_item(slot_gloves)
	if (istype(gloves))
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
