//A cooking step that involves using an item on the food.
var/list/hammering_tools = list(
	/obj/item/pickaxe/sledgehammer,
	/obj/item/shovel,
	/obj/item/wrench,
	/obj/item/storage/toolbox,
	)

/datum/cooking/recipe_step/use_tool
	class=CWJ_USE_ITEM
	var/tool_type
	var/tool_quality
	var/inherited_quality_modifier = 0.1


//item_type: The type path of the object we are looking for.
//base_quality_award: The quality awarded by following this step.
//our_recipe: The parent recipe object
/datum/cooking/recipe_step/use_tool/New(type, quality, datum/cooking/recipe/our_recipe)

	desc = "Use \a [type] tool of quality [quality] or higher."

	tool_type = type
	tool_quality = quality

	..(our_recipe)


/datum/cooking/recipe_step/use_tool/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	if(!istype(added_item, /obj/item ))
		return CWJ_CHECK_INVALID

	var/obj/item/our_tool = added_item
	// REVIEW make tool quality list
	switch(tool_type)
		if(QUALITY_CUTTING)
			if(!has_edge(our_tool))
				return CWJ_CHECK_INVALID
		if(QUALITY_HAMMERING)
			if(!is_type_in_list(our_tool, hammering_tools))
				return CWJ_CHECK_INVALID

	if(!(our_tool in tool_type))
		return CWJ_CHECK_INVALID

	return CWJ_CHECK_VALID

/datum/cooking/recipe_step/use_tool/follow_step(obj/added_item, obj/item/reagent_containers/vessel/cooking_container/container)
	var/obj/item/our_tool = added_item
	if(our_tool.tool_sound)
		playsound(usr.loc, our_tool.tool_sound, 50, 1)
	to_chat(usr, SPAN_NOTICE("You use the [added_item] according to the recipe."))

	/*REVIEW - No tool quality so comment that shit
	if(our_tool.get_tool_quality(tool_type) < tool_quality)
		return to_chat(usr, SPAN_NOTICE("The low quality of the tool hurts the quality of the dish."))
		*/

	return CWJ_SUCCESS

//Think about a way to make this more intuitive?
/datum/cooking/recipe_step/use_tool/calculate_quality(obj/added_item)
	/*REVIEW - No tool quality so comment that shit
	var/obj/item/our_tool = added_item
	var/raw_quality = (our_tool.get_tool_quality(tool_type) - tool_quality) * inherited_quality_modifier
	*/
	var/raw_quality = tool_quality * inherited_quality_modifier
	return clamp_quality(raw_quality)
