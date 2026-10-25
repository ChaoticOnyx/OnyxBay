GLOBAL_LIST_EMPTY(cwj_recipe_list)
GLOBAL_LIST_EMPTY(cwj_recipe_dictionary)
GLOBAL_LIST_EMPTY(cwj_step_dictionary)
GLOBAL_LIST_EMPTY(cwj_step_dictionary_ordered)
GLOBAL_LIST_EMPTY(cwj_optional_step_exclusion_dictionary)


/proc/ticks_to_text(ticks)
	var/seconds = round(ticks / (1 SECOND))
	if(seconds >= 60)
		var/minutes = round(seconds / 60)
		var/rem = seconds % 60
		if(rem)
			return "[minutes] minute[minutes > 1 ? "s" : ""] and [rem] second[rem > 1 ? "s" : ""]"
		return "[minutes] minute[minutes > 1 ? "s" : ""]"
	return "[seconds] second[seconds != 1 ? "s" : ""]"

/obj/item/proc/has_quality(quality_type)
	return get_tool_quality(quality_type) > 0

/obj/item/proc/get_tool_quality(quality_type)
	switch(quality_type)
		if(QUALITY_CUTTING)
			if(istype(src, /obj/item/material/kitchen/utensil/knife) || istype(src, /obj/item/material/knife) || istype(src, /obj/item/scalpel) || istype(src, /obj/item/circular_saw) || istype(src, /obj/item/material/hatchet))
				return 30
			if(sharp || edge)
				return 20
		if(QUALITY_HAMMERING)
			if(istype(src, /obj/item/material/kitchen/rollingpin))
				return 30
			if(force >= 10 && !sharp && !edge)
				return 15
		if(QUALITY_SAWING)
			if(istype(src, /obj/item/circular_saw) )
				return 30
			if(sharp && edge)
				return 20
	return 0

