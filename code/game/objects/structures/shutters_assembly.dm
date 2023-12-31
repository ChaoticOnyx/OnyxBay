/obj/structure/shutters_assembly
	name = "shutters assembly"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter0"
	anchored = 0
	density = 1
	w_class = ITEM_SIZE_NO_CONTAINER
	var/state = 0
	var/obj/item/device/assembly/signaler/signaler = null
	var/obj/item/airlock_electronics/electronics = null
	var/code = null
	var/frequency = null

/obj/structure/shutters_assembly/Initialize()
	. = ..()

/obj/structure/shutters_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W) && state == 0)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		if(anchored)
			user.visible_message("[user] begins unsecuring the shutters assembly from the floor.", "You starts unsecuring the shutters assembly from the floor.")
		else
			user.visible_message("[user] begins securing the shutters assembly to the floor.", "You starts securing the shutters assembly to the floor.")

		if(do_after(user, 40,src))
			if(!src) return
			to_chat(user, "<span class='notice'>You [anchored? "un" : ""]secured the shutters assembly!</span>")
			anchored = !anchored

	else if(isCoil(W) && state == 0 && anchored)
		var/obj/item/stack/cable_coil/C = W
		if (C.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of coil to wire the shutters assembly.</span>")
			return
		user.visible_message("[user] wires the shutters assembly.", "You start to wire the shutters assembly.")
		if(do_after(user, 40,src) && anchored)
			if (C.use(1))
				to_chat(user, "<span class='notice'>You wire the shutters.</span>")
				src.state = 1

	else if(isWirecutter(W) && state == 1 && !in_use)
		in_use = TRUE
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("[user] cuts the wires from the shutters assembly.", "You start to cut the wires from shutters assembly.")

		if(do_after(user, 40,src))
			if(!src) return
			to_chat(user, "<span class='notice'>You cut the shutters wires.!</span>")
			new /obj/item/stack/cable_coil(src.loc, 1)
			src.state = 0
		in_use = FALSE

	else if(istype(W, /obj/item/airlock_electronics) && state == 1)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the shutters assembly.", "You start to install electronics into the shutters assembly.")

		if(do_after(user, 40, src))
			if(!src)
				return
			if(!user.drop(W, src))
				return
			to_chat(user, "<span class='notice'>You installed the shutters electronics!</span>")
			electronics = W
			state = 2

	else if(isCrowbar(W) && !in_use && (state == 2 || state == 3))
		//This should never happen, but just in case I guess
		if (!electronics)
			to_chat(user, "<span class='notice'>There was nothing to remove.</span>")
			src.state = 1
			return

		in_use = TRUE
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		if(electronics && state == 2)
			user.visible_message("\The [user] starts removing the electronics from the airlock assembly.", "You start removing the electronics from the airlock assembly.")

			if(do_after(user, 40,src))
				if(!src) return
				to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")
				src.state = 1
				electronics.dropInto(loc)
				electronics = null
			in_use = FALSE
		else if(signaler && state == 3)
			user.visible_message("\The [user] starts removing the signaller from the shutters assembly.", "You start removing the electronics from the shutters assembly.")

			if(do_after(user, 40,src))
				if(!src) return
				to_chat(user, "<span class='notice'>You removed the signaller electronics!</span>")
				src.state = 2
				signaler.dropInto(loc)
				signaler = null
			in_use = FALSE

	else if(istype(W, /obj/item/device/assembly/signaler) && state == 2)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the signaller into the shutter assembly.", "You start to install signaller into the shutters assembly.")

		if(do_after(user, 40, src))
			if(!src)
				return
			if(!user.drop(W, src))
				return
			to_chat(user, "<span class='notice'>You installed the shutters signaller!</span>")
			signaler = W
			code = signaler.code
			frequency = signaler.frequency
			src.state = 3

	else if(isScrewdriver(W) && state == 3)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		to_chat(user, "<span class='notice'>Now finishing the shutters.</span>")

		if(do_after(user, 40,src))
			new /obj/machinery/door/blast/shutters(src.loc, code, frequency, usr.dir)
			qdel(src)
	else
		..()
