/obj/structure/rail
	name = "rail"
	desc = "A huge metal bar."
	icon = 'icons/obj/rails.dmi'
	icon_state = "rail"
	density = 0
	anchored = 1
	layer = BELOW_DOOR_LAYER
	
	var/glow = FALSE

/obj/structure/rail/Initialize()
	. = ..()
	
	if(glow)
		set_light(0.8, 0.6, 1, l_color = "#e9e9cf")
