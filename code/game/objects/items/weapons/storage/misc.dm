/obj/item/weapon/storage/pill_bottle/dice	//7d6
	name = "bag of dice"
	desc = "It's a small bag with dice inside."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"

/obj/item/weapon/storage/pill_bottle/dice/New()
	..()
	for(var/i = 1 to 7)
		new /obj/item/weapon/dice( src )

/obj/item/weapon/storage/pill_bottle/dice_nerd	//DnD dice
	name = "bag of gaming dice"
	desc = "It's a small bag with gaming dice inside."
	icon = 'icons/obj/dice.dmi'
	icon_state = "magicdicebag"

/obj/item/weapon/storage/pill_bottle/dice_nerd/New()
	..()
	new /obj/item/weapon/dice/d4( src )
	new /obj/item/weapon/dice( src )
	new /obj/item/weapon/dice/d8( src )
	new /obj/item/weapon/dice/d10( src )
	new /obj/item/weapon/dice/d12( src )
	new /obj/item/weapon/dice/d20( src )
	new /obj/item/weapon/dice/d100( src )

/*
 * Donut Box
 */

/obj/item/weapon/storage/box/donut
	icon = 'icons/obj/food.dmi'
	icon_state = "donutbox"
	name = "donut box"
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/donut)
	foldable = /obj/item/stack/material/cardboard

	startswith = list(/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 6)

/obj/item/weapon/storage/box/donut/update_icon()
	overlays.Cut()
	var/i = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/donut/D in contents)
		overlays += image('icons/obj/food.dmi', "[i][D.overlay_state]")
		i++

/obj/item/weapon/storage/box/donut/empty
	startswith = null

/*
 * Chalk Box
 */

/obj/item/weapon/storage/box/chalk
	name = "box of chalk"
	desc = "A box of chalk. Outlining corpses? Mixing coke with it? Decorating your gun and convincing people to subscribe to SpacePewCake? Whatever pleases you."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "chalkbox"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 6
	foldable = /obj/item/stack/material/cardboard

	startswith = list(/obj/item/weapon/pen/crayon/chalk = 6)
