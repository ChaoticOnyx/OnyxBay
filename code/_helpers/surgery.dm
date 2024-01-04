/// Sorts GLOB surgeries list by priority.
/proc/sort_surgeries()
	var/gap = length(GLOB.surgery_steps)
	var/swapped = TRUE
	while(gap > 1 || swapped)
		swapped = FALSE
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= length(GLOB.surgery_steps); i++)
			var/datum/surgery_step/l = GLOB.surgery_steps[i]
			var/datum/surgery_step/r = GLOB.surgery_steps[gap + i]
			if(l.priority < r.priority)
				GLOB.surgery_steps.Swap(i, gap + i)
				swapped = TRUE

/// Creates and "centers" organ image for later use inside radial menu.
/proc/adjust_organ_image(obj/item/organ/O)
	var/image/I = image(icon = O.icon, icon_state = O.icon_state)
	I.CopyOverlays(O)
	I.pixel_y = -5
	return I
