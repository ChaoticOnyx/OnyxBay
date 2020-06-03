/obj/machinery/cooker/cereal
	name = "cereal maker"
	desc = "Now with Dann O's available!"
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "cereal_off"
	cook_type = "cerealized"
	on_icon = "cereal_on"
	off_icon = "cereal_off"

/obj/machinery/cooker/cereal/change_product_strings(obj/item/weapon/product)
	product.SetName("box of [product.name] cereal")
	product.desc = "[product.desc] It has been [cook_type]."
	return product

/obj/machinery/cooker/cereal/change_product_appearance(obj/item/weapon/product)
	var/image/food_image = image(product.icon, product.icon_state)
	food_image.color = product.color
	food_image.overlays += product.overlays
	food_image.transform *= 0.7

	product.icon = 'icons/obj/food.dmi'
	product.icon_state = "cereal_box"
	if(istype(product, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = product
		S.filling_color = S.color

	product.overlays += food_image
	return product
