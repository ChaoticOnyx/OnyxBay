/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act

*/

/mob/living/carbon/human/bullet_act(var/obj/item/projectile/P, var/def_zone)

	def_zone = check_zone(def_zone)
	if(!has_organ(def_zone))
		return PROJECTILE_FORCE_MISS //if they don't have the organ in question then the projectile just passes by.

	//Marauder Shields
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
				for(var/obj/item/organ/victim in victims)
					damage_amt /= 2
					victim.take_damage(damage_amt)

	//Embed or sever artery
	if(P.can_embed() && !(species.species_flags & SPECIES_FLAG_NO_EMBED) && prob(22.5 + max(penetrating_damage, -10)) && !(prob(50) && (organ.sever_artery())))
		var/obj/item/weapon/material/shard/shrapnel/SP = new()
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

/mob/living/carbon/human/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone)
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
/mob/living/carbon/human/run_armor_check(var/def_zone = null, var/attack_flag = "melee", var/armor_pen = 0, var/absorb_text = null, var/soften_text = null, var/aforce = 0)
	var/effective_armor = getarmor(def_zone, attack_flag) - armor_pen

	if(effective_armor <= 0)
		return 0

	return effective_armor

/mob/living/carbon/human/getarmor(var/def_zone, var/type)
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
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(var/obj/item/organ/external/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = max(species.siemens_coefficient,0)

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(var/obj/item/organ/external/def_zone, var/type)
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
		if(istype(gear) && (gear.body_parts_covered & FACE) && !(gear.item_flags & ITEM_FLAG_FLEXIBLEMATERIAL))
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

/mob/living/carbon/human/proc/bodypart_miss_chance(zone, var/mob/target, var/miss_chance_mod = 1, var/ranged_attack=0, var/reach = 0)
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

	if(user.a_intent == I_GRAB)
		return target_zone

	var/handymod = round(sqrt(2-I.mod_handy), 0.01)

	//visible_message("Debug: handymod [handymod]") // Debug Message

	var/hit_zone = bodypart_miss_chance(target_zone, src, handymod, reach=I.mod_reach)

	if(!hit_zone)
		visible_message("<span class='warning'>\The [user] misses [src] with \the [I]!</span>")
		return null

	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if (!affecting || affecting.is_stump())
		to_chat(user, "<span class='danger'>They are missing that limb!</span>")
		return null

	return hit_zone

//aka Regular Attack
//Jesus Christ what a mess I've made ~Toby
/mob/living/carbon/human/standard_weapon_hit_effects(obj/item/I, mob/living/user, var/effective_force, var/blocked, var/hit_zone)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return 0

	var/poise_damage

	visible_message("<span class='danger'>[src] has been [I.attack_verb.len? pick(I.attack_verb) : "attacked"] in the [affecting.name] with [I.name] by [user]!</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		A.poise -= 2.0+(I.mod_weight*2 + (1-I.mod_handy))

		//visible_message("Debug \[HIT\]: [A] used [2.0+(I.mod_weight*2 + (1-I.mod_handy))] poise ([A.poise]/[A.poise_pool])") // Debug Message

	poise_damage = round((2.5+(I.mod_weight*3.0 + I.mod_reach))/1.5 + (2.5+(I.mod_weight*3.0 + I.mod_reach))/1.5*((100-blocked)/100),0.1)
	if(headcheck(hit_zone))
		poise_damage *= 1.15
	src.poise -= poise_damage

	//visible_message("Debug \[HIT\]: [src] lost [poise_damage] poise ([src.poise]/[src.poise_pool])") // Debug Message

	////////// Here goes the REAL armor processing.

	effective_force -= blocked*0.05 // Flat armor (i.e. reduces damage by 2.5 if armor=50)

	//Hulk modifier
	if(HULK in user.mutations)
		effective_force *= 2

	if(src.lying)
		effective_force *= 1.5 // Well it's easier to beat a lying dude to death right?

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		if((A.body_build.name == "Slim" || A.body_build.name == "Slim Alt") && !I.sharp)
			effective_force *= 0.75 // It's kinda hard to club people when you're two times thinner than a regular person.

	effective_force *= round((100-blocked)/100, 0.01)


	//Apply weapon damage
	var/damage_flags = I.damage_flags()
	if(prob(blocked)) //armour provides a chance to turn sharp/edge weapon attacks into blunt ones
		damage_flags &= ~(DAM_SHARP|DAM_EDGE)


	//Oh you've run outta poise? I see... You're wrecked, my boy.
	if(I.damtype == BRUTE || I.damtype == PAIN)
		if(poise <= poise_pool*0.7)
			switch(hit_zone)
				if(BP_HEAD, BP_EYES, BP_MOUTH) //Knocking your enemy out or making them dizzy
					if(poise <= effective_force/3*I.mod_weight)
						if(!stat || (stat && !paralysis))
							visible_message("<span class='danger'>[src] [species.knockout_message]</span>")
							custom_pain("Your head's definitely gonna hurt tomorrow.", 30, affecting = affecting)
						apply_effect(min(effective_force,4), PARALYZE, blocked)
					else
						if(prob(effective_force))
							src.visible_message("<span class='danger'>[src] looks momentarily disoriented.</span>", "<span class='danger'>You see stars.</span>")
							src.apply_effect(2, EYE_BLUR, blocked)
				if(BP_CHEST, BP_GROIN, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT) //Knock down
					if(poise <= effective_force/3*I.mod_weight)
						if(!stat || (stat && !paralysis))
							visible_message("<span class='danger'>[src] has been knocked down!</span>")
							apply_effect(min((I.mod_weight*3),2), WEAKEN, blocked)
				if(BP_L_HAND, BP_R_HAND) //Knocking someone down by smashing their hands? Hell no.
					if(poise <= effective_force/3*I.mod_weight)
						visible_message("<span class='danger'>[user] disarms [src] with their [I.name]!</span>")
						var/list/holding = list(src.get_active_hand() = 40, src.get_inactive_hand() = 20)
						for(var/obj/item/D in holding)
							if(D)
								src.drop_from_inventory(D)
						playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		//Apply blood
		attack_bloody(I, user, effective_force, hit_zone)

	//visible_message("Debug \[HIT\]: effective_force = [effective_force] | armor = [blocked] | flat_defence = [blocked*0.05]") // Debug Message

	if(effective_force <= 0)
		show_message("<span class='warning'>Your armor absorbs the blow!</span>")
		return 0

	apply_damage(effective_force, I.damtype, hit_zone, blocked, damage_flags, used_weapon=I)

	//////////

	if(effective_force > 10 || effective_force >= 5 && prob(33))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already

	return 1

// Well it has to look like this for the future reworks. I'm really sorry. ~Toby
// Literally 'pull punches' for weapons.
/mob/living/carbon/human/proc/alt_weapon_hit_effects(obj/item/I, mob/living/user, var/effective_force, var/blocked, var/hit_zone)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)

	if(!affecting)
		return 0

	var/poise_damage
	var/damage_flags = I.damage_flags()
	damage_flags &= ~(DAM_SHARP|DAM_EDGE)

	visible_message("<span class='danger'>[user] bashes [src]'s [affecting.name] with their [I.name]!</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		A.poise -= 2.0+(I.mod_weight*2 + (1-I.mod_handy))

		//visible_message("Debug \[BASH\]: [A] used [2.0+(I.mod_weight*2 + (1-I.mod_handy))] poise ([A.poise]/[A.poise_pool])") // Debug Message

	poise_damage = round((3.5+(I.mod_weight*3.0 + I.mod_reach))/1.5 + (3.5+(I.mod_weight*4.0 + I.mod_reach))/1.5*((100-blocked)/100),0.1)
	if(headcheck(hit_zone))
		poise_damage *= 1.15
	src.poise -= poise_damage

	//visible_message("Debug \[BASH\]: [src] lost [poise_damage] poise ([src.poise]/[src.poise_pool])") // Debug Message

	//////////

	effective_force = round(sqrt(effective_force), 0.1)*2 + I.mod_weight*4

	//Hulk modifier
	if(HULK in user.mutations)
		effective_force *= 2

	if(src.lying)
		effective_force *= 1.5 // Well it's easier to beat all the shit outta lying dudes right?

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		if(A.body_build.name == "Slim" || A.body_build.name == "Slim Alt")
			effective_force *= 0.8

	effective_force *= round((100-blocked)/60, 0.01)

	if(poise <= poise_pool*0.7)
		switch(hit_zone) // strong punches can have effects depending on where they hit
			if(BP_HEAD, BP_EYES, BP_MOUTH)
				if(poise <= effective_force/3*I.mod_weight)
					if(!stat || (stat && !paralysis))
						visible_message("<span class='danger'>[src] [species.knockout_message]</span>")
						apply_effect(20, PARALYZE, blocked)
				else
					if(prob(effective_force))
						src.visible_message("<span class='danger'>[src] looks momentarily disoriented.</span>", "<span class='danger'>You see stars.</span>")
						src.apply_effect(2, EYE_BLUR, blocked)
			if(BP_L_ARM)
				if(src.l_hand && (poise <= effective_force/3*I.mod_weight*1.5))
					src.visible_message("<span class='danger'>\The [src.l_hand] was knocked right out of [src]'s grasp!</span>")
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					src.drop_l_hand()
			if(BP_R_ARM)
				if(src.r_hand && (poise <= effective_force/3*I.mod_weight*1.5))
					src.visible_message("<span class='danger'>\The [src.l_hand] was knocked right out of [src]'s grasp!</span>")
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					src.drop_r_hand()
			if(BP_L_HAND, BP_R_HAND)
				if(poise <= effective_force*I.mod_reach)
					visible_message("<span class='danger'>[user] disarms [src] with their [I.name]!</span>")
					var/list/holding = list(src.get_active_hand() = 40, src.get_inactive_hand() = 20)
					for(var/obj/item/D in holding)
						if(D)
							src.drop_from_inventory(D)
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			if(BP_CHEST, BP_GROIN, BP_L_LEG, BP_R_LEG)
				if(!stat && (poise <= effective_force/3*I.mod_weight))
					visible_message("<span class='danger'>[src] has been knocked down!</span>")
					apply_effect((I.mod_weight*3), WEAKEN, blocked)
				else
					if(!stat && prob(effective_force))
						var/turf/T = get_step(get_turf(src), get_dir(get_turf(user), get_turf(src)))
						if(prob(50))
							src.set_dir(GLOB.reverse_dir[src.dir])
						if(!T.density)
							step(src, get_dir(get_turf(user), get_turf(src)))
							src.visible_message("<span class='danger'>[pick("[src] was sent flying backward!", "[src] staggers back from the impact!")]</span>")
						else
							src.visible_message("<span class='danger'>[src] bumps into \the [T]!</span>")
							src.apply_effect(effective_force * 0.4, WEAKEN, blocked)
			if(BP_L_FOOT, BP_R_FOOT)
				if(poise <= effective_force*I.mod_reach)
					visible_message("<span class='danger'>[user] takes [src] down with their [I.name]!</span>")
					apply_effect((I.mod_reach*5), WEAKEN, blocked)

	//visible_message("Debug \[BASH\]: effective_force = [effective_force] | armor = [blocked] | poise_damage = [poise_damage]") // Debug Message

	if(effective_force <= 0)
		show_message("<span class='warning'>Your armor absorbs the blow!</span>")
		return 0

	apply_damage(effective_force*0.5, PAIN, hit_zone, blocked, damage_flags, used_weapon=I)
	apply_damage(effective_force*0.2, BRUTE, hit_zone, blocked, damage_flags, used_weapon=I)

	//////////

	if(effective_force > 10 || effective_force >= 5 && prob(33))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already

	return 1

//User uses I to attack src.
/mob/living/carbon/human/hit_with_weapon(obj/item/I, mob/living/user, var/effective_force, var/hit_zone, var/atype = 0)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return //should be prevented by attacked_with_item() but for sanity.

	var/blocked = run_armor_check(hit_zone, "melee", I.armor_penetration, "Your armor has protected your [affecting.name].", "Your armor has softened the blow to your [affecting.name].")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		if(parrying)
			if(A.get_parried_w(src,I))
				return
		if(blocking)
			if(A.get_blocked_w(src,I))
				return
		if(!atype)
			standard_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)
		else
			alt_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)
		return blocked

	standard_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)

	return blocked

