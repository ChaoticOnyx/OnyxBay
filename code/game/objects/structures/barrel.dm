/obj/structure/barrel
	name = "barrel"
	desc = "A barrel."
	density = 1
	anchored = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"

/obj/structure/barrel/Initialize()
	. = ..()
	set_light(1, 0.1, 3, 2, "#da6a02")
	particles = new /particles/bonfire()
