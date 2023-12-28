
/obj/machinery/vending/fitness
	name = "SweatMAX"
	desc = "An exercise aid and nutrition supplement vendor that preys on your inadequacy."
	product_slogans = "SweatMAX, get robust!"
	product_ads = "Pain is just weakness leaving the body!;Run! Your fat is catching up to you;Never forget leg day!;Push out!;This is the only break you get today.;Don't cry, sweat!;Healthy is an outfit that looks good on everybody."
	icon_state = "fitness"
	use_vend_state = TRUE
	vend_delay = 6
	component_types = list(/obj/item/vending_cartridge/fitness)
	legal = list(	/obj/item/reagent_containers/vessel/carton/milk = 8,
					/obj/item/reagent_containers/vessel/carton/milk/chocolate = 8,
					/obj/item/reagent_containers/vessel/fitnessflask/proteinshake = 8,
					/obj/item/reagent_containers/vessel/fitnessflask = 8,
					/obj/item/reagent_containers/food/packaged/nutribar = 8,
					/obj/item/reagent_containers/food/liquidfood = 8,
					/obj/item/reagent_containers/pill/diet = 8,
					/obj/item/towel/random = 8)
	illegal = list(/obj/item/reagent_containers/syringe/steroid/packaged = 4)
	prices = list(	/obj/item/reagent_containers/vessel/carton/milk = 250,
					/obj/item/reagent_containers/vessel/carton/milk/chocolate = 300,
					/obj/item/reagent_containers/vessel/fitnessflask/proteinshake = 250,
					/obj/item/reagent_containers/vessel/fitnessflask = 100,
					/obj/item/reagent_containers/food/packaged/nutribar = 150,
					/obj/item/reagent_containers/food/liquidfood = 500,
					/obj/item/reagent_containers/pill/diet = 500,
					/obj/item/towel/random = 100)

/obj/item/vending_cartridge/fitness
	name = "sweat"
	build_path = /obj/machinery/vending/fitness
