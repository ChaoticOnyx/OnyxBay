/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 9.0
	throwforce = 10.0
	throw_range = 10
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 1.5
	mod_handy = 1.0
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")

/obj/item/mop/Initialize()
	. = ..()
	create_reagents(30)
	AddComponent(/datum/component/liquids_interaction, nameof(/obj/item/mop.proc/attack_on_liquids_turf))

/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	..()
