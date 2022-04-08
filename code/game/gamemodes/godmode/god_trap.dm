/obj/structure/deity/trap
	density = 0
	health = 1
	var/triggered = 0

/obj/structure/deity/trap/New()
	..()

	register_signal(get_turf(src), SIGNAL_ENTERED, /obj/structure/deity/trap/proc/trigger)

/obj/structure/deity/trap/Destroy()
	unregister_signal(get_turf(src), SIGNAL_ENTERED)

	return ..()

/obj/structure/deity/trap/Move()
	unregister_signal(get_turf(src), SIGNAL_ENTERED)

	. = ..()

	register_signal(get_turf(src), SIGNAL_ENTERED, /obj/structure/deity/trap/proc/trigger)

/obj/structure/deity/trap/attackby(obj/item/W as obj, mob/user as mob)
	trigger(user)
	return ..()

/obj/structure/deity/trap/bullet_act()
	return

/obj/structure/deity/trap/proc/trigger(atom/entered, atom/movable/enterer)
	if(triggered > world.time || !istype(enterer, /mob/living))
		return

	triggered = world.time + 30 SECONDS
