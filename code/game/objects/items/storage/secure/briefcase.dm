/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon_state = "secure"
	item_state = "sec-case"
	inspect_state = "secure-open"
	desc = "A large briefcase with a digital locking system."
	force = 8.0
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	mod_weight = 1.5
	mod_reach = 0.75
	mod_handy = 1.0
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/storage/secure/briefcase/attack_hand(mob/user)
	if(loc == user && locked)
		show_splash_text(user, "locked!")

	else if(loc == user && !locked)
		open(user)

	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)

	add_fingerprint(user)
