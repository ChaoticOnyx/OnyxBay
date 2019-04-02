/obj/item/grab/normal

	type_name = GRAB_NORMAL
	start_grab_name = NORM_PASSIVE

/obj/item/grab/normal/init()
	..()

	if(!affecting)
		return

	if(affecting.w_uniform)
		affecting.w_uniform.add_fingerprint(assailant)

	assailant.put_in_active_hand(src)
	assailant.do_attack_animation(affecting)
	playsound(affecting.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	var/obj/O = get_targeted_organ()
	if(O.name == "right hand" || O.name == "left hand")
		visible_message("<span class='notice'>[assailant] has grabbed [affecting] by their hands!</span>")
	else
		visible_message("<span class='warning'>[assailant] has grabbed [affecting]'s [O.name]!</span>")
	affecting.grabbed_by += src

	if(!(affecting.a_intent == I_HELP))
		upgrade(TRUE)

/datum/grab/normal
	type_name = GRAB_NORMAL

	var/drop_headbutt = 1

	icon = 'icons/mob/screen1.dmi'

	help_action = "inspect"
	disarm_action = "pin"
	grab_action = "jointlock"
	harm_action = "dislocate"

/datum/grab/normal/on_hit_help(var/obj/item/grab/normal/G)
	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(O)
		return O.inspect(G.assailant)

/datum/grab/normal/on_hit_disarm(var/obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant

	if(!G.attacking && !affecting.lying)

		affecting.visible_message("<span class='notice'>[assailant] is trying to pin [affecting] to the ground!</span>")
		G.attacking = 1

		if(do_mob(assailant, affecting, action_cooldown - 1))
			G.attacking = 0
			G.action_used()
			affecting.Weaken(2)
			affecting.visible_message("<span class='notice'>[assailant] pins [affecting] to the ground!</span>")
			affecting.poise = 0

			return 1
		else
			affecting.visible_message("<span class='notice'>[assailant] fails to pin [affecting] to the ground.</span>")
			G.attacking = 0
			return 0
	else
		return 0


/datum/grab/normal/on_hit_grab(var/obj/item/grab/G)
	var/obj/item/organ/external/O = G.get_targeted_organ()
	var/mob/living/carbon/human/assailant = G.assailant
	var/mob/living/carbon/human/affecting = G.affecting

	if(!O)
		to_chat(assailant, "<span class='warning'>[affecting] is missing that body part!</span>")
		return 0

	assailant.visible_message("<span class='danger'>[assailant] begins to [pick("bend", "twist")] [affecting]'s [O.name] into a jointlock!</span>")
	G.attacking = 1

	if(do_mob(assailant, affecting, action_cooldown - 1))

		G.attacking = 0
		G.action_used()
		O.jointlock(assailant)
		assailant.visible_message("<span class='danger'>[affecting]'s [O.name] is twisted!</span>")
		playsound(assailant.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return 1

	else

		affecting.visible_message("<span class='notice'>[assailant] fails to jointlock [affecting]'s [O.name].</span>")
		G.attacking = 0
		return 0


/datum/grab/normal/on_hit_harm(var/obj/item/grab/G)
	var/obj/item/organ/external/O = G.get_targeted_organ()
	var/mob/living/carbon/human/assailant = G.assailant
	var/mob/living/carbon/human/affecting = G.affecting

	if(!O)
		to_chat(assailant, "<span class='warning'>[affecting] is missing that body part!</span>")
		return 0

	if(!O.dislocated)

		assailant.visible_message("<span class='warning'>[assailant] begins to dislocate [affecting]'s [O.joint]!</span>")
		G.attacking = 1

		if(do_mob(assailant, affecting, action_cooldown - 1))

			G.attacking = 0
			G.action_used()
			O.dislocate(1)
			assailant.visible_message("<span class='danger'>[affecting]'s [O.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
			playsound(assailant.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			return 1

		else

			affecting.visible_message("<span class='notice'>[assailant] fails to dislocate [affecting]'s [O.joint].</span>")
			G.attacking = 0
			return 0

	else if (O.dislocated > 0)
		to_chat(assailant, "<span class='warning'>[affecting]'s [O.joint] is already dislocated!</span>")
		return 0
	else
		to_chat(assailant, "<span class='warning'>You can't dislocate [affecting]'s [O.joint]!</span>")
		return 0

/datum/grab/normal/resolve_openhand_attack(var/obj/item/grab/G)
	if(G.assailant.a_intent != I_HELP)
		if(G.target_zone == BP_HEAD)
			if(G.assailant.zone_sel.selecting == BP_EYES)
				if(attack_eye(G))
					return 1
			else
				if(headbutt(G))
					if(drop_headbutt)
						let_go()
					return 1
		//else if(G.target_zone ==
	return 0

/datum/grab/normal/proc/attack_eye(var/obj/item/grab/G)
	var/mob/living/carbon/human/attacker = G.assailant
	var/mob/living/carbon/human/target = G.affecting

	var/datum/unarmed_attack/attack = attacker.get_unarmed_attack(target, BP_EYES)

	if(!attack)
		return
	for(var/obj/item/protection in list(target.head, target.wear_mask, target.glasses))
		if(protection && (protection.body_parts_covered & EYES))
			to_chat(attacker, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
			return
	if(!target.has_eyes())
		to_chat(attacker, "<span class='danger'>You cannot locate any eyes on [target]!</span>")
		return

	admin_attack_log(attacker, target, "Grab attacked the victim's eyes.", "Had their eyes grab attacked.", "attacked the eyes, using a grab action, of")

	attack.handle_eye_attack(attacker, target)
	return 1

/datum/grab/normal/proc/headbutt(var/obj/item/grab/G)
	var/mob/living/carbon/human/attacker = G.assailant
	var/mob/living/carbon/human/target = G.affecting

	if(target.lying)
		return

	var/damage = 20
	var/obj/item/clothing/hat = attacker.head
	var/damage_flags = 0
	if(istype(hat))
		damage += hat.force * 3
		damage_flags = hat.damage_flags()

	if(damage_flags & DAM_SHARP)
		attacker.visible_message("<span class='danger'>[attacker] gores [target][istype(hat)? " with \the [hat]" : ""]!</span>")
	else
		attacker.visible_message("<span class='danger'>[attacker] thrusts \his head into [target]'s skull!</span>")

	var/armor = target.run_armor_check(BP_HEAD, "melee")
	target.apply_damage(damage, BRUTE, BP_HEAD, armor, damage_flags)
	attacker.apply_damage(10, BRUTE, BP_HEAD, attacker.run_armor_check(BP_HEAD, "melee"))

	if(armor < 50 && target.headcheck(BP_HEAD) && prob(damage))
		target.apply_effect(20, PARALYZE)
		target.visible_message("<span class='danger'>[target] [target.species.get_knockout_message(target)]</span>")

	playsound(attacker.loc, "swing_hit", 25, 1, -1)

	admin_attack_log(attacker, target, "Headbutted their victim.", "Was headbutted.", "headbutted")
	return 1

// Handles special targeting like eyes and mouth being covered.
/datum/grab/normal/special_target_effect(var/obj/item/grab/G)
	if(G.special_target_functional)
		switch(G.last_target)
			if(BP_MOUTH)
				if(G.affecting.silent < 3)
					G.affecting.silent = 3
			if(BP_EYES)
				if(G.affecting.eye_blind < 3)
					G.affecting.eye_blind = 3

// Handles when they change targeted areas and something is supposed to happen.
/datum/grab/normal/special_target_change(var/obj/item/grab/G, var/diff_zone)
	if(G.target_zone != BP_HEAD && G.target_zone != BP_CHEST)
		return
	switch(diff_zone)
		if(BP_MOUTH)
			G.assailant.visible_message("<span class='warning'>\The [G.assailant] covers [G.affecting]'s mouth!</span>")
		if(BP_EYES)
			G.assailant.visible_message("<span class='warning'>\The [G.assailant] covers [G.affecting]'s eyes!</span>")


/datum/grab/normal/check_special_target(var/obj/item/grab/G)
	switch(G.last_target)
		if(BP_MOUTH)
			if(!G.affecting.check_has_mouth())
				to_chat(G.assailant, "<span class='danger'>You cannot locate a mouth on [G.affecting]!</span>")
				return 0
		if(BP_EYES)
			if(!G.affecting.has_eyes())
				to_chat(G.assailant, "<span class='danger'>You cannot locate any eyes on [G.affecting]!</span>")
				return 0
	return 1

/datum/grab/normal/resolve_item_attack(var/obj/item/grab/G, var/mob/living/carbon/human/user, var/obj/item/I)
	switch(G.target_zone)
		if(BP_EYES)
			return poke_eyes(G, I, user)
		if(BP_MOUTH)
			return cut_smile(G, I, user)
		if(BP_HEAD)
			switch(user:zone_sel.selecting) // Yes, it IS meant to be like this. We DO need these checks. Don't complain, Unbidden-kun.
				if(BP_EYES)
					return poke_eyes(G, I, user)
				if(BP_MOUTH)
					return cut_smile(G, I, user)
				else
					return attack_throat(G, I, user)
		else
			return attack_tendons(G, I, user, G.target_zone)



/datum/grab/normal/proc/attack_throat(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user)
	var/mob/living/carbon/human/affecting = G.affecting

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon
	user.visible_message("<span class='danger'>\The [user] begins to slit [affecting]'s throat with \the [W]!</span>")

	user.next_move = world.time + 30 //also should prevent user from triggering this repeatedly
	if(!do_after(user, 30))
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0

	var/damage_mod = 1
	//presumably, if they are wearing a helmet that stops pressure effects, then it probably covers the throat as well
	var/obj/item/clothing/head/helmet = affecting.get_equipped_item(slot_head)
	if(istype(helmet) && (helmet.body_parts_covered & HEAD) && (helmet.item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE))
		//we don't do an armor_check here because this is not an impact effect like a weapon swung with momentum, that either penetrates or glances off.
		damage_mod = 1.0 - (helmet.armor["melee"]/100)

	var/total_damage = 0
	var/damage_flags = W.damage_flags()
	for(var/i in 1 to 3)
		var/damage = min(W.force*1.5, 20)*damage_mod
		affecting.apply_damage(damage, W.damtype, BP_HEAD, 0, damage_flags, used_weapon=W)
		total_damage += damage


	if(total_damage)
		user.visible_message("<span class='danger'>\The [user] slit [affecting]'s throat open with \the [W]!</span>")

		if(W.hitsound)
			playsound(affecting.loc, W.hitsound, 50, 1, -1)

	G.last_action = world.time

	admin_attack_log(user, affecting, "Knifed their victim", "Was knifed", "knifed")
	return 1

//wanna know how i got these scars?
/datum/grab/normal/proc/cut_smile(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user)
	var/mob/living/carbon/human/affecting = G.affecting

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon

	var/obj/item/organ/external/head/head = affecting.organs_by_name[BP_HEAD]
	if(head && head.deformities > 0)
		return 0 //already smiling

	var/obj/item/clothing/head/helmet = affecting.get_equipped_item(slot_head)
	if(istype(helmet) && (helmet.body_parts_covered & HEAD) && (helmet.item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE))
		return 0 //hard to reach one's soft cheeks through that spess helm

	user.visible_message("<span class='danger'>\The [user] begins to slit [affecting]'s cheeks with \the [W]!</span>")

	user.next_move = world.time + 30
	if(!do_after(user, 30))
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0

	var/damage_flags = W.damage_flags()
	for(var/i in 1 to 2) // one for each cheek
		var/damage = min(W.force, 12)
		affecting.apply_damage(damage, W.damtype, BP_HEAD, 0, damage_flags, used_weapon=W)

	user.visible_message("<span class='danger'>\The [user] slit [affecting]'s cheeks  with \the [W], giving them a bloody smile!</span>")
	head.deformities = 1
	affecting.update_deformities()

	if(W.hitsound)
		playsound(affecting.loc, W.hitsound, 50, 1, -1)

	G.last_action = world.time

	admin_attack_log(user, affecting, "Glasgow-smiled their victim", "Was glasgow-smiled", "glasgow-smiled")
	return 1

/datum/grab/normal/proc/attack_tendons(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user, var/target_zone)
	var/mob/living/carbon/human/affecting = G.affecting

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon

	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(!O || O.is_stump() || !O.has_tendon || (O.status & ORGAN_TENDON_CUT))
		return FALSE

	user.visible_message("<span class='danger'>\The [user] begins to cut \the [affecting]'s [O.tendon_name] with \the [W]!</span>")
	user.next_move = world.time + 20

	if(!do_after(user, 20, progress=0))
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0
	if(!O || O.is_stump() || !O.sever_tendon())
		return 0

	user.visible_message("<span class='danger'>\The [user] cut \the [affecting]'s [O.tendon_name] with \the [W]!</span>")
	if(W.hitsound) playsound(affecting.loc, W.hitsound, 50, 1, -1)
	G.last_action = world.time
	admin_attack_log(user, affecting, "hamstrung their victim", "was hamstrung", "hamstrung")
	return 1

/datum/grab/normal/proc/poke_eyes(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user)
	var/mob/living/carbon/human/affecting = G.affecting

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!istype(W,/obj/item/weapon/material/kitchen/utensil/spoon))
		if(!W.sharp || !W.force || W.damtype != BRUTE || W.w_class > ITEM_SIZE_NORMAL)
			return 0 //unsuitable weapon

	for(var/obj/item/protection in list(affecting.head, affecting.wear_mask, affecting.glasses))
		if(protection && (protection.body_parts_covered & EYES))
			to_chat(user, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
			return 0
	if(!affecting.has_eyes())
		to_chat(user, "<span class='warning'>You cannot locate any eyes on [affecting]!</span>")
		return 0

	user.visible_message("<span class='danger'>\The [user] aims \his [W.name] at [affecting]'s eyes!</span>")

	user.next_move = world.time + 25
	if(!do_after(user, 25))
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0

	var/obj/item/organ/internal/eyes/eyes = affecting.internal_organs_by_name[BP_EYES]

	eyes.damage += rand(8,12)
	if(eyes.damage >= eyes.min_bruised_damage)
		if(affecting.stat != 2)
			if(eyes.robotic < ORGAN_ROBOT) //robot eyes bleeding might be a bit silly
				to_chat(affecting, "<span class='danger'>Your eyes start to bleed profusely!</span>")
		if(prob(50))
			if(affecting.stat != 2)
				to_chat(affecting, "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>")
				affecting.drop_item()
			affecting.eye_blurry += 10
			affecting.Paralyse(1)
			affecting.Weaken(4)
		if (eyes.damage >= eyes.min_broken_damage)
			if(affecting.stat != 2)
				to_chat(affecting, "<span class='warning'>You go blind!</span>")

		var/obj/item/organ/external/E = affecting.get_organ(eyes.parent_organ)
		E.take_damage(10)

	user.visible_message("<span class='danger'>\The [user] stabs [affecting]'s eyes with \the [W]!</span>")
	admin_attack_log(user, affecting, "Grab-stabbed the victim's eyes.", "Had their eyes grab-stabbed.", "stabbed the eyes, using a grab action, of")

	if(!eyes)
		return 0 //rare case of the victim's eyes being removed by someone faster than us
	if(!do_after(user, 50))
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0

	eyes.cut_away(affecting)
	var/obj/item/organ/external/E = affecting.get_organ(eyes.parent_organ)
	E.implants -= eyes
	eyes.dropInto(affecting.loc)
	playsound(affecting.loc, 'sound/effects/squelch1.ogg', 20, 1)

	user.visible_message("<span class='danger'>\The [user] brutally pokes [affecting]'s eyes out with \the [W]!</span>")
	admin_attack_log(user, affecting, "Poked the victim's eyes out.", "Had their eyes poked out.", "poked the eyes out, using a grab action, of")

	affecting.update_deformities()

	return 1
