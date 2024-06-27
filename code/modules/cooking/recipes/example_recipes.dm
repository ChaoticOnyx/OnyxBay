
/*
//Example of the same recipe, but for the grill, just to show off how compact everything is.

/datum/cooking/recipe/sandwich_basic_bowl
	cooking_container = BOWL
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, qmod=0.5, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_deep_fryer
	cooking_container = DF_BASKET
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, qmod=0.5, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_air_fryer
	cooking_container = AF_BASKET
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, qmod=0.5, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_pot
	cooking_container = POT
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, qmod=0.5, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_oven
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, qmod=0.5, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5)
	)
	appear_in_default_catalog = FALSE


/datum/cooking/recipe/sandwich_bad_with_tomato
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_PRODUCE, "tomato", prod_desc="There is a whole tomato stuffed in the sandwich."),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_tofu_bad
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/tofu, desc="Add tofu to it.", prod_desc="There is tofu between the bread."),
		list(CWJ_USE_ITEM_OPTIONAL, /obj/item/reagent_containers/food/tofu, desc="Brush Tofu on it.", prod_desc="It has been in contact with tofu."),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_bad_stacked
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cutlet, desc="Add even more of any kind of cutlet.", prod_desc="There is additional meat between the bread."),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_salted
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cutlet, desc="Add any kind of cutlet.", prod_desc="There is meat between the bread."),
		list(CWJ_ADD_REAGENT, "sodiumchloride", 5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/breadslice)
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/sandwich_split
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/sandwich
	product_count = 2
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sandwich, qmod=0.5),
		list(CWJ_USE_TOOL, QUALITY_SAWING, 10)
	)
	appear_in_default_catalog = FALSE


/datum/cooking/recipe/sandwich_toasted
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/sandwich
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sandwich),
		list(CWJ_USE_GRILL, J_LO, 30 SECONDS, prod_desc="It has been toasted.")
	)
	appear_in_default_catalog = FALSE

*/
