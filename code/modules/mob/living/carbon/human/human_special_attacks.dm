/mob/living/carbon/human/MiddleClickOn(atom/A)
	. = ..()
	switch(mmb_intents)
		if(MMB_BITE)
			bite(A)
		if(MMB_JUMP)
			INVOKE_ASYNC(src, nameof(.proc/jump), A)

/mob/living/carbon/human/proc/mmb_switch(intent)
	if(mmb_intents == intent)
		mmb_intents = null
	else
		mmb_intents = intent

	switch(intent)
		if(MMB_BITE)
			jump_icon?.icon_state = "act_jump0"
			if(bite_icon?.icon_state == "act_bite1")
				bite_icon?.icon_state = "act_bite0"
			else
				bite_icon?.icon_state = "act_bite1"

		if(MMB_JUMP)
			bite_icon?.icon_state = "act_bite0"
			if(jump_icon?.icon_state == "act_jump1")
				jump_icon?.icon_state = "act_jump0"
			else
				jump_icon?.icon_state = "act_jump1"

/mob/living/carbon/human/proc/bite(mob/living/carbon/human/victim)
	THROTTLE(cooldown, (6 SECONDS))
	if(!cooldown)
		return

	if(!istype(victim))
		return

	if(!victim.Adjacent(src))
		return

	if(victim == src)
		return

	if(incapacitated())
		return

	if(head && (head.item_flags & ITEM_FLAG_AIRTIGHT))
		to_chat(src, SPAN("warning", "headgear is blocking your mouth!"))
		return

	var/obj/item/blocked = check_mouth_coverage()
	if(blocked)
		to_chat(src, SPAN("warning", "\The [blocked] is in the way!"))
		return

	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		to_chat(src, SPAN_WARNING("I don't want to harm [victim]!"))
		return FALSE

	setClickCooldown(FAST_WEAPON_COOLDOWN)
	face_atom(victim)

	var/zone = check_zone(zone_sel.selecting)
	var/obj/item/organ/external/affecting = victim?.get_organ(zone)
	if(!istype(affecting))
		to_chat(src, SPAN_WARNING("Nothing to bite!"))
		return

	var/damage = 3 + ((species.strength + 1) * 4)
	var/blocked_dam = victim.run_armor_check(zone, "melee")
	victim.apply_damage(damage, BRUTE, zone, blocked_dam, user = src)
	damage_poise(5)
	victim.damage_poise(round(10 * damage * 0.5 * (100 - victim.get_flat_armor(zone, "brute")), 0.1))
	make_grab(src, victim, GRAB_BITE)

/// Godafwul shit, indeed.
/atom/movable/var/jumped = FALSE

/mob/living/carbon/human/proc/jump(atom/A)
	if(!A || QDELETED(A) || !A.loc)
		return

	if(A == src || A == src.loc)
		return

	if(lying)
		to_chat(src, SPAN_WARNING("I should stand up first."))
		return

	if(pulledby || LAZYLEN(grabbed_by))
		to_chat(src, SPAN_WARNING("I'm being grabbed!"))
		return

	if(poise <= poise_pool / 2)
		to_chat(src, SPAN_WARNING("I haven't regained my balance yet."))
		return

	if(A.z != z)
		return

	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	face_atom(A)
	emote("jump")
	throw_spin = FALSE
	var/jump_turf = get_step(get_step(src, dir), dir)

	damage_poise(body_build.poise_pool / 2)
	throw_at(jump_turf, 2, 1, src)
	throw_spin = TRUE
