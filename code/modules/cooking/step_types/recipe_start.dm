//The default starting step.
//Doesn't do anything, just holds the item.

/datum/cooking/recipe_step/start
	class = CWJ_START
	var/required_container

/datum/cooking/recipe_step/start/New(container)
	required_container = container
