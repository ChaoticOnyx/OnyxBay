// TODO: IF YOU HAVE NOTHING TO DO, SORT DAT SHIT

//Example Recipes
/datum/cooking/recipe/steak_stove

	//Name of the recipe. If not defined, it will just use the name of the product_type
	name="Stove-Top cooked Steak"

	//The recipe will be cooked on a pan
	cooking_container = PAN

	//The product of the recipe will be a steak.
	product_type = /obj/item/reagent_containers/food/meatsteak

	//The product will have it's initial reagents wiped, prior to the recipe adding in reagents of its own.
	replace_reagents = FALSE

	step_builder = list(

		//Butter your pan by adding a slice of butter, and then melting it. Adding the butter unlocks the option to melt it on the stove.
		CWJ_BEGIN_OPTION_CHAIN,
		//base - the lowest amount of quality following this step can award.
		//reagent_skip - Exclude the added item's reagents from being included the product
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/butterslice, base=10),

		//Melt the butter into the pan by cooking it on a stove set to Low for 10 seconds
		list(CWJ_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS),
		CWJ_END_OPTION_CHAIN,

		//A steak is needed to start the meal.
		//qmod- Half of the food quality of the parent will be considered.
		//exclude_reagents- Blattedin and Carpotoxin will be filtered out of the steak. EXCEPT THIS IS ERIS, WE EMBRACE THE ROACH, and has thus been removed from every
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		//Add some mushrooms to give it some zest. Only one kind is allowed!
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_PRODUCE_OPTIONAL, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "reishi", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "amanita", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "plumphelmet", qmod=0.4),
		CWJ_END_EXCLUSIVE_OPTIONS,

		//Beat that meat to increase its quality
		list(CWJ_USE_TOOL_OPTIONAL, QUALITY_HAMMERING, 15),

		//You can add up to 3 units of honey to increase the quality. Any more will negatively impact it.
		//base- for CWJ_ADD_REAGENT, the amount that this step will award if followed perfectly.
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 3, base=3),

		//You can add capaicin or wine, but not both
		//prod_desc- A description appended to the resulting product.
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/capsaicin, 5, base=6, prod_desc="The steak was Spiced with chili powder."),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/ethanol/wine, 5, remain_percent=0.1 ,base=6, prod_desc="The steak was sauteed in wine"),
		CWJ_END_EXCLUSIVE_OPTIONS,

		//Cook on a stove, at medium temperature, for 30 seconds
		list(CWJ_USE_STOVE, J_MED, 30 SECONDS)
	)

//**Meat and Seafood**//
//Missing: cubancarp, friedchicken, tonkatsu, enchiladas, monkeysdelight, fishandchips, katsudon, fishfingers,
/datum/cooking/recipe/donkpocket //Special interactions in recipes_microwave.dm, not sure if this is going to function as expected
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/donkpocket

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5)
	)

/datum/cooking/recipe/donkpocket //Special interactions in recipes_microwave.dm, not sure if this is going to function as expected
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/donkpocket

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5)
	)

/datum/cooking/recipe/cooked_cutlet
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/cutlet
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/rawcutlet, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/cooked_faggot
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/faggot
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/rawfaggot, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_LO, 20 SECONDS)
	)

/datum/cooking/recipe/cooked_patty
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/patty
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/patty_raw, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_GRILL, J_LO, 10 SECONDS)
	)

