#define STATE_UNANCHORED  0
#define STATE_EMPTY       1
#define STATE_WIRED       2
#define STATE_SIGNALLER   3

/obj/structure/pdoor_assembly
	name = "shutters assembly"
	icon = 'icons/obj/doors/rapid_pdoor_assembly.dmi'
	anchored = FALSE
	density = TRUE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/state = STATE_EMPTY
	var/obj/item/device/assembly/signaler/signaler = null
	var/base_icon = null
	var/material_path = null
	var/door_path = null

/obj/structure/pdoor_assembly/Destroy()
	QDEL_NULL(signaler)
	return ..()

/obj/structure/pdoor_assembly/update_icon()
	switch(state)
		if(STATE_EMPTY)
			icon_state = "[base_icon]_st0"
		if(STATE_WIRED)
			icon_state = "[base_icon]_st1"
		if(STATE_SIGNALLER)
			icon_state = "[base_icon]_st2"

/obj/structure/pdoor_assembly/attackby(obj/item/W, mob/user)
	switch(state)
		if(STATE_UNANCHORED)
			if(isWelder(W))
				deconstruct_assembly(W, user)
			if(isWrench(W))
				wrench_floor_bolts(user)
		if(STATE_EMPTY)
			if(isWrench(W))
				wrench_floor_bolts(user)
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

/obj/structure/pdoor_assembly/proc/deconstruct_assembly(obj/item/weldingtool/WT, mob/user)
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

/obj/structure/pdoor_assembly/wrench_floor_bolts(mob/user, delay = 40)
	. = ..()

	if(anchored)
		state = STATE_EMPTY
	else
		state = STATE_UNANCHORED

/obj/structure/pdoor_assembly/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if (C.get_amount() < 1)
		to_chat(user, SPAN_WARNING("You need one length of coil to wire \the [src] ."))
		return

	user.visible_message("[user] wires \the [src].", "You start to wire \the [src].")
	if(do_after(user, 40, src) && anchored)
		if (C.use(1))
			to_chat(user, SPAN_NOTICE("You wire \the [src]."))
			state = STATE_WIRED
			update_icon()

/obj/structure/pdoor_assembly/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
	user.visible_message("[user] cuts the wires from \the [src].", "You start to cut the wires from \the [src].")

	if(do_after(user, 40, src))
		to_chat(user, SPAN_NOTICE("You cut \the [src] wires!"))
		new /obj/item/stack/cable_coil(loc, 1)
		state = STATE_EMPTY
		update_icon()

/obj/structure/pdoor_assembly/proc/add_signaler(obj/item/device/assembly/signaler/W, mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	user.visible_message("[user] installs the signaller into \the [src].", "You start to install signaller into \the [src].")

	if(do_after(user, 40, src))
		if(!user.drop(W, src))
			return

		to_chat(user, SPAN_NOTICE("You installed signaller into \the [src]!"))
		signaler = W
		state = STATE_SIGNALLER
		update_icon()

/obj/structure/pdoor_assembly/proc/remove_signaler(mob/user)
	user.visible_message("\The [user] starts removing the signaller from \the [src].", "You start removing the signaller from \the [src].")

	if(do_after(user, 40, src))
		to_chat(user, SPAN_NOTICE("You removed \the signaller!"))
		state = STATE_WIRED
		signaler.dropInto(loc)
		signaler = null
		update_icon()

/obj/structure/pdoor_assembly/proc/finish_assembly(mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	to_chat(user, SPAN_NOTICE("Now finishing \the shutters."))

	if(do_after(user, 40, src))
		new door_path(loc, signaler?.code, signaler?.frequency, dir)
		qdel(src)

/obj/structure/pdoor_assembly/blast
	name = "blast door assembly"
	icon = 'icons/obj/doors/rapid_pdoor_assembly.dmi'
	icon_state = "blast_st0"
	base_icon = "blast"
	material_path = /obj/item/stack/material/plasteel
	door_path = /obj/machinery/door/blast/regular

/obj/structure/pdoor_assembly/shutters
	name = "shutters assembly"
	icon = 'icons/obj/doors/rapid_pdoor_assembly.dmi'
	icon_state = "shutter_st0"
	base_icon = "shutter"
	material_path = /obj/item/stack/material/steel
	door_path = /obj/machinery/door/blast/shutters


#undef STATE_UNANCHORED
#undef STATE_EMPTY
#undef STATE_WIRED
#undef STATE_SIGNALLER
