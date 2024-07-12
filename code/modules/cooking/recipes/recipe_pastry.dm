/datum/cooking/recipe/waffles
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/waffles
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 10),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 3, base=3),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5, base=1),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/flour, 5, base=1),
		list(CWJ_USE_TOOL, QUALITY_CUTTING, 1),
		list(CWJ_USE_OVEN, J_LO, 5 SECONDS)
	)

/datum/cooking/recipe/rofflewaffles
	cooking_container = PAN
	product_type = /obj/item/reagent_containers/food/rofflewaffles
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/rofflewaffles, qmod=0.5),
		list(CWJ_ADD_REAGENT, "psilocybin", 5),
		CWJ_BEGIN_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_REAGENT_OPTIONAL, "pwine", 5, base=6, remain_percent=0.1, prod_desc="The fancy wine soaks up into the fluffy waffles."),
		list(CWJ_ADD_REAGENT_OPTIONAL, "space_drugs", 5, base=6, remain_percent=0.5, prod_desc="The space drugs soak into the waffles."),
		list(CWJ_ADD_REAGENT_OPTIONAL, "mindbreaker", 5, base=6, remain_percent=0.1, prod_desc="Not for waking up to."),
		CWJ_END_EXCLUSIVE_OPTIONS,
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_USE_OVEN, J_LO, 5 SECONDS)
	)
