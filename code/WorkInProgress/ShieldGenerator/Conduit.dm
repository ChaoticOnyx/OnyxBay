/obj/shieldconduit
	name = "Shielding Conduit"
	icon = 'shield_cable.dmi'
	icon_state = "0-1"
	layer = 2.4
	level = 1
	var/d1 = 0
	var/d2 = 0


/obj/shieldconduit/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1)
		Hide(T.intact)

/obj/shieldconduit/proc/GetConnections()
	var/list/L = list()

	var/turf/T

	T = get_step_3d(src, d1)

	L += power_list(T, src , d1, 1)

	T = get_step_3d(src, d2)

	L += power_list(T, src, d2, 1)

	return L


/obj/shieldconduit/proc/Hide(var/i)

	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	UpdateIcon()

/obj/shieldconduit/proc/UpdateIcon()
	icon_state = "[d1]-[d2][invisibility?"-f":""]"
	return