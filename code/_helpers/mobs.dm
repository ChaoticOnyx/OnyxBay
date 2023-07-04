/atom/movable/proc/get_mob()
	return

/obj/mecha/get_mob()
	return occupant

/obj/vehicle/train/get_mob()
	return buckled_mob

/mob/get_selected_zone()
	return zone_sel.selecting

/mob/get_active_item()
	return get_active_hand()

/mob/get_mob()
	return src

/mob/living/bot/mulebot/get_mob()
	if(load && istype(load, /mob/living))
		return list(src, load)
	return src

//helper for inverting armor blocked values into a multiplier
#define blocked_mult(blocked) max(1 - (blocked/100), 0)

/proc/mobs_in_view(range, source)
	var/list/mobs = list()
	for(var/atom/movable/AM in view(range, source))
		var/M = AM.get_mob()
		if(M)
			mobs += M

	return mobs

/proc/random_hair_style(gender, species = SPECIES_HUMAN)
	var/h_style = "Bald"

	var/datum/species/mob_species = all_species[species]
	var/list/valid_hairstyles = mob_species.get_hair_styles()
	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style

/proc/random_facial_hair_style(gender, species = SPECIES_HUMAN)
	var/f_style = "Shaved"

	var/datum/species/mob_species = all_species[species]
	var/list/valid_facialhairstyles = mob_species.get_facial_hair_styles(gender)
	if(valid_facialhairstyles.len)
		f_style = pick(valid_facialhairstyles)

		return f_style

/proc/sanitize_name(name, species = SPECIES_HUMAN)
	var/datum/species/current_species
	if(species)
		current_species = all_species[species]

	return current_species ? current_species.sanitize_name(name) : sanitizeName(name)

/proc/random_name(gender, species = SPECIES_HUMAN)

	var/datum/species/current_species
	if(species)
		current_species = all_species[species]

	if(!current_species)
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	else
		return current_species.get_random_name(gender)

/proc/random_skin_tone(datum/species/current_species)
	var/species_tone = current_species ? 35 - current_species.max_skin_tone() : -185
	switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
		if("caucasian")		. = -10
		if("afroamerican")	. = -115
		if("african")		. = -165
		if("latino")		. = -55
		if("albino")		. = 34
		else				. = rand(species_tone,34)

	return min(max(. + rand(-25, 25), species_tone), 34)

/proc/skintone2racedescription(tone)
	switch (tone)
		if(30 to INFINITY)		return "albino"
		if(20 to 30)			return "pale"
		if(5 to 15)				return "light skinned"
		if(-10 to 5)			return "white"
		if(-25 to -10)			return "tan"
		if(-45 to -25)			return "darker skinned"
		if(-65 to -45)			return "brown"
		if(-INFINITY to -65)	return "black"
		else					return "unknown"

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"

/proc/RoundHealth(health)
	var/list/icon_states = icon_states('icons/mob/huds/hud.dmi')
	for(var/icon_state in icon_states)
		if(health >= text2num(icon_state))
			return icon_state
	return icon_states[icon_states.len] // If we had no match, return the last element

//checks whether this item is a module of the robot it is located in.
/proc/is_robot_module(obj/item/thing)
	if (!thing || !istype(thing.loc, /mob/living/silicon/robot))
		return 0
	var/mob/living/silicon/robot/R = thing.loc
	return (thing in R.module.modules)

/proc/get_exposed_defense_zone(atom/movable/target)
	return pick(BP_HEAD, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_CHEST, BP_GROIN)

/proc/do_mob(atom/movable/affecter, mob/target, time = 30, target_zone = 0, uninterruptible = 0, progress = 1, incapacitation_flags = INCAPACITATION_DEFAULT)
	if(!affecter || !target)
		return 0
	var/mob/user = affecter
	var/is_mob_type = istype(user)
	var/user_loc = affecter.loc
	var/target_loc = target.loc

	var/holding = affecter.get_active_item()

	if(istype(user,/mob/living))
		var/mob/living/L = user
		for(var/datum/modifier/actionspeed/ASM in L.modifiers)
			time = time * ASM.actionspeed_coefficient

	var/datum/progressbar/progbar
	if(is_mob_type && progress)
		progbar = new(user, time, target)

	var/endtime = world.time+time
	var/starttime = world.time
	. = 1
	while (world.time < endtime)

		stoplag(1)

		if(progbar)
			progbar.update(world.time - starttime)

		if(!affecter || !target)
			. = 0
			break

		if(uninterruptible)
			continue

		if(!affecter || (is_mob_type && user.incapacitated(incapacitation_flags)) || affecter.loc != user_loc)
			. = 0
			break

		if(target.loc != target_loc)
			. = 0
			break

		if(affecter.get_active_item() != holding)
			. = 0
			break

		if(target_zone && affecter.get_selected_zone() != target_zone)
			. = 0
			break

	if(progbar)
		qdel(progbar)

