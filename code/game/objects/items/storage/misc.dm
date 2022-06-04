/obj/item/storage/pill_bottle/dice	//7d6
	name = "bag of dice"
	desc = "It's a small bag with dice inside."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"

/obj/item/storage/pill_bottle/dice/New()
	..()
	for(var/i = 1 to 7)
		new /obj/item/dice( src )

/obj/item/storage/pill_bottle/dice_nerd	//DnD dice
	name = "bag of gaming dice"
	desc = "It's a small bag with gaming dice inside."
	icon = 'icons/obj/dice.dmi'
	icon_state = "magicdicebag"

/obj/item/storage/pill_bottle/dice_nerd/New()
	..()
	new /obj/item/dice/d4( src )
	new /obj/item/dice( src )
	new /obj/item/dice/d8( src )
	new /obj/item/dice/d10( src )
	new /obj/item/dice/d12( src )
	new /obj/item/dice/d20( src )
	new /obj/item/dice/dp( src )

/*
 * Donut Box
 */

/obj/item/storage/box/donut
	icon = 'icons/obj/food.dmi'
	icon_state = "donutbox"
	name = "donut box"
	can_hold = list(/obj/item/reagent_containers/food/donut)
	max_storage_space = 12 // Eggs-actly 6 donuts, not a single bite more
	foldable = /obj/item/stack/material/cardboard

	startswith = list(/obj/item/reagent_containers/food/donut/normal = 6)

/obj/item/storage/box/donut/update_icon()
	overlays.Cut()
	var/i = 0
	for(var/obj/item/reagent_containers/food/donut/D in contents)
		var/image/lying_donut = image('icons/obj/food.dmi', "[i][D.overlay_state]")
		lying_donut.color = D.color
		overlays += lying_donut
		i++

/obj/item/storage/box/donut/empty
	startswith = null

/*
 * Chalk Box
 */

/obj/item/storage/box/chalk
	name = "box of chalk"
	desc = "A box of chalk. Outlining corpses? Mixing coke with it? Decorating your gun and convincing people to subscribe to SpacePewCake? Whatever pleases you."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "chalkbox"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 6
	foldable = /obj/item/stack/material/cardboard

	startswith = list(/obj/item/pen/crayon/chalk = 6)
