/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"
	var/icon_screwed = "coffin_locked"
	setup = CLOSET_CAN_BE_WELDED
	dremovable = 0

/obj/structure/closet/coffin/update_icon()
	if (welded)
		icon_state = icon_screwed
	else if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/obj/structure/closet/coffin/attackby(obj/item/weapon/W, mob/user)
	if(!opened && istype(W, /obj/item/weapon/screwdriver))
		if(welded)
			user.visible_message(SPAN("notice", "[user] unscrewed bolts from [src]."))
			welded = !welded
			update_icon()
		else
			user.visible_message(SPAN("notice", "[user] screwed bolts in [src]."))
			welded = !welded
			update_icon()
	else if (opened)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			src.MouseDrop_T(G.affecting, user)      //act like they were dragged onto the closet
			return 0
		if(istype(W,/obj/item/tk_grab))
			return 0
		if(usr.drop_item())
			W.forceMove(loc)
			W.pixel_x = 0
			W.pixel_y = 0
			W.pixel_z = 0
			W.pixel_w = 0
		return
	else
		attack_hand(user)
