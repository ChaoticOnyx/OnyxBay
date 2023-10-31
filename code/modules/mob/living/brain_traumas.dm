////////////////////////////////////////TRAUMAS/////////////////////////////////////////

/mob/living/carbon/proc/get_traumas()
	. = list()
	var/obj/item/organ/internal/cerebrum/brain/B = internal_organs_by_name[BP_BRAIN]
	if(B)
		. = B.traumas

/mob/living/carbon/proc/has_trauma_type(brain_trauma_type, resilience)
	var/obj/item/organ/internal/cerebrum/brain/B = internal_organs_by_name[BP_BRAIN]
	if(B)
		. = B.has_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/obj/item/organ/internal/cerebrum/brain/B = internal_organs_by_name[BP_BRAIN]
	if(B)
		var/list/arguments = list()
		if(args.len > 2)
			arguments = args.Copy(3)
		. = B.brain_gain_trauma(trauma, resilience, arguments)

/mob/living/carbon/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/internal/cerebrum/brain/B = internal_organs_by_name[BP_BRAIN]
	if(B)
		. = B.gain_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/internal/cerebrum/brain/B = internal_organs_by_name[BP_BRAIN]
	if(B)
		. = B.cure_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_all_traumas(resilience)
	var/obj/item/organ/internal/cerebrum/brain/B = internal_organs_by_name[BP_BRAIN]
	if(B)
		. = B.cure_all_traumas(resilience)
