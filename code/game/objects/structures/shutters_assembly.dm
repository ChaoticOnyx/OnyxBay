#define STATE_UNANCHORED  0
#define STATE_EMPTY       1
#define STATE_WIRED       2
#define STATE_SIGNALLER   3

/obj/structure/shutters_assembly
	name = "shutters assembly"
	icon = 'icons/obj/doors/shutter_assembly.dmi'
	icon_state = "shutter_st0"
	anchored = FALSE
	density = TRUE
	var/state = STATE_EMPTY
	var/obj/item/device/assembly/signaler/signaler = null

/obj/structure/shutters_assembly/Destroy()
	QDEL_NULL(signaler)
	return ..()

/obj/structure/shutters_assembly/update_icon()
	switch(state)
		if(STATE_EMPTY)
			icon_state = "shutter_st0"
		if(STATE_WIRED)
			icon_state = "shutter_st1"
		if(STATE_SIGNALLER)
			icon_state = "shutter_st2"

/obj/structure/shutters_assembly/attackby(obj/item/W, mob/user)
	switch(state)
		if(STATE_UNANCHORED)
			if(isWelder(W))
				deconstruct_assembly(W, user)
			if(isWrench(W))
				wrench_assembly()
		if(STATE_EMPTY)
			if(isWrench(W))
				wrench_assembly(user)
			if(isCoil(W))
				add_cable(W, user)
		if(STATE_WIRED)
			if(isWirecutter(W))
				remove_cable(user)
			if(istype(W, /obj/item/device/assembly/signaler))
				add_signaler(W, user)
		if(STATE_SIGNALLER)
			if(isCrowbar(W))
				remove_signaler(user)
			if(isScrewdriver(W))
				finish_assembly(user)

/obj/structure/shutters_assembly/proc/deconstruct_assembly(obj/item/weldingtool/WT, mob/user)
	if (WT.remove_fuel(0, user))
		playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
		user.visible_message("[user] dissassembles \the [src] .", "You start to dissassemble \the [src] .")
		if(do_after(user, 40, src))
			if(!WT.isOn())
				return

			to_chat(user, SPAN_NOTICE("You dissasembled \the [src] a!"))
			new /obj/item/stack/material/steel(loc, 10)
			qdel(src)
	else
		to_chat(user, SPAN_NOTICE("You need more welding fuel."))
		return

/obj/structure/shutters_assembly/proc/wrench_assembly(mob/user)
	playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
	user.visible_message("[user] begins [anchored? "un" : ""]securing \the [src]  from the floor.", "You starts [anchored? "un" : ""]securing \the [src] from the floor.")

	if(do_after(user, 40, src))
		to_chat(user, SPAN_NOTICE("You [anchored? "un" : ""]secured \the [src]!"))
		anchored = !anchored

/obj/structure/shutters_assembly/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if (C.get_amount() < 1)
		to_chat(user, SPAN_WARNING("You need one length of coil to wire \the [src] ."))
		return

	user.visible_message("[user] wires \the [src].", "You start to wire \the [src].")
	if(do_after(user, 40, src) && anchored)
		if (C.use(1))
			to_chat(user, SPAN_NOTICE("You wire \the [src]."))
			state = STATE_WIRED
			update_icon()

/obj/structure/shutters_assembly/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
	user.visible_message("[user] cuts the wires from \the [src].", "You start to cut the wires from \the [src].")

	if(do_after(user, 40, src))
		to_chat(user, SPAN_NOTICE("You cut \the [src] wires!"))
		new /obj/item/stack/cable_coil(loc, 1)
		state = STATE_EMPTY
		update_icon()

/obj/structure/shutters_assembly/proc/add_signaler(obj/item/device/assembly/signaler/W, mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	user.visible_message("[user] installs the signaller into \the [src].", "You start to install signaller into \the [src].")

	if(do_after(user, 40, src))
		if(!user.drop(W, src))
			return

		to_chat(user, SPAN_NOTICE("You installed signaller into \the [src]!"))
		signaler = W
		state = STATE_SIGNALLER
		update_icon()

/obj/structure/shutters_assembly/proc/remove_signaler(mob/user)
	user.visible_message("\The [user] starts removing the signaller from \the [src].", "You start removing the signaller from \the [src].")

	if(do_after(user, 40, src))
		to_chat(user, SPAN_NOTICE("You removed \the signaller!"))
		state = STATE_WIRED
		signaler.dropInto(loc)
		signaler = null
		update_icon()

/obj/structure/shutters_assembly/proc/finish_assembly(mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	to_chat(user, SPAN_NOTICE("Now finishing \the shutters."))

	if(do_after(user, 40, src))
		new /obj/machinery/door/blast/shutters(loc, signaler?.code, signaler?.frequency, dir)
		qdel(src)

#undef STATE_UNANCHORED
#undef STATE_EMPTY
#undef STATE_WIRED
#undef STATE_SIGNALLER
