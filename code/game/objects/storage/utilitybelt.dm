/obj/item/weapon/storage/utilitybelt/dropped(mob/user as mob)
	..()

/obj/item/weapon/storage/utilitybelt/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if (!istype(over_object, /obj/screen))
		if(can_use())
			return ..()
		else
			M << "\red I need to wear the belt for that."
			return
	playsound(src.loc, "rustle", 50, 1, -5)
	if (!M.restrained() && !M.stat && can_use())
		if (over_object.name == "r_hand")
			if (!( M.r_hand ))
				M.u_equip(src)
				M.r_hand = src
		else
			if (over_object.name == "l_hand")
				if (!( M.l_hand ))
					M.u_equip(src)
					M.l_hand = src
		M.update_clothing()
		src.add_fingerprint(usr)
		return

/obj/item/weapon/storage/utilitybelt/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/storage/utilitybelt/attack_hand(mob/user as mob)
	if (src.loc == user)
		if(can_use())
			playsound(src.loc, "rustle", 50, 1, -5)
			if (user.s_active)
				user.s_active.close(user)
			src.show_to(user)
		else
			user << "\red I need to wear the belt for that."
			return
	else
		return ..()

	src.add_fingerprint(user)

/obj/item/weapon/storage/utilitybelt/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!can_use())
		user << "\red I need to wear the belt for that."
		return
	else
		..()

/obj/item/weapon/storage/utilitybelt/proc/can_use()
	if(!ismob(loc)) return 0
	return 1
	//var/mob/M = loc
	//if(src in M.get_equipped_items())
	//	return 1
	//else
	//	return 0