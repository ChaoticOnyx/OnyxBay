/mob/living
	var/atom/last_mouse_target // save last atom entry

/atom/MouseEntered(location, control, params)
	if(istype(usr, /mob/living))
		var/mob/living/L = usr
		if(istype(src, /obj/screen/click_catcher))
			var/obj/screen/S = src
			L.last_mouse_target = screen_loc2turf(S.screen_loc, get_turf(usr))
		else
			L.last_mouse_target = src