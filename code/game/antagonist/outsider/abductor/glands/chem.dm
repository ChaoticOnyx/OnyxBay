/obj/item/organ/internal/heart/gland/chem
	abductor_hint = "intrinsic pharma-provider. The abductee constantly produces random chemicals inside their bloodstream. They also quickly regenerate toxin damage."
	cooldown_low = 50
	cooldown_high = 50
	uses = -1
	icon_state = "viral"
	mind_control_uses = 3
	mind_control_duration = 1200
	var/list/possible_reagents = list()

/obj/item/organ/internal/heart/gland/chem/Initialize(mapload)
	. = ..()
	for(var/R in subtypesof(/datum/reagent))
		if(istype(R,/datum/reagent/adminordrazine)||istype(R,/datum/reagent/nanites))
			continue
		possible_reagents += R

/obj/item/organ/internal/heart/gland/chem/activate()
	var/chem_to_add = pick(possible_reagents)
	owner.reagents.add_reagent(chem_to_add, 2)
	var/to_heal = min(20, owner.getToxLoss())
	owner.adjustToxLoss(0 - to_heal)
	..()
