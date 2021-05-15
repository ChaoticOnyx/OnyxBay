/*
=== Item Click Call Sequences ===
These are the default click code call sequences used when clicking on stuff with an item.

Atoms:

mob/ClickOn() calls the item's resolve_attackby() proc.
item/resolve_attackby() calls the target atom's attackby() proc.

Mobs:

mob/living/attackby() after checking for surgery, calls the item's attack() proc.
item/attack() generates attack logs, sets click cooldown and calls the mob's attacked_with_item() proc. If you override this, consider whether you need to set a click cooldown, play attack animations, and generate logs yourself.
mob/attacked_with_item() should then do mob-type specific stuff (like determining hit/miss, handling shields, etc) and then possibly call the item's apply_hit_effect() proc to actually apply the effects of being hit.

Item Hit Effects:

item/apply_hit_effect() can be overriden to do whatever you want. However "standard" physical damage based weapons should make use of the target mob's hit_with_weapon() proc to
avoid code duplication. This includes items that may sometimes act as a standard weapon in addition to having other effects (e.g. stunbatons on harm intent).
*/


////////////////////
//Item procs below//
////////////////////

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

//I would prefer to rename this to attack(), but that would involve touching hundreds of files.
/obj/item/proc/resolve_attackby(atom/A, mob/user, click_params)
	if(!(item_flags & ITEM_FLAG_NO_PRINT))
		add_fingerprint(user)
	return A.attackby(src, user, click_params)

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

//I would prefer to rename this attack_as_weapon(), but that would involve touching hundreds of files.
/obj/item/proc/attack(mob/living/M, mob/living/user, target_zone)
	if(!force || (item_flags & ITEM_FLAG_NO_BLUDGEON))
		return 0
	if(M == user && user.a_intent != I_HURT)
		return 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.blocking && (world.time - H.last_block) > 15)
			to_chat(user, SPAN("warning", "You can't attack while blocking!"))
			return 0

	//////////Logging////////
	if(!no_attack_log)
		admin_attack_log(user, M, "Attacked using \a [src] (DAMTYE: [uppertext(damtype)])", "Was attacked with \a [src] (DAMTYE: [uppertext(damtype)])", "used \a [src] (DAMTYE: [uppertext(damtype)]) to attack")
	//////////Logging////////

	user.setClickCooldown(update_attack_cooldown())
	user.do_attack_animation(M)
	if(!user.aura_check(AURA_TYPE_WEAPON, src, user))
		return 0

	var/hit_zone = M.resolve_item_attack(src, user, target_zone)
	if(user.a_intent != I_GRAB)
		if(hit_zone)
			apply_hit_effect(M, user, hit_zone)
	else
		apply_hit_effect(M, user, target_zone)

	return 1

//Called when a weapon is used to make a successful melee attack on a mob. Returns the blocked result
/obj/item/proc/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)

	var/power = force
	for(var/datum/modifier/M in user.modifiers)
		if(!isnull(M.outgoing_melee_damage_percent))
			power *= M.outgoing_melee_damage_percent
	// if(MUTATION_HULK in user.mutations)
		// power *= 2
		// TODO [V] Check if hulk mutation adding modifier somewhere else
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/A = user
		A.useblock_off()
		switch(A.a_intent)
			if(I_HELP)
				return target.touch_with_weapon(src, user, power, hit_zone)
			if(I_GRAB)
				return target.parry_with_weapon(src, user, power, hit_zone)
			if(I_DISARM)
				playsound(loc, 'sound/effects/woodhit.ogg', 50, 1, -1)
				return target.hit_with_weapon(src, user, power, hit_zone, 1)
			if(I_HURT)
				if(hitsound) playsound(loc, hitsound, 50, 1, -1)
				return target.hit_with_weapon(src, user, power, hit_zone)
	if(istype(user, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/A = user
		switch(A.a_intent)
			if(I_HELP)
				return target.touch_with_weapon(src, user, power, hit_zone)
			if(I_HURT)
				if(hitsound)
					playsound(loc, hitsound, 50, 1, -1)
				return target.hit_with_weapon(src, user, power, hit_zone)
	else
		if(hitsound) playsound(loc, hitsound, 50, 1, -1)
		return target.hit_with_weapon(src, user, power, hit_zone)

////////////////////
//Atom procs below//
////////////////////

/atom/proc/attackby(obj/item/W, mob/user, click_params)
	return

/atom/movable/attackby(obj/item/W, mob/user)
	if(!(W.item_flags & ITEM_FLAG_NO_BLUDGEON))
		visible_message(SPAN("danger", "[src] has been hit by [user] with [W]."))
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		obj_attack_sound(W)

/atom/proc/obj_attack_sound(obj/item/W)
	if(W.hitsound == 'sound/effects/fighting/smash.ogg')
		playsound(loc, 'sound/effects/fighting/smash.ogg', 50, 1, -1)
		return
	playsound(loc, 'sound/effects/metalhit2.ogg', rand(45,65), 1, -1)
	return

////////////////////
//Mobs procs below//
////////////////////

/mob/living/attackby(obj/item/I, mob/user)
	if(!ismob(user))
		return 0
	if(can_operate(src, user) && I.do_surgery(src, user)) //Surgery
		return 1
	return I.attack(src, user, user.zone_sel.selecting)

/mob/living/carbon/human/attackby(obj/item/I, mob/user)
	if(user == src && src.a_intent == I_DISARM && src.zone_sel.selecting == "mouth")
		var/obj/item/blocked = src.check_mouth_coverage()
		if(blocked)
			to_chat(user, SPAN("warning", "\The [blocked] is in the way!"))
			return 1
		else if(devour(I))
			return 1
	return ..()
