
/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."

	icon = 'icons/obj/machines/vending/coffee.dmi'
	icon_state = "coffee"
	light_color = COLOR_GREEN_GRAY

	idle_power_usage = 211 WATTS //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	vend_power_usage = 85 KILO WATTS //85 kJ to heat a 250 mL cup of coffee

	vend_delay = 34
	use_alt_icons = TRUE
	alt_icons = list("coffee", "coffee_alt")
	use_vend_state = TRUE
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"

	vending_sound = SFX_VENDING_COFFEE

	component_types = list(
		/obj/item/vending_cartridge/coffee
		)

	legal = list(
		/obj/item/reagent_containers/vessel/coffee = 25,
		/obj/item/reagent_containers/vessel/tea = 25,
		/obj/item/reagent_containers/vessel/h_chocolate = 25,
		/obj/item/reagent_containers/vessel/can/startrucks = 25,
		/obj/item/storage/pill_bottle/sugar_cubes = 5
		)

	illegal = list(
		/obj/item/reagent_containers/vessel/ice = 10
		)

	prices = list(
		/obj/item/reagent_containers/vessel/coffee = 3,
		/obj/item/reagent_containers/vessel/tea = 3,
		/obj/item/reagent_containers/vessel/h_chocolate = 3,
		/obj/item/storage/pill_bottle/sugar_cubes = 10
		)

/obj/item/vending_cartridge/coffee
	icon_state = "refill_joe"
	build_path = /obj/machinery/vending/coffee
