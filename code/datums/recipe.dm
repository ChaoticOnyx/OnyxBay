/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * /datum/recipe by rastaf0            13 apr 2011 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This is powerful and flexible recipe system.
 * It exists not only for food.
 * supports both reagents and objects as prerequisites.
 * In order to use this system you have to define a deriative from /datum/recipe
 * * reagents are reagents. Acid, milc, booze, etc.
 * * items are objects. Fruits, tools, circuit boards.
 * * result is type to create as new object
 * * time is optional parameter, you shall use in in your machine,
 * * default /datum/recipe/ procs does not rely on this parameter.
 *
 *  Functions you need:
 *  /datum/recipe/proc/make(var/obj/container as obj)
 *    Creates result inside container,
 *    deletes prerequisite reagents,
 *    transfers reagents from prerequisite objects,
 *    deletes all prerequisite objects (even not needed for recipe at the moment).
 *
 *  /proc/select_recipe(list/datum/recipe/avaiable_recipes, obj/obj as obj, exact = 1)
 *    Wonderful function that select suitable recipe for you.
 *    obj is a machine (or magik hat) with prerequisites,
 *    exact = 0 forces algorithm to ignore superfluous stuff.
 *
 *
 *  Functions you do not need to call directly but could:
 *  /datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents)
 *  /datum/recipe/proc/check_items(var/obj/container as obj)
 *
 * */

#define RECIPE_MISMATCH   0
#define RECIPE_MATCH      1
#define RECIPE_MAXRESULT 20

/datum/recipe
	var/list/reagents // example: = list(/datum/reagent/drink/juice/berry = 5) // do not list same reagent twice
	var/list/items    // example: = list(/obj/item/crowbar, /obj/item/welder) // place /foo/bar before /foo
	var/list/fruit    // example: = list("fruit" = 3)
	var/result        // example: = /obj/item/reagent_containers/food/donut/normal
	var/time = 100    // 1/10 part of second
	var/amount = 1    // number of 'result' instances to spawn

/datum/recipe/proc/check_reagents(datum/reagents/available_reagents, exact)
	// The recipe doesn't require any reagents.
	if(!length(reagents))
		return exact ? RECIPE_MATCH : RECIPE_MAXRESULT

	// We have more/less types than needed.
	if(length(available_reagents.reagent_list) != reagents.len)
		return RECIPE_MISMATCH

	var/available_amount = 0
	var/required_amount = 0
	. = RECIPE_MAXRESULT

	for(var/reagent_type in reagents)
		required_amount = reagents[reagent_type]
		available_amount = available_reagents.get_reagent_amount(reagent_type)
		// Exact match.
		if(available_amount == required_amount)
			. = min(., 1)
			continue
		// Mismatch, and we need an exact amount.
		if(exact)
			return RECIPE_MISMATCH
		// Not enough.
		if(available_amount < required_amount)
			return RECIPE_MISMATCH
		// Checking if we can produce any extra results.
		. = min(., floor(available_amount / required_amount))

	return .

/datum/recipe/proc/check_items(obj/container, exact)
	// The recipe doesn't require any items or fruits.
	if(!length(items) && !length(fruit))
		return exact ? RECIPE_MATCH : RECIPE_MAXRESULT

	var/list/available_items = container.InsertedContents()
	// We don't have any items.
	if(!length(available_items))
		return RECIPE_MISMATCH

	var/alist/checklist = alist()
	if(length(items))
		for(var/item_type in items)
			if(checklist[item_type])
				checklist[item_type] += 1
			else
				checklist[item_type] = 1
	if(length(fruit))
		for(var/fruit_tag in fruit)
			checklist[fruit_tag] = fruit[fruit_tag]

	// Checking if we have any extra items not required by the recipe.
	for(var/obj/item/I in available_items)
		var/bad_item = TRUE
		if(istype(I, /obj/item/reagent_containers/food/grown))
			var/obj/item/reagent_containers/food/grown/G = I
			// Found some broken shit, aborting.
			if(!G.seed || !G.seed.kitchen_tag)
				return RECIPE_MISMATCH
			for(var/fruit_tag in checklist)
				if(ispath(fruit_tag))
					continue
				if(G.seed.kitchen_tag == fruit_tag)
					bad_item = FALSE
					break
		else
			for(var/item_type in checklist)
				if(!ispath(item_type))
					continue
				if(istype(I, item_type))
					bad_item = FALSE
					break

		if(bad_item)
			return RECIPE_MISMATCH

	. = RECIPE_MAXRESULT
	for(var/item_type in checklist)
		var/found_amount = 0

		if(ispath(item_type))
			for(var/thing in available_items)
				if(!istype(thing, item_type))
					continue
				found_amount += 1
		else
			for(var/thing in available_items)
				if(!istype(thing, /obj/item/reagent_containers/food/grown))
					continue
				var/obj/item/reagent_containers/food/grown/G = thing
				if(G.seed.kitchen_tag != item_type)
					continue
				found_amount += 1

		// Not enough.
		if(found_amount < checklist[item_type])
			return RECIPE_MISMATCH
		// Too much.
		if(exact && found_amount > checklist[item_type])
			return RECIPE_MISMATCH
		// Not a multiple, i.e. we need either 3 or 6 slabs of meat and we have 5.
		if(found_amount % checklist[item_type])
			return RECIPE_MISMATCH
		. = min(., found_amount / checklist[item_type])

	return .

