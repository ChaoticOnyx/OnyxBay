
/datum/reagent/metastases
	name = "Metastases"
	description = "Liquid, which is an extremely contagious metastases of cosmic cancer."
	taste_description = "bitterness"
	taste_mult = 3
	reagent_state = LIQUID
	color = "#bf0000"
	overdose = REAGENTS_OVERDOSE * 0.5
	scannable = 5
	flags = IGNORE_MOB_SIZE
	metabolism = REM * 0.25

/datum/reagent/metastases/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		M.adjustToxLoss(0.05)

/datum/reagent/metastases/overdose(var/mob/living/carbon/M, var/alien)
	..()
	if(ishuman(M))
		M.adjustToxLoss(0.5)
		var/C = 0
		for (var/obj/item/organ/internal/cancer/CAN in M.contents)
			C++
		if(prob(15))
			if(C < 6)
				new /obj/item/organ/internal/cancer(M)
			infect(M)

/datum/reagent/metastases/proc/infect(var/mob/living/carbon/A)
	var/l = list()
	for(var/mob/living/carbon/M in orange(1,A))
		var/obj/item/organ/internal/cancer/CAN = locate() in M.contents
		if(!CAN)
			l += M
	var/k = pick(l)
	if((infection_chance(k, "Airborne") == 0) && (infection_chance(k, "Contact") == 0))
		return
	var/obj/item/organ/internal/cancer/OW = locate() in A.contents
	if(prob(50) && (OW.Adjacent(k)))
		new /obj/item/organ/internal/cancer(k)

/obj/item/organ/internal/cancer
	name = "strange biostructure"
	desc = "Strange abhorrent biostructure of unknown origins. Is that an alien organ, a xenoparasite or some sort of space cancer? Is that normal to bear things like that inside you?"
	icon_state = "Strange_biostructure"
	dead_icon = "Strange_biostructure_dead"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_CANCER
	parent_organ = BP_CHEST
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	relative_size = 60
	var/chance = 0
	var/infectious = 0
	detectability = FALSE
	var/weakness = /datum/reagent/paracetamol

/obj/item/organ/internal/cancer/New(var/mob/living/carbon/holder)
	var/obj/item/organ/internal/cancer/CAN = locate() in (holder.contents - src)
	if(CAN)
		src.weakness = CAN.weakness
	else
		var/list/chem_cure = list(
		/datum/reagent/tramadol,
		/datum/reagent/paracetamol,
		/datum/reagent/arithrazine,
		/datum/reagent/spaceacillin,
		/datum/reagent/antidexafen,
		)
		src.weakness = pick(chem_cure)
	..()
	parent_organ = pick(BP_CHEST, BP_HEAD, BP_GROIN)


/obj/item/organ/internal/cancer/Process()

	..()
/*
	var/C = 0
	for (var/obj/item/organ/internal/cancer/CAN in owner.contents)
		C++
	if((!infectious) && prob(chance) && (C < 6))
		new /obj/item/organ/internal/cancer(owner)
*/
	var/datum/reagent/R = weakness
	if(owner.reagents.get_reagent_amount(weakness) > R.overdose)
		src.take_damage(5)
	if(infectious)
		owner.reagents.add_reagent(/datum/reagent/metastases, 0.5)
	else
		chance += 0.5
		if(chance > 50)
			infectious = 1
		owner.reagents.add_reagent(/datum/reagent/metastases, 0.1)
/*
	owner.adjustToxLoss(0.01)

/obj/item/organ/internal/cancer/proc/infect()
	var/l = list()
	for(var/mob/living/carbon/M in orange(1,owner))
		var/obj/item/organ/internal/cancer/CAN = locate() in M.contents
		if(!CAN)
			l += M
	var/k = pick(l)
	if((infection_chance(k, "Airborne") == 0) && (infection_chance(k, "Contact") == 0))
		return
	if(prob(50) && (Adjacent(k)))
		new /obj/item/organ/internal/cancer(k)
		*/