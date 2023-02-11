//Hypercharged metroid cell - Charged Yellow
/obj/item/cell/high/metroid_hypercharged
	name = "hypercharged metroid core"
	desc = "A charged yellow metroid extract, infused with plasma. It almost hurts to touch."
	icon = 'icons/mob/metroids.dmi'
	icon_state = "yellow metroid extract"
	maxcharge = 3000

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of metroid. When squeezed, it grows to massive size!"
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "barriercube"
	w_class = ITEM_SIZE_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/metroid) in get_turf(loc))
		to_chat(user, SPAN_WARNING("You can't fit more than one barrier in the same space!"))
		return
	to_chat(user, SPAN_NOTICE("You squeeze [src]."))
	var/obj/B = new /obj/structure/barricade/metroid(get_turf(loc))
	B.visible_message(SPAN_WARNING("[src] suddenly grows into a large, gelatinous barrier!"))
	qdel(src)

//metroid barricade - Chilling Grey
/obj/structure/barricade/metroid
	name = "gelatinous barrier"
	desc = "A huge chunk of grey metroid. Bullets might get stuck in it."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "metroidbarrier"
	maxhealth = 60

//metroid forcefield - Chilling Metal
/obj/effect/forcefield/metroidwall
	name = "solidified gel"
	desc = "A mass of solidified metroid gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "metroidbarrier_thick"

//Frozen stasis - Chilling Dark Blue
/obj/structure/ice_stasis
	name = "ice block"
	desc = "A massive block of ice. You can see something vaguely humanoid inside."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	var/health = 100

/obj/structure/ice_stasis/attack_generic(mob/user, damage, attack_verb, wallbreaker)
	health -= damage
	if(health<=0)
		Destroy()

/obj/structure/ice_stasis/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/effects/ethereal_exit.ogg', 50, TRUE)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/materials/glass/glassbr.ogg', 50, TRUE)
	return ..()

/obj/screen/movable/alert/status_effect/freon/stasis
	name = "Frozen Solid"
	desc = "You're frozen inside of a protective ice cube! While inside, you can't do anything, but are immune! Resist to get out."
	icon_state = "frozen"



/obj/item/flame/lighter/zippo/metroid
	name = "metroid zippo"
	desc = "A specialty zippo made from metroids and industry. Has a much hotter flame than normal."
	icon_state = "slighter"
	light_color = COLOR_LIGHT_CYAN
	flame_overlay = "metroid"
