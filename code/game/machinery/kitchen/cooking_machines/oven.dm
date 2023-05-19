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
		"Personal Pizza" = /obj/item/reagent_containers/food/variable/pizza,
		"Bread" = /obj/item/reagent_containers/food/sliceable/bread/variable,
		"Pie" = /obj/item/reagent_containers/food/pie/variable,
		"Small Cake" = /obj/item/reagent_containers/food/sliceable/plaincake/variable,
		"Hot Pocket" = /obj/item/reagent_containers/food/donkpocket/variable,
		"Kebab" = /obj/item/reagent_containers/food/tofukabob/variable,
		"Waffles" = /obj/item/reagent_containers/food/waffles/variable,
		"Pancakes" = /obj/item/reagent_containers/food/pancakes/variable,
		"Cookie" = /obj/item/reagent_containers/food/cookie/variable,
		"Donut" = /obj/item/reagent_containers/food/donut/variable,
		)
