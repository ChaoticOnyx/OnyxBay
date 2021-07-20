var/list/organ_cache = list()

/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	germ_level = 0
	w_class = ITEM_SIZE_TINY
	dir = SOUTH

	// Strings.
	var/organ_tag = "organ"           // Unique identifier.
	var/parent_organ = BP_CHEST       // Organ holding this object.

	// Status tracking.
	var/status = 0                    // Various status flags (such as robotic)
	var/vital                         // Lose a vital limb, die immediately.

	// Reference data.
	var/mob/living/carbon/human/owner // Current mob owning the organ.
	var/datum/dna/dna                 // Original DNA.
	var/datum/species/species         // Original species.

	// Damage vars.
	var/damage = 0                    // Current damage to the organ
	var/min_broken_damage = 30     	  // Damage before becoming broken
	var/max_damage             	  // Damage cap
	var/rejecting                     // Is this organ already being rejected?

	var/death_time

	var/food_organ_type				  // path of food made from organ, ex.
	var/obj/item/weapon/reagent_containers/food/snacks/food_organ
	var/disable_food_organ = FALSE // used to override food_organ's creation and using

/obj/item/organ/return_item()
	return food_organ

/obj/item/organ/proc/organ_eaten(mob/user)
	qdel(src)

/obj/item/organ/proc/update_food_from_organ()
	food_organ.SetName(name)
	food_organ.appearance = src
	reagents.trans_to(food_organ, reagents.total_volume)

/obj/item/organ/Destroy()
	owner = null
	dna = null
	QDEL_NULL(food_organ)
	return ..()

/obj/item/organ/proc/update_health()
	return

/obj/item/organ/proc/is_broken()
	return (damage >= min_broken_damage || (status & ORGAN_CUT_AWAY) || (status & ORGAN_BROKEN))

