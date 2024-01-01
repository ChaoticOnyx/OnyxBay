#define STATE_EMPTY       0
#define STATE_WIRED       1
#define STATE_ELECTRONICS 2
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
	var/obj/item/airlock_electronics/electronics = null
	var/code = null
	var/frequency = null

/obj/structure/shutters_assembly/update_icon()
	switch(state)
		if(STATE_EMPTY)
			icon_state = "shutter_st0"
		if(STATE_WIRED)
			icon_state = "shutter_st1"
		if(STATE_ELECTRONICS)
			icon_state = "shutter_st2"
		if(STATE_SIGNALLER)
			icon_state = "shutter_st3"

/obj/structure/shutters_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if(isWelder(W) && state == STATE_EMPTY && !anchored)
		var/obj/item/weldingtool/WT = W
		if (WT.remove_fuel(0, user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
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

	if(isWrench(W) && state == STATE_EMPTY)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		if(anchored)
			user.visible_message("[user] begins unsecuring the shutters assembly from the floor.", "You starts unsecuring the shutters assembly from the floor.")
		else
			user.visible_message("[user] begins securing the shutters assembly to the floor.", "You starts securing the shutters assembly to the floor.")

		if(do_after(user, 40, src))
			if(!src)
				return

			to_chat(user, SPAN_NOTICE("You [anchored? "un" : ""]secured the shutters assembly!"))
			anchored = !anchored

	else if(isCoil(W) && state == STATE_EMPTY && anchored)
		var/obj/item/stack/cable_coil/C = W
		if (C.get_amount() < 1)
			to_chat(user, SPAN_WARNING("You need one length of coil to wire the shutters assembly."))
			return

		user.visible_message("[user] wires the shutters assembly.", "You start to wire the shutters assembly.")
		if(do_after(user, 40,src) && anchored)
			if (C.use(1))
				to_chat(user, SPAN_NOTICE("You wire the shutters."))
				state = STATE_WIRED

	else if(isWirecutter(W) && state == STATE_WIRED && !in_use)
		in_use = TRUE
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("[user] cuts the wires from the shutters assembly.", "You start to cut the wires from shutters assembly.")

		if(do_after(user, 40,src))
			if(!src)
				return
			to_chat(user, SPAN_NOTICE("You cut the shutters wires!"))
			new /obj/item/stack/cable_coil(loc, 1)
			state = STATE_EMPTY
		in_use = FALSE

	else if(istype(W, /obj/item/airlock_electronics) && state == STATE_WIRED)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the shutters assembly.", "You start to install electronics into the shutters assembly.")

		if(do_after(user, 40, src))
			if(!src)
				return

			if(!user.drop(W, src))
				return

			to_chat(user, SPAN_NOTICE("You installed the shutters electronics!"))
			electronics = W
			state = STATE_ELECTRONICS

	else if(isCrowbar(W) && !in_use && (state == STATE_ELECTRONICS || state == STATE_SIGNALLER))
		//This should never happen, but just in case I guess
		if (!electronics)
			to_chat(user, SPAN_NOTICE("There was nothing to remove."))
			state = STATE_WIRED
			return

		in_use = TRUE
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		if(electronics && state == STATE_ELECTRONICS)
			user.visible_message("\The [user] starts removing the electronics from the airlock assembly.", "You start removing the electronics from the airlock assembly.")

			if(do_after(user, 40,src))
				if(!src) return
				to_chat(user, SPAN_NOTICE("You removed the airlock electronics!"))
				src.state = STATE_WIRED
				electronics.dropInto(loc)
				electronics = null
			in_use = FALSE
		else if(signaler && state == STATE_SIGNALLER)
			user.visible_message("\The [user] starts removing the signaller from the shutters assembly.", "You start removing the electronics from the shutters assembly.")

			if(do_after(user, 40,src))
				if(!src) return
				to_chat(user, SPAN_NOTICE("You removed the signaller electronics!"))
				state = STATE_ELECTRONICS
				signaler.dropInto(loc)
				signaler = null
			in_use = FALSE

	else if(istype(W, /obj/item/device/assembly/signaler) && state == STATE_ELECTRONICS)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the signaller into the shutter assembly.", "You start to install signaller into the shutters assembly.")

		if(do_after(user, 40, src))
			if(!src)
				return
			if(!user.drop(W, src))
				return
			to_chat(user, SPAN_NOTICE("You installed the shutters signaller!"))
			signaler = W
			code = signaler.code
			frequency = signaler.frequency
			state = STATE_SIGNALLER

	else if(isScrewdriver(W) && state == STATE_SIGNALLER)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		to_chat(user, SPAN_NOTICE("Now finishing the shutters."))

		if(do_after(user, 40,src))
			new /obj/machinery/door/blast/shutters(src.loc, code, frequency, usr.dir)
			qdel(src)
	else
		..()
	update_icon()

#undef STATE_EMPTY
#undef STATE_WIRED
#undef STATE_ELECTRONICS
#undef STATE_SIGNALLER
