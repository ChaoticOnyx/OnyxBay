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
		show_splash_text(src, "Too soon!", SPAN_WARNING("It is too soon to bite!"))
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
		show_splash_text(src, "Mouth is blocked!", SPAN_WARNING("Headgear is blocking your mouth!"))
		return

	var/obj/item/organ/internal/jaw/jaw = internal_organs_by_name[BP_JAW]
	if(!istype(jaw))
		return

	if(jaw.get_teeth_count() < jaw.max_teeth_count && prob(80))
		show_splash_text(src, "Mouth is blocked!", SPAN_WARNING("Biting without teeth proved difficult!"))
		return

	var/obj/item/blocked = check_mouth_coverage()
	if(blocked)
		show_splash_text(src, "Mouth is blocked!", SPAN("warning", "\The [blocked] is in the way!"))
		return

	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		show_splash_text(src, "You are a pacifist!", SPAN_WARNING("I don't want to harm [victim]!"))
		return FALSE

	setClickCooldown(FAST_WEAPON_COOLDOWN)
	face_atom(victim)
	do_attack_animation(victim)

	var/zone = check_zone(zone_sel.selecting)
	var/obj/item/organ/external/affecting = victim?.get_organ(zone)
	if(!istype(affecting))
		show_splash_text(src, "Nothing to bite!", SPAN_WARNING("Nothing to bite!"))
		return

	finalize_bite(victim, zone, TRUE)

/mob/living/carbon/human/proc/finalize_bite(mob/living/carbon/human/victim, zone, will_grab = TRUE)
	var/obj/item/organ/internal/jaw/jaw = internal_organs_by_name[BP_JAW]
	var/damage = 7
	var/grab_chance = 10
	if(jaw.teeth_types[/obj/item/tooth/unathi] > jaw.max_teeth_count / 2)
		grab_chance += 50
		damage += 10
	else if(jaw.teeth_types[/obj/item/tooth/robotic] > jaw.max_teeth_count / 2)
		grab_chance += 50
		damage += 7

	playsound(get_turf(src), 'sound/weapons/bite.ogg', 100, FALSE, -1)
	var/blocked_dam = victim.run_armor_check(zone, "melee")
	victim.apply_damage(damage, BRUTE, zone, blocked_dam, user = src)
	damage_poise(5)
	victim.damage_poise(round(10 * damage * 0.5 * (100 - victim.get_flat_armor(zone, "brute")), 0.1))
	visible_message(SPAN("danger", "[src] bites [victim]'s [zone]!"),\
		SPAN("danger", "You bite [victim]'s [zone]!.")
	)

	if(will_grab && prob(grab_chance))
		make_grab(victim, /datum/grab/normal/struggle, defer_hand = FALSE)

/mob/living/carbon/human/proc/jump(atom/A)
	if(!A || QDELETED(A) || !A.loc)
		return

	if(A == src || A == src.loc)
		return

	if(lying)
		to_chat(src, SPAN_WARNING("I should stand up first."))
		return

	if(LAZYLEN(grabbed_by))
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

	damage_poise(get_poise_pool() / 2)
	throw_at(jump_turf, 2, 1, src)
	throw_spin = TRUE
