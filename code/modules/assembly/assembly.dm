/obj/item/device/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 100)
	throwforce = 2
	throw_range = 10
	origin_tech = list(TECH_MAGNET = 1)

	var/secured = TRUE
	var/list/attached_overlays = list()
	var/obj/item/device/assembly_holder/holder = null
	var/cooldown = 0//To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE

	var/const/WIRE_RECEIVE = 1        //Allows Pulsed(0) to call Activate()
	var/const/WIRE_PULSE = 2          //Allows Pulse(0) to act on the holder
	var/const/WIRE_PULSE_SPECIAL = 4  //Allows Pulse(0) to act on the holders special assembly
	var/const/WIRE_RADIO_RECEIVE = 8  //Allows Pulsed(1) to call Activate()
	var/const/WIRE_RADIO_PULSE = 16   //Allows Pulse(1) to send a radio message

	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/device/assembly/Destroy()
	holder = null
	return ..()

//What the device does when turned on
/obj/item/device/assembly/proc/activate()
	if(!secured)
		return FALSE

	THROTTLE(cooldown, 0.2 SECONDS)
	if(!cooldown)
		return FALSE

	return TRUE

//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
/obj/item/device/assembly/proc/pulsed(radio = 0)
	if(holder && (wires & WIRE_RECEIVE))
		activate()
	if(radio && (wires & WIRE_RADIO_RECEIVE))
		activate()
	return 1

//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
/obj/item/device/assembly/proc/pulse(radio = 0)
	if(holder && (wires & WIRE_PULSE))
		holder.process_activation(src, 1, 0)
	if(holder && (wires & WIRE_PULSE_SPECIAL))
		holder.process_activation(src, 0, 1)
//		if(radio && (wires & WIRE_RADIO_PULSE))
		//Not sure what goes here quite yet send signal?
	return 1

//Code that has to happen when the assembly is un\secured goes here
/obj/item/device/assembly/proc/toggle_secure()
	secured = !secured
	update_icon()
	return secured

//Called when an assembly is attacked by another
/obj/item/device/assembly/proc/attach_assembly(obj/A, mob/user)
	holder = new /obj/item/device/assembly_holder(get_turf(src))
	if(holder.attach(A, src, user))
		to_chat(user, SPAN("notice", "You attach \the [A] to \the [src]!"))
		return 1
	return 0

//Called when the holder is moved
/obj/item/device/assembly/proc/holder_movement()
	return

//Called when attack_self is called
/obj/item/device/assembly/interact(mob/user)
	return

/obj/item/device/assembly/attackby(obj/item/W, mob/user)
	if(isassembly(W))
		var/obj/item/device/assembly/A = W
		if((!A.secured) && (!secured))
			attach_assembly(A,user)
			return
	if(isScrewdriver(W))
		if(toggle_secure())
			to_chat(user, SPAN("notice", "\The [src] is ready!"))
		else
			to_chat(user, SPAN("notice", "\The [src] can now be attached!"))
		return
	..()
	return


/obj/item/device/assembly/Process()
	return PROCESS_KILL


/obj/item/device/assembly/examine(mob/user, infix)
	. = ..()

	if((in_range(src, user) || loc == user))
		if(secured)
			. += "\The [src] is ready!"
		else
			. += "\The [src] can be attached!"

/obj/item/device/assembly/attack_self(mob/user)
	if(!user)	return 0
	user.set_machine(src)
	interact(user)
	return 1

/obj/item/device/assembly/interact(mob/user)
	return //HTML MENU FOR WIRES GOES HERE

/obj/item/device/assembly/nano_host()
	if(istype(loc, /obj/item/device/assembly_holder))
		return loc.nano_host()
	return ..()

/obj/item/device/assembly/CanUseTopic(mob/user)
	if(!istype(user) || user.stat || !(get_top_holder_obj(src) in user.contents))
		return STATUS_CLOSE
	return STATUS_INTERACTIVE

/obj/item/device/assembly/forceMove(atom/new_loc)
	if(istype(loc, /atom/movable))
		if(istype(loc, /obj/item/gripper) && isrobot(loc.loc))
			unregister_signal(loc.loc, SIGNAL_MOVED)
		else
			unregister_signal(loc, SIGNAL_MOVED)
	if(istype(new_loc, /atom/movable))
		if(istype(new_loc, /obj/item/gripper) && isrobot(new_loc.loc))
			register_signal(new_loc.loc, SIGNAL_MOVED, nameof(.proc/retransmit_moved))
		else
			register_signal(new_loc, SIGNAL_MOVED, nameof(.proc/retransmit_moved))
	..()

/obj/item/device/assembly/proc/retransmit_moved(mover, old_loc, new_loc)
	SEND_SIGNAL(src, SIGNAL_MOVED, src, old_loc, new_loc)