//User (A) uses their I to parry src's attack.
/mob/living/carbon/human/parry_with_weapon(obj/item/I, mob/living/user, var/effective_force, var/hit_zone)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		A.setClickCooldown(I.update_attack_cooldown()*2)
		A.parrying = 1
		A.visible_message("<span class='warning'>[A] attempts to parry [src]'s attack with their [I]!</span>")

		//visible_message("[A] tries to parry [src]'s attack with their [I]! Parry window: [I.mod_handy*8]") //Debug message

		spawn(I.mod_handy*8)
			//visible_message("[A]'s parry window has ended.") //Debug message
			A.parrying = 0
	else
		hit_with_weapon(I, user, effective_force, blocked, hit_zone)

//User uses their I to touch src. I can't figure out how you can help anyone while holding a weapon :/
/mob/living/touch_with_weapon(obj/item/I, mob/living/user, var/effective_force, var/hit_zone)
	visible_message("<span class='notice'>[user] touches [src] with [I.name].</span>")

//	Parry processing
//src	= defender
//P		= defender's weapon
//A		= attacker
//I		= attacker's weapon
/mob/living/carbon/human/proc/get_parried_w(mob/living/user, obj/item/w_atk)
	var/mob/living/carbon/human/attacker = src
	var/failing = 0
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/defender = user
		if(defender.get_active_hand())
			var/obj/item/w_def = defender.get_active_hand()
			if(!w_def.force)
				defender.parrying = 0
				visible_message("<span class='warning'>[defender] pointlessly attempts to parry [attacker]'s [w_atk.name] with their [w_def].</span>")
				return 0  //For the case of candles and dices lmao

			if(w_def.mod_reach > 1.25)
				if((w_def.mod_reach - w_atk.mod_reach) > 1.0)
					failing = 1
			else if(w_def.mod_reach < 0.75)
				if((w_atk.mod_reach - w_def.mod_reach) > 1.0)
					failing = 1
			if(failing)
				visible_message("<span class='warning'>[defender] fails to parry [attacker]'s [w_atk.name] with their [w_def.name].</span>")
				defender.parrying = 0
				return 0
			defender.next_move = world.time+1 //Well I'd prefer to use setClickCooldown but it ain't gonna work here.
			defender.poise -= 2.5+(w_atk.mod_weight*1.5)

			//visible_message("Debug \[parry\]: Defender [defender] lost [2.5+(w_def.mod_weight*2.5)] poise ([defender.poise]/[defender.poise_pool])") // Debug Message

			attacker.setClickCooldown(w_atk.update_attack_cooldown()*2)
			attacker.poise -= 17.5+(w_atk.mod_weight*7.5)

			//visible_message("Debug \[parry\]: Attacker [attacker] lost [20.0+(w_atk.mod_weight*5.0)] poise ([defender.poise]/[defender.poise_pool])") // Debug Message

			visible_message("<span class='warning'>[defender] parries [attacker]'s [w_atk.name] with their [w_def.name].</span>")

			if(attacker.poise <= 5)
				visible_message("<span class='warning'>[attacker] falls down, unable to keep balance!</span>")
				attacker.apply_effect(5, WEAKEN, 0)
			else if(attacker.poise <= 20)
				visible_message("<span class='warning'>[attacker]'s [w_atk.name] flies off!</span>")
				attacker.drop_from_inventory(w_atk)

			playsound(loc, 'sound/weapons/parry.ogg', 50, 1, -1) // You know what's gonna happen next, eh?
			defender.parrying = 0
			return 1
		else
			//visible_message("[defender] tries to parry [attacker]'s [w_atk] with their bare hands.") //Debug Message
			defender.parrying = 0
			return 0
	return 1

