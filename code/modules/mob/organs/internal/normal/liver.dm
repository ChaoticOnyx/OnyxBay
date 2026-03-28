
/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_LIVER
	parent_organ = BP_CHEST
	min_bruised_damage = 20
	min_broken_damage = 45 // Also the amount of toxic damage it can store
	max_damage = 70
	relative_size = 40
	var/stored_tox = 0
	var/coagulation = COAGULATION_NORMAL
	var/filtering_efficiency = 3.0

/obj/item/organ/internal/liver/Initialize()
	. = ..()
	update_coagulation()

/obj/item/organ/internal/liver/robotize()
	. = ..()
	SetName("hepatic filter")
	icon_state = "liver-prosthetic"
	dead_icon = "liver-prosthetic-br"

/obj/item/organ/internal/liver/set_dna(datum/dna/new_dna)
	..()
	update_coagulation()

/obj/item/organ/internal/liver/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	owner?.coagulation = COAGULATION_NONE
	..()

/obj/item/organ/internal/liver/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	. = ..()
	if(. && owner)
		update_coagulation()

/obj/item/organ/internal/liver/proc/update_coagulation()
	if(species)
		coagulation = species.coagulation
	if(is_broken())
		coagulation = COAGULATION_NONE
	else if(is_bruised())
		coagulation = COAGULATION_WEAK
	return coagulation

/obj/item/organ/internal/liver/proc/store_tox(amount) // Store toxins up to min_broken_damage, return excessive toxins
	var/store_left = max(0, min_broken_damage - stored_tox)
	. = max(0, amount - store_left)
	stored_tox += amount - .

/obj/item/organ/internal/liver/think()
	..()

	if(!owner)
		return

	if(isundead(owner))
		return

	update_coagulation()

	// Update the filtering efficiency of the liver.
	filtering_efficiency = 3
	// Not enough to cease functions, but works at reduced efficiency..
	if(is_bruised())
		filtering_efficiency -= 1
	// That's where we're in trouble.
	if(is_broken())
		filtering_efficiency -= 1
	// Robotic organs filter better but don't get benefits from dylovene for filtering.
	if(BP_IS_ROBOTIC(src) || owner.chem_effects[CE_ANTITOX])
		filtering_efficiency += 1
	// Enough to get poisoned even w/ a healthy liver, unless it's robotic or dylovene-boosted.
	if(owner.chem_effects[CE_ALCOHOL_TOXIC])
		filtering_efficiency -= 2
	// Not enough to get poisoned when your liver is fine, but it's better not to touch booze when it's bruised.
	else if(owner.chem_effects[CE_ALCOHOL])
		filtering_efficiency -= 1

	// If the liver's not too busy, the body slowly regains its "anti-toxic shield".
	if(filtering_efficiency >= 2 && !owner.chem_effects[CE_TOXIN])
		stored_tox = max(damage, (stored_tox - filtering_efficiency * 0.1))

/obj/item/organ/internal/liver/die()
	..()
	if(status & ORGAN_DEAD)
		filtering_efficiency = 0

/obj/item/organ/internal/liver/autoheal()
	if(!damage)
		return

	if(BP_IS_ROBOTIC(src))
		return // Flesh is superior.

	var/heal_value = autoheal_value * owner.coagulation

	// Boost healing a bit if we're not busy. Livers regenerate well, after all.
	if(!(owner.chem_effects[CE_ALCOHOL] || owner.chem_effects[CE_TOXIN] || owner.radiation > SAFE_RADIATION_DOSE))
		heal_value *= 1.5

	if(damage >= min_bruised_damage)
		damage = max(min_bruised_damage, damage - heal_value)
		return

	damage = max(0, damage - heal_value)
	return
