/obj/machinery/kitchen/cereal
	name = "cereal maker"
	desc = "Now with Dann O's available!"
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "cereal_off"
/*
	cook_type = "cerealized"
	on_icon = "cereal_on"
	off_icon = "cereal_off"
	output_options = list("Cereal" = /obj/item/reagent_containers/food/variable/cereal)
	selected_option = "Cereal"

/obj/machinery/kitchen/cereal/change_product_strings(atom/movable/product, atom/movable/origin)
	. = ..()
	product.SetName("box of [product.name]")
	return product

/obj/machinery/kitchen/cereal/change_product_appearance(obj/item/reagent_containers/food/variable/cereal/product, atom/movable/origin)
	ClearOverlays()
	var/icon/background = icon(product.icon, "[product.icon_state]_filling")
	var/origin_color
	if(istype(origin, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/S = origin
		origin_color = S.filling_color
	else
		origin_color = origin.color
	if(origin_color)
		background.Blend(origin_color, ICON_SUBTRACT) // Invert
		product.filling_color = origin_color

	product.AddOverlays(background)

	var/image/food_image = image(origin.icon, origin.icon_state)
	food_image.color = origin.color
	food_image.CopyOverlays(origin)
	food_image.SetTransform(scale = 0.5)
	food_image.pixel_y = 2
	product.AddOverlays(food_image)
	return product
*/
