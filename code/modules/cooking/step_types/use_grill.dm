//A cooking step that involves adding a reagent to the food.
/datum/cooking/recipe_step/use_grill
	class=CWJ_USE_GRILL
	auto_complete_enabled = TRUE
	var/time
	var/heat

//reagent_id: The id of the required reagent to be added, E.G. 'salt'.
//amount: The amount of the required reagent that needs to be added.
//base_quality_award: The quality awarded by following this step.
//our_recipe: The parent recipe object,
/datum/cooking/recipe_step/use_grill/New(set_heat, set_time, datum/cooking/recipe/our_recipe)



	time = set_time
	heat = set_heat

	desc = "Cook on a grill set to [heat] for [ticks_to_text(time)]."

	..(our_recipe)


/datum/cooking/recipe_step/use_grill/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)

	if(!istype(used_item, /obj/machinery/kitchen/grill))
		return CWJ_CHECK_INVALID

	return CWJ_CHECK_VALID

//Reagents are calculated prior to object creation
/datum/cooking/recipe_step/use_grill/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/vessel/cooking_container/container = tracker.holder_ref.resolve()

	var/obj/machinery/kitchen/grill/our_grill = used_item


	var/bad_cooking = 0
	for (var/key in container.grill_data)
		if (heat != key)
			bad_cooking += container.grill_data[key]

	bad_cooking = round(bad_cooking/(5 SECONDS))

	var/good_cooking = round(time/(3 SECONDS)) - bad_cooking + our_grill.quality_mod

	return clamp_quality(good_cooking)


/datum/cooking/recipe_step/use_grill/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker)
	return CWJ_SUCCESS

/datum/cooking/recipe_step/use_grill/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker)

	var/obj/item/reagent_containers/vessel/cooking_container/container = tracker.holder_ref.resolve()

	if(container.grill_data[heat] >= time)
		#ifdef CWJ_DEBUG
		log_debug("use_grill/is_complete() Returned True; comparing [heat]: [container.grill_data[heat]] to [time]")
		#endif
		return TRUE

	#ifdef CWJ_DEBUG
	log_debug("use_grill/is_complete() Returned False; comparing [heat]: [container.grill_data[heat]] to [time]")
	#endif
	return FALSE
