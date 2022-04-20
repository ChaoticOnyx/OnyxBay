/obj/machinery/cooker/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	cooked_sound = 'sound/machines/ding.ogg'
	on_icon = "oven_on"
	off_icon = "oven_off"
	cook_type = "baked"
	cook_time = 300
	food_color = "#a34719"
	can_burn_food = 1

	output_options = list(
		"Personal Pizza" = /obj/item/reagent_containers/food/snacks/variable/pizza,
		"Bread" = /obj/item/reagent_containers/food/snacks/sliceable/bread/variable,
		"Pie" = /obj/item/reagent_containers/food/snacks/pie/variable,
		"Small Cake" = /obj/item/reagent_containers/food/snacks/sliceable/plaincake/variable,
		"Hot Pocket" = /obj/item/reagent_containers/food/snacks/donkpocket/variable,
		"Kebab" = /obj/item/reagent_containers/food/snacks/tofukabob/variable,
		"Waffles" = /obj/item/reagent_containers/food/snacks/waffles/variable,
		"Pancakes" = /obj/item/reagent_containers/food/snacks/pancakes/variable,
		"Cookie" = /obj/item/reagent_containers/food/snacks/cookie/variable,
		"Donut" = /obj/item/reagent_containers/food/snacks/donut/variable,
		)
