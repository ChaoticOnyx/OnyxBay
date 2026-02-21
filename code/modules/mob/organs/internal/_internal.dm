/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/
/obj/item/organ/internal
	food_organ_type = /obj/item/reagent_containers/food/organ
	throwforce = 0.1                // Enough to upset you, not enough to crack your ribcage open
	var/dead_icon                   // Icon to use when the organ has died.
	var/surface_accessible = FALSE
	var/relative_size = 25          // Relative size of the organ. Roughly % of space they take in the target projection :D
	var/list/will_assist_languages = list()
	var/list/datum/language/assists_languages = list()
	var/min_bruised_damage = 0        // Damage before considered bruised
	var/foreign = FALSE               // foreign organs shouldn't be removed or recreated on revive
	var/override_species_icon = FALSE // Should we ignore species-specific icons?
	/// Should this organs icon changed to prosthetic?
	var/override_organic_icon = TRUE
	/// Should this organ be hidden on scanners?
	var/hidden = FALSE
	var/autoheal_value = 0.1

/obj/item/organ/internal/New(mob/living/carbon/holder)
	if(!min_bruised_damage)
		min_bruised_damage = Floor(max_damage / 4)

	..(holder)

	if(istype(holder))
		holder.internal_organs |= src

		var/mob/living/carbon/human/H = holder
		if(istype(H))
			var/obj/item/organ/external/E = H.get_organ(parent_organ)
			if(!E)
				CRASH("[src] spawned in [holder] without a parent organ: [parent_organ].")
			E.internal_organs |= src
			E.cavity_max_w_class = max(E.cavity_max_w_class, w_class)

		handle_foreign()

	update_icon()

/obj/item/organ/internal/Destroy()
	if(owner)
		owner.internal_organs.Remove(src)
		owner.internal_organs_by_name -= organ_tag
		while(null in owner.internal_organs)
			owner.internal_organs -= null
		var/obj/item/organ/external/E = owner.organs_by_name[parent_organ]
		if(istype(E)) E.internal_organs -= src
	return ..()

/obj/item/organ/internal/think()
	..()

	if(!owner)
		return

	if(isundead(owner))
		return

	if(damage)
		autoheal()

/obj/item/organ/internal/set_dna(datum/dna/new_dna)
	..()
	if(!override_species_icon && species && species.organs_icon)
		icon = species.organs_icon

//disconnected the organ from it's owner but does not remove it, instead it becomes an implant that can be removed with implant surgery
//TODO move this to organ/internal once the FPB port comes through
/obj/item/organ/proc/cut_away(mob/living/user)
	var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
	if(istype(parent)) //TODO ensure that we don't have to check this.
		removed(user, 0)
		parent.implants += src

/obj/item/organ/internal/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	if(owner)
		owner.internal_organs_by_name -= organ_tag
		owner.internal_organs -= src

		if(detach)
			var/obj/item/organ/external/affected = owner.get_organ(parent_organ)
			if(affected)
				affected.internal_organs -= src
				status |= ORGAN_CUT_AWAY
	..()

/obj/item/organ/internal/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)

	if(!istype(target))
		return 0

	if(status & ORGAN_CUT_AWAY)
		return 0 //organs don't work very well in the body when they aren't properly attached

	// robotic organs emulate behavior of the equivalent flesh organ of the species
	if(BP_IS_ROBOTIC(src) || !species)
		species = target.species

	..()

	set_next_think(0)
	target.internal_organs |= src
	affected.internal_organs |= src
	target.internal_organs_by_name[organ_tag] = src
	return 1

/obj/item/organ/internal/die()
	..()
	if((status & ORGAN_DEAD) && dead_icon)
		icon_state = dead_icon

/obj/item/organ/internal/remove_rejuv()
	if(owner)
		owner.internal_organs -= src
		owner.internal_organs_by_name -= organ_tag
		while(null in owner.internal_organs)
			owner.internal_organs -= null
		var/obj/item/organ/external/E = owner.organs_by_name[parent_organ]
		if(istype(E)) E.internal_organs -= src
	..()

/obj/item/organ/internal/is_usable()
	return ..() && !is_broken()

/obj/item/organ/internal/robotize()
	..()
	min_bruised_damage += 5
	min_broken_damage += 10

	override_species_icon = TRUE

	if(override_organic_icon)
		icon = 'icons/mob/human_races/organs/cyber.dmi'

/obj/item/organ/internal/proc/getToxLoss()
	if(BP_IS_ROBOTIC(src))
		return damage * 0.5
	return damage

/obj/item/organ/internal/proc/bruise()
	damage = max(damage, min_bruised_damage)

/obj/item/organ/internal/proc/is_damaged()
	return damage > 0

/obj/item/organ/internal/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/internal/take_general_damage(amount, silent = FALSE)
	take_internal_damage(amount, silent)

/obj/item/organ/internal/proc/take_internal_damage(amount, silent = FALSE)
	if(owner?.status_flags & GODMODE)
		return 0
	if(BP_IS_ROBOTIC(src))
		damage = between(0, src.damage + (amount * 0.8), max_damage)
	else
		damage = between(0, src.damage + amount, max_damage)

		//only show this if the organ is not robotic
		if(owner && can_feel_pain() && parent_organ && (amount > 5 || prob(10)))
			var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
			if(parent && !silent)
				var/degree = ""
				if(is_bruised())
					degree = " a lot"
				if(damage < 5)
					degree = " a bit"
				owner.custom_pain("Something inside your [parent.name] hurts[degree].", amount, affecting = parent)

// Slowly heals towards 0 damage if not bruised, or towards min_bruised_damage if already bruised.
/obj/item/organ/internal/proc/autoheal()
	if(!damage)
		return

	if(BP_IS_ROBOTIC(src))
		return // Flesh is superior.

	if(status & ORGAN_DEAD)
		return

	if(damage >= max_damage)
		return

	var/heal_value = autoheal_value * owner.coagulation

	if(damage >= min_broken_damage)
		damage = max(min_broken_damage, damage - heal_value)
	else if(damage >= min_bruised_damage)
		damage = max(min_bruised_damage, damage - heal_value)
	else
		damage = max(0, damage - heal_value)

	return

/obj/item/organ/internal/emp_act(severity)
	if(owner?.status_flags & GODMODE)
		return 0
	if(!BP_IS_ROBOTIC(src))
		return
	switch(severity)
		if(1)
			take_internal_damage(9)
		if(2)
			take_internal_damage(3)
		if(3)
			take_internal_damage(1)

// Things we should do if we are a foreign organ. Used only by lings' biostructures for now.
/obj/item/organ/internal/proc/handle_foreign()
	return
