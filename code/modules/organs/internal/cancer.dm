
/datum/reagent/metastases
	name = "Metastases"
	description = "Liquid, which is an extremely contagious metastases of cosmic cancer."
	taste_description = "bitterness"
	taste_mult = 3
	reagent_state = LIQUID
	color = "#bf0000"
	overdose = REAGENTS_OVERDOSE * 0.5
	scannable = TRUE
	flags = IGNORE_MOB_SIZE
	metabolism = REM

/datum/reagent/metastases/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		M.adjustToxLoss(0.05)

/datum/reagent/metastases/overdose(var/mob/living/carbon/M, var/alien)
	..()
	if(ishuman(M))
		M.adjustToxLoss(0.1)
		var/C = 0
		var/P = 0
		for (var/obj/item/organ/internal/cancer/CAN in M.contents)
			C++
			if(CAN.infectious)
				P++
		if(prob(15))
			if(C < 6)
				new /obj/item/organ/internal/cancer(M)
			else
				if((P == 6) && prob(10))
					decay(M)
					if(prob(10))
						var/mob/living/carbon/human/H = M
						H.zombify()
			infect(M)



/datum/reagent/metastases/proc/decay(owner)
	var/mob/living/carbon/T = owner
	var/list/detachable_limbs = T.organs.Copy()
	for (var/obj/item/organ/external/E in detachable_limbs)
		if (E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.organ_tag == BP_CHEST || E.organ_tag == BP_GROIN || E.is_stump())
			detachable_limbs -= E
	var/obj/item/organ/external/organ_to_remove = pick(detachable_limbs)
	if(!organ_to_remove)
		return 0
	if(!T.organs.Find(organ_to_remove))
		return 0

	T.visible_message("<span class='danger'>\the [organ_to_remove] ripping off from [T].</span>", \
					"<span class='danger'>We begin ripping our \the [organ_to_remove].</span>")

	playsound(T.loc, 'sound/effects/bonebreak1.ogg', 100, 1)
	var/mob/living/L

	if(organ_to_remove.organ_tag == BP_L_LEG || organ_to_remove.organ_tag == BP_R_LEG)
		L = new /mob/living/simple_animal/hostile/little_changeling/leg_chan(get_turf(T))
	else if(organ_to_remove.organ_tag == BP_L_ARM || organ_to_remove.organ_tag == BP_R_ARM)
		L = new /mob/living/simple_animal/hostile/little_changeling/arm_chan(get_turf(T))
	else if(organ_to_remove.organ_tag == BP_HEAD)
		L = new /mob/living/simple_animal/hostile/little_changeling/head_chan(get_turf(T))

	organ_to_remove.droplimb(1)
	qdel(organ_to_remove)

	var/mob/living/carbon/human/H = T
	if(istype(H))
		H.regenerate_icons()


/datum/reagent/decomposition_products
	name = "Decomposition products"
	description = "The fluid resulting from the active decay of mutated biological tissues."
	taste_description = "bitterness"
	taste_mult = 3
	reagent_state = LIQUID
	color = "#bf0000"
	scannable = TRUE
	flags = IGNORE_MOB_SIZE
	metabolism = REM * 0.5

/datum/reagent/decomposition_products/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		for(var/obj/item/organ/internal/cancer/OW in M.contents)
			OW.chance -= 2
		M.adjustToxLoss(0.06)

/datum/reagent/metastases/proc/infect(var/mob/living/carbon/A)
	var/list/l = list()
	for(var/mob/living/carbon/human/M in orange(1,A))
		var/obj/item/organ/internal/cancer/CAN = locate() in M.contents
		if(!CAN)
			l += M
	if(l.len == 0)
		return
	var/mob/living/carbon/human/k = pick(l)
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
	var/next_time = 0

/obj/item/organ/internal/cancer/New(var/mob/living/carbon/human/holder)
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
	if(!owner)
		return
	for(var/datum/reagent/R in owner.reagents)
		if(istype(R, weakness) && (R.overdose < owner.reagents.get_reagent_amount(R)))
			src.take_damage(5)
			owner.reagents.add_reagent(/datum/reagent/decomposition_products, 0.2)
			if(world.time >= next_time)
				next_time = world.time + rand(200,800)
				to_chat(owner, "<span class='warning'>You feel sick.</span>")

	if(infectious)
		owner.reagents.add_reagent(/datum/reagent/metastases, 0.5)
	else
		chance += 0.05
		if(chance > 50)
			infectious = 1
		owner.reagents.add_reagent(/datum/reagent/metastases, 0.1)


/obj/item/organ/internal/proc/list_of_identify_organs(dict_key,var/mob/living/carbon/ow)
	var/R = ow.internal_organs_by_name[dict_key]
	ow.internal_organs_by_name[dict_key] = list()
	return ow.internal_organs_by_name[dict_key] += R + src