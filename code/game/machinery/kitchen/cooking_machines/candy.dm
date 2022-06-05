/obj/machinery/cooker/candy
	name = "candy machine"
	desc = "Get yer candied cheese wheels here!"
	icon_state = "mixer_off"
	off_icon = "mixer_off"
	on_icon = "mixer_on"
	cook_type = "candied"

	output_options = list(
		"Jawbreaker" = /obj/item/reagent_containers/food/variable/jawbreaker,
		"Candy Bar" = /obj/item/reagent_containers/food/candy/variable,
		"Sucker" = /obj/item/reagent_containers/food/variable/sucker,
		"Jelly" = /obj/item/reagent_containers/food/variable/jelly
		)

/obj/machinery/cooker/candy/change_product_appearance()
	food_color = get_random_colour(1)
	. = ..()