/datum/cooking/recipe/chickensteak
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/chickensteak

	replace_reagents = FALSE

	step_builder = list(
		CWJ_BEGIN_OPTION_CHAIN,
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/butterslice, base=10),
		list(CWJ_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS),
		CWJ_END_OPTION_CHAIN,
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/chickenbreast, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_PRODUCE_OPTIONAL, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "reishi", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "amanita", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "plumphelmet", qmod=0.4),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 3, base=3),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/capsaicin, 5, base=6, prod_desc="The chicken was Spiced with chili powder."),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/drink/juice/lemon, 5, remain_percent=0.1 ,base=3, prod_desc="The chicken was sauteed in lemon juice"),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_USE_STOVE, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/porkchops
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/porkchop

	replace_reagents = FALSE

	step_builder = list(
		CWJ_BEGIN_OPTION_CHAIN,
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/butterslice, base=10),
		list(CWJ_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS),
		CWJ_END_OPTION_CHAIN,
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/pork, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_PRODUCE_OPTIONAL, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "reishi", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "amanita", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "plumphelmet", qmod=0.4),
		CWJ_END_EXCLUSIVE_OPTIONS,
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/capsaicin, 5, base=6, prod_desc="The pork was Spiced with chili powder."),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 5, remain_percent=0.1 ,base=3, prod_desc="The pork was glazed with honey"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/barbecue, 3, remain_percent=0.5 ,base=8, prod_desc="The pork was layered with BBQ sauce"),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_USE_STOVE, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/roastchicken
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/roastchicken
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/chicken, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/stuffing, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/tofurkey //Not quite meat but cooked similar to roast chicken
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/tofurkey
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/stuffing, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/boiled_egg
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/boiledegg
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/friedegg_basic
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/friedegg
	step_builder = list(

		CWJ_BEGIN_OPTION_CHAIN,
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/butterslice, base=10),
		list(CWJ_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS),
		CWJ_END_OPTION_CHAIN,

		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_USE_STOVE, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/bacon
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/bacon
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/rawbacon, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 1, base=1),
		list(CWJ_USE_OVEN, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/baconegg
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/baconeggs
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/friedegg, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_USE_OVEN, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/benedict
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/benedict
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/protein/egg, 3),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 3, base=3),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledegg, qmod=0.5),
		list(CWJ_USE_OVEN, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/omelette
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/omelette
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 2),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 3, base=3),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_LO, 10 SECONDS)
	)

/datum/cooking/recipe/taco
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/taco
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tortilla),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_PRODUCE, "corn"),
		list(CWJ_ADD_PRODUCE, "cabbage"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)


/datum/cooking/recipe/sausage
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/sausage
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/rawfaggot),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/rawbacon),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_USE_GRILL, J_MED, 10 SECONDS)
	)

/datum/cooking/recipe/wingfangchu
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/wingfangchu
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/xeno, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/soysauce, 5),
		list(CWJ_USE_TOOL, QUALITY_CUTTING, 1)
	)

/datum/cooking/recipe/sashimi
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/sashimi
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/carpmeat, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/carpmeat, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/soysauce, 5),
		list(CWJ_USE_TOOL, QUALITY_CUTTING, 1)
	)

/datum/cooking/recipe/chawanmushi
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/chawanmushi
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/soysauce, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_USE_OVEN, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/kabob
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/meatkabob
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/stack/rods = 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_USE_GRILL, J_MED, 20 SECONDS)
	)

/datum/cooking/recipe/tofukabob
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/tofukabob
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/stack/rods = 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_USE_GRILL, J_MED, 20 SECONDS)
	)

/datum/cooking/recipe/humankabob
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/meatkabob
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/stack/rods = 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/human, qmod=0.5, prod_desc="The kabob has some strange sweet meat"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/human, qmod=0.5),
		list(CWJ_USE_GRILL, J_MED, 20 SECONDS)
	)

//**Cereals and Grains**//
//missing: poppyprezel
/datum/cooking/recipe/bread
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/bread
	recipe_guide = "Put dough in an oven, bake for 30 seconds on medium."
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/meatbread
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/meatbread
	recipe_guide = "Put dough in an oven, bake for 30 seconds on medium."
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/xenomeatbread
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/xenomeatbread
	recipe_guide = "Put dough in an oven, bake for 30 seconds on medium."
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/xeno),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/xeno),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/tofubread
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/tofubread
	recipe_guide = "Put dough in an oven, bake for 30 seconds on medium."
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/creamcheesebread
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/creamcheesebread
	recipe_guide = "Put dough in an oven, bake for 30 seconds on medium."
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/bananabread
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/bananabread

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 2),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 15),
		list(CWJ_ADD_PRODUCE, "banana", 1),
		list(CWJ_USE_OVEN, J_MED, 40 SECONDS)
	)
/datum/cooking/recipe/baguette
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/baguette
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/dough, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/cracker
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/cracker
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/bun
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/bun
	product_count = 3
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1),
		list(CWJ_USE_OVEN, J_HI, 5 SECONDS)
	)

/datum/cooking/recipe/flatbread
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/flatbread
	product_count = 3
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1),
		list(CWJ_USE_OVEN, J_HI, 5 SECONDS)
	)

/datum/cooking/recipe/twobread
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/twobread
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/ethanol/wine, 5)
	)

/datum/cooking/recipe/pancakes
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/pancakes
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 3, base=3),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5, base=1),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/flour, 5, base=1),
		list(CWJ_USE_OVEN, J_LO, 15 SECONDS)
	)