//Src tries to hit user (A) and gets blocked with their I.
/mob/living/carbon/human/proc/get_blocked_w(mob/living/user, obj/item/w_atk)
	var/mob/living/carbon/human/attacker = src
	var/d_mult = 1
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/defender = user
		var/obj/item/w_def
		if(defender.blocking_hand && defender.get_inactive_hand())
			w_def = defender.get_inactive_hand()
		else if(defender.get_active_hand())
			w_def = defender.get_active_hand()
		if(w_def)
			if(!w_def.force)
				defender.useblock_off()
				visible_message("<span class='warning'>[defender] pointlessly attempts to block [attacker]'s [w_atk.name] with [w_def].</span>")
				return 0 //For the case of candles and dices lmao

			if(w_def.mod_reach < w_atk.mod_reach)
				if(((w_atk.mod_reach+w_atk.mod_weight)/2 - w_def.mod_reach) > 0)
					d_mult = ((w_atk.mod_reach+w_atk.mod_weight)/2 - w_def.mod_reach) / 0.25
			else if(w_def.mod_weight < w_atk.mod_weight)
				d_mult = (w_atk.mod_weight-w_def.mod_weight)/0.5

			defender.poise -= (4.0+(w_atk.mod_weight*2.5 + w_atk.mod_reach)) + (w_atk.mod_weight*2.5 + w_atk.mod_reach)*d_mult/w_def.mod_shield

			//visible_message("Debug \[block\]: [defender] lost [(4.0+(w_atk.mod_weight*2.5 + w_atk.mod_reach)) + (w_atk.mod_weight*2.5 + w_atk.mod_reach)*d_mult/w_def.mod_shield] poise ([defender.poise]/[defender.poise_pool])") // Debug Message

			attacker.poise -= 2.0+(w_atk.mod_weight*2 + (1-w_atk.mod_handy)*2)

			//visible_message("Debug \[block\]: [attacker] lost [2.0+(w_atk.mod_weight*2 + (1-w_atk.mod_handy)*2)] poise ([attacker.poise]/[attacker.poise_pool])") // Debug Message

			visible_message("<span class='warning'>[defender] blocks [attacker]'s [w_atk.name] with their [w_def.name]!</span>")

			if(defender.poise <= 5)
				visible_message("<span class='warning'>[defender] falls down, unable to keep balance!</span>")
				defender.apply_effect(3, WEAKEN, 0)
			else if(defender.poise <= 15)
				visible_message("<span class='warning'>[defender]'s [w_def.name] flies off!</span>")
				defender.drop_from_inventory(w_def)

			playsound(loc, 'sound/weapons/Genhit.ogg', 50, 1, -1)
			defender.useblock_off()
		else
			defender.poise -= 2.5+(w_atk.mod_weight*10 + w_atk.mod_reach*5)
			attacker.poise -= (w_atk.mod_weight*2 + (1-w_atk.mod_handy)*2)
			if((w_atk.sharp || w_atk.edge) && w_atk.force >= 10)
				visible_message("<span class='warning'>[defender] blocks [attacker]'s [w_atk.name] with their bare hands! Ouch.</span>")
				defender.apply_damage((w_atk.force*0.2), w_atk.damtype, BP_R_HAND, 0, 0, used_weapon=w_atk)
				defender.apply_damage((w_atk.force*0.2), w_atk.damtype, BP_L_HAND, 0, 0, used_weapon=w_atk)
			else
				visible_message("<span class='warning'>[defender] blocks [attacker]'s [w_atk.name] with their bare hands!</span>")
			defender.useblock_off()
			if(defender.poise <= 10)
				visible_message("<span class='warning'>[defender] falls down, unable to keep balance!</span>")
				defender.apply_effect(3, WEAKEN, 0)
	return 1

