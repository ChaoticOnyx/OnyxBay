// Here will be animals skin. Now here just a goat skin.
/obj/item/skin
	icon = 'icons/obj/item.dmi'
	w_class = ITEM_SIZE_NORMAL
	desc = "That a skin of the some animal."
	mod_reach = 0.25
	mod_weight = 0.25
	mod_handy = 0.25

/obj/item/skin/goat
	name = "goats skin"
	icon_state = "goatskin"
	decs = "A goat skin, what was brutally butchet from goat."

obj/item/skin/goat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/material/kitchen/utensil/knife) || istype(W, /obj/item/weapon/material/knife) || istype(W, /obj/item/weapon/material/knife/ritual))
		to_chat(user, SPAN("notice", "You use [W] to cut a ugly hole in [src]."))
		new /obj/item/clothing/suit/goatskincape(user.loc)
		qdel(src)
		return