/datum/cooking/recipe/jelliedtoast
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/jelliedtoast/cherry
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cherryjelly, 5),
		list(CWJ_USE_TOOL, QUALITY_CUTTING, 1)
	)

/datum/cooking/recipe/slimetoast
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/jelliedtoast/metroid
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/metroidjelly, 5),
		list(CWJ_USE_TOOL, QUALITY_CUTTING, 1)
	)

/datum/cooking/recipe/stuffing
	cooking_container = BOWL
	product_type = /obj/item/reagent_containers/food/stuffing
	product_count = 3
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/bread, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 5),
	)

/datum/cooking/recipe/tortilla
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/tortilla
	product_count = 3
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/flatdoughslice),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/flatdoughslice),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/flatdoughslice),
		list(CWJ_USE_OVEN, J_HI, 5 SECONDS)
	)

/datum/cooking/recipe/muffin
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/muffin
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/chocolatebar, qmod=0.5),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/boiledrice
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/boiledrice
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/rice, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_HI, 15 SECONDS)
	)

/datum/cooking/recipe/ricepudding
	cooking_container = BOWL
	product_type = /obj/item/reagent_containers/food/ricepudding
	step_builder = list(
		list(CWJ_ADD_REAGENT, , 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/drink/milk/cream, 10),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledrice, qmod=0.5)
	)



//**Sandwiches**//
/datum/cooking/recipe/sandwich_basic
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "cabbage"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, qmod=0.5, desc="Add any kind of cooked cutlet."),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5)
	)

/datum/cooking/recipe/metroidsandwich
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/jellysandwich/metroid
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/metroidjelly, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5)
	)

/datum/cooking/recipe/cherrysandwich
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/jellysandwich/cherry
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cherryjelly, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5)
	)

/datum/cooking/recipe/blt
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/blt
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "cabbage"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, qmod=0.5, desc="Add any kind of cooked cutlet."),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5)
	)

/datum/cooking/recipe/grilledcheese
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/grilledcheese
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/slice/bread, qmod=0.5),
		list(CWJ_USE_GRILL, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/toastedsandwich
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/toastedsandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sandwich, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_GRILL, J_LO, 15 SECONDS)
	)

//**Pastas**//
/datum/cooking/recipe/raw_spaghetti
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/spaghetti
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/flour, 1, base=1),
		list(CWJ_USE_TOOL, QUALITY_CUTTING, 1)
	)

/datum/cooking/recipe/boiledspaghetti
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/boiledspaghetti
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/spaghetti, qmod=0.5),
		list(CWJ_USE_STOVE, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/pastatomato
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/pastatomato
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledspaghetti, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "tomato", qmod=0.4),
		list(CWJ_ADD_PRODUCE, "tomato", qmod=0.4),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/meatballspaghetti
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/faggotspaghetti
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledspaghetti, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato", qmod=0.4),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/spesslaw
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/spesslaw
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledspaghetti, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato", qmod=0.4),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS)
	)

//**Pizzas**//
/datum/cooking/recipe/pizzamargherita
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/pizza/margherita
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "tomato", qmod=0.2),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/flour, 5),
		list(CWJ_USE_OVEN, J_MED, 35 SECONDS)
	)

/datum/cooking/recipe/meatpizza
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/pizza/meatpizza
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/flour, 5),
		list(CWJ_ADD_PRODUCE, "tomato", qmod=0.2),
		list(CWJ_USE_OVEN, J_MED, 35 SECONDS)
	)

/datum/cooking/recipe/mushroompizza
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/pizza/mushroompizza
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/flour, 5),
		list(CWJ_ADD_PRODUCE, "tomato", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_USE_OVEN, J_MED, 35 SECONDS)
	)

/datum/cooking/recipe/vegetablepizza
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/pizza/vegetablepizza
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/flour, 5),
		list(CWJ_ADD_PRODUCE, "tomato", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "eggplant", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "cabbage", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "carrot", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_USE_OVEN, J_MED, 35 SECONDS)
	)

//**Pies**//
/datum/cooking/recipe/meatpie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/meatpie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/tofupie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/tofupie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/xemeatpie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/xemeatpie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/xeno, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/pie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/pie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "banana", qmod=0.2),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/cherrypie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/cherrypie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "cherry", qmod=0.2),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/berryclafoutis
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/berryclafoutis
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "berries", qmod=0.2),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/amanita_pie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/amanita_pie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/toxin/amatoxin, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/plump_pie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/plump_pie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "plumphelmet", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/pumpkinpie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/pumpkinpie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "pumpkin", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/applepie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/applepie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "apple", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

