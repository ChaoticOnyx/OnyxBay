
/*
	apply_damage() args
	damage - How much damage to take
	damage_type - What type of damage to take, brute, burn
	def_zone - Where to take the damage if its brute or burn

	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, used_weapon = null)
	if(status_flags & GODMODE)
		return TRUE

	if(!damage || (blocked >= 100))
		return FALSE

	if(!damage || (blocked >= 100))
		return FALSE

	for(var/datum/modifier/M in modifiers)
		if(!M.affected_items.len)
			continue

		if(used_weapon in M.affected_items)
			damage += M.run_item_damage(damage, damagetype, def_zone, blocked, damage_flags, used_weapon)

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * blocked_mult(blocked))
		if(BURN)
			if(MUTATION_COLD_RESISTANCE in mutations)	damage = 0
			adjustFireLoss(damage * blocked_mult(blocked))
		if(TOX)
			adjustToxLoss(damage * blocked_mult(blocked))
		if(OXY)
			adjustOxyLoss(damage * blocked_mult(blocked))
		if(CLONE)
			adjustCloneLoss(damage * blocked_mult(blocked))
		if(PAIN)
			adjustHalLoss(damage * blocked_mult(blocked))
		if(ELECTROCUTE)
			electrocute_act(damage, used_weapon, 1.0, def_zone)

	updatehealth()
	return 1


/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, halloss = 0, def_zone = null, blocked = 0, damage_flags = 0)
	if(status_flags & GODMODE)
		return 0
	if(blocked >= 100)	return 0
	if(brute)	apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)	apply_damage(burn, BURN, def_zone, blocked)
	if(tox)		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)	apply_damage(clone, CLONE, def_zone, blocked)
	if(halloss) apply_damage(halloss, PAIN, def_zone, blocked)
	return 1


/mob/living/proc/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	if(status_flags & GODMODE)
		return 0
	if(!effect || (blocked >= 100))	return 0

	switch(effecttype)
		if(STUN)
			Stun(effect * blocked_mult(blocked))
		if(WEAKEN)
			Weaken(effect * blocked_mult(blocked))
		if(PARALYZE)
			Paralyse(effect * blocked_mult(blocked))
		if(PAIN)
			adjustHalLoss(effect * blocked_mult(blocked))
		if(STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter - TODO CANSTUTTER flag?
				stuttering = max(stuttering, effect * blocked_mult(blocked))
		if(EYE_BLUR)
			eye_blurry = max(eye_blurry, effect * blocked_mult(blocked))
		if(DROWSY)
			drowsyness = max(drowsyness, effect * blocked_mult(blocked))
	updatehealth()
	return 1


/mob/living/proc/apply_effects(stun = 0, weaken = 0, paralyze = 0, stutter = 0, eyeblur = 0, drowsy = 0, agony = 0, blocked = 0)
	if(status_flags & GODMODE)
		return 0
	if(blocked >= 2)	return 0
	if(stun)		apply_effect(stun,      STUN, blocked)
	if(weaken)		apply_effect(weaken,    WEAKEN, blocked)
	if(paralyze)	apply_effect(paralyze,  PARALYZE, blocked)
	if(stutter)		apply_effect(stutter,   STUTTER, blocked)
	if(eyeblur)		apply_effect(eyeblur,   EYE_BLUR, blocked)
	if(drowsy)		apply_effect(drowsy,    DROWSY, blocked)
	if(agony)		apply_effect(agony,     PAIN, blocked)
	return 1
