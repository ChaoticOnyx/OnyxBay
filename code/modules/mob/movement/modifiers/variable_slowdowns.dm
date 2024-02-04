/datum/movespeed_modifier/equipment_slowdown
	variable = TRUE

/mob/proc/update_equipment_slowdown()
	return

/mob/living/carbon/human/update_equipment_slowdown()
	var/equipment_slowdown = -1
	for(var/slot = slot_first to slot_last)
		var/obj/item/I = get_equipped_item(slot)
		if(istype(I))
			var/item_slowdown = 0
			item_slowdown += I.slowdown_general
			item_slowdown += I.slowdown_per_slot[slot]
			item_slowdown += I.slowdown_accessory
			if(item_slowdown > 0)
				var/size_mod = 0
				if(!(mob_size == MOB_MEDIUM))
					size_mod = log(2, mob_size / MOB_MEDIUM)
				if(species.strength + size_mod + 1 > 0)
					item_slowdown = item_slowdown / (species.strength + size_mod + 1)
				else
					item_slowdown = item_slowdown - species.strength - size_mod
			equipment_slowdown += item_slowdown

	if(body_build.equipment_modifier > 0) // Is our equipment_modifier a good thing?
		if(equipment_slowdown + 1 > body_build.equipment_modifier)  // Lowering equipment cooldown if it's higher
			equipment_slowdown += equipment_slowdown - body_build.equipment_modifier // than equipment_modifier, ignoring it otherwise
		else
			equipment_slowdown = -1 // Since default equipment_slowdown is -1 for some reason
	else if(equipment_slowdown > -1)
		equipment_slowdown += equipment_slowdown - body_build.equipment_modifier

	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/equipment_slowdown, slowdown = equipment_slowdown)

/datum/movespeed_modifier/health_deficiency_slowdown
	variable = TRUE

/mob/living/proc/update_health_slowdown()
	var/health_deficiency_percent = 100 - (health / maxHealth) * 100
	var/calculated_slowdown
	if(health_deficiency_percent >= 40)
		calculated_slowdown = health_deficiency_percent / 25
	else
		calculated_slowdown = 0

	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/health_deficiency_slowdown, slowdown = calculated_slowdown)

/datum/movespeed_modifier/bodytemp_slowdown
	variable = TRUE

/mob/living/proc/update_bodytemp_slowdown()
	var/calculated_slowdown = 0
	if(bodytemperature < 283.222)
		calculated_slowdown = (283.222 - bodytemperature) / 10 * 1.75

	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bodytemp_slowdown, slowdown = calculated_slowdown)

/datum/movespeed_modifier/pain_slowdown
	variable = TRUE

/mob/proc/update_pain_slowdown()
	return

/mob/living/carbon/human/update_pain_slowdown()
	var/calculated_slowdown
	var/shock = get_shock()
	if(shock >= 10)
		calculated_slowdown = (shock / 10)
	else
		calculated_slowdown = 0

	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/pain_slowdown, slowdown = calculated_slowdown)

/datum/movespeed_modifier/organ_movespeed
	variable = TRUE

/mob/living/carbon/human/proc/update_organ_movespeed()
	var/calculated_slowdown = 0
	var/list/organ_list = BP_LIMBS_LOCOMOTION
	if(istype(buckled, /obj/structure/bed/chair/wheelchair))
		organ_list = BP_LIMBS_ARM_LOCOMOTION

	for(var/organ_name in organ_list)
		var/obj/item/organ/external/E = get_organ(organ_name)
		if(!E)
			calculated_slowdown += 4
		else
			calculated_slowdown += E.movement_tally

	if(calculated_slowdown == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/organ_movespeed)
	else
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/organ_movespeed, slowdown = calculated_slowdown)

/datum/movespeed_modifier/nutrition_slowdown
	variable = TRUE

/datum/movespeed_modifier/pull_slowdown
	variable = TRUE
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/mob/proc/update_pull_slowdown(atom/pulled)
	if(!istype(pulled)) // Just in case
		return

	var/calculated_slowdown = 0
	if(istype(pulled, /obj))
		var/obj/O = pulled
		if(O.pull_slowdown == PULL_SLOWDOWN_WEIGHT)
			calculated_slowdown += between(0, O.w_class, ITEM_SIZE_GARGANTUAN) / 5
		else
			calculated_slowdown += O.pull_slowdown
	else if(istype(pulled, /mob))
		var/mob/M = pulled
		calculated_slowdown += max(0, M.mob_size) / MOB_MEDIUM * (M.lying ? 2 : 0.5)
	else
		calculated_slowdown += 1

	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/pull_slowdown, slowdown = calculated_slowdown)

/datum/movespeed_modifier/chem_slowdown
	variable = TRUE

/datum/movespeed_modifier/hyperzine_boost
	priority = MOVESPEED_PRIORITY_LAST
	variable = TRUE
	flags = MOVESPEED_FLAG_OVERRIDING_SPEED

/mob/proc/update_chem_slowdown(ce_effect)
	return

/mob/living/carbon/update_chem_slowdown(ce_effect)
	switch(ce_effect)
		if(CE_SPEEDBOOST)
			var/calculated_slowdown = max((cached_slowdown - chem_effects[CE_SPEEDBOOST]), (config.movement.run_speed/2))
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hyperzine_boost, slowdown = calculated_slowdown)
		if(CE_SLOWDOWN)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/chem_slowdown, slowdown = chem_effects[CE_SLOWDOWN])
		if(null)
			remove_movespeed_modifier(/datum/movespeed_modifier/hyperzine_boost)
			remove_movespeed_modifier(/datum/movespeed_modifier/chem_slowdown)

/datum/movespeed_modifier/purge_slowdown
	priority = MOVESPEED_PRIORITY_LAST
	variable = TRUE
	flags = MOVESPEED_FLAG_SPACEMOVEMENT