//general version
/datum/recipe/proc/make(obj/container)
	var/obj/result_obj = new result(container)
	for(var/obj/item/I in (container.InsertedContents() - result_obj))
		I.return_item().reagents.trans_to_obj(result_obj, I.return_item().reagents.total_volume)
		qdel(I)
	container.reagents.clear_reagents()
	return result_obj

// Old version of the proc, adds up all the reagents (except nutriments) from the ingredients to the resulting food item.
/datum/recipe/proc/make_food_legacy(obj/container)
	if(!result)
		log_error("<span class='danger'>Recipe [type] is defined without a result, please bug this.</span>")

		return
	var/obj/result_obj = new result(container)
	for(var/obj/item/I in (container.InsertedContents() - result_obj))
		var/obj/item/O = I.return_item()
		if (O.reagents)
			O.reagents.del_reagent(/datum/reagent/nutriment)
			O.reagents.update_total()
			O.reagents.trans_to_obj(result_obj, O.reagents.total_volume)
		if(istype(I, /obj/item/holder/))
			var/obj/item/holder/H = I
			H.destroy_all()
		qdel(I)
	container.reagents.clear_reagents()
	return result_obj

// New version, only adds up "extra" reagents and supports multi-object output.
/datum/recipe/proc/make_food(obj/container, result_mult = 1, preserve_items = null)
	if(!result)
		log_error(SPAN("danger", "Recipe [type] is defined without a result, please bug this."))
		return

	var/list/result_reagents = list()
	var/list/result_objs = list()
	for(var/i = 1; i <= (amount * result_mult); i++)
		result_objs.Add(new result(container))

	if(result_objs[1].reagents?.reagent_list)
		for(var/datum/reagent/R in result_objs[1].reagents.reagent_list)
			result_reagents[R.type] = R.volume * amount * result_mult

	var/datum/reagents/add_up_reagents = new /datum/reagents(100 LITERS, GLOB.temp_reagents_holder)
	for(var/obj/item/I in (container.InsertedContents() - result_objs))
		var/obj/item/O = I.return_item()
		if(O.reagents)
			for(var/datum/reagent/R in O.reagents.reagent_list)
				// No water in my boiled eggs please.
				if(istype(R, /datum/reagent/water))
					continue
				// Fuck basic nutriments, child types are okay.
				if(R.type == /datum/reagent/nutriment)
					continue
				// Cooking proteins.
				if(istype(R, /datum/reagent/nutriment/protein))
					var/datum/reagent/nutriment/protein/P = R
					add_up_reagents.add_reagent((P.cooked_path ? P.cooked_path : P.type), P.volume)
					continue
				// Adding the reagent if it hasn't been caught by anything above.
				add_up_reagents.add_reagent(R.type, R.volume)

		if(istype(I, /obj/item/holder))
			var/obj/item/holder/H = I
			H.destroy_all()

		if(!length(preserve_items) || !preserve_items[I])
			qdel(I)

	for(var/datum/reagent/R in add_up_reagents.reagent_list)
		if(result_reagents[R.type] && result_reagents[R.type] >= R.volume)
			continue
		for(var/obj/result_obj in result_objs)
			add_up_reagents.trans_type_to(result_obj, R.type, round((R.volume - result_reagents[R.type]) / (amount * result_mult), 0.1))

	qdel(add_up_reagents)
	container.reagents.clear_reagents()
	return result_objs

/proc/select_recipe(list/datum/recipe/avaiable_recipes, obj/O, exact)
	var/alist/possible_recipes = alist()

	for(var/datum/recipe/recipe in avaiable_recipes)
		// Exact recipes do not allow any excessive ingredients.
		if(exact)
			if((recipe.check_reagents(O.reagents, TRUE) != RECIPE_MATCH) || (recipe.check_items(O, TRUE) != RECIPE_MATCH))
				continue
			possible_recipes[recipe] = 1
			continue

		// Nonexact recipes allow excessive ingredients, and will result in multiple results if there's enough of them..
		var/check_reagents = recipe.check_reagents(O.reagents)
		if(check_reagents < RECIPE_MATCH)
			continue
		var/check_items = recipe.check_items(O)
		if(check_items < RECIPE_MATCH)
			continue
		possible_recipes[recipe] = min(check_reagents, check_items)

	// Nothing
	if(!length(possible_recipes))
		return null

	// Let's select the most complicated recipe
	var/highest_count = 0
	for(var/datum/recipe/recipe in possible_recipes)
		var/count = ((recipe.items)?(recipe.items.len):0) + ((recipe.reagents)?(recipe.reagents.len):0) + ((recipe.fruit)?(recipe.fruit.len):0)
		if(count >= highest_count)
			highest_count = count
			. = list(recipe, possible_recipes[recipe])
	return .
