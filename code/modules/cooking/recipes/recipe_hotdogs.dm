/datum/cooking/recipe/hotdog
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/hotdog
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/sausage, qmod=0.5),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)

/datum/cooking/recipe/classichotdog
	cooking_container = GRILL
	product_type = /obj/item/reagent_containers/food/classichotdog
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/holder/corgi, qmod=0.5),
		list(CWJ_USE_STOVE, J_MED, 15 SECONDS)
	)
