
/mob/living/carbon/standard_weapon_hit_effects(obj/item/I, mob/living/user, effective_force, blocked, hit_zone)
	if(!effective_force || blocked >= 100)
		return FALSE

	//Hulk modifier
	if(MUTATION_HULK in user.mutations)
		effective_force *= 2

	if(MUTATION_STRONG in user.mutations)
		effective_force *= 2

	//Apply weapon damage
	var/damage_flags = I.damage_flags()
	if(prob(blocked)) //armour provides a chance to turn sharp/edge weapon attacks into blunt ones
		damage_flags &= ~(DAM_SHARP|DAM_EDGE)

	if(!apply_damage(effective_force, I.damtype, hit_zone, blocked, damage_flags, used_weapon=I))
		return FALSE

	//Melee weapon embedded object code.
	if(I && I.damtype == BRUTE && !I.anchored && !is_robot_module(I))
		var/weapon_sharp = (damage_flags & DAM_SHARP)
		var/damage = effective_force //just the effective damage used for sorting out embedding, no further damage is applied here
		if (blocked)
			damage *= blocked_mult(blocked)

		//blunt objects should really not be embedding in things unless a huge amount of force is involved
		var/embed_chance = weapon_sharp ? (damage / I.w_class) : (damage / (I.w_class * 3))
		var/embed_threshold = weapon_sharp ? (I.w_class * 5) : (I.w_class * 15)

		//Sharp objects will always embed if they do enough damage.
		if((weapon_sharp && damage > (I.w_class * 10)) || (damage > embed_threshold && prob(embed_chance)))
			embed(I, hit_zone)

	return TRUE
