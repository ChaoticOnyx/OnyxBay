//A cooking step that involves using SPECIFICALLY Grown foods
/datum/cooking/recipe_step/add_produce
	class=CWJ_ADD_PRODUCE
	var/required_produce_type
	var/base_potency
	var/reagent_skip = FALSE
	var/inherited_quality_modifier

	var/list/exclude_reagents = list()

/datum/cooking/recipe_step/add_produce/New(produce, datum/cooking/recipe/our_recipe)
	if(!SSplants)
		CRASH("/datum/cooking/recipe_step/add_produce/New: SSplants not initialized! Exiting.")
	if(produce && SSplants && SSplants.seeds[produce])
		desc = "Add \a [produce] into the recipe."
		required_produce_type = produce
		group_identifier = produce

		//Get tooltip image for plants
		var/datum/seed/seed = SSplants.seeds[produce]
		var/icon_key = "fruit-[seed.get_trait(TRAIT_PRODUCT_ICON)]-[seed.get_trait(TRAIT_PRODUCT_COLOUR)]-[seed.get_trait(TRAIT_PLANT_COLOUR)]"
		if(SSplants.plant_icon_cache[icon_key])
			tooltip_image = SSplants.plant_icon_cache[icon_key]
		else
			log_debug("[seed] is missing it's icon to add to tooltip_image")
		base_potency = seed.get_trait(TRAIT_POTENCY)
	else
		CRASH("/datum/cooking/recipe_step/add_produce/New: Seed [produce] not found. Exiting.")
	..(base_quality_award, our_recipe)

/datum/cooking/recipe_step/add_produce/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	#ifdef CWJ_DEBUG
	log_debug("Called add_produce/check_conditions_met for [added_item] against [required_produce_type]")
	#endif

	if(!istype(added_item, /obj/item/reagent_containers/food/grown))
		return CWJ_CHECK_INVALID

	var/obj/item/reagent_containers/food/grown/added_produce = added_item

	if(added_produce.plantname == required_produce_type)
		return CWJ_CHECK_VALID

	return CWJ_CHECK_INVALID

/datum/cooking/recipe_step/add_produce/calculate_quality(obj/added_item, datum/cooking/recipe_tracker/tracker)

	var/obj/item/reagent_containers/food/grown/added_produce = added_item

	var/potency_raw = round(base_quality_award + (added_produce.potency - base_potency) * inherited_quality_modifier)

	return clamp_quality(potency_raw)

/datum/cooking/recipe_step/add_produce/follow_step(obj/added_item, datum/cooking/recipe_tracker/tracker)
	#ifdef CWJ_DEBUG
	log_debug("Called: /datum/cooking/recipe_step/add_produce/follow_step")
	#endif
	var/obj/item/container = tracker.holder_ref.resolve()
	if(container)
		if(usr.can_unequip(added_item))
			usr.drop(added_item, container)
		else
			added_item.forceMove(container)
	return CWJ_SUCCESS
