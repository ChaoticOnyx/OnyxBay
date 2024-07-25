/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "The ultimate in janitorial carts! Has space for water, mops, signs, trash bags, and more!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	atom_flags = ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_CLIMBABLE
	pull_slowdown = PULL_SLOWDOWN_LIGHT
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag	= null
	var/obj/item/mop/mymop = null
	var/obj/item/reagent_containers/spray/myspray = null
	var/obj/item/device/lightreplacer/myreplacer = null
	var/signs = 0	//maximum capacity hardcoded below


/obj/structure/janitorialcart/New()
	..()
	create_reagents(180)


/obj/structure/janitorialcart/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 1)
		. += "[src] \icon[src] contains [reagents.total_volume] unit\s of liquid!"


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/storage/bag/trash) && !mybag && user.drop(I, src))
		mybag = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/mop))
		if(I.reagents.total_volume < I.reagents.maximum_volume)	//if it's not completely soaked we assume they want to wet it, otherwise store it
			if(reagents.total_volume < 1)
				to_chat(user, "<span class='warning'>[src] is out of water!</span>")
			else
				reagents.trans_to_obj(I, I.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>You wet [I] in [src].</span>")
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
				return
		if(!mymop && user.drop(I, src))
			mymop = I
			update_icon()
			updateUsrDialog()
			to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/reagent_containers/spray) && !myspray && user.drop(I, src))
		myspray = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/device/lightreplacer) && !myreplacer && user.drop(I, src))
		myreplacer = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/caution))
		if(signs < 4)
			if(!user.drop(I, src))
				return
			signs++
			update_icon()
			updateUsrDialog()
			to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] can't hold any more signs.</span>")

	else if(istype(I, /obj/item/reagent_containers/vessel))
		var/obj/item/reagent_containers/vessel/V = I
		if(V.is_open_container())
			return // So we do not put them in the trash bag as we mean to fill the mop bucket

	else if(mybag)
		mybag.attackby(I, user)


/obj/structure/janitorialcart/attack_hand(mob/user)
	ui_interact(user)
	return

/obj/structure/janitorialcart/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/data[0]
	data["name"] = capitalize(name)
	data["bag"] = mybag ? capitalize(mybag.name) : null
	data["mop"] = mymop ? capitalize(mymop.name) : null
	data["spray"] = myspray ? capitalize(myspray.name) : null
	data["replacer"] = myreplacer ? capitalize(myreplacer.name) : null
	data["signs"] = signs ? "[signs] sign\s" : null

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "janitorcart.tmpl", "Janitorial cart", 240, 160)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr

	if(href_list["take"])
		switch(href_list["take"])
			if("garbage")
				if(mybag)
					if(user.pick_or_drop(mybag))
						to_chat(user, SPAN("notice", "You take [mybag] from [src]."))
					else
						to_chat(user, SPAN("notice", "You drop [mybag] from [src]."))
					mybag = null
			if("mop")
				if(mymop)
					if(user.pick_or_drop(mymop))
						to_chat(user, SPAN("notice", "You take [mymop] from [src]."))
					else
						to_chat(user, SPAN("notice", "You drop [mymop] from [src]."))
					mymop = null
			if("spray")
				if(myspray)
					if(user.pick_or_drop(myspray))
						to_chat(user, SPAN("notice", "You take [myspray] from [src]."))
					else
						to_chat(user, SPAN("notice", "You drop [myspray] from [src]."))
					myspray = null
			if("replacer")
				if(myreplacer)
					if(user.pick_or_drop(myreplacer))
						to_chat(user, SPAN("notice", "You take [myreplacer] from [src]."))
					else
						to_chat(user, SPAN("notice", "You drop [myreplacer] from [src]."))
					myreplacer = null
			if("sign")
				if(signs)
					var/obj/item/caution/Sign = locate() in src
					if(Sign)
						if(user.pick_or_drop(Sign))
							to_chat(user, SPAN("notice", "You take \a [Sign] from [src]."))
						else
							to_chat(user, SPAN("notice", "You drop \a [Sign] from [src]."))
						signs--
					else
						warning("[src] signs ([signs]) didn't match contents")
						signs = 0

	update_icon()
	updateUsrDialog()


/obj/structure/janitorialcart/on_update_icon()
	ClearOverlays()
	if(mybag)
		AddOverlays("cart_garbage")
	if(mymop)
		AddOverlays("cart_mop")
	if(myspray)
		AddOverlays("cart_spray")
	if(myreplacer)
		AddOverlays("cart_replacer")
	if(signs)
		AddOverlays("cart_sign[signs]")

/obj/item/key
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = ITEM_SIZE_TINY
