
/obj/machinery/door_control
	name = "Remote Door Control"
	icon = 'stationobjs.dmi'
	icon_state = "doorctrl00"
	desc = "A remote control switch for a door."
	var/icon_toggled = "doorctrl1"
	var/icon_normal = "doorctrl0"
	var/icon_nopower = "doorctrl-p"
	var/needspower = 1
	var/id = null
	var/toggled = "0"
	anchored = 1.0


/obj/machinery/door_control/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(needspower)
		use_power(5)
	icon_state = icon_toggled
	if(toggled == "1")
		toggled = "0"
	else
		toggled = "1"

	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			if (M.density)
				M.open()
				//TransmitNetworkPacket(PrependNetworkAddress("[M.get_password()] OPEN", M))
			else
				M.close()
				//TransmitNetworkPacket(PrependNetworkAddress("[M.get_password()] CLOSE", M))
	src.add_fingerprint(usr)
	sleep(10)
	icon_state = icon_normal + toggled

/obj/machinery/door_control/power_change()
	..()
	if(!needspower)
		return
	if(stat & NOPOWER)
		icon_state = icon_nopower
	else
		icon_state = icon_normal + toggled

/obj/machinery/driver_button
	name = "Mass Driver Button"
	icon = 'objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a Mass Driver."
	var/id = null
	var/active = 0
	anchored = 1.0
/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user as mob)

	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)
	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in machines)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

	return

/obj/machinery/vent_control
	name = "Remote Vent Control"
	icon = 'stationobjs.dmi'
	icon_state = "leverbig00"
	desc = "A heavy hydraulic control switch for the core vents. Pushing it towards the reactor opens the vents, pulling it away from the reactor closes the vents."
	var/icon_toggled = "leverbig01"
	var/icon_normal = "leverbig0"
	var/icon_nopower = "doorctrl-p"
	var/needspower = 0
	var/id = null
	var/toggled = "0"
	anchored = 1.0


/obj/machinery/vent_control/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/vent_control/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/vent_control/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/vent_control/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(needspower)
		use_power(5)
	icon_state = icon_toggled

	radioalert("CORE VENTS CYCLING","Core control computer")
	playsound(src.loc, 'warning-buzzer.ogg', 75)

	if(toggled == "1")
		toggled = "0"
	else
		toggled = "1"

	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			if (M.density)
				M.open()
				//TransmitNetworkPacket(PrependNetworkAddress("[M.get_password()] OPEN", M))
			else
				M.close()
				//TransmitNetworkPacket(PrependNetworkAddress("[M.get_password()] CLOSE", M))
	src.add_fingerprint(usr)

	icon_state = icon_normal + toggled

/obj/machinery/vent_control/power_change()
	..()
	if(!needspower)
		return
	if(stat & NOPOWER)
		icon_state = icon_nopower
	else
		icon_state = icon_normal + toggled