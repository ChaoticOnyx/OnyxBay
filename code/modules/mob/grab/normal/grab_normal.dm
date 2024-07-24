/datum/grab/normal
	name              = "grab"
	help_action       = "inspect"
	disarm_action     = "pin"
	grab_action       = "jointlock"
	harm_action       = "dislocate"
	var/drop_headbutt = TRUE

/datum/grab/normal/on_hit_help(obj/item/grab/G, atom/A, proximity)
	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(!O || !proximity || (A && A != G.get_affecting_mob()))
		return FALSE

	return O.inspect(G.assailant)

/datum/grab/normal/on_hit_disarm(obj/item/grab/G, atom/A, proximity)
	if(!proximity)
		return FALSE

	var/mob/living/carbon/human/affecting = G.get_affecting_mob()
	var/mob/living/carbon/human/assailant = G.assailant

	G.is_currently_resolving_hit = TRUE
	affecting.visible_message(SPAN_DANGER("\The [assailant] is trying to pin \the [affecting] to the ground!"))
	if(do_mob(assailant, affecting, action_cooldown - 1))
		G.is_currently_resolving_hit = FALSE
		G.action_used()
		affecting.Weaken(2)
		affecting.Stun(2)
		affecting.visible_message(SPAN_DANGER("\The [assailant] pins \the [affecting] to the ground!"))
		affecting.damage_poise(affecting.poise)
		return TRUE
	else
		affecting.visible_message(SPAN_DANGER("\The [assailant] fails to pin \the [affecting] to the ground."))
		G.is_currently_resolving_hit = FALSE
		return FALSE

