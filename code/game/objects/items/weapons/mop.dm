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

/obj/item/mop/New()
	create_reagents(30)

/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(istype(A, /turf) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		var/volume_to_spend
		if(reagents.has_reagent(/datum/reagent/space_cleaner, 1))
			volume_to_spend = 5
		else if(reagents.has_reagent(/datum/reagent/water, 3))
			volume_to_spend = 30

		if(!volume_to_spend)
			to_chat(user, SPAN("notice", "Your mop is too dry!"))
			return

		var/turf/T = get_turf(A)
		if(!T)
			return

		user.visible_message("<b>[user]</b> begins to clean \the [T].")

		if(!do_after(user, (3 SECONDS), T))
			return

		if(T)
			T.clean(src, user)
		to_chat(user, SPAN("notice", "You have finished mopping!"))


/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	..()
