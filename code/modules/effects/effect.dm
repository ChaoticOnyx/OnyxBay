/obj/effect/temp_visual
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 1 SECOND
	var/randomdir = TRUE
	var/timerid

/obj/effect/temp_visual/Initialize()
	. = ..()
	if(randomdir)
		set_dir(pick(GLOB.cardinal))

	QDEL_IN(src, duration)
