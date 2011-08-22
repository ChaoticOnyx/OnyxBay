/obj/item/toy
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0

/obj/item/toy/crayonbox
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'crayons.dmi'
	icon_state = "crayonbox"
	w_class = 2.0

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'crayons.dmi'
	icon_state = "crayonred"
	w_class = 1.0
	var/colour = "#FF0000" //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes