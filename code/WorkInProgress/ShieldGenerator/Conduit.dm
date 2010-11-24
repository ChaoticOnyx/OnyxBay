/obj/shieldconduit
	name = "Shielding Conduit"
	icon = 'shield_cable.dmi'
	icon_state = "0-1"
	layer = 2.4
	level = 1
	var/d1
	var/d2
/obj/shieldconduit/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)


/obj/shieldconduit/hide(var/i)

	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	updateicon()

/obj/shieldconduit/proc/updateicon()
	return