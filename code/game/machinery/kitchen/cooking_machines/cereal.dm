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
	. = ..()
	var/product_name = ""
	if(thing_inside_parent)
		product_name = "[thing_inside_parent.name] cereal"
	else
		product_name = product.name
	product.SetName("box of [product_name]")
	return product

/obj/machinery/cooker/cereal/change_product_appearance(obj/item/weapon/reagent_containers/food/snacks/variable/cereal/product, atom/movable/origin)
	var/icon/background = icon(product.icon, "[product.icon_state]_filling")
	var/origin_color
	if(istype(origin, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = origin
		origin_color = S.filling_color
	else
		origin_color = origin.color
	if(origin_color)
		background.Blend(origin_color, ICON_SUBTRACT) // Invert
		product.filling_color = origin_color

	product.overlays += background

	var/image/food_image
	if(istype(thing_inside_parent, /obj/item/organ/internal))
		food_image = image(thing_inside_parent.icon, thing_inside_parent.icon_state)
	else if(istype(thing_inside_parent, /obj/item/organ/external))
		var/obj/item/organ/external/E = thing_inside_parent
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/snack = new E.food_organ_type(E)
		food_image = image(snack.icon, snack.icon_state)
		qdel(snack)
		E = null
	else
		food_image = image(origin.icon, origin.icon_state)
	food_image.color = origin.color
	food_image.overlays += origin.overlays
	if(istype(thing_inside_parent, /obj/item/organ/internal/brain))
		food_image.transform *= 0.4
	else if(istype(thing_inside_parent, /obj/item/organ/internal))
		food_image.transform *= 0.7
	else
		food_image.transform *= 0.7
		food_image.pixel_y = 2
	product.overlays += food_image
	return product
