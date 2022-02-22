
/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	use_vend_state = TRUE
	vend_delay = 11
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	rand_amount = TRUE
	products = list(/obj/item/reagent_containers/food/drinks/cans/cola = 10,
					/obj/item/reagent_containers/food/drinks/cans/colavanilla = 10,
					/obj/item/reagent_containers/food/drinks/cans/colacherry = 10,
					/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 10,
					/obj/item/reagent_containers/food/drinks/cans/starkist = 10,
					/obj/item/reagent_containers/food/drinks/cans/waterbottle = 10,
					/obj/item/reagent_containers/food/drinks/cans/space_up = 10,
					/obj/item/reagent_containers/food/drinks/cans/iced_tea = 10,
					/obj/item/reagent_containers/food/drinks/cans/grape_juice = 10,
					/obj/item/reagent_containers/food/drinks/cans/red_mule = 5)

	contraband = list(/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 5,
					  /obj/item/reagent_containers/food/drinks/cans/dopecola = 5,
					  /obj/item/reagent_containers/food/snacks/liquidfood = 6)

	premium = list(/obj/item/reagent_containers/food/drinks/cans/waterbottle/fi4i = 5)

	prices = list(/obj/item/reagent_containers/food/drinks/cans/cola = 5,
				  /obj/item/reagent_containers/food/drinks/cans/colavanilla = 8,
				  /obj/item/reagent_containers/food/drinks/cans/colacherry = 8,
				  /obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 5,
				  /obj/item/reagent_containers/food/drinks/cans/dr_gibb = 5,
				  /obj/item/reagent_containers/food/drinks/cans/starkist = 5,
				  /obj/item/reagent_containers/food/drinks/cans/waterbottle = 3,
				  /obj/item/reagent_containers/food/drinks/cans/space_up = 5,
				  /obj/item/reagent_containers/food/drinks/cans/iced_tea = 8,
				  /obj/item/reagent_containers/food/drinks/cans/grape_juice = 5,
				  /obj/item/reagent_containers/food/drinks/cans/red_mule = 15)

	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

/obj/machinery/vending/cola/red
	icon_state = "Cola_Machine_red"
