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

/obj/structure/closet/coffin/attackby(obj/item/W, mob/user)
	if(opened && !isWelder(W))
		..()
	else if(istype(W, /obj/item/screwdriver))
		if(welded)
			user.visible_message(SPAN("notice", "[user] unscrewed bolts from [src]."))
			welded = !welded
			update_icon()
		else
			user.visible_message(SPAN("notice", "[user] screwed bolts in [src]."))
			welded = !welded
			update_icon()
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 80, 1)
	else
		attack_hand(user)
