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
	w_class = ITEM_SIZE_NO_CONTAINER
	var/state = STATE_EMPTY
	var/obj/item/device/assembly/signaler/signaler = null

/obj/structure/shutters_assembly/on_update_icon()
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
	on_update_icon()

/obj/structure/shutters_assembly/proc/deconstruct_assembly(obj/item/weldingtool/WT, mob/user)
	if (WT.remove_fuel(0, user))
		playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
		user.visible_message("[user] dissassembles the shutters assembly.", "You start to dissassemble the shutters assembly.")
		if(do_after(user, 40, src))
			if(!src || !WT.isOn())
				return

			to_chat(user, SPAN_NOTICE("You dissasembled the shutters assembly!"))
			new /obj/item/stack/material/steel(loc, 10)
			qdel(src)
	else
		to_chat(user, "<span class='notice'>You need more welding fuel.</span>")
		return

/obj/structure/shutters_assembly/proc/wrench_assembly(mob/user)
	playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
	if(anchored)
		user.visible_message("[user] begins unsecuring the shutters assembly from the floor.", "You starts unsecuring the shutters assembly from the floor.")
	else
		user.visible_message("[user] begins securing the shutters assembly to the floor.", "You starts securing the shutters assembly to the floor.")

	if(do_after(user, 40, src))

		to_chat(user, SPAN_NOTICE("You [anchored? "un" : ""]secured the shutters assembly!"))
		anchored = !anchored

/obj/structure/shutters_assembly/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if (C.get_amount() < 1)
		to_chat(user, SPAN_WARNING("You need one length of coil to wire the shutters assembly."))
		return

	user.visible_message("[user] wires the shutters assembly.", "You start to wire the shutters assembly.")
	if(do_after(user, 40, src) && anchored)
		if (C.use(1))
			to_chat(user, SPAN_NOTICE("You wire the shutters."))
			state = STATE_WIRED

/obj/structure/shutters_assembly/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
	user.visible_message("[user] cuts the wires from the shutters assembly.", "You start to cut the wires from shutters assembly.")

	if(do_after(user, 40, src))
		to_chat(user, SPAN_NOTICE("You cut the shutters wires!"))
		new /obj/item/stack/cable_coil(loc, 1)
		state = STATE_EMPTY

/obj/structure/shutters_assembly/proc/add_signaler(obj/item/device/assembly/signaler/W, mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	user.visible_message("[user] installs the signaller into the shutter assembly.", "You start to install signaller into the shutters assembly.")

	if(do_after(user, 40, src))
		if(!user.drop(W, src))
			return
		to_chat(user, SPAN_NOTICE("You installed the shutters signaller!"))
		signaler = W
		state = STATE_SIGNALLER

/obj/structure/shutters_assembly/proc/remove_signaler(mob/user)
	//This should never happen, but just in case I guess
	if (!signaler)
		to_chat(user, SPAN_NOTICE("There was nothing to remove."))
		state = STATE_WIRED
		return

	if(signaler && state == STATE_SIGNALLER)
		user.visible_message("\The [user] starts removing the signaller from the shutters assembly.", "You start removing the signaller from the shutters assembly.")

		if(do_after(user, 40, src))
			to_chat(user, SPAN_NOTICE("You removed the signaller!"))
			state = STATE_WIRED
			signaler.dropInto(loc)
			signaler = null

/obj/structure/shutters_assembly/proc/finish_assembly(mob/user)
	playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
	to_chat(user, SPAN_NOTICE("Now finishing the shutters."))

	if(do_after(user, 40, src))
		new /obj/machinery/door/blast/shutters(loc, signaler?.code, signaler?.frequency, dir)
		qdel(src)

#undef STATE_UNANCHORED
#undef STATE_EMPTY
#undef STATE_WIRED
#undef STATE_SIGNALLER
