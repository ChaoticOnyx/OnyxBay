//Cooking
//A dictionary of unique step ids that point to other step IDs that should be EXCLUDED if it is present in a recipe_pointer's list of possible steps.
GLOBAL_LIST_EMPTY(cwj_optional_step_exclusion_dictionary)

//A dictionary of all recipes by the basic ingredient
//Format: {base_ingedient_type:{unique_id:recipe}}
GLOBAL_LIST_EMPTY(cwj_recipe_dictionary)

//A dictionary of all recipes full_stop. Used later for assembling the HTML list.
//Format: {recipe_type:{unique_id:recipe}}
GLOBAL_LIST_EMPTY(cwj_recipe_list)

//A dictionary of all steps held within all recipes
//Format: {unique_id:step}
GLOBAL_LIST_EMPTY(cwj_step_dictionary)

//An organized heap of recipes by class and grouping.
//Format: {class_of_step:{step_group_identifier:{unique_id:step}}}
GLOBAL_LIST_EMPTY(cwj_step_dictionary_ordered)
