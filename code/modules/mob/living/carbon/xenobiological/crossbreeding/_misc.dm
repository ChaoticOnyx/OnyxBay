//Hypercharged slime cell - Charged Yellow
/obj/item/cell/high/slime_hypercharged
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with plasma. It almost hurts to touch."
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "yellow slime extract"
	maxcharge = 3000

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = ITEM_SIZE_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(loc))
		to_chat(user, SPAN_WARNING("You can't fit more than one barrier in the same space!"))
		return
	to_chat(user, SPAN_NOTICE("You squeeze [src]."))
	var/obj/B = new /obj/structure/barricade/slime(get_turf(loc))
	B.visible_message(SPAN_WARNING("[src] suddenly grows into a large, gelatinous barrier!"))
	qdel(src)

//Slime barricade - Chilling Grey
/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "slimebarrier"
	maxhealth = 60
