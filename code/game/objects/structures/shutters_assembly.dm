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
			user.visible_message("[user] begins unsecuring the shutters assembly from the floor.", "You starts unsecuring the airlock assembly from the floor.")
		else
			user.visible_message("[user] begins securing the shutters assembly to the floor.", "You starts securing the airlock assembly to the floor.")

		if(do_after(user, 40,src))
			if(!src) return
			to_chat(user, "<span class='notice'>You [anchored? "un" : ""]secured the shutters assembly!</span>")
			anchored = !anchored

	else if(isCoil(W))
		var/obj/item/stack/cable_coil/C = W
		if (C.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of coil to wire the airlock assembly.</span>")
			return
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly.")
		if(do_after(user, 40,src) && anchored)
			if (C.use(1))
				to_chat(user, "<span class='notice'>You wire the airlock.</span>")

	else if(istype(W, /obj/item/airlock_electronics))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the shutters assembly.", "You start to install electronics into the airlock assembly.")

		if(do_after(user, 40, src))
			if(!src)
				return
			if(!user.drop(W, src))
				return
			to_chat(user, "<span class='notice'>You installed the shutters electronics!</span>")
			electronics = W

	else if(istype(W, /obj/item/device/assembly/signaler))
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
