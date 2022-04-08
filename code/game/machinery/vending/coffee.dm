
/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	alt_icons = list("coffee", "coffee_alt")
	use_alt_icons = TRUE
	use_vend_state = TRUE
	vend_delay = 34
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	vend_power_usage = 85000 //85 kJ to heat a 250 mL cup of coffee
	rand_amount = TRUE
	products = list(/obj/item/reagent_containers/food/drinks/coffee = 25,
					/obj/item/reagent_containers/food/drinks/tea = 25,
					/obj/item/reagent_containers/food/drinks/h_chocolate = 25,
					/obj/item/storage/pill_bottle/sugar_cubes = 5)
	contraband = list(/obj/item/reagent_containers/food/drinks/ice = 10)
	prices = list(/obj/item/reagent_containers/food/drinks/coffee = 3,
			   	  /obj/item/reagent_containers/food/drinks/tea = 3,
			   	  /obj/item/reagent_containers/food/drinks/h_chocolate = 3,
			   	  /obj/item/storage/pill_bottle/sugar_cubes = 10)
