
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
	var/saved_name = ""

/obj/item/device/emag/Initialize()
	. = ..()

	if(!my_cell)
		my_cell = new /obj/item/cell/device/high

/obj/item/device/emag/resolve_attackby(atom/A, mob/user)
	if(!revealed)
		return ..(A, user)

	if(!my_cell?.check_charge(charge_per_usage))
		return TRUE

	if(A.emag_act(floor(my_cell.charge / charge_per_usage), user, src) != NO_EMAG_ACT)
		my_cell.use(charge_per_usage)
		A.add_fingerprint(user)

		log_and_message_admins("emagged \an [A].")

	return TRUE

/obj/item/device/emag/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 1)
		if(revealed)
			. += "\nThe number [round(CELL_PERCENT(my_cell))]% is displayed in the corner of the screen."
		else
			. += "\nThe time [stationtime2text()] is displayed in the corner of the screen."

/obj/item/device/emag/attack_self(mob/user)
	add_fingerprint(user)
	playsound(loc, 'sound/signals/ping5.ogg', 50, 0)
	to_chat(user, "\The [src] doesn't seem to react.")
	return

/obj/item/device/emag/proc/toggle_reveal(mob/user)
	revealed = !revealed
	if(user)
		add_fingerprint(user)
		to_chat(user, "You [revealed ? "reveal" : "hide"] \the [src]'s hidden mechanism.")

	if(revealed)
		SetName("modified PDA")
		name = "modified PDA"
		desc += " It looks extremely suspicious, with some sort of a weird mechanism revealed."
		icon_state = "emag1"
	else
		if(saved_name)
			SetName("PDA-[saved_name]")
		else
			name = initial(name)
		desc = initial(desc)
		icon_state = "emag0"
	return

/obj/item/device/emag/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/cartridge))
		to_chat(user, SPAN("notice", "\The [src] rejects the cartridge."))
		return

	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/idcard = I
		if(!idcard.registered_name)
			to_chat(user, SPAN("notice", "\The [src] rejects the ID."))
			return

		saved_name = "[idcard.registered_name] ([idcard.assignment])"
		if(!revealed)
			SetName("PDA-[saved_name]")
		to_chat(user, SPAN("notice", "Card scanned."))
		return

	if(istype(I, /obj/item/device/paicard))
		to_chat(user, SPAN("notice", "\The [src] rejects \the [I]."))
		return

	if(istype(I, /obj/item/pen))
		var/obj/item/pen/O = locate() in src
		if(O)
			to_chat(user, SPAN("notice", "There is already a pen in \the [src]."))
		else if(user.drop(I, src))
			to_chat(user, SPAN("notice", "You slide \the [I] into \the [src]."))
		return

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
		toggle_reveal(usr)
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

/obj/item/device/emag/verb/verb_remove_cell()
	set category = "Object"
	set name = "Remove cartridge"
	set src in usr

	if(issilicon(usr))
		return

	if(QDELETED(my_cell))
		to_chat(usr, SPAN("notice", "\The [src] does not have a cartridge in it."))
		return

	if(!can_use(usr))
		to_chat(usr, SPAN("notice", "You cannot do this."))
		return

	remove_cell(usr)

/obj/item/device/emag/verb/verb_reset_name()
	set category = "Object"
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		to_chat(usr, SPAN("notice", "You press the reset button on \the [src]."))
		saved_name = ""
		if(!revealed)
			name = initial(name)
	else
		to_chat(usr, SPAN("notice", "You cannot do this."))

/obj/item/device/emag/verb/verb_toggle_reveal()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if(!can_use(usr))
		to_chat(usr, SPAN("notice", "You cannot do this."))
		return

	toggle_reveal(usr)

/obj/item/device/emag/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if(!can_use(usr))
		to_chat(usr, SPAN("notice", "You cannot do this."))
		return

	var/obj/item/pen/O = locate() in src
	if(!O)
		to_chat(usr, SPAN("notice", "\The [src] does not have a pen in it."))
		return

	O.forceMove(get_turf(src))
	if(ismob(loc))
		var/mob/M = loc
		M.pick_or_drop(O)
	to_chat(usr, SPAN("notice", "You remove \the [O] from \the [src]."))

/obj/item/device/emag/proc/can_use()
	if(!ismob(loc))
		return FALSE

	var/mob/M = loc

	if(M.stat || M.restrained() || M.paralysis || M.stunned || M.weakened)
		return FALSE

	if((src in M.contents) || ( istype(loc, /turf) && in_range(src, M) ))
		return TRUE

	return FALSE
