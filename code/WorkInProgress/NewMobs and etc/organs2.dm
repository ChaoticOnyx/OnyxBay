/datum/organ/proc/process()
	return

/datum/organ/proc/receive_chem(chemical as obj)
	return
/datum/organ/external/proc/take_damage(brute, burn, slash, supbrute)
	if ((brute <= 0 && burn <= 0))
		return 0
	if(destroyed)
		return 0
	if(slash)
		var/chance = rand(1,5)
		var/nux = brute * chance
		if(brute_dam >= max_damage)
			if(prob(5 * brute))
				for(var/mob/M in viewers(owner))
					M.show_message("\red [owner.name]'s [display_name] flies off.")
				if(name == "chest")
					owner.gib()
				if(name == "head")
					var/obj/item/weapon/organ/head/H = new(owner.loc)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					owner:update_face()
					owner:update_body()
					owner.death()
					return
				if(name == "r arm")
					var/obj/item/weapon/organ/r_arm/H = new(owner.loc)
					if(owner:organs["r_hand"])
						var/datum/organ/external/S = owner:organs["r_hand"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/r_hand/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return
				if(name == "l arm")
					var/obj/item/weapon/organ/l_arm/H = new(owner.loc)
					if(owner:organs["l_hand"])
						var/datum/organ/external/S = owner:organs["l_hand"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/l_hand/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off in arc.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return
				if(name == "r leg")
					var/obj/item/weapon/organ/r_leg/H = new(owner.loc)
					if(owner:organs["r_foot"])
						var/datum/organ/external/S = owner:organs["r_foot"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/l_foot/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off flies off in arc.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return
				if(name == "l leg")
					var/obj/item/weapon/organ/l_leg/H = new(owner.loc)
					if(owner:organs["l_foot"])
						var/datum/organ/external/S = owner:organs["l_foot"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/l_foot/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return
		else if(prob(nux))
			createwound(rand(1,5))
			owner << "You feel something wet on your [display_name]"
			goto damage
/*	if(brute >= max_damage)
		destroyed = 1
		if(name == "chest")
			for(var/mob/M in viewers(owner))
				M.show_message("\red [owner.name]'s explodes into gore.")
			owner.gib()
			return
		else if(name == "head")
			owner.death(0)
			for(var/mob/M in viewers(owner))
				M.show_message("\red [owner.name]'s [display_name] explodes into gore.")
		else
			for(var/mob/M in viewers(owner))
				M.show_message("\red [owner.name]'s [display_name] explodes into gore.")
		owner:update_body()
		return*/
	damage
	if ((brute_dam + burn_dam + brute + burn) < max_damage)
		brute_dam += brute
		burn_dam += burn
	else
		var/can_inflict = max_damage - (brute_dam + burn_dam)
		if (can_inflict)
			if (brute > 0 && burn > 0)
				brute = can_inflict/2
				burn = can_inflict/2
				var/ratio = brute / (brute + burn)
				brute_dam += ratio * can_inflict
				burn_dam += (1 - ratio) * can_inflict
			else
				if (brute > 0)
					brute = can_inflict
					brute_dam += brute
				else
					burn = can_inflict
					burn_dam += burn
		else
			return 0

		if(broken)
			owner.emote("scream")

	var/result = update_icon()

	return result

/datum/organ/external/proc/heal_damage(brute, burn,var/internal = 0)
	brute_dam = max(0, brute_dam - brute)
	burn_dam = max(0, burn_dam - burn)
	if(internal)
		broken = 0
		perma_injury = 0
	return update_icon()

/datum/organ/external/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam - perma_injury,perma_injury)	//could use health?

/datum/organ/external/proc/get_damage_brute()
	return max(brute_dam+perma_injury,perma_injury)

/datum/organ/external/proc/get_damage_fire()
	return burn_dam

//G:goto

// new damage icon system
// returns just the brute/burn damage code

/datum/organ/external/proc/damage_state_text()
	if(open)
		return "33"
	var/tburn = 0
	var/tbrute = 0

	if(burn_dam ==0)
		tburn =0
	else if (burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if (burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3

	if (brute_dam == 0)
		tbrute = 0
	else if (brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if (brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"

// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)

/datum/organ/external/proc/update_icon()

	var/n_is = damage_state_text()
	if (n_is != damage_state)
		damage_state = n_is
		return 1
	else
		return 0
	return
obj/item/weapon/organ/
	icon = 'human.dmi'
obj/item/weapon/organ/head
	name = "head"
	icon_state = "head_l"
obj/item/weapon/organ/l_arm
	name = "left arm"
	icon_state = "arm_left_l"
obj/item/weapon/organ/l_foot
	name = "left foot"
	icon_state = "foot_left_l"
obj/item/weapon/organ/l_hand
	name = "left hand"
	icon_state = "hand_left_l"
obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = "leg_left_l"
obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = "arm_right_l"
obj/item/weapon/organ/r_foot
	name = "right foot"
	icon_state = "foot_right_l"
obj/item/weapon/organ/r_hand
	name = "right hand"
	icon_state = "hand_right_l"
obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = "leg_right_l"
