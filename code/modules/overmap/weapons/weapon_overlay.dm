
/obj/weapon_overlay
	name = "Weapon overlay"
	layer = 4
	mouse_opacity = FALSE
	layer = ABOVE_WINDOW_LAYER
	var/angle = 0 //Debug

/obj/weapon_overlay/proc/do_animation()
	return

/obj/weapon_overlay/railgun //Railgun sits on top of the ship and swivels to face its target
	name = "Railgun"
	icon_state = "railgun"

/obj/weapon_overlay/railgun_overlay/do_animation()
	flick("railgun_charge", src)

/obj/weapon_overlay/laser
	name = "Laser cannon"
	//icon = 'icons/obj/hand_of_god_structures.dmi'
	//icon_state = "conduit-red"

/obj/weapon_overlay/laser/do_animation()
	flick("laser", src)
