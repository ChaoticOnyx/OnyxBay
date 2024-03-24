/obj/structure/hoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"

	icon_state = "hoop"
	icon = 'icons/obj/basketball.dmi'

	anchored = TRUE
	density = TRUE
	throwpass = TRUE

/obj/structure/hoop/CanPass(atom/movable/mover, turf/target)
	if(mover.throwing && isitem(mover) && !istype(mover, /obj/item/projectile))
		var/obj/item/throwing_item = mover

		if(prob(50))
			throwing_item.forceMove(loc)
			visible_message(SPAN_NOTICE("Swish! \the [throwing_item] lands in \the [src]."))
		else
			visible_message(SPAN_WARNING("\The [throwing_item] bounces off of \the [src]'s rim!"))

		return FALSE

	return ..()
