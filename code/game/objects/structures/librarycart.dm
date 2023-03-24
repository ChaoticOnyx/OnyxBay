//I'm almost not ashamed of the fact that this is a recycling of a cleaner's cart. I will try not to delete the old hints, suddenly they will be needed.

/obj/structure/librarycart
	name = "library cart"
	desc = "The ultimate in library cart! Has lot space for books!"
	icon = 'icons/obj/library.dmi'
	icon_state = "library_cart-0"
	anchored = 0
	density = 1
	atom_flags = ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_CLIMBABLE
	pull_slowdown = PULL_SLOWDOWN_LIGHT
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite




/obj/structure/librarycart/New()




/obj/structure/librarycart/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/book))
		if(user.drop(O, src))
			update_icon()
	else
		..()
	return


/obj/structure/librarycart/attack_hand(mob/user as mob)
	if(contents.len)
		var/list/titles = list()
		for(var/obj/item in contents)
			var/item_name = item.name
			if(istype(item, /obj/item/book))
				var/obj/item/book/B = item
				item_name = B.title
			titles[item_name] = item
		var/title = input("Which book would you like to remove from the shelf?") as null|anything in titles
		if(title)
			if(!CanPhysicallyInteract(user))
				return
			var/obj/choice = titles[title]
			ASSERT(choice)
			if(ishuman(user))
				user.pick_or_drop(choice)
			else
				choice.forceMove(loc)
			update_icon()

/obj/structure/librarycart/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/book/b in contents)
				qdel(b)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/book/b in contents)
				if (prob(50)) b.loc = (get_turf(src))
				else qdel(b)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				for(var/obj/item/book/b in contents)
					b.loc = (get_turf(src))
				qdel(src)
			return
	return

/obj/structure/librarycart/update_icon()
	icon_state = "library_cart-[clamp(contents.len, 0, 4)]"
