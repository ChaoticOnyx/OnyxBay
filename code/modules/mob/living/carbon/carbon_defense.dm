
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

	if(apply_damage(effective_force, I.damtype, hit_zone, blocked, damage_flags, used_weapon=I))
		return TRUE

	return FALSE
