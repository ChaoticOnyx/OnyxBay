/obj/effect/effect/cig_smoke
	name = "smoke"
	icon_state = "smallsmoke"
	icon = 'icons/effects/effects.dmi'
	opacity = 0
	anchored = 1
	mouse_opacity = 0
	layer = ABOVE_HUMAN_LAYER
	var/time_to_live = 100

/obj/effect/effect/cig_smoke/New()
	..()
	set_dir(pick(GLOB.cardinal))
	pixel_x = rand(-13, 13)
	pixel_y = rand(-10, 13)

/obj/effect/effect/cig_smoke/Initialize()
	. = ..()
	QDEL_IN(src, time_to_live)
