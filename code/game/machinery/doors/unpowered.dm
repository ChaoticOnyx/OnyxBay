/obj/machinery/door/unpowered
	autoclose = 0
	var/locked = 0

/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(src.locked)
		return
	..()
	return

/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/melee/energy/blade))	return
	if(src.locked)	return
	..()
	return

/obj/machinery/door/unpowered/emag_act()
	return -1

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1


/obj/machinery/door/unpowered/vent_shaft
	name = "Vent Shaft"
	desc = "Used to hide ugly pipes and cabels."
	icon = 'icons/obj/doors/doormorgue.dmi'
	icon_state = "door1"

/obj/machinery/door/unpowered/vent_shaft/inoperable(additional_flags = 0)
	return (stat & (BROKEN|additional_flags))