//**Salads**//
/datum/cooking/recipe/tossedsalad
	cooking_container = BOWL
	product_type = /obj/item/reagent_containers/food/tossedsalad
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "cabbage", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "cabbage", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "carrot", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "apple", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/stuffing, base=10),
		list(CWJ_ADD_PRODUCE, "tomato", qmod=0.2),
	)

/datum/cooking/recipe/aesirsalad
	cooking_container = BOWL
	product_type = /obj/item/reagent_containers/food/aesirsalad
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "ambrosiadeus", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/stuffing, base=10),
		list(CWJ_ADD_PRODUCE, "goldapple", qmod=0.2),
	)

/datum/cooking/recipe/validsalad
	cooking_container = BOWL
	product_type = /obj/item/reagent_containers/food/validsalad
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "ambrosia", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "ambrosia", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "ambrosia", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/stuffing, base=5),
		list(CWJ_ADD_PRODUCE, "potato", qmod=0.2),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
	)
//**Soups**// Possibly replaced by Handyman's Soup project, which'll be based on cauldron soup kitchen aesthetic
/datum/cooking/recipe/tomatosoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/tomatosoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/drink/milk/cream, 5, base=3, prod_desc="The soup turns a lighter red and thickens with the cream."),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 5 ,base=5, prod_desc="The thickens as the honey mixes in."),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_USE_STOVE, J_LO, 30 SECONDS)
	)

/datum/cooking/recipe/meatballsoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/faggotsoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/faggot, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "carrot"),
		list(CWJ_ADD_PRODUCE, "potato"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_USE_STOVE, J_LO, 30 SECONDS)
	)

/datum/cooking/recipe/vegetablesoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/vegetablesoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "carrot"),
		list(CWJ_ADD_PRODUCE, "potato"),
		list(CWJ_ADD_PRODUCE, "eggplant"),
		list(CWJ_ADD_PRODUCE, "cabbage"),
		list(CWJ_USE_STOVE, J_LO, 30 SECONDS)
	)

/datum/cooking/recipe/nettlesoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/nettlesoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "potato"),
		list(CWJ_ADD_PRODUCE, "nettle"),
		list(CWJ_USE_STOVE, J_LO, 30 SECONDS)
	)

/datum/cooking/recipe/wishsoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/wishsoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 20),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/coldchili
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/coldchili
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "icechili"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_USE_STOVE, J_LO, 30 SECONDS)
	)

/datum/cooking/recipe/hotchili
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/hotchili
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "chili"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_USE_STOVE, J_LO, 30 SECONDS)
	)

/datum/cooking/recipe/bearchili
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/bearchili
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "chili"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bearmeat, qmod=0.5),
		list(CWJ_USE_STOVE, J_LO, 30 SECONDS)
	)

/datum/cooking/recipe/stew
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/stew
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "carrot"),
		list(CWJ_ADD_PRODUCE, "potato"),
		list(CWJ_ADD_PRODUCE, "mushrooms"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/milosoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/milosoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/soydope, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/soydope, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/beetsoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/beetsoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_PRODUCE, "whitebeet"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "potato"),
		list(CWJ_ADD_PRODUCE, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/drink/milk/cream, 5, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1, base=1),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/mushroomsoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/mushroomsoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk/cream, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_PRODUCE, "mushrooms", qmod=0.2),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_PRODUCE_OPTIONAL, "reishi", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "amanita", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "plumphelmet", qmod=0.4),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/mysterysoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/mysterysoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/badrecipe, qmod=0.5),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_USE_STOVE, J_MED, 20 SECONDS)
	)

/datum/cooking/recipe/bloodsoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/bloodsoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/blood, 30),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/metroidsoup
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/metroidsoup
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT, /datum/reagent/metroidjelly, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/beefcurry
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/beefcurry

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, base=10),
		list(CWJ_USE_STOVE, J_LO, 10 SECONDS),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/flour, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/soysauce, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledrice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "chili"),
		list(CWJ_ADD_PRODUCE, "carrot"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_USE_STOVE, J_MED, 40 SECONDS)
	)

/datum/cooking/recipe/chickencurry
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/chickencurry

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, base=10),
		list(CWJ_USE_STOVE, J_LO, 10 SECONDS),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/flour, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/soysauce, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledrice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/chickenbreast, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "chili"),
		list(CWJ_ADD_PRODUCE, "carrot"),
		list(CWJ_ADD_PRODUCE, "tomato"),
		list(CWJ_USE_STOVE, J_MED, 40 SECONDS)
	)

