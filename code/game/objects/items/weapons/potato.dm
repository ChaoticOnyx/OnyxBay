/obj/item/potato
	name = "potato trap"
	throw_range = 3
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "potato"
	desc = "A potato activated leg trap. Low-tech, but reliable. Looks like it could really hurt if you set it off."
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 3, TECH_COMBAT = 2)
	matter = list(MATERIAL_STEEL = 3750)

/obj/item/potato/attack_self(mob/user as mob)
	..()
	user.drop(src)

/obj/item/potato/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.m_intent == M_RUN)
			L.visible_message(
				"<span class='danger'>[L] steps on \the [src].</span>",
				"<span class='danger'>You step on \the [src]!</span>",
				"<b>You hear a loud beep!</b>"
				)
			explosion(loc, 0, 0, 1, 0)
			spawn(0)
				qdel(src)
	..()
