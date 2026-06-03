
/obj/structure/prop
	name = "prop"
	desc = "A prop."
	icon = 'maps/csgo/props.dmi'
	icon_state = ""
	anchored = TRUE
	density = TRUE
	opacity = FALSE

	var/l_max_bright = 0
	var/l_inner_range = 0
	var/l_outer_range = 0

	var/catch_bullet_prob = 100 // The chance of interrupting a moving projectile, from 0 to 100, as props don't rely on density for interrupting projectiles.
	var/embrasure = FALSE // If TRUE, it won't interrupt projectiles fired from an adjacent tile, regardless of the catch_bullet_prob.

	var/climbable = FALSE

/obj/structure/prop/Initialize()
	. = ..()
	if(l_max_bright)
		set_light(l_max_bright, l_inner_range, l_outer_range)
	if(climbable)
		atom_flags |= ATOM_FLAG_CLIMBABLE

/obj/structure/prop/examine()
	. = ..()
	if(climbable)
		. += SPAN("notice", "It's <b>climbable</b>.")
	if(catch_bullet_prob)
		. += SPAN("notice", "It has a <b>[catch_bullet_prob]%</b> chance to stop a bullet.")
		if(embrasure)
			. += SPAN("notice", "It can be used as an <b>embrasure</b>.")

/obj/structure/prop/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile))
		if(embrasure)
			var/obj/item/projectile/P = mover
			if(P.trajectory && abs(x - P.trajectory.starting_x) <= 1 && abs(y - P.trajectory.starting_y) <= 1) // Simple adjacency check.
				return TRUE
		if(climbable)
			var/mob/M = locate() in get_turf(src)
			if(istype(M))
				return TRUE
		return prob(catch_bullet_prob)
	return !density

/obj/structure/prop/crate
	name = "crate"
	desc = "A crate."
	icon_state = "crate"
	catch_bullet_prob = 40
	embrasure = TRUE
	turf_height_offset = 14
	climbable = TRUE

/obj/structure/prop/crate/secure/icon_state = "crate_secure"
/obj/structure/prop/crate/rough/icon_state = "crate_rough"
/obj/structure/prop/crate/oxy/icon_state = "crate_oxy"
/obj/structure/prop/crate/weapon/icon_state = "crate_weapon"
/obj/structure/prop/crate/rad/icon_state = "crate_rad"
/obj/structure/prop/crate/bin/icon_state = "crate_bin"
/obj/structure/prop/crate/cart/icon_state = "crate_cart"
/obj/structure/prop/crate/trash/icon_state = "crate_trash"


/obj/structure/prop/bin
	name = "large bin"
	desc = "A large bin."
	icon_state = "crate_bin"
	catch_bullet_prob = 25
	embrasure = TRUE
	turf_height_offset = 16
	climbable = TRUE

/obj/structure/prop/largecrate
	name = "large crate"
	desc = "A large crate."
	icon_state = "lagrecrate"

/obj/structure/prop/largecrate/tank/icon_state = "lagrecrate_tank"
/obj/structure/prop/largecrate/hydro/icon_state = "lagrecrate_hydro"
/obj/structure/prop/largecrate/ore1/icon_state = "lagrecrate_ore1"
/obj/structure/prop/largecrate/ore2/icon_state = "lagrecrate_ore2"
/obj/structure/prop/largecrate/wood1/icon_state = "lagrecrate_wood1"
/obj/structure/prop/largecrate/wood2/icon_state = "lagrecrate_wood2"
/obj/structure/prop/largecrate/wood3/icon_state = "lagrecrate_wood3"
/obj/structure/prop/largecrate/wood4/icon_state = "lagrecrate_wood4"

/obj/structure/prop/floodlight
	name = "floodlight"
	desc = "A floodlight."
	icon_state = "floodlight"
	l_max_bright = 1.0
	l_inner_range = 2
	l_outer_range = 8
	catch_bullet_prob = 40
	embrasure = TRUE

/obj/structure/prop/canister
	name = "canister"
	desc = "A heavy-duty gas canister."
	icon_state = "canister"
	catch_bullet_prob = 50
	embrasure = TRUE
	turf_height_offset = 21
	climbable = TRUE

/obj/structure/prop/canister/red/icon_state = "canister_red"
/obj/structure/prop/canister/orange/icon_state = "canister_orange"
/obj/structure/prop/canister/blue/icon_state = "canister_blue"
/obj/structure/prop/canister/black/icon_state = "canister_black"
/obj/structure/prop/canister/redws/icon_state = "canister_redws"
/obj/structure/prop/canister/grey/icon_state = "canister_grey"
/obj/structure/prop/canister/purple/icon_state = "canister_purple"

/obj/structure/prop/canister/broken
	name = "broken canister"
	desc = "A ruptured heavy-duty gas canister."
	icon_state = "bcanister"
	catch_bullet_prob = 25
	density = FALSE
	turf_height_offset = 12

/obj/structure/prop/canister/broken/red/icon_state = "bcanister_red"
/obj/structure/prop/canister/broken/orange/icon_state = "bcanister_orange"
/obj/structure/prop/canister/broken/blue/icon_state = "bcanister_blue"
/obj/structure/prop/canister/broken/black/icon_state = "bcanister_black"
/obj/structure/prop/canister/broken/redws/icon_state = "bcanister_redws"
/obj/structure/prop/canister/broken/grey/icon_state = "bcanister_grey"
/obj/structure/prop/canister/broken/purple/icon_state = "bcanister_purple"

/obj/structure/prop/door
	name = "door"
	desc = "It's locked."
	icon_state = "blast"
	catch_bullet_prob = 100
	density = TRUE
	opacity = TRUE

/obj/structure/prop/door/blast/icon_state = "blast"
/obj/structure/prop/door/shutter/icon_state = "shutter"
/obj/structure/prop/door/blast_old/icon_state = "blast_old"

/obj/structure/prop/door/open
	name = "open door"
	desc = "It's open.."
	icon_state = "blast"
	catch_bullet_prob = 0
	density = FALSE
	opacity = FALSE

/obj/structure/prop/door/open/blast/icon_state = "blast_open"
/obj/structure/prop/door/open/shutter/icon_state = "shutter_open"
/obj/structure/prop/door/open/blast_old/icon_state = "blast_old_open"

/obj/structure/prop/door/half
	name = "stuck door"
	desc = "It's stuck in a half-closed state."
	icon_state = "blast"
	catch_bullet_prob = 60
	density = TRUE
	opacity = FALSE
	climbable = TRUE

/obj/structure/prop/door/half/blast/icon_state = "blast_half"
/obj/structure/prop/door/half/shutter/icon_state = "shutter_half"
/obj/structure/prop/door/half/blast_old/icon_state = "blast_old_half"