//**Vegetables**//
//missing: soylenviridians, soylentgreen
/datum/cooking/recipe/mashpotato
	cooking_container = BOWL
	product_type = /obj/item/reagent_containers/food/mashpotatoes

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_PRODUCE, "potato", 2),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 2),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, base=10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_USE_TOOL, QUALITY_HAMMERING, 15)
	)

/datum/cooking/recipe/loadedbakedpotato
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/loadedbakedpotato

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_PRODUCE, "potato", 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/butterslice, base=10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/fries
	cooking_container = DF_BASKET
	product_type = /obj/item/reagent_containers/food/fries
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/rawsticks),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_USE_STOVE, J_HI, 15 SECONDS)
	)

/datum/cooking/recipe/cheesyfries
	cooking_container = DF_BASKET
	product_type = /obj/item/reagent_containers/food/cheesyfries
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/fries),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge),
		list(CWJ_USE_STOVE, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/eggplantparm
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/eggplantparm
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "eggplant"),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/butterslice, base=3),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_PRODUCE_OPTIONAL, "mushrooms", qmod=0.2),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "reishi", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "amanita", qmod=0.4),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "plumphelmet", qmod=0.4),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_USE_STOVE, J_HI, 30 SECONDS)
	)

/datum/cooking/recipe/stewedsoymeat
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/stewedsoymeat
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/soydope, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/soydope, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "carrot"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_HI, 15 SECONDS)
	)

//**Cakes**//
/datum/cooking/recipe/plaincake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/plaincake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/butterstick, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 15),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/flour, 15),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/protein/egg, 9),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/carrotcake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/carrotcake
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "carrot", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "carrot", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "carrot", qmod=0.2),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_USE_STOVE, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/cheesecake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/cheesecake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_USE_STOVE, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/orangecake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/orangecake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "orange", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/limecake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/limecake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "lime", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/lemoncake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/lemoncake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "lemon", qmod=0.2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/chocolatecake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/chocolatecake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/chocolatebar, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/coco, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/applecake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/applecake
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "apple", qmod=0.2),
		list(CWJ_ADD_PRODUCE, "apple", qmod=0.2),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 1, base=1),
		list(CWJ_USE_STOVE, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/birthdaycake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/birthdaycake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/clothing/head/cakehat, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/braincake
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/braincake
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/plaincake, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/organ/internal/cerebrum/brain, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/butterstick, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

/datum/cooking/recipe/brownies
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sliceable/brownie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/butterstick, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 15),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/coco, 10),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/protein/egg, 9),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/chocolatebar, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/woodpulp, 5),
		list(CWJ_USE_OVEN, J_MED, 30 SECONDS)
	)

//**Desserts and Sweets**//
//missing: fortunecookie, honey_bun, honey_pudding
//Changes: Now a chemical reaction: candy_corn, mint,
/datum/cooking/recipe/chocolateegg
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/chocolateegg
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/egg, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/chocolatebar, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sugar, 5),
		list(CWJ_USE_STOVE, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/candiedapple
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/candiedapple
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "apple", qmod=0.2),
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 1, base=1),
		list(CWJ_USE_STOVE, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/cookie
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/cookie
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/cornoil, 2),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/chocolatebar, qmod=0.5),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/appletart
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/appletart
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "goldapple", qmod=0.2),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/flour, 10),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/protein/egg, 3),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/plumphelmetbiscuit
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/plumphelmetbiscuit
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sliceable/flatdough, qmod=0.5),
		list(CWJ_ADD_PRODUCE, "plumphelmet", qmod=0.2),
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/flour, 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_LO, 15 SECONDS)
	)

/datum/cooking/recipe/popcorn
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/popcorn
	step_builder = list(
		list(CWJ_ADD_PRODUCE, "corn"),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 2),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_USE_STOVE, J_LO, 5 SECONDS)
	)

//UNSORTED
//missing: spacylibertyduff
/datum/cooking/recipe/boiled_metroid_extract
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/boiledmetroidcore
	step_builder = list(
		list(CWJ_ADD_REAGENT, /datum/reagent/water, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_ITEM, /obj/item/metroid_extract, qmod=0.5),
		list(CWJ_USE_STOVE, J_HI, 15 SECONDS)
	)
