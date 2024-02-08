
/obj/item/device/emag
	name = "\improper PDA"
	desc = "A portable microcomputer by Tricktornic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "emag0"
	item_state = "electronic"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_ID | SLOT_BELT

	var/revealed = FALSE
	var/obj/item/cell/device/my_cell = null
	var/charge_per_usage = 20

/obj/item/device/emag/Initialize()
	. = ..()
	if(!my_cell)
		my_cell = new /obj/item/cell/device/high

/obj/item/device/emag/resolve_attackby(atom/A, mob/user)
	if(!revealed)
		return ..(A, user)

	if(!my_cell.check_charge(charge_per_usage))
		return TRUE

	A.emag_act(floor(my_cell.charge / charge_per_usage), user, src)
	my_cell.use(charge_per_usage)
	A.add_fingerprint(user)

	log_and_message_admins("emagged \an [A].")

	return TRUE

/obj/item/device/emag/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 1)
		. += "\nThe number [round(CELL_PERCENT(my_cell))] is displayed in the corner of the screen."

/obj/item/device/emag/attack_self(mob/user)
	add_fingerprint(user)
	to_chat(user, "You [revealed ? "reveal" : "hide"] \the [src]'s hidden mechanism.")
	revealed = !revealed

	if(revealed)
		name = "modified PDA"
		desc += " It looks extremely suspicious, with some sort of a weird mechanism revealed."
		icon_state = "emag1"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = "emag0"
	return

/obj/item/device/emag/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/cell/device))
		if(my_cell)
			return
		if(!user.drop(I, src))
			return
		my_cell = I
		to_chat(user, SPAN("notice", "You insert \the [I] into \the [src]."))
		return

	if(isScrewdriver(I))
		remove_cell(user)
		playsound(user.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		return

	return ..()

/obj/item/device/emag/AltClick()
	if(Adjacent(usr))
		remove_cell(usr)
	else
		return ..()

/obj/item/device/emag/proc/remove_cell(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.pick_or_drop(my_cell)
		to_chat(H, SPAN("notice", "You remove \the [my_cell] from \the [src]."))
	else
		my_cell.forceMove(get_turf(src))

	my_cell = null
