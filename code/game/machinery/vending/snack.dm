
/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."

	icon = 'icons/obj/machines/vending/snack.dmi'
	icon_state = "snack"
	light_color = "#FF9900"

	vend_delay = 25
	use_vend_state = TRUE
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"

	vending_sound = SFX_VENDING_DROP

	component_types = list(
		/obj/item/vending_cartridge/snack
		)

	legal = list(
		/obj/item/reagent_containers/food/packaged/tweakers = 6,
		/obj/item/reagent_containers/food/packaged/sweetroid = 6,
		/obj/item/reagent_containers/food/packaged/sugarmatter = 6,
		/obj/item/reagent_containers/food/packaged/jellaws = 6,
		/obj/item/reagent_containers/vessel/dry_ramen = 6,
		/obj/item/reagent_containers/vessel/chickensoup = 6,
		/obj/item/reagent_containers/food/packaged/chips = 6,
		/obj/item/reagent_containers/food/packaged/sosjerky = 6,
		/obj/item/reagent_containers/food/packaged/no_raisin = 6,
		/obj/item/reagent_containers/food/spacetwinkie = 6,
		/obj/item/reagent_containers/food/packaged/cheesiehonkers = 6,
		/obj/item/reagent_containers/food/packaged/tastybread = 6
		)
	illegal = list(
		/obj/item/reagent_containers/food/packaged/syndicake = 6,
		/obj/item/reagent_containers/food/packaged/skrellsnacks = 3,
		/obj/item/storage/box/sinpockets = 1
		)
	premium = list(
		/obj/item/reagent_containers/food/superbiteburger = 1
		)
	prices = list(
		/obj/item/reagent_containers/food/packaged/tweakers = 5,
		/obj/item/reagent_containers/food/packaged/sweetroid = 5,
		/obj/item/reagent_containers/food/packaged/sugarmatter = 5,
		/obj/item/reagent_containers/food/packaged/jellaws = 5,
		/obj/item/reagent_containers/vessel/dry_ramen = 10,
		/obj/item/reagent_containers/vessel/chickensoup = 20,
		/obj/item/reagent_containers/food/packaged/chips = 10,
		/obj/item/reagent_containers/food/packaged/sosjerky = 20,
		/obj/item/reagent_containers/food/packaged/no_raisin = 15,
		/obj/item/reagent_containers/food/spacetwinkie = 5,
		/obj/item/reagent_containers/food/packaged/cheesiehonkers = 10,
		/obj/item/reagent_containers/food/packaged/tastybread = 10
		)

/obj/item/vending_cartridge/snack
	icon_state = "refill_snack"
	build_path = /obj/machinery/vending/snack

/obj/machinery/vending/snack/wallsnack
	name = "Getmore Chocolate Corp"

	icon_state = "snack_wall"
	use_vend_state = FALSE
	component_types = list(/obj/item/vending_cartridge/wallsnack)
	legal = list(	/obj/item/reagent_containers/food/packaged/tweakers =6,
					/obj/item/reagent_containers/food/packaged/sweetroid = 6,
					/obj/item/reagent_containers/food/packaged/sugarmatter = 6,
					/obj/item/reagent_containers/food/packaged/jellaws = 6,
					/obj/item/reagent_containers/vessel/dry_ramen = 6,
					/obj/item/reagent_containers/vessel/chickensoup = 6,
					/obj/item/reagent_containers/food/packaged/chips = 6,
					/obj/item/reagent_containers/food/packaged/sosjerky = 6,
					/obj/item/reagent_containers/food/packaged/no_raisin = 6,
					/obj/item/reagent_containers/food/spacetwinkie = 6,
					/obj/item/reagent_containers/food/packaged/cheesiehonkers = 6,
					/obj/item/reagent_containers/food/packaged/tastybread = 6)
	illegal = list(	/obj/item/reagent_containers/food/packaged/syndicake = 6,
					/obj/item/reagent_containers/food/packaged/skrellsnacks = 3,
					/obj/item/storage/box/sinpockets = 1)
	premium = list( /obj/item/reagent_containers/food/superbiteburger = 1)
	prices = list(	/obj/item/reagent_containers/food/packaged/tweakers = 5,
					/obj/item/reagent_containers/food/packaged/sweetroid = 5,
					/obj/item/reagent_containers/food/packaged/sugarmatter = 5,
					/obj/item/reagent_containers/food/packaged/jellaws = 5,
					/obj/item/reagent_containers/vessel/dry_ramen = 10,
					/obj/item/reagent_containers/vessel/chickensoup = 20,
					/obj/item/reagent_containers/food/packaged/chips = 10,
					/obj/item/reagent_containers/food/packaged/sosjerky = 20,
					/obj/item/reagent_containers/food/packaged/no_raisin = 15,
					/obj/item/reagent_containers/food/spacetwinkie = 5,
					/obj/item/reagent_containers/food/packaged/cheesiehonkers = 10,
					/obj/item/reagent_containers/food/packaged/tastybread = 10)

/obj/item/vending_cartridge/wallsnack
	icon_state = "refill_snack"
	build_path = /obj/machinery/vending/snack/wallsnack

/obj/machinery/vending/snack/medbay
	name = "Getmore Healthy Snacks"
	desc = "A snack machine manufactured by Getmore Chocolate Corporation, specifically for hospitals."
	product_slogans = "Try our new Hema-2-Gen bar!;Twice the health for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"

	icon_state = "snackmed"
	use_vend_state = TRUE
	light_color = "#B8D4CB"

	vend_delay = 25
	component_types = list(/obj/item/vending_cartridge/medbay)
	legal = list(	/obj/item/reagent_containers/food/grown/apple = 10,
					/obj/item/reagent_containers/food/packaged/hematogen = 10,
					/obj/item/reagent_containers/food/packaged/nutribar = 10,
					/obj/item/reagent_containers/food/packaged/no_raisin = 10,
					/obj/item/reagent_containers/food/grown/orange = 10,
					/obj/item/reagent_containers/food/packaged/tastybread = 10)
	illegal = list(	/obj/item/reagent_containers/food/packaged/hemptogen = 3,
					/obj/item/reagent_containers/food/packaged/skrellsnacks = 3)
	premium = list( /obj/item/reagent_containers/food/aesirsalad = 1)
	prices = list(	/obj/item/reagent_containers/food/grown/apple = 1,
					/obj/item/reagent_containers/food/packaged/hematogen = 10,
					/obj/item/reagent_containers/food/packaged/nutribar = 5,
					/obj/item/reagent_containers/food/packaged/no_raisin = 1,
					/obj/item/reagent_containers/food/grown/orange = 1,
					/obj/item/reagent_containers/food/packaged/tastybread = 3)

/obj/item/vending_cartridge/medbay
	icon_state = "refill_snack"
	build_path = /obj/machinery/vending/snack/medbay