/proc/resolve_cwj_reagent_path(reagent_id)
	if(ispath(reagent_id))
		return reagent_id
	switch(reagent_id)
		if("water") return /datum/reagent/water
		if("sugar") return /datum/reagent/sugar
		if("flour") return /datum/reagent/nutriment/flour
		if("milk") return /datum/reagent/drink/milk
		if("soymilk") return /datum/reagent/drink/milk/soymilk
		if("cream") return /datum/reagent/drink/milk/cream
		if("coco") return /datum/reagent/nutriment/coco
		if("Chocolate") return /datum/reagent/nutriment/coco
		if("chocolate") return /datum/reagent/nutriment/coco
		if("hot_coco") return /datum/reagent/drink/hot_coco
		if("coffee") return /datum/reagent/caffeine/coffee
		if("tea") return /datum/reagent/drink/tea
		if("icetea") return /datum/reagent/drink/tea/icetea
		if("egg") return /datum/reagent/nutriment/protein/egg
		if("protein") return /datum/reagent/nutriment/protein
		if("nutriment") return /datum/reagent/nutriment
		if("honey") return /datum/reagent/nutriment/honey
		if("mayo") return /datum/reagent/nutriment/mayo
		if("ketchup") return /datum/reagent/nutriment/ketchup
		if("barbecue", "bbqsauce") return /datum/reagent/nutriment/barbecue
		if("cinnamonpowder") return /datum/reagent/nutriment/cinnamonpowder
		if("rice") return /datum/reagent/nutriment/rice
		if("slimejelly", "metroidjelly") return /datum/reagent/metroidjelly
		if("amatoxin") return /datum/reagent/toxin/amatoxin
		if("mindbreaker") return /datum/reagent/mindbreaker
		if("psilocybin", "psi_juice") return /datum/reagent/psilocybin
		if("pwine") return /datum/reagent/ethanol/wine/premium
		if("space_drugs") return /datum/reagent/space_drugs
		if("thermite") return /datum/reagent/thermite
		if("woodpulp") return /datum/reagent/woodpulp
		if("lean") return /datum/reagent/painkiller/opium
		if("Mustard") return /datum/reagent/nutriment/mustard
		if("mustard") return /datum/reagent/nutriment/mustard
		if("soysauce") return /datum/reagent/nutriment/soysauce
		if("vinegar") return /datum/reagent/nutriment/vinegar
		if("cookingoil") return /datum/reagent/nutriment/oil
		if("cornoil") return /datum/reagent/nutriment/oil/corn
		if(" oliveoil") return /datum/reagent/nutriment/oil/corn
		if("oliveoil") return /datum/reagent/nutriment/oil/corn
		if("sodiumchloride") return /datum/reagent/salt
		if("blackpepper") return /datum/reagent/blackpepper
		if("capsaicin") return /datum/reagent/capsaicin
		if("condensedcapsaicin") return /datum/reagent/capsaicin/condensed
		if("frostoil") return /datum/reagent/frostoil
		if("cheddar") return /datum/reagent/nutriment/cheddar
		if("batter") return /datum/reagent/nutriment/batter
		if("cakebatter") return /datum/reagent/nutriment/cakebatter
		if("dough") return /datum/reagent/nutriment/dough
		if("butter") return /datum/reagent/nutriment/butter
		if("cherryjelly") return /datum/reagent/nutriment/cherryjelly
		if(" peanutbutter") return /datum/reagent/nutriment/peanutbutter
		if("peanutbutter") return /datum/reagent/nutriment/peanutbutter
		if("vanilla") return /datum/reagent/nutriment/vanilla
		if("ramen") return /datum/reagent/drink/dry_ramen
		if("hot_ramen") return /datum/reagent/drink/hot_ramen
		if("hell_ramen") return /datum/reagent/drink/hell_ramen
		if("orangejuice") return /datum/reagent/drink/juice/orange
		if("lemonjuice") return /datum/reagent/drink/juice/lemon
		if("limejuice") return /datum/reagent/drink/juice/lime
		if("tomatojuice") return /datum/reagent/drink/juice/tomato
		if("berryjuice") return /datum/reagent/drink/juice/berry
		if("poisonberryjuice") return /datum/reagent/toxin/poisonberryjuice
		if("carrotjuice") return /datum/reagent/drink/juice/carrot
		if("bananajuice") return /datum/reagent/drink/juice/banana
		if("watermelonjuice") return /datum/reagent/drink/juice/watermelon
		if("potatojuice") return /datum/reagent/drink/juice/potato
		if("grapejuice") return /datum/reagent/drink/juice/grape
		if("pineapplejuice") return /datum/reagent/drink/juice/pineapple
		if("applejuice") return /datum/reagent/drink/juice/apple
		if("garlicjuice") return /datum/reagent/drink/juice/garlic
		if("onionjuice") return /datum/reagent/drink/juice/onion
		if("beer") return /datum/reagent/ethanol/beer
		if("wine") return /datum/reagent/ethanol/wine
		if("rum") return /datum/reagent/ethanol/rum
		if("vodka") return /datum/reagent/ethanol/vodka
		if("whiskey") return /datum/reagent/ethanol/whiskey
		if("tequila") return /datum/reagent/ethanol/tequilla
		if("vermouth") return /datum/reagent/ethanol/vermouth
		if("cognac") return /datum/reagent/ethanol/cognac
		if("ale") return /datum/reagent/ethanol/ale
		if("kahlua") return /datum/reagent/ethanol/kahlua
		if("gin") return /datum/reagent/ethanol/gin
		if("sake") return /datum/reagent/ethanol/sake
		if("absinthe") return /datum/reagent/ethanol/absinthe
		if("melonliquor") return /datum/reagent/ethanol/melonliquor
		if("bluecuracao") return /datum/reagent/ethanol/bluecuracao
		if("grenadine") return /datum/reagent/drink/grenadine
		if("cola") return /datum/reagent/drink/space_cola
		if("spacemountainwind") return /datum/reagent/drink/spacemountainwind
		if("dr_gibb") return /datum/reagent/drink/dr_gibb
		if("space_up") return /datum/reagent/drink/space_up
		if("lemon_lime") return /datum/reagent/drink/lemon_lime
		if("sodawater") return /datum/reagent/drink/sodawater
		if("tonic") return /datum/reagent/drink/tonic
		if("ice") return /datum/reagent/drink/ice
		if("blood") return /datum/reagent/blood
		if("carbon") return /datum/reagent/carbon
		if("iron") return /datum/reagent/iron
		if("gold") return /datum/reagent/gold
		if("silver") return /datum/reagent/silver
		if("phoron") return /datum/reagent/toxin/plasma
		if("plasma") return /datum/reagent/toxin/plasma
		if("toxin") return /datum/reagent/toxin
		if("Polyacid") return /datum/reagent/acid/polyacid
		if("pacid") return /datum/reagent/acid/polyacid
		if("sacid") return /datum/reagent/acid
		if("hclacid") return /datum/reagent/acid/hydrochloric
		if("biomatter") return /datum/reagent/nutriment/protein
		if("virion") return /datum/reagent/toxin
	return null

/proc/is_reagent_with_id_exist(reagent_id)
	var/rpath = resolve_cwj_reagent_path(reagent_id)
	return ispath(rpath, /datum/reagent)

/proc/initialize_cooking_recipes()
	//All combination path datums, save for the default recipes we don't want.
	var/list/recipe_paths = typesof(/datum/cooking_with_jane/recipe)
	recipe_paths -= /datum/cooking_with_jane/recipe
	for (var/path in recipe_paths)
		var/datum/cooking_with_jane/recipe/example_recipe
		try
			example_recipe = new path()
		catch(var/exception/e)
			log_debug("CWJ: failed to build recipe [path]: [e]")
			continue
		if(!GLOB.cwj_recipe_dictionary[example_recipe.cooking_container])
			GLOB.cwj_recipe_dictionary[example_recipe.cooking_container] = list()
		GLOB.cwj_recipe_dictionary[example_recipe.cooking_container]["[example_recipe.unique_id]"] = example_recipe

		GLOB.cwj_recipe_list += example_recipe
	createCookingCatalogs()

