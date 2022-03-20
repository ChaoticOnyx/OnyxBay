
/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	use_vend_state = TRUE
	vend_delay = 25
	rand_amount = TRUE
	products = list(/obj/item/reagent_containers/food/snacks/packaged/tweakers = 6,
					/obj/item/reagent_containers/food/snacks/packaged/sweetroid = 6,
					/obj/item/reagent_containers/food/snacks/packaged/sugarmatter = 6,
					/obj/item/reagent_containers/food/snacks/packaged/jellaws = 6,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 6,
					/obj/item/reagent_containers/food/drinks/chickensoup = 6,
					/obj/item/reagent_containers/food/snacks/packaged/chips = 6,
					/obj/item/reagent_containers/food/snacks/packaged/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/packaged/no_raisin = 6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/reagent_containers/food/snacks/packaged/cheesiehonkers = 6,
					/obj/item/reagent_containers/food/snacks/packaged/tastybread = 6)
	contraband = list(/obj/item/reagent_containers/food/snacks/packaged/syndicake = 6,
					  /obj/item/reagent_containers/food/snacks/packaged/skrellsnacks = 3)
	prices = list(/obj/item/reagent_containers/food/snacks/packaged/tweakers = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/sweetroid = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/sugarmatter = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/jellaws = 5,
				  /obj/item/reagent_containers/food/drinks/dry_ramen = 10,
				  /obj/item/reagent_containers/food/drinks/chickensoup = 20,
				  /obj/item/reagent_containers/food/snacks/packaged/chips = 10,
				  /obj/item/reagent_containers/food/snacks/packaged/sosjerky = 20,
				  /obj/item/reagent_containers/food/snacks/packaged/no_raisin = 15,
				  /obj/item/reagent_containers/food/snacks/spacetwinkie = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/cheesiehonkers = 10,
				  /obj/item/reagent_containers/food/snacks/packaged/tastybread = 10)

/obj/machinery/vending/snack/wallsnack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack_wall"
	use_vend_state = FALSE
	vend_delay = 25
	products = list(/obj/item/reagent_containers/food/snacks/packaged/tweakers =6,
					/obj/item/reagent_containers/food/snacks/packaged/sweetroid = 6,
					/obj/item/reagent_containers/food/snacks/packaged/sugarmatter = 6,
					/obj/item/reagent_containers/food/snacks/packaged/jellaws = 6,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 6,
					/obj/item/reagent_containers/food/drinks/chickensoup = 6,
					/obj/item/reagent_containers/food/snacks/packaged/chips = 6,
					/obj/item/reagent_containers/food/snacks/packaged/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/packaged/no_raisin = 6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/reagent_containers/food/snacks/packaged/cheesiehonkers = 6,
					/obj/item/reagent_containers/food/snacks/packaged/tastybread = 6)
	contraband = list(/obj/item/reagent_containers/food/snacks/packaged/syndicake = 6,
					  /obj/item/reagent_containers/food/snacks/packaged/skrellsnacks = 3)
	prices = list(/obj/item/reagent_containers/food/snacks/packaged/tweakers = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/sweetroid = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/sugarmatter = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/jellaws = 5,
				  /obj/item/reagent_containers/food/drinks/dry_ramen = 10,
				  /obj/item/reagent_containers/food/drinks/chickensoup = 20,
				  /obj/item/reagent_containers/food/snacks/packaged/chips = 10,
				  /obj/item/reagent_containers/food/snacks/packaged/sosjerky = 20,
				  /obj/item/reagent_containers/food/snacks/packaged/no_raisin = 15,
				  /obj/item/reagent_containers/food/snacks/spacetwinkie = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/cheesiehonkers = 10,
				  /obj/item/reagent_containers/food/snacks/packaged/tastybread = 10)

/obj/machinery/vending/snack/medbay
	name = "Getmore Healthy Snacks"
	desc = "A snack machine manufactured by Getmore Chocolate Corporation, specifically for hospitals."
	product_slogans = "Try our new Hema-2-Gen bar!;Twice the health for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snackmed"
	use_vend_state = TRUE
	vend_delay = 25
	products = list(/obj/item/reagent_containers/food/snacks/grown/apple = 10,
					/obj/item/reagent_containers/food/snacks/packaged/hematogen = 10,
					/obj/item/reagent_containers/food/snacks/packaged/nutribar = 10,
					/obj/item/reagent_containers/food/snacks/packaged/no_raisin = 10,
					/obj/item/reagent_containers/food/snacks/grown/orange = 10,
					/obj/item/reagent_containers/food/snacks/packaged/tastybread = 10)
	contraband = list(/obj/item/reagent_containers/food/snacks/packaged/hemptogen = 3,
					  /obj/item/reagent_containers/food/snacks/packaged/skrellsnacks = 3)
	prices = list(/obj/item/reagent_containers/food/snacks/grown/apple = 1,
				  /obj/item/reagent_containers/food/snacks/packaged/hematogen = 10,
				  /obj/item/reagent_containers/food/snacks/packaged/nutribar = 5,
				  /obj/item/reagent_containers/food/snacks/packaged/no_raisin = 1,
				  /obj/item/reagent_containers/food/snacks/grown/orange = 1,
				  /obj/item/reagent_containers/food/snacks/packaged/tastybread = 3)