/datum/grab/normal/on_hit_grab(obj/item/grab/G, atom/A, proximity)
	if(!proximity)
		return FALSE

	var/mob/living/affecting = G.get_affecting_mob()
	if(!affecting || (A && A != affecting))
		return FALSE

	var/mob/living/assailant = G.assailant
	if(!assailant)
		return FALSE

	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(!O)
		to_chat(assailant, SPAN_WARNING("\The [affecting] is missing that body part!"))
		return FALSE

	//if(!assailant.skill_check(SKILL_COMBAT, SKILL_ADEPT))
	//	to_chat(assailant, SPAN_WARNING("You clumsily attempt to jointlock \the [affecting]'s [O.name], but fail!"))
	//	return FALSE

	assailant.visible_message(SPAN_DANGER("\The [assailant] begins to [pick("bend", "twist")] \the [affecting]'s [O.name] into a jointlock!"))
	if(do_mob(assailant, affecting, action_cooldown - 1))
		G.action_used()
		O.jointlock(assailant)
		assailant.visible_message(SPAN_DANGER("\The [affecting]'s [O.name] is twisted!"))
		playsound(assailant.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return TRUE

	affecting.visible_message(SPAN_WARNING("\The [assailant] fails to jointlock \the [affecting]'s [O.name]."))
	return FALSE

/datum/grab/normal/on_hit_harm(obj/item/grab/G, atom/A, proximity)
	if(!proximity)
		return FALSE

	var/mob/living/affecting = G.get_affecting_mob()
	if(!affecting || (A && A != affecting))
		return FALSE

	var/mob/living/assailant = G.assailant
	if(!assailant)
		return FALSE

	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(!O)
		to_chat(assailant, SPAN_WARNING("\The [affecting] is missing that body part!"))
		return  FALSE

	//if(!assailant.skill_check(SKILL_COMBAT, SKILL_ADEPT))
	//	to_chat(assailant, SPAN_WARNING("You clumsily attempt to dislocate \the [affecting]'s [O.name], but fail!"))
	//	return FALSE

	if(!O.is_dislocated())
		assailant.visible_message(SPAN_DANGER("\The [assailant] begins to dislocate \the [affecting]'s [O.joint]!"))
		G.is_currently_resolving_hit = TRUE
		if(do_mob(assailant, affecting, action_cooldown - 1))
			G.is_currently_resolving_hit = TRUE
			G.action_used()
			O.dislocate()
			assailant.visible_message(SPAN_DANGER("\The [affecting]'s [O.joint] [pick("gives way","caves in","crumbles","collapses")]!"))
			playsound(assailant.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			return TRUE
		else
			G.is_currently_resolving_hit = TRUE
			affecting.visible_message(SPAN_WARNING("\The [assailant] fails to dislocate \the [affecting]'s [O.joint]."))
			return FALSE
	else
		to_chat(assailant, SPAN_WARNING("\The [affecting]'s [O.joint] is already dislocated!"))
		return FALSE

/datum/grab/normal/resolve_openhand_attack(obj/item/grab/G)
	if(G.assailant.a_intent != I_HELP)
		if(G.target_zone == BP_HEAD)
			if(G.assailant.zone_sel.selecting == BP_EYES)
				if(attack_eye(G))
					return TRUE
			else
				if(headbutt(G))
					if(drop_headbutt)
						let_go()
					return TRUE
	return FALSE

/datum/grab/normal/proc/attack_eye(obj/item/grab/G)
	var/mob/living/carbon/human/target = G.get_affecting_mob()
	var/mob/living/carbon/human/attacker = G.assailant
	if(!istype(target) || !istype(attacker))
		return

	var/datum/unarmed_attack/attack = attacker.get_unarmed_attack(target, BP_EYES)

	for(var/obj/item/protection in list(target.head, target.wear_mask, target.glasses))
		if(protection && (protection.body_parts_covered & EYES))
			to_chat(attacker, SPAN_WARNING("You're going to need to remove the eye covering first."))
			return

	if(!target.has_eyes())
		to_chat(attacker, SPAN_WARNING("You cannot locate any eyes on [target]!"))
		return

	admin_attack_log(attacker, target, "Grab attacked the victim's eyes.", "Had their eyes grab attacked.", "attacked the eyes, using a grab action, of")

	attack?.handle_eye_attack(attacker, target)
	return TRUE

/datum/grab/normal/proc/headbutt(obj/item/grab/G)
	var/mob/living/carbon/human/target = G.get_affecting_mob()
	var/mob/living/carbon/human/attacker = G.assailant
	if(!istype(target) || !istype(attacker))
		return

	/// skill check goes here

	if(target.lying)
		return

	var/damage = 20
	var/obj/item/clothing/hat = attacker.get_equipped_item(slot_head_str)
	var/damage_flags = 0
	if(istype(hat))
		damage += hat.force * 3
		damage_flags = hat.damage_flags()

	if(damage_flags & DAM_SHARP)
		if(istype(hat))
			attacker.visible_message(SPAN_DANGER("\The [attacker] gores \the [target] with \the [hat]!"))
		else
			attacker.visible_message(SPAN_DANGER("\The [attacker] gores \the [target]!"))
	else
		var/datum/gender/gender = gender_datums[attacker.gender]
		attacker.visible_message(SPAN_DANGER("\The [attacker] thrusts [gender.his] head into \the [target]'s skull!"))

	var/armor = target.run_armor_check(BP_HEAD, "melee")
	target.apply_damage(damage, BRUTE, BP_HEAD, damage_flags)
	attacker.apply_damage(10, BRUTE, BP_HEAD, attacker.run_armor_check(BP_HEAD, "melee"))

	if(armor < 50 && target.headcheck(BP_HEAD) && prob(damage))
		target.apply_effect(20, PARALYZE)
		target.visible_message(SPAN_DANGER("\The [target] [target.species.get_knockout_message(target)]"))

	playsound(attacker.loc, "SFX_FIGHTING_SWING", 25, 1, -1)

	admin_attack_log(attacker, target, "Headbutted their victim.", "Was headbutted.", "headbutted")
	return 1

// Handles special targeting like eyes and mouth being covered.
/datum/grab/normal/special_target_effect(obj/item/grab/G)
	var/mob/living/affecting_mob = G.get_affecting_mob()
	if(G.special_target_functional)
		switch(G.target_zone)
			if(BP_MOUTH)
				if(affecting_mob.silent < 3)
					affecting_mob.silent = 3
			if(BP_EYES)
				if(affecting_mob.eye_blind < 3)
					affecting_mob.eye_blind = 3

// Handles when they change targeted areas and something is supposed to happen.
/datum/grab/normal/special_target_change(obj/item/grab/G, old_zone, new_zone)
	if((old_zone != BP_HEAD && old_zone != BP_CHEST) || !G.get_affecting_mob())
		return
	switch(new_zone)
		if(BP_MOUTH)
			G.assailant.visible_message("<span class='warning'>\The [G.assailant] covers [G.affecting]'s mouth!</span>")
		if(BP_EYES)
			G.assailant.visible_message("<span class='warning'>\The [G.assailant] covers [G.affecting]'s eyes!</span>")

/datum/grab/normal/check_special_target(obj/item/grab/G)
	var/mob/living/affecting_mob = G.get_affecting_mob()
	if(!istype(affecting_mob))
		return FALSE

	switch(G.target_zone)
		if(BP_MOUTH)
			if(!affecting_mob.check_has_mouth())
				to_chat(G.assailant, SPAN_DANGER("You cannot locate a mouth on [G.affecting]!"))
				return FALSE
		if(BP_EYES)
			if(!affecting_mob.has_eyes())
				to_chat(G.assailant, SPAN_DANGER("You cannot locate any eyes on [G.affecting]!"))
				return FALSE

	return TRUE

/datum/grab/normal/resolve_item_attack(obj/item/grab/G, mob/living/carbon/human/user, obj/item/I)
	switch(G.target_zone)
		if(BP_HEAD)
			return attack_throat(G, I, user)
		else
			return attack_tendons(G, I, user, G.target_zone)

/datum/grab/normal/proc/attack_throat(obj/item/grab/G, obj/item/W, mob/user)
	var/mob/living/affecting = G.get_affecting_mob()
	if(!affecting)
		return
	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon

	user.visible_message(SPAN_DANGER("\The [user] begins to slit [affecting]'s throat with \the [W]!"))

	user.next_move = world.time + 30 //also should prevent user from triggering this repeatedly

	/// SKILL CHECK

	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0

	var/damage_mod = 1
	var/damage_flags = W.damage_flags()
	//presumably, if they are wearing a helmet that stops pressure effects, then it probably covers the throat as well
	var/obj/item/clothing/head/helmet = affecting.get_equipped_item(slot_head)
	if(istype(helmet) && (helmet.body_parts_covered & HEAD) && (helmet.item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE))
		//we don't do an armor_check here because this is not an impact effect like a weapon swung with momentum, that either penetrates or glances off.
		damage_mod = 1.0 - (helmet.armor["melee"]/100)

	var/total_damage = 0
	for(var/i in 1 to 3)
		var/damage = min(W.force*1.5, 20)*damage_mod
		affecting.apply_damage(damage, W.damtype, BP_HEAD, 0, damage_flags, used_weapon = W)
		total_damage += damage

	if(total_damage)
		user.visible_message(SPAN_DANGER("\The [user] slit [affecting]'s throat open with \the [W]!"))

		if(W.hitsound)
			playsound(affecting.loc, W.hitsound, 50, 1, -1)

	G.last_action = world.time

	admin_attack_log(user, affecting, "Knifed their victim", "Was knifed", "knifed")
	return 1

/datum/grab/normal/proc/attack_tendons(obj/item/grab/G, obj/item/W, mob/user, target_zone)
	var/mob/living/affecting = G.get_affecting_mob()
	if(!affecting)
		return

	/// Skill check goes here

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon

	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(!O || O.is_stump() || !(O.organ_flags & ORGAN_FLAG_HAS_TENDON) || (O.status & ORGAN_TENDON_CUT))
		return FALSE

	user.visible_message(SPAN_DANGER("\The [user] begins to cut \the [affecting]'s [O.tendon_name] with \the [W]!"))
	user.next_move = world.time + (2 SECONDS)
	if(!do_after(user, (2 SECONDS), progress = FALSE))
		return 0

	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0

	if(!O || !O.sever_tendon())
		return 0

	user.visible_message(SPAN_DANGER("\The [user] cut \the [affecting]'s [O.tendon_name] with \the [W]!"))
	if(W.hitsound)
		playsound(affecting.loc, W.hitsound, 50, 1, -1)
	G.last_action = world.time
	admin_attack_log(user, affecting, "hamstrung their victim", "was hamstrung", "hamstrung")
	return 1