/obj/item/organ/New(mob/living/carbon/holder)
	..(holder)

	if(food_organ_type && !disable_food_organ)
		food_organ = new food_organ_type(src)

	if(max_damage)
		min_broken_damage = Floor(max_damage / 2)
	else
		max_damage = min_broken_damage * 2

	if(istype(holder))
		owner = holder
		w_class = max(w_class + mob_size_difference(holder.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller organs.

		if(holder.dna)
			dna = holder.dna.Clone()
			species = all_species[dna.species]
		else
			species = all_species[SPECIES_HUMAN]
			log_debug("[src] spawned in [holder] without a proper DNA.")

	if(dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.b_type

	create_reagents(5 * (w_class-1)**2)
	reagents.add_reagent(/datum/reagent/nutriment/protein, reagents.maximum_volume)

	src.after_organ_creation()

	update_icon()

/obj/item/organ/proc/set_dna(datum/dna/new_dna)
	if(new_dna)
		dna = new_dna.Clone()
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA.Cut()
		blood_DNA[dna.unique_enzymes] = dna.b_type
		species = all_species[new_dna.species]

/obj/item/organ/proc/die()
	damage = max_damage
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	death_time = world.time
	if(owner && vital)
		owner.death()

/obj/item/organ/Process()
	if(loc != owner)
		owner = null

	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return
	// Don't process if we're in a freezer, an MMI or a stasis bag.or a freezer or something I dunno
	if(is_preserved())
		return
	//Process infections
	if (BP_IS_ROBOTIC(src) || (owner && owner.species && (owner.species.species_flags & SPECIES_FLAG_IS_PLANT)))
		germ_level = 0
		return

	if(!owner && reagents)
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
		if(B && prob(40))
			reagents.remove_reagent(/datum/reagent/blood,0.1)
			blood_splatter(src,B,1)
		if(config.organs_decay)
			take_general_damage(rand(1,3))
		germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(4,8)
		if(germ_level >= INFECTION_LEVEL_THREE)
			germ_level += rand(1,2)
		if(germ_level >= INFECTION_LEVEL_FOUR)
			die()

	else if(owner && owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()
		handle_rejection()
		handle_germ_effects()

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

	if(food_organ)
		update_food_from_organ()

/obj/item/organ/proc/cook_organ()
	die()

/obj/item/organ/proc/is_preserved()
	if(istype(loc,/obj/item/organ))
		var/obj/item/organ/O = loc
		return O.is_preserved()
	else
		return (istype(loc,/obj/item/device/mmi) || istype(loc,/obj/structure/closet/body_bag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer) || istype(loc,/obj/item/weapon/storage/box/freezer) || istype(loc,/mob/living/simple_animal/hostile/little_changeling))

/obj/item/organ/examine(mob/user)
	. = ..()
	. += "\n[show_decay_status(user)]"
	if(get_dist(src, user) > 1)
		return
	. += food_organ.get_bitecount()

/obj/item/organ/proc/show_decay_status(mob/user)
	if(status & ORGAN_DEAD)
		return SPAN_NOTICE("\The [src] looks severely damaged.")

/obj/item/organ/proc/handle_germ_effects()
	//** Handle the effects of infections

	var/virus_immunity = owner.virus_immunity()

	var/antibiotics = owner.chem_effects[CE_ANTIBIOTIC]

	if(germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(virus_immunity * 0.3))
		germ_level--

	if(germ_level >= INFECTION_LEVEL_ONE/2)
		if(antibiotics < 5 && prob(round(germ_level/(INFECTION_LEVEL_TWO*0.015) * owner.immunity_weakness())))
			germ_level += round(M_EULER**(germ_level/1000) * owner.immunity_weakness())
		else // Will only trigger if immunity has hit zero. Once it does, 10x infection rate.
			germ_level += round(M_EULER**(germ_level/1000) * owner.immunity_weakness()) * 10

	if(germ_level >= INFECTION_LEVEL_ONE)
		if(owner.bodytemperature - T0C < 45.5)
			owner.bodytemperature += germ_level / 170

	if(germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		//spread germs
		if(antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(owner.immunity_weakness() * 0.3) ))
			parent.germ_level++

		if(prob(3))	//about once every 30 seconds
			take_general_damage(1,silent=prob(30))

	if(germ_level >= INFECTION_LEVEL_THREE)
		if(prob(6))
			take_general_damage(1, silent=prob(20))

	if(germ_level >= INFECTION_LEVEL_FOUR)
		if(prob(12))
			take_general_damage(1, silent=prob(15))

/obj/item/organ/proc/handle_rejection()
	// Process unsuitable transplants. TODO: consider some kind of
	// immunosuppressant that changes transplant data to make it match.
	if(owner.virus_immunity() < 10) //for now just having shit immunity will suppress it
		return
	if(BP_IS_ROBOTIC(src))
		return
	if(dna)
		if(!rejecting)
			if(owner.blood_incompatible(dna.b_type, species))
				rejecting = 1
		else
			rejecting++ //Rejection severity increases over time.
			if(rejecting % 10 == 0) //Only fire every ten rejection ticks.
				switch(rejecting)
					if(1 to 50)
						germ_level++
					if(51 to 200)
						germ_level += rand(1,2)
					if(201 to 500)
						germ_level += rand(2,3)
					if(501 to INFINITY)
						germ_level += rand(3,5)
						owner.reagents.add_reagent(/datum/reagent/toxin, rand(1,2))

/obj/item/organ/proc/receive_chem(chemical as obj)
	return 0

/obj/item/organ/proc/remove_rejuv()
	qdel(src)

/obj/item/organ/proc/rejuvenate(ignore_prosthetic_prefs = FALSE)
	damage = 0
	status = 0
	if(!ignore_prosthetic_prefs && owner && owner.client && owner.client.prefs && owner.client.prefs.real_name == owner.real_name)
		var/status = owner.client.prefs.organ_data[organ_tag]
		if(status == "assisted")
			mechassist()
		else if(status == "mechanical")
			robotize()

/obj/item/organ/proc/handle_antibiotics()
	if(!owner || !germ_level || BP_IS_ROBOTIC(src))
		return

	var/antibiotics = owner.chem_effects[CE_ANTIBIOTIC]
	if(!antibiotics)
		return

	germ_level -= Interpolate(antibiotics, 1, germ_level / (INFECTION_LEVEL_FOUR + 400))
	if(germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0 // cure instantly

/obj/item/organ/proc/take_general_damage(amount, silent = FALSE)
	CRASH("Not Implemented")

/obj/item/organ/proc/heal_damage(amount)
	damage = between(0, damage - round(amount, 0.1), max_damage)

/obj/item/organ/proc/robotize() //Being used to make robutt hearts, etc
	status = ORGAN_ROBOTIC

/obj/item/organ/proc/mechassist() //Used to add things like pacemakers, etc
	status = ORGAN_ASSISTED

/**
 *  Remove an organ
 *
 *  drop_organ - if true, organ will be dropped at the loc of its former owner
 */
/obj/item/organ/proc/removed(mob/living/user, drop_organ=1)

	if(!istype(owner))
		return

	if(drop_organ)
		dropInto(owner.loc)

	playsound(src, "crunch", rand(65, 80), FALSE)

	// Start processing the organ on his own
	START_PROCESSING(SSobj, src)
	rejecting = null
	if(!BP_IS_ROBOTIC(src))
		var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list //TODO fix this and all other occurences of locate(/datum/reagent/blood) horror
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			owner.vessel.trans_to(src, 5, 1, 1)

	if(owner && vital)
		if(user)
			admin_attack_log(user, owner, "Removed a vital organ ([src]).", "Had a vital organ ([src]) removed.", "removed a vital organ ([src]) from")
		owner.death()

	owner = null

/obj/item/organ/proc/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	owner = target
	forceMove(owner) //just in case
	if(BP_IS_ROBOTIC(src))
		set_dna(owner.dna)
	return 1

/obj/item/organ/attack(mob/target, mob/user)
	if(status & ORGAN_ROBOTIC || !istype(target) || !istype(user) || (user != target && user.a_intent == I_HELP))
		return ..()

	if(food_organ.bitecount == 0)
		if(alert("Do you really want to use this organ as food? It will be useless for anything else afterwards.",,"Ew, no.","Bon appetit!") == "Ew, no.")
			to_chat(user, SPAN_NOTICE("You successfully repress your cannibalistic tendencies."))
			return
		update_food_from_organ()
		cook_organ()

	if(QDELETED(src))
		return

	target.attackby(return_item(), user)

/obj/item/organ/proc/can_feel_pain()
	return (!BP_IS_ROBOTIC(src) && (!species || !(species.species_flags & SPECIES_FLAG_NO_PAIN)))

/obj/item/organ/proc/is_usable()
	return !(status & (ORGAN_CUT_AWAY|ORGAN_MUTATED|ORGAN_DEAD))

/obj/item/organ/proc/can_recover()
	return (!(status & ORGAN_DEAD) || death_time >= world.time - ORGAN_RECOVERY_THRESHOLD)

/obj/item/organ/proc/get_scan_results()
	. = list()
	if(BP_IS_ASSISTED(src))
		. += "Assisted"
	else if(BP_IS_ROBOTIC(src))
		. += "Mechanical"

	if(status & ORGAN_CUT_AWAY)
		. += "Severed"
	if(status & ORGAN_MUTATED)
		. += "Genetic Deformation"
	if(status & ORGAN_DEAD)
		if(can_recover())
			. += "Critical"
		else
			. += "Destroyed"
	switch (germ_level)
		if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 50)
			. += "Mild Infection I"
		if(INFECTION_LEVEL_ONE + 50 to INFECTION_LEVEL_ONE + 100)
			. += "Mild Infection II"
		if(INFECTION_LEVEL_ONE + 100 to INFECTION_LEVEL_TWO)
			. += "Mild Infection III"
		if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 100)
			. += "Acute Infection I"
		if(INFECTION_LEVEL_TWO + 100 to INFECTION_LEVEL_TWO + 200)
			. += "Acute Infection II"
		if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_THREE)
			. += "Acute Infection III"
		if(INFECTION_LEVEL_THREE to INFECTION_LEVEL_THREE + 100)
			. += "Septic I"
		if(INFECTION_LEVEL_THREE + 100 to INFECTION_LEVEL_THREE + 200)
			. += "Septic II"
		if(INFECTION_LEVEL_THREE + 200 to INFECTION_LEVEL_FOUR)
			. += "Septic III"
		if(INFECTION_LEVEL_FOUR to INFINITY)
			. += "Gangrene"
	if(rejecting)
		. += "Genetic Rejection"

// special organ instruction for correct functional
/obj/item/organ/proc/after_organ_creation()
	return

//used by stethoscope
/obj/item/organ/proc/listen()
	return
