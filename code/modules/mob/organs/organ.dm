var/list/organ_cache = list()

/obj/item/organ
	name = "organ"
	icon = 'icons/mob/human_races/organs/human.dmi'
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
	var/min_broken_damage = 0         // Damage before becoming broken
	var/max_damage = 60               // Damage cap
	var/rejecting                     // Is this organ already being rejected?
	var/no_pain = FALSE

	var/death_time
	var/start_robotized = FALSE

	var/food_organ_type				  // path of food made from organ, ex.
	var/obj/item/reagent_containers/food/food_organ
	var/disable_food_organ = FALSE // used to override food_organ's creation and using

	/// Currently implanted objects.
	var/list/implants = list()
	/// List of installed augmentations.
	var/list/organ_modules = list()
	/// Types of modules without which this organ will not work. Applies ONLY to prosthetic limbs.
	var/list/necessary_organ_modules

	var/max_module_size = 1
	var/occupied_space = 0

	drop_sound = SFX_DROP_FLESH
	pickup_sound = SFX_PICKUP_FLESH

/obj/item/organ/Initialize()
	. = ..()

	if(!min_broken_damage)
		min_broken_damage = Floor(max_damage / 2)

	if(ishuman(loc))
		owner = loc
		w_class = max(w_class + mob_size_difference(owner.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller organs.
		dna = owner.dna ? owner.dna.Clone() : null

	if(dna)
		species = all_species[dna.species]
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.b_type
	else
		species = all_species[SPECIES_HUMAN]
		log_debug("[src] spawned in [owner] without a proper DNA.")

	create_reagents(50 * (w_class-1)**2)
	reagents.add_reagent(/datum/reagent/nutriment/protein, reagents.maximum_volume)

	if(food_organ_type && !disable_food_organ)
		food_organ = new food_organ_type(src)

	if(start_robotized)
		robotize()

/obj/item/organ/Destroy()
	owner = null
	dna = null

	QDEL_NULL(food_organ)
	QDEL_NULL_LIST(organ_modules)
	QDEL_NULL_LIST(implants)

	if(ismob(loc))
		var/mob/M = loc
		M.drop(src, force = TRUE, changing_slots = TRUE) // Changing_slots prevents drop_sound from playing

	return ..()

/obj/item/organ/think()
	if(loc != owner)
		owner = null

	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	//Process infections
	if(BP_IS_ROBOTIC(src) || (owner?.species?.species_flags & SPECIES_FLAG_IS_PLANT))
		// If `think()` is called not by the owner in `handle_organs()` but on his own.
		if(NEXT_THINK)
			set_next_think(world.time + 1 SECOND)
		return

	if(owner)
		if(isundead(owner))
			if(NEXT_THINK)
				set_next_think(world.time + 1 SECOND)
			return
		if(owner.bodytemperature >= 170)
			handle_rejection()
	else if(reagents && !is_preserved()) // Disbloodied or frozen organs don't decay.
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
		if(B && prob(40))
			reagents.remove_reagent(/datum/reagent/blood, 0.1)
			blood_splatter(src, B, 1)
		if(config.health.organs_can_decay)
			take_general_damage(rand(1, 3))

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

	if(food_organ)
		update_food_from_organ()

	// If `think()` is called not by the owner in `handle_organs()` but on his own.
	if(NEXT_THINK)
		set_next_think(world.time + 1 SECOND)

/obj/item/organ/return_item()
	return food_organ

/obj/item/organ/proc/organ_eaten(mob/user)
	qdel(src)

/obj/item/organ/proc/update_food_from_organ()
	food_organ.SetName(name)
	food_organ.appearance = src
	reagents.trans_to(food_organ, reagents.total_volume)

/obj/item/organ/proc/is_broken()
	return (damage >= min_broken_damage || (status & ORGAN_CUT_AWAY) || (status & ORGAN_BROKEN))

/obj/item/organ/proc/set_dna(datum/dna/new_dna)
	if(!new_dna)
		return
	dna = new_dna.Clone()
	if(!blood_DNA)
		blood_DNA = list()
	blood_DNA.Cut()
	blood_DNA[dna.unique_enzymes] = dna.b_type
	species = all_species[new_dna.species]

/obj/item/organ/proc/die()
	if(status & ORGAN_DEAD)
		return FALSE // Already dead
	damage = max_damage
	status |= ORGAN_DEAD
	set_next_think(0)
	death_time = world.time
	if(owner && vital)
		owner.death()
	return TRUE

/obj/item/organ/proc/cook_organ()
	die()

/obj/item/organ/proc/is_preserved()
	if(istype(loc,/obj/item/organ))
		var/obj/item/organ/O = loc
		return O.is_preserved()
	else
		return (istype(loc,/obj/item/organ/internal/cerebrum/mmi) || istype(loc,/obj/structure/closet/body_bag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer) || istype(loc,/obj/item/storage/box/freezer) || istype(loc,/mob/living/simple_animal/hostile/little_changeling))

/obj/item/organ/examine(mob/user, infix)
	. = ..()

	. += show_decay_status(user)

	if(get_dist(src, user) > 1)
		return

	. += food_organ.get_bitecount()

/obj/item/organ/proc/show_decay_status(mob/user)
	if(status & ORGAN_DEAD)
		return SPAN_NOTICE("\The [src] looks severely damaged.")

/obj/item/organ/proc/handle_rejection()
	// Process unsuitable transplants. TODO: consider some kind of
	// immunosuppressant that changes transplant data to make it match.
	if(owner.virus_immunity() < 10) //for now just having shit immunity will suppress it
		if(rejecting)
			rejecting--
		return FALSE

	if(BP_IS_ROBOTIC(src))
		return FALSE

	if(!dna)
		return FALSE

	if(!rejecting)
		if(owner.blood_incompatible(dna.b_type, species))
			rejecting = 1
	else
		rejecting++

	return TRUE

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

/obj/item/organ/proc/take_general_damage(amount, silent = FALSE)
	CRASH("Not Implemented")

/obj/item/organ/proc/heal_damage(amount)
	damage = between(0, damage - round(amount, 0.1), max_damage)


/obj/item/organ/proc/robotize(company) //Being used to make robutt hearts, etc
	if(BP_IS_ROBOTIC(src))
		return FALSE

	status = ORGAN_ROBOTIC
	no_pain = TRUE
	if(owner?.isSynthetic()) // If owner becomes fully synthetic - he receives all corresponding emotes.
		owner.add_synth_emotes()

	return TRUE


/obj/item/organ/proc/mechassist() //Used to add things like pacemakers, etc
	status = ORGAN_ASSISTED

/**
 *  Remove an organ
 *
 *  drop_organ - if true, organ will be dropped at the loc of its former owner
 */
/obj/item/organ/proc/removed(mob/living/user, drop_organ = TRUE)
	if(!istype(owner))
		return

	if(drop_organ)
		dropInto(owner.loc)

	playsound(src, SFX_FIGHTING_CRUNCH, rand(65, 80), FALSE)

	// Start processing the organ on his own
	set_next_think(world.time)
	rejecting = null
	if(!BP_IS_ROBOTIC(src))
		var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list //TODO fix this and all other occurences of locate(/datum/reagent/blood) horror
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			owner.vessel.trans_to(src, 5, 1, 1)

	if(owner && vital)
		if(user)
			admin_attack_log(user, owner, "Removed a vital organ ([src]).", "Had a vital organ ([src]) removed.", "removed a vital organ ([src]) from")
		owner.death()

	for(var/obj/item/organ_module/module in organ_modules)
		module.organ_removed(src, owner)

	owner = null

/obj/item/organ/proc/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	if(QDELETED(target))
		qdel_self()
		return FALSE
	owner = target
	forceMove(owner) //just in case
	if(BP_IS_ROBOTIC(src))
		set_dna(owner.dna)
	for(var/obj/item/organ_module/module in organ_modules)
		module.organ_installed(src, owner)
	return TRUE

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
	return (!no_pain && owner && !owner.no_pain && (!species || !(species.species_flags & SPECIES_FLAG_NO_PAIN)))

/obj/item/organ/proc/is_usable()
	return (owner && !(status & (ORGAN_CUT_AWAY | ORGAN_MUTATED | ORGAN_DEAD)))

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

	if(rejecting)
		. += "Transplant Rejection"

	if(!istype(src, /obj/item/organ/external) && length(implants))
		var/unknown_body = 0
		for(var/I in implants)
			var/obj/item/implant/imp = I
			if(istype(imp) && imp.known)
				. += "[capitalize(imp.name)] implanted"
			else
				unknown_body++
		if(unknown_body)
			. += "Unknown body present"

//used by stethoscope
/obj/item/organ/proc/listen()
	return

/obj/item/organ/proc/get_contents()
	. = list()

	LAZYDISTINCTADD(., implants)
	LAZYDISTINCTADD(., organ_modules) // Should be covered by the above, but let's make sure.
	LAZYDISTINCTADD(., contents)

/obj/item/organ/proc/apply_snowflake(flags)
	if(flags & ORGAN_SNOWFLAKE_ROBOTIC)
		robotize()
	if(flags & ORGAN_SNOWFLAKE_NO_PAIN)
		no_pain = TRUE
