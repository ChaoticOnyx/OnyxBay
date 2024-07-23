/obj/structure/firedoor_assembly
	name = "\improper emergency shutter assembly"
	desc = "It can save lives."
	icon = 'icons/obj/doors/doorhazard.dmi'
	icon_state = "door_construction"
	anchored = 0
	opacity = 0
	density = 1
	var/wired = 0

/obj/structure/firedoor_assembly/on_update_icon()
	if(anchored)
		icon_state = "door_anchored"
	else
		icon_state = "door_construction"

/obj/structure/firedoor_assembly/attackby(obj/item/C, mob/user)
	if(isCoil(C) && !wired && anchored)
		var/obj/item/stack/cable_coil/cable = C
		if (cable.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of coil to wire \the [src].</span>")
			return
		user.visible_message("[user] wires \the [src].", "You start to wire \the [src].")
		if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG) && !wired && anchored)
			if (cable.use(1))
				wired = 1
				to_chat(user, "<span class='notice'>You wire \the [src].</span>")

	else if(isWirecutter(C) && wired )
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("[user] cuts the wires from \the [src].", "You start to cut the wires from \the [src].")

		if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
			if(!src) return
			to_chat(user, "<span class='notice'>You cut the wires!</span>")
			new /obj/item/stack/cable_coil(src.loc, 1)
			wired = 0

	else if(istype(C, /obj/item/airalarm_electronics) && wired)
		if(anchored)
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='warning'>[user] has inserted a circuit into \the [src]!</span>",
								  "You have inserted the circuit into \the [src]!")
			new /obj/machinery/door/firedoor(src.loc)
			qdel(C)
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You must secure \the [src] first!</span>")
	else if(isWrench(C))
		anchored = !anchored
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] has [anchored ? "" : "un" ]secured \the [src]!</span>",
							  "You have [anchored ? "" : "un" ]secured \the [src]!")
		update_icon()
	else if(!anchored && isWelder(C))
		var/obj/item/weldingtool/WT = C
		user.visible_message("<span class='warning'>[user] dissassembles \the [src].</span>",
			"You start to dissassemble \the [src].")
		if(!WT.use_tool(src, user, delay = 4 SECONDS, amount = 1))
			return

		if(QDELETED(src) || !user)
			return

		user.visible_message("<span class='warning'>[user] has dissassembled \the [src].</span>",
								"You have dissassembled \the [src].")
		new /obj/item/stack/material/steel(src.loc, 2)
		qdel(src)
	else
		..(C, user)

/obj/structure/firedoor_assembly/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("delay" = 5 SECONDS, "cost" = 16)

	else if(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS)
		return list("delay" = 2 SECONDS, "cost" = 1)

	return FALSE

/obj/structure/firedoor_assembly/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			show_splash_text(user, "circuit installed", SPAN("notice", "You install the circuit into \the [src]!"))
			new /obj/machinery/door/firedoor(get_turf(src))
			qdel_self()
			return TRUE

		if(RCD_DECONSTRUCT)
			qdel_self()
			return TRUE

	return FALSE
