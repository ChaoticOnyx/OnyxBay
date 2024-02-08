/obj/item/device/handcharger
	name = "hand-crank charger"
	desc = "A handheld device used for converting your calories into precious electricity."
	description_info = "You can insert a power cell into this device. The power cell can be charged by using this device multiple times. In fact, using it A LOT. The power cell can be ejected by either a verb, or by alt-clicking."
	description_fluff = "Truly an ancient technology, a man-powered dynamo, it's pretty much relevant to the day, as electricity is still finite, and humans still have hands."
	icon_state = "handcharger0"
	item_state = "multitool"
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 300)

	var/charge_per_use = 0
	var/obj/item/cell/my_cell = null
	var/obj/item/stock_parts/capacitor/my_capacitor = null
	var/start_empty = FALSE

/obj/item/device/handcharger/empty
	start_empty = TRUE


/obj/item/device/handcharger/Initialize()
	. = ..()
	if(!start_empty && !my_capacitor)
		my_capacitor = new /obj/item/stock_parts/capacitor(src)
		charge_per_use = my_capacitor.rating
	update_icon()

/obj/item/device/handcharger/Destroy()
	QDEL_NULL(my_cell)
	QDEL_NULL(my_capacitor)
	. = ..()

/obj/item/device/handcharger/proc/remove_cell(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.pick_or_drop(my_cell)
		to_chat(H, SPAN("notice", "You remove \the [my_cell] from \the [src]."))
	else
		my_cell.forceMove(get_turf(src))

	playsound(loc, "bullet_insert", 50, 1)
	my_cell = null
	update_icon()

/obj/item/device/handcharger/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) > 2)
		return

	. += "\nThere's [my_cell ? "a" : "no"] power cell in \the [src]."
	if(my_cell)
		. += "\nCurrent charge: [my_cell.charge]"

/obj/item/device/handcharger/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cell))
		if(my_cell)
			to_chat(user, SPAN("notice", "There's already a power cell inside."))
			return
		if(!user.drop(I, src))
			return
		my_cell = I
		playsound(loc, "bullet_insert", 50, 1)
		to_chat(user, SPAN("notice", "You insert \the [I] into \the [src]."))
		update_icon()
		return

	if(istype(I, /obj/item/stock_parts/capacitor))
		if(my_capacitor)
			to_chat(user, SPAN("notice", "There's already a capacitor inside."))
			return
		if(!user.drop(I, src))
			return
		my_capacitor = I
		charge_per_use = my_capacitor.rating
		to_chat(user, SPAN("notice", "You install \the [I] into \the [src]."))
		update_icon()
		playsound(user.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		return

	if(isScrewdriver(I) && my_capacitor)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.pick_or_drop(my_capacitor)
			to_chat(H, SPAN("notice", "You uninstall \the [my_capacitor] from \the [src]."))
		else
			my_capacitor.forceMove(get_turf(src))
		my_capacitor = null
		charge_per_use = 0
		update_icon()
		playsound(user.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		return

	return ..()

/obj/item/device/handcharger/on_update_icon()
	icon_state = "handcharger[my_cell ? 1 : 0]"

	ClearOverlays()
	if(!my_capacitor)
		AddOverlays("handcharger-nocap")
	else if(my_cell)
		var/chargelevel = round(CELL_PERCENT(my_cell) * 4.0 / 99)
		AddOverlays("handcharger-o[chargelevel]")

/obj/item/device/handcharger/AltClick()
	if(Adjacent(usr))
		remove_cell(usr)

/obj/item/device/handcharger/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		remove_cell(user)
		return
	return ..()

/obj/item/device/handcharger/attack_self(mob/user)
	if(!ishuman(user))
		return

	if(!my_cell)
		to_chat(user, SPAN("notice", "The lever doesn't seem to be moving. Perhaps, a power cell must be inserted first."))
		return

	if(!my_capacitor)
		to_chat(user, SPAN("notice", "The [src] doesn't seem to react at all. Perhaps, it's missing some parts."))
		return

	var/mob/living/carbon/human/H = user

	if(H.nutrition > 10)
		THROTTLE(cooldown, 5)
		if(!cooldown)
			return

		flick("handcharger2", src)
		playsound(user.loc, 'sound/items/Ratchet.ogg', 50, 1)

		H.remove_nutrition(0.5)
		my_cell.give(charge_per_use)
	else
		to_chat(H, "You can barely move your fingers at this point. Perhaps, YOU are the one who needs recharging now.")

	update_icon()
