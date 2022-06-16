/obj/item/reagent_containers/food/packaged/tin
	name = "Can of some product"
	nutriment_amt = 6
	var/fill_color = COLOR_WHITE
	var/tin_fill_type
	var/stabs_to_open = 5
	bitesize = 4
	icon = 'icons/obj/tins.dmi'
	icon_state = "closedcan"

/obj/item/reagent_containers/food/packaged/tin/Initialize()
	. = ..()
	stabs_to_open = rand(1, stabs_to_open)
	update_icon()

/obj/item/reagent_containers/food/packaged/tin/attackby(obj/item/W, mob/user)
	. = ..()
	if(is_sharp(W) && !is_open_container())
		if(prob(25) && !--stabs_to_open)
			to_chat(user, SPAN("notice", "You open \the [src]!"))
			atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			update_icon()
		else
			to_chat(user, SPAN("notice", "You failed in opening \the [src]"))
		playsound(loc, 'sound/items/shpshpsh.ogg', 50, 1)
		return

/obj/item/reagent_containers/food/packaged/tin/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/packaged/tin/On_Consume(mob/M)
	return

/obj/item/reagent_containers/food/packaged/tin/get_bitecount()
	return

/obj/item/reagent_containers/food/packaged/tin/update_icon()
	overlays.Cut()
	if(is_open_container())
		icon_state = "emptycan"
		if(bitecount <= round(bitesize / 2, 1))
			overlays += image(icon, src, "filled")
		else
			overlays += image(icon, src, "halffilled")
	else
		icon_state = initial(icon_state)
	if(!reagents.total_volume)
		overlays.Cut()
	if(blood_overlay)
		overlays += blood_overlay
