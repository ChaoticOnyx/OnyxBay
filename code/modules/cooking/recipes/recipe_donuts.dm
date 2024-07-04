/datum/cooking/recipe/medialuna //This is 100% a donut but with extra layers
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/medialuna
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/butterslice, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_USE_OVEN, J_LO, 20 SECONDS),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1, base=1),
		list(CWJ_ADD_REAGENT, /datum/reagent/drink/milk, 5),
		list(CWJ_USE_TOOL, QUALITY_CUTTING, 1)
	)

/datum/cooking/recipe/donut
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/donut
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 1, base=1),
		list(CWJ_USE_OVEN, J_LO, 10 SECONDS)
	)

/datum/cooking/recipe/jellydonut
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/donut/jelly
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_REAGENT, "berryjuice", 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 1, base=1),
		list(CWJ_USE_OVEN, J_LO, 20 SECONDS)
	)

/datum/cooking/recipe/slime_jellydonut
	cooking_container = OVEN
	product_type = /obj/item/reagent_containers/food/donut/metroidjelly
	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/doughslice, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cornoil, 1),
		list(CWJ_ADD_REAGENT, /datum/reagent/metroidjelly, 5),
		list(CWJ_ADD_REAGENT, /datum/reagent/sugar, 5),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/honey, 1, base=1),
		list(CWJ_USE_OVEN, J_LO, 20 SECONDS)
	)
