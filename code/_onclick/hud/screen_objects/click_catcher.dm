/client/proc/add_click_catcher()
	if(isnull(catcher))
		catcher = new

	screen |= catcher

/atom/movable/screen/click_catcher
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/atom/movable/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)

	if(modifiers["middle"] && istype(usr, /mob/living/carbon))
		var/mob/living/carbon/C = usr
		C.swap_hand()
	else
		var/turf/T = parse_caught_click_modifiers(modifiers, usr?.client, get_turf(usr))
		if(T)
			T.Click(location, control, params)

	. = 1
