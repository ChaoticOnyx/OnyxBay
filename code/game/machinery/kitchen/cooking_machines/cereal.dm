/obj/machinery/cooker/cereal
	name = "cereal maker"
	desc = "Now with Dann O's available!"
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "cereal_off"
	cook_type = "cerealized"
	on_icon = "cereal_on"
	off_icon = "cereal_off"
	output_options = list("Cereal" = /obj/item/weapon/reagent_containers/food/snacks/variable/cereal)
	selected_option = "Cereal"

/obj/machinery/cooker/cereal/change_product_strings(atom/movable/product, atom/movable/origin)
	..(product, origin)
	product.SetName("box of [product.name]")
	return product

/obj/machinery/cooker/cereal/change_product_appearance(obj/item/weapon/reagent_containers/food/snacks/variable/cereal/product, atom/movable/origin)
	var/image/food_image = image(origin.icon, origin.icon_state)
	food_image.color = origin.color
	food_image.overlays += origin.overlays
	food_image.transform *= 0.7
	food_image.pixel_y = 2

	var/image/background = image(product.icon, "[product.icon_state]_filling")
	if(istype(origin, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = origin
		background.color = S.filling_color
	else
		background.color = origin.color
	if(background.color)
		background.color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1) // Invert
		product.filling_color = background.color

	background.layer = food_image.layer - 1
	product.overlays += background
	product.overlays += food_image
	return product
