/proc/sort_surgeries()
	var/gap = length(GLOB.surgery_steps)
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= length(GLOB.surgery_steps); i++)
			var/datum/surgery_step/l = GLOB.surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = GLOB.surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				GLOB.surgery_steps.Swap(i, gap + i)
				swapped = 1

//check if mob is lying down on something we can operate him on.
/proc/can_operate(mob/living/carbon/M, mob/living/carbon/user)
	var/turf/T = get_turf(M)
	if(locate(/obj/machinery/optable, T))
		. = TRUE
	if(locate(/obj/structure/bed, T))
		. = TRUE
	if(locate(/obj/structure/table, T))
		. = TRUE
	if(locate(/obj/effect/rune/, T))
		. = TRUE

	if(M == user)
		var/hitzone = check_zone(user.zone_sel.selecting)
		var/list/badzones = list(BP_HEAD)
		if(user.hand)
			badzones += BP_L_ARM
			badzones += BP_L_HAND
		else
			badzones += BP_R_ARM
			badzones += BP_R_HAND
		if(hitzone in badzones)
			return FALSE

/proc/agjust_organ_image(obj/item/organ/O)
	var/image/I = image(icon = O.icon, icon_state = O.icon_state)
	I.overlays = O.overlays
	I.pixel_y = -5
	return I
