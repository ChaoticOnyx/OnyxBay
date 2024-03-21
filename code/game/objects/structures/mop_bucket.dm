/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	w_class = ITEM_SIZE_NORMAL
	atom_flags = ATOM_FLAG_CLIMBABLE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	pull_slowdown = PULL_SLOWDOWN_TINY
	turf_height_offset = 14
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite


/obj/structure/mopbucket/New()
	create_reagents(180)
	..()

/obj/structure/mopbucket/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 1)
		. += "\n[src] \icon[src] contains [reagents.total_volume] unit\s of water!"

/obj/structure/mopbucket/ShiftClick(mob/user)
	. = ..()
	var/obj/O = user.get_active_hand()
	if(istype(O, /obj/item/mop))
		if(O.reagents.total_volume == 0)
			to_chat(user, "<span class='warning'>[O] is dry, you can't squeeze anything out!</span>")
			return
		if(reagents.total_volume == reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return
		O.reagents.remove_any(O.reagents.total_volume * SQUEEZING_DISPERSAL_RATIO)
		O.reagents.trans_to(src, O.reagents.total_volume)
		to_chat(user, "<span class='notice'>You squeeze the liquids from [O] to [src].</span>")

/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='warning'>\The [src] is out of water!</span>")
		else
			reagents.trans_to_obj(I, 5)
			to_chat(user, "<span class='notice'>You wet \the [I] in \the [src].</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
