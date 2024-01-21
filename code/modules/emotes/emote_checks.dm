/proc/is_stat(stat, mob/M, intentional)
	if(M.stat > stat)
		if(intentional)
			to_chat(M, SPAN_NOTICE("You can't emote in this state."))
		return FALSE

	return TRUE

/proc/is_stat_or_not_intentional(stat, mob/M, intentional)
	if(!intentional)
		return TRUE

	return is_stat(stat, M, intentional)

/proc/is_species_not_flag(flag, mob/M, intentional)
	var/datum/species/S = all_species[M.get_species()]
	if(!S)
		return TRUE

	//if(S.flags[flag])
	//	if(intentional)
	//		to_chat(M, SPAN_NOTICE("Your species can't perform this emote."))
	//	return FALSE

	return TRUE

/proc/is_intentional_or_species_no_flag(flag, mob/M, intentional)
	if(intentional)
		return TRUE

	return is_species_not_flag(flag, M, intentional)

/proc/is_one_hand_usable(mob/M, intentional)
	if(M.restrained())
		if(intentional)
			to_chat(M, SPAN_NOTICE("You can't perform this emote while being restrained."))
		return FALSE

	if(!ishuman(M))
		return TRUE

	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/l_arm = H.get_organ(BP_L_ARM)
	var/obj/item/organ/external/r_arm = H.get_organ(BP_R_ARM)

	return (l_arm && l_arm.is_usable()) || (r_arm && r_arm.is_usable())

/proc/is_present_bodypart(zone, mob/M, intentional)
	if(!ishuman(M))
		return TRUE

	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/BP = H.get_organ(zone)
	if(!BP)
		if(intentional)
			to_chat(H, SPAN_NOTICE("You can't perform this emote without a [parse_zone(zone)]."))
		return FALSE

	return TRUE

/proc/is_not_species(species, mob/M, intentional)
	if(M.get_species() == species)
		if(intentional)
			to_chat(M, SPAN_NOTICE("Your species can't perform this emote."))
		return FALSE

	return TRUE

/proc/has_robot_module(module_type, mob/M, intentional)
	if(!isrobot(M))
		return FALSE

	var/mob/living/silicon/robot/R = M
	if(!istype(R.module, module_type))
		if(intentional)
			to_chat(R, SPAN_NOTICE("You do not have the required module for this emote."))
		return FALSE

	return TRUE

/proc/is_synth_or_robot(mob/living/M, intentional)
	if(!istype(M) || !M.isSynthetic())
		return FALSE

	return TRUE