/mob/living/carbon/human/proc/get_blocked_h(mob/living/user)
	var/mob/living/carbon/human/attacker = src
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/defender = user
		var/obj/item/w_def
		defender.useblock_off()

		if(defender.blocking_hand && defender.get_inactive_hand())
			w_def = defender.get_inactive_hand()
		else if(defender.get_active_hand())
			w_def = defender.get_active_hand()

		if(w_def)
			if(!w_def.force)
				defender.useblock_off()
				visible_message("<span class='warning'>[defender] pointlessly attempts to block [attacker]'s attack with [w_def].</span>")
				return 0 //For the case of candles and dices lmao

			defender.poise -= 5.0
			attacker.poise -= 5.0+w_def.mod_weight*2+w_def.mod_handy*3

			visible_message("<span class='warning'>[defender] blocks [attacker]'s attack with their [w_def.name]!</span>")

			if(defender.poise < 5)
				visible_message("<span class='warning'>[defender] falls down, unable to keep balance!</span>")
				defender.apply_effect(3, WEAKEN, 0)
			else if(defender.poise < 15)
				visible_message("<span class='warning'>[defender]'s [w_def.name] flies off!</span>")
				defender.drop_from_inventory(w_def)

			//visible_message("Debug \[block\]: [attacker] lost [5.0+w_def.mod_weight*2+w_def.mod_handy*3] poise ([attacker.poise]/[attacker.poise_pool])") // Debug Message

		else
			defender.poise -= 7.5
			attacker.poise -= 5.0

			visible_message("<span class='warning'>[defender] blocks [attacker]'s attack!</span>")

			defender.useblock_off()
			if(defender.poise <= 5)
				visible_message("<span class='warning'>[defender] falls down, unable to keep balance!</span>")
				defender.apply_effect(3, WEAKEN, 0)
	return 1


