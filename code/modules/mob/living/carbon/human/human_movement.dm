/mob/living/carbon/human/movement_delay()
	var/tally = ..()

	tally += species.handle_movement_delay_special(src)

	if(istype(loc, /turf/space))
		return -1 // It's hard to be slowed down in space by... anything

	if(embedded_flag || (stomach_contents && stomach_contents.len))
		handle_embedded_and_stomach_objects() //Moving with objects stuck in you can cause bad times.

	for(var/E in chem_effects)
		switch(E)
			if(CE_SPEEDBOOST)
				return -1
			if(CE_SLOWDOWN)
				tally += chem_effects[CE_SLOWDOWN]

	var/human_delay = config.human_delay

	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.haste) && M.haste == TRUE)
			return -1 // Returning -1 will actually result in a slowdown for Teshari.
		if(!isnull(M.slowdown))
			tally += M.slowdown

	if(species.slowdown)
		tally += species.slowdown

	if(aiming)
		tally += aiming.movement_tally // Iron sights make you slower, it's a well-known fact.

	if(bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	tally += blocking * 1.5

	var/health_deficiency = (maxHealth - health)
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)

	var/shock = get_shock()
	if(shock >= 10)
		tally += (shock / 10) //pain shouldn't slow you down if you can't even feel it

	if(!isSynthetic(src))	// are you hungry? I think yes
		var/nut_level = nutrition / 100
		switch(nutrition)
			if(0 to 150)
				tally += 1.5 - nut_level
			if(450 to INFINITY)
				tally += nut_level - 4.5

	tally += equipment_slowdown

	var/list/organ_list = list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)  // if character use legs
	if(istype(buckled, /obj/structure/bed/chair/wheelchair))              // if character buckled into wheelchair
		organ_list = list(BP_L_HAND, BP_R_HAND, BP_L_ARM, BP_R_ARM)

	for(var/organ_name in organ_list)
		var/obj/item/organ/external/E = get_organ(organ_name)
		if(!E)
			tally += 4
		else
			tally += E.movement_tally

	return (tally + human_delay)

/mob/living/carbon/human/Allow_Spacemove(check_drift = 0)
	//Can we act?
	if(restrained())
		return 0

	//Do we have a working jetpack?
	var/obj/item/weapon/tank/jetpack/thrust
	if(back)
		if(istype(back,/obj/item/weapon/tank/jetpack))
			thrust = back
		else if(istype(back,/obj/item/weapon/rig))
			var/obj/item/weapon/rig/rig = back
			for(var/obj/item/rig_module/maneuvering_jets/module in rig.installed_modules)
				thrust = module.jets
				break

	if(thrust)
		if(((!check_drift) || (check_drift && thrust.stabilization_on)) && (!lying) && (thrust.allow_thrust(0.01, src)))
			inertia_dir = 0
			return 1

	//If no working jetpack then use the other checks
	. = ..()


/mob/living/carbon/human/slip_chance(prob_slip = 5)
	if(!..())
		return 0

	//Check hands and mod slip
	if(!l_hand)	prob_slip -= 2
	else if(l_hand.w_class <= ITEM_SIZE_SMALL)	prob_slip -= 1
	if (!r_hand)	prob_slip -= 2
	else if(r_hand.w_class <= ITEM_SIZE_SMALL)	prob_slip -= 1

	return prob_slip

/mob/living/carbon/human/Check_Shoegrip()
	if(species.species_flags & SPECIES_FLAG_NO_SLIP)
		return 1
	if(shoes && (shoes.item_flags & ITEM_FLAG_NOSLIP) && istype(shoes, /obj/item/clothing/shoes/magboots))  //magboots + dense_object = no floating
		return 1
	return 0
