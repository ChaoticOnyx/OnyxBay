/obj/window
	name = "window"
	icon = 'structures.dmi'
	icon_state = "window"
	desc = "A window."
	density = 1
	var/health = 14.0
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER

// Prefab windows to make it easy...



// Basic

/obj/window/basic/north
	dir = NORTH

/obj/window/basic/east
	dir = EAST

/obj/window/basic/west
	dir = WEST

/obj/window/basic/south
	dir = SOUTH

/obj/window/basic/northwest
	dir = NORTHWEST

/obj/window/basic/northeast
	dir = NORTHEAST

/obj/window/basic/southwest
	dir = SOUTHWEST

/obj/window/basic/southeast
	dir = SOUTHEAST

// Pod
/obj/window_pod
	name = "window"
	icon = 'shuttle.dmi'
	icon_state = "window1"
	desc = "A thick window secured into its frame."
	dir = 2
	anchored = 1
	density = 1

/obj/window_pod/attack_hand()
	return

/obj/window_pod/attack_paw()
	return

/obj/window_pod/blob_act()
	return

/obj/window_pod/bullet_act(flag)
	return

/obj/window_pod/ex_act(severity)
	return

/obj/window_pod/hitby(AM as mob|obj)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] was hit by [AM].</B>"), 1)
	playsound(src.loc, 'Glasshit.ogg', 100, 1)
	return

/obj/window/meteorhit()
	return

/obj/window_pod/CanPass(atom/movable/mover, turf/source, height=0, air_group=0)
	if(istype(mover, /obj/beam))
		return 1

	return 0

/obj/window_pod/Move()
	return 0

// Reinforced

/obj/window/reinforced
	reinf = 1
	explosionstrength = 1
	icon_state = "rwindow"
	name = "reinforced window"

/obj/window/reinforced/north
	dir = NORTH

/obj/window/reinforced/east
	dir = EAST

/obj/window/reinforced/west
	dir = WEST

/obj/window/reinforced/south
	dir = SOUTH

/obj/window/reinforced/northwest
	dir = NORTHWEST

/obj/window/reinforced/northeast
	dir = NORTHEAST

/obj/window/reinforced/southwest
	dir = SOUTHWEST

/obj/window/reinforced/southeast
	dir = SOUTHEAST
/*/obj/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	var/pressure = air.return_pressure() //DERP22
	if(pressure >= 200)
		del src
*/