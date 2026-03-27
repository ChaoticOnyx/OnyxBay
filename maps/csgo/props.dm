
/obj/structure/prop
	name = "prop"
	desc = "A prop."
	icon = 'maps/csgo/props.dmi'
	icon_state = ""
	anchored = TRUE
	density = TRUE
	opacity = FALSE

	var/catch_bullet_prob = 100

/obj/structure/prop/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile))
		return prob(catch_bullet_prob)
	return !density
