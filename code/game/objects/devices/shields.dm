/obj/item/device/shield
	name = "shield"
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 4.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0


/obj/item/device/shield/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The shield is now active."
		src.icon_state = "shield1"
	else
		user << "\blue The shield is now inactive."
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return

/obj/item/weapon/cloaking_device/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The cloaking device is now active."
		src.icon_state = "shield1"
	else
		user << "\blue The cloaking device is now inactive."
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return