/mob/living/carbon/human/proc/attack_bloody(obj/item/W, mob/living/attacker, var/effective_force, var/hit_zone)
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

/mob/living/carbon/human/proc/projectile_hit_bloody(obj/item/projectile/P, var/effective_force, var/hit_zone)
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

/mob/living/carbon/human/proc/attack_joint(var/obj/item/organ/external/organ, var/obj/item/W, var/effective_force, var/dislocate_mult, var/blocked)
	if(!organ || (organ.dislocated == 2) || (organ.dislocated == -1) || blocked >= 100)
		return 0
	if(W.damtype != BRUTE)
		return 0

	//want the dislocation chance to be such that the limb is expected to dislocate after dealing a fraction of the damage needed to break the limb
	var/dislocate_chance = effective_force/(dislocate_mult * organ.min_broken_damage * config.organ_health_multiplier)*100
	if(prob(dislocate_chance * blocked_mult(blocked)))
		visible_message("<span class='danger'>[src]'s [organ.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
		organ.dislocate(1)
		return 1
	return 0

/mob/living/carbon/human/emag_act(var/remaining_charges, mob/user, var/emag_source)
	var/obj/item/organ/external/affecting = get_organ(user.zone_sel.selecting)
	if(!affecting || !(affecting.robotic >= ORGAN_ROBOT))
		to_chat(user, "<span class='warning'>That limb isn't robotic.</span>")
		return -1
	if(affecting.sabotaged)
		to_chat(user, "<span class='warning'>[src]'s [affecting.name] is already sabotaged!</span>")
		return -1
	to_chat(user, "<span class='notice'>You sneakily slide [emag_source] into the dataport on [src]'s [affecting.name] and short out the safeties.</span>")
	affecting.sabotaged = 1
	return 1

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM as mob|obj,var/speed = THROWFORCE_SPEED_DIVISOR)
	if(istype(AM,/obj/))
		var/obj/O = AM

		if(in_throw_mode && !get_active_hand() && speed <= THROWFORCE_SPEED_DIVISOR)	//empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(isturf(O.loc))
					put_in_active_hand(O)
					visible_message("<span class='warning'>[src] catches [O]!</span>")
					throw_mode_off()
					return

		var/dtype = O.damtype
		var/throw_damage = O.throwforce*(speed/THROWFORCE_SPEED_DIVISOR)

		if(src.blocking)
			var/obj/item/w_def
			if(src.blocking_hand && src.get_inactive_hand())
				w_def = src.get_inactive_hand()
			else if(src.get_active_hand())
				w_def = src.get_active_hand()
			if(w_def)
				if(w_def.force && w_def.w_class >= O.w_class)
					var/dir = get_dir(src,O)
					O.throw_at(get_edge_target_turf(src,dir),1)

					visible_message("<span class='warning'>[src] blocks [O] with [w_def]!</span>")

					poise -= throw_damage/w_def.mod_shield
					if(poise < throw_damage/w_def.mod_shield)
						visible_message("<span class='warning'>[src] falls down, unable to keep balance!</span>")
						apply_effect(2, WEAKEN, 0)
					src.useblock_off()
					return


		var/zone
		if (istype(O.thrower, /mob/living))
			var/mob/living/L = O.thrower
			if(L.zone_sel)
				zone = check_zone(L.zone_sel.selecting)
		else
			zone = ran_zone(BP_CHEST,75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		var/miss_chance = 15
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			miss_chance = max(15*(distance-2), 0)
		zone = get_zone_with_miss_chance(zone, src, miss_chance, ranged_attack=1)

		if(zone && O.thrower != src)
			var/shield_check = check_shields(throw_damage, O, thrower, zone, "[O]")
			if(shield_check == PROJECTILE_FORCE_MISS)
				zone = null
			else if(shield_check)
				return

		if(!zone)
			visible_message("<span class='notice'>\The [O] misses [src] narrowly!</span>")
			return

		O.throwing = 0		//it hit, so stop moving

		var/obj/item/organ/external/affecting = get_organ(zone)
		var/hit_area = affecting.name
		var/datum/wound/created_wound

		src.visible_message("<span class='warning'>\The [src] has been hit in the [hit_area] by \the [O].</span>")
		var/armor = run_armor_check(affecting, "melee", O.armor_penetration, "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].") //I guess "melee" is the best fit here
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
		if(dtype == BRUTE && istype(O,/obj/item))
			var/obj/item/I = O
			if (!is_robot_module(I))
				var/sharp = is_sharp(I)
				var/damage = throw_damage //the effective damage used for embedding purposes, no actual damage is dealt here
				if (armor)
					damage *= blocked_mult(armor)

				//blunt objects should really not be embedding in things unless a huge amount of force is involved
				var/embed_chance = sharp? damage/I.w_class : damage/(I.w_class*3)
				var/embed_threshold = sharp? 5*I.w_class : 15*I.w_class

				//Sharp objects will always embed if they do enough damage.
				//Thrown sharp objects have some momentum already and have a small chance to embed even if the damage is below the threshold
				if((sharp && prob(damage/(10*I.w_class)*100)) || (damage > embed_threshold && prob(embed_chance)))
					affecting.embed(I, supplied_wound = created_wound)

		// Begin BS12 momentum-transfer code.
		var/mass = 1.5
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class/THROWNOBJ_KNOCKBACK_DIVISOR
		var/momentum = speed*mass

		if(O.throw_source && momentum >= THROWNOBJ_KNOCKBACK_SPEED)
			var/dir = get_dir(O.throw_source, src)

			visible_message("<span class='warning'>\The [src] staggers under the impact!</span>","<span class='warning'>You stagger under the impact!</span>")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!O || !src) return

			if(O.loc == src && O.sharp) //Projectile is embedded and suitable for pinning.
				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O

/mob/living/carbon/human/embed(var/obj/O, var/def_zone=null, var/datum/wound/supplied_wound)
	if(!def_zone) ..()

	var/obj/item/organ/external/affecting = get_organ(def_zone)
	if(affecting)
		affecting.embed(O, supplied_wound = supplied_wound)

/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)
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

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(0)
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(0)

/mob/living/carbon/human/proc/handle_suit_punctures(var/damtype, var/damage, var/def_zone)

	// Tox and oxy don't matter to suits.
	if(damtype != BURN && damtype != BRUTE) return

	// The rig might soak this hit, if we're wearing one.
	if(back && istype(back,/obj/item/weapon/rig))
		var/obj/item/weapon/rig/rig = back
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
