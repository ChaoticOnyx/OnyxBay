//A cooking step that involves using an item on the food.
/datum/cooking_with_jane/recipe_step/use_item
	class=CWJ_USE_ITEM
	var/required_item_type
	var/exact_path = FALSE //Tests if the item has to be the EXACT ITEM PATH, or just a child of the item path.

//item_type: The type path of the object we are looking for.
//base_quality_award: The quality awarded by following this step.
//our_recipe: The parent recipe object
/datum/cooking_with_jane/recipe_step/use_item/New(item_type, datum/cooking_with_jane/recipe/our_recipe)
	#ifdef CWJ_DEBUG
	if(!ispath(item_type))
		log_debug("/datum/cooking_with_jane/recipe_step/add_item/New(): item [item_type] is not a valid path")
	#endif

	if(ispath(item_type, /atom))
		var/atom/example_item = item_type
		desc = "Apply \a [initial(example_item.name)]."

		required_item_type = item_type
		group_identifier = item_type
	#ifdef CWJ_DEBUG
	else
		log_debug("/datum/cooking_with_jane/recipe_step/add_item/New(): item [item_type] couldn't be created.")
	#endif
	..(our_recipe)


/datum/cooking_with_jane/recipe_step/use_item/check_conditions_met(obj/added_item, datum/cooking_with_jane/recipe_tracker/tracker)
	if(src.exact_path)
		if(added_item.type == required_item_type)
			return CWJ_CHECK_VALID
	else
		if(istype(added_item,required_item_type))
			return CWJ_CHECK_VALID
	return CWJ_CHECK_INVALID

//Think about a way to make this more intuitive?
/datum/cooking_with_jane/recipe_step/use_item/calculate_quality(obj/added_item)
	return clamp_quality(0)
