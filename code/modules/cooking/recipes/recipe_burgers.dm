//**Burgers**//
/datum/cooking/recipe/burger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/plainburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/patty)
	)

/datum/cooking/recipe/humanburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/human/burger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/human)
	)

/datum/cooking/recipe/brainburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/brainburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/organ/internal/cerebrum/brain)
	)

/datum/cooking/recipe/roburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/roburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/robot_parts/head)
	)

/datum/cooking/recipe/xenoburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/xenoburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/meat/xeno)
	)

/datum/cooking/recipe/fishburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/fishburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/carpmeat)
	)

/datum/cooking/recipe/tofuburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/tofuburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5), //Adding non-vegan optional to a vegan style dish is hysterical
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5), //Double down
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/tofu)
	)

/datum/cooking/recipe/clownburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/clownburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/clothing/mask/gas/clown_hat)
	)

/datum/cooking/recipe/mimeburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/mimeburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/clothing/head/beret)
	)

/datum/cooking/recipe/bigbiteburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/bigbiteburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/plainburger, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/patty, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/patty, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/patty, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledegg, qmod=0.5)
	)

/datum/cooking/recipe/superbiteburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/superbiteburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bigbiteburger, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/patty, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/boiledegg, qmod=0.5)
	)

/datum/cooking/recipe/jellyburger
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/jellyburger

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cherryjelly, 5)
	)

/datum/cooking/recipe/jellyburger/cherry
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/jellyburger/cherry

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/nutriment/cherryjelly, 1),
	)

/datum/cooking/recipe/jellyburger/metroid
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/jellyburger/metroid

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "cabbage"),
		list(CWJ_ADD_PRODUCE_OPTIONAL, "tomato"),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/nutriment/ketchup, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/sodiumchloride, 1),
		list(CWJ_ADD_REAGENT_OPTIONAL, /datum/reagent/blackpepper, 1),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/bacon, qmod=0.5),
		list(CWJ_ADD_ITEM_OPTIONAL, /obj/item/reagent_containers/food/cheesewedge, qmod=0.5),
		list(CWJ_ADD_REAGENT, /datum/reagent/metroidjelly, 5)
	)

/datum/cooking/recipe/bunbun
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/reagent_containers/food/bunbun

	replace_reagents = FALSE

	step_builder = list(
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
		list(CWJ_ADD_ITEM, /obj/item/reagent_containers/food/bun, qmod=0.5),
	)