/proc/do_after(mob/user, delay, atom/target = null, needhand = 1, progress = 1, incapacitation_flags = INCAPACITATION_DEFAULT, same_direction = 0, can_move = 0)
	if(!user)
		return 0
	var/atom/target_loc = null
	var/target_type = null

	var/original_dir = user.dir

	if(target)
		target_loc = target.loc
		target_type = target.type

	var/atom/original_loc = user.loc

	var/holding = user.get_active_hand()

	if(istype(user,/mob/living))
		var/mob/living/L = user
		for(var/datum/modifier/actionspeed/ASM in L.modifiers)
			delay = delay * ASM.actionspeed_coefficient

	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, delay, target)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = 1
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)

		if(!user || user.incapacitated(incapacitation_flags) || (user.loc != original_loc && !can_move) || (same_direction && user.dir != original_dir))
			. = 0
			break

		if(target_loc && (!target || QDELETED(target) || target_loc != target.loc || target_type != target.type))
			. = 0
			break

		if(needhand)
			if(user.get_active_hand() != holding)
				. = 0
				break

	if (progbar)
		qdel(progbar)

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(istype(H.species, species_datum))
			. = TRUE

/proc/able_mobs_in_oview(origin)
	var/list/mobs = list()
	for(var/mob/living/M in oview(origin)) // Only living mobs are considered able.
		if(!M.is_physically_disabled())
			mobs += M
	return mobs

// Returns true if M was not already in the dead mob list
/mob/proc/switch_from_living_to_dead_mob_list()
	remove_from_living_mob_list()
	. = add_to_dead_mob_list()

// Returns true if M was not already in the living mob list
/mob/proc/switch_from_dead_to_living_mob_list()
	remove_from_dead_mob_list()
	. = add_to_living_mob_list()

// Returns true if the mob was in neither the dead or living list
/mob/proc/add_to_living_mob_list()
	return FALSE
/mob/living/add_to_living_mob_list()
	if((src in GLOB.living_mob_list_) || (src in GLOB.dead_mob_list_))
		return FALSE
	GLOB.living_mob_list_ += src
	return TRUE

// Returns true if the mob was removed from the living list
/mob/proc/remove_from_living_mob_list()
	return GLOB.living_mob_list_.Remove(src)

// Returns true if the mob was in neither the dead or living list
/mob/proc/add_to_dead_mob_list()
	CAN_BE_REDEFINED(TRUE)

	SEND_SIGNAL(src, SIGNAL_MOB_DEATH, src)
	SEND_GLOBAL_SIGNAL(SIGNAL_MOB_DEATH, src)

	return FALSE

/mob/living/add_to_dead_mob_list()
	if((src in GLOB.living_mob_list_) || (src in GLOB.dead_mob_list_))
		return FALSE

	..()
	GLOB.dead_mob_list_ += src

	return TRUE

// Returns true if the mob was removed form the dead list
/mob/proc/remove_from_dead_mob_list()
	return GLOB.dead_mob_list_.Remove(src)

/mob/proc/can_block_magic()
	return FALSE
//Find a dead mob with a brain and client.
/proc/find_dead_player(find_key, include_observers = 0)
	if(isnull(find_key))
		return

	var/mob/selected = null

	if(include_observers)
		for(var/mob/M in GLOB.player_list)
			if((!M.is_ooc_dead()) || (!M.client))
				continue
			if(M.ckey == find_key)
				selected = M
				break
	else
		for(var/mob/living/M in GLOB.player_list)
			//Dead people only thanks!
			if((!M.is_ooc_dead()) || (!M.client))
				continue
			//They need a brain!
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.should_have_organ(BP_BRAIN) && !H.has_brain())
					continue
			if(M.ckey == find_key)
				selected = M
				break

	return selected

// Returns a worn item in target zone, if any.
/proc/get_target_clothes(mob/living/carbon/human/target, target_zone)
	if(!target)
		return
	if(!ishuman(target))
		return
	if(!target_zone)
		return

	. = list()
	switch(target_zone)
		if(BP_HEAD)
			if(target.head)
				. += target.head
		if(BP_MOUTH)
			if(istype(target.head, /obj/item/clothing/head/helmet/space))
				. += target.head
			else if(target.wear_mask)
				. += target.wear_mask
		if(BP_EYES)
			if(istype(target.head, /obj/item/clothing/head/helmet/space))
				. += target.head
			else if(target.glasses)
				. += target.glasses

		if(BP_CHEST, BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)
			if(target.wear_suit)
				. += target.wear_suit
			if(target.w_uniform)
				. += target.w_uniform
		if(BP_GROIN)
			if(target.wear_suit)
				. += target.wear_suit
			if(target.w_uniform)
				. += target.w_uniform
			if(istype(target.belt, /obj/item/storage))
				. += target.belt

		if(BP_L_FOOT, BP_R_FOOT)
			if(target.shoes)
				. += target.shoes
		if(BP_L_HAND, BP_L_HAND)
			if(target.gloves)
				. += target.gloves

/proc/organ_name_by_zone(mob/living/carbon/human/target, target_zone)
	if(!target)
		return
	if(!target_zone)
		return

	var/obj/item/organ/O = target.organs_by_name[target_zone]
	return O ? O.name : target_zone
