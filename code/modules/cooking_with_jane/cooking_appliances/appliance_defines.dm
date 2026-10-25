/obj/effect/flick_light_overlay
	name = ""
	icon_state = ""
	mouse_opacity = 0

/obj/effect/flick_light_overlay/New(atom/movable/loc)
	..()
	if(istype(loc))
		icon = loc.icon
		layer = loc.layer + 0.01
		vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
		loc.vis_contents += src

/obj/machinery/cooking_with_jane
	name = "Default Cooking Appliance"
	desc = "Lookit me, I'm a cool machinery-doo."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/cooking = FALSE
