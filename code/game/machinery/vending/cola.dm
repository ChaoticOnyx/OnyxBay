
/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."

	icon = 'icons/obj/machines/vending/cola.dmi'
	icon_state = "Cola_Machine"
	light_color = "#EC2F2F"

	idle_power_usage = 211 WATTS //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

	vend_delay = 11
	use_vend_state = TRUE
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."

	vending_sound = SFX_VENDING_CANS

	component_types = list(
		/obj/item/vending_cartridge/cola
		)

	legal = list(
		/obj/item/reagent_containers/vessel/can/cola = 10,
		/obj/item/reagent_containers/vessel/can/colavanilla = 10,
		/obj/item/reagent_containers/vessel/can/colacherry = 10,
		/obj/item/reagent_containers/vessel/can/space_mountain_wind = 10,
		/obj/item/reagent_containers/vessel/can/dr_gibb = 10,
		/obj/item/reagent_containers/vessel/can/starkist = 10,
		/obj/item/reagent_containers/vessel/plastic/waterbottle = 10,
		/obj/item/reagent_containers/vessel/can/space_up = 10,
		/obj/item/reagent_containers/vessel/can/iced_tea = 10,
		/obj/item/reagent_containers/vessel/can/grape_juice = 10,
		/obj/item/reagent_containers/vessel/can/startrucks = 10,
		/obj/item/reagent_containers/vessel/can/red_mule = 5
		)

	illegal = list(
		/obj/item/reagent_containers/vessel/can/thirteenloko = 5,
		/obj/item/reagent_containers/vessel/can/dopecola = 5,
		/obj/item/reagent_containers/food/liquidfood = 6
		)

	premium = list(
		/obj/item/reagent_containers/vessel/plastic/waterbottle/fi4i = 5
		)

	prices = list(
		/obj/item/reagent_containers/vessel/can/cola = 5,
		/obj/item/reagent_containers/vessel/can/colavanilla = 8,
		/obj/item/reagent_containers/vessel/can/colacherry = 8,
		/obj/item/reagent_containers/vessel/can/space_mountain_wind = 5,
		/obj/item/reagent_containers/vessel/can/dr_gibb = 5,
		/obj/item/reagent_containers/vessel/can/starkist = 5,
		/obj/item/reagent_containers/vessel/plastic/waterbottle = 3,
		/obj/item/reagent_containers/vessel/can/space_up = 5,
		/obj/item/reagent_containers/vessel/can/iced_tea = 8,
		/obj/item/reagent_containers/vessel/can/grape_juice = 5,
		/obj/item/reagent_containers/vessel/can/startrucks = 10,
		/obj/item/reagent_containers/vessel/can/red_mule = 15
		)

/obj/item/vending_cartridge/cola
	icon_state = "refill_cola"
	build_path = /obj/machinery/vending/cola
