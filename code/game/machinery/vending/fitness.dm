
/obj/machinery/vending/fitness
	name = "SweatMAX"
	desc = "An exercise aid and nutrition supplement vendor that preys on your inadequacy."

	icon_state = "fitness"

	vend_delay = 6
	use_vend_state = TRUE
	product_slogans = "SweatMAX, get robust!"
	product_ads = "Pain is just weakness leaving the body!;Run! Your fat is catching up to you;Never forget leg day!;Push out!;This is the only break you get today.;Don't cry, sweat!;Healthy is an outfit that looks good on everybody."

	vending_sound = SFX_VENDING_DROP

	component_types = list(
		/obj/item/vending_cartridge/fitness
		)

	legal = list(
		/obj/item/reagent_containers/vessel/carton/milk = 8,
		/obj/item/reagent_containers/vessel/carton/milk/chocolate = 8,
		/obj/item/reagent_containers/vessel/fitnessflask/proteinshake = 8,
		/obj/item/reagent_containers/vessel/fitnessflask = 8,
		/obj/item/reagent_containers/food/packaged/nutribar = 8,
		/obj/item/reagent_containers/food/liquidfood = 8,
		/obj/item/reagent_containers/pill/diet = 8,
		/obj/item/towel/random = 8
		)

	illegal = list(
		/obj/item/reagent_containers/syringe/steroid/packaged = 4
		)

	prices = list(
		/obj/item/reagent_containers/vessel/carton/milk = 3,
		/obj/item/reagent_containers/vessel/carton/milk/chocolate = 3,
		/obj/item/reagent_containers/vessel/fitnessflask/proteinshake = 20,
		/obj/item/reagent_containers/vessel/fitnessflask = 5,
		/obj/item/reagent_containers/food/packaged/nutribar = 5,
		/obj/item/reagent_containers/food/liquidfood = 5,
		/obj/item/reagent_containers/pill/diet = 25,
		/obj/item/towel/random = 40
		)

/obj/item/vending_cartridge/fitness
	icon_state = "refill_snack"
	build_path = /obj/machinery/vending/fitness
