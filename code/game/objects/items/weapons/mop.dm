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
	AddComponent(/datum/component/liquids_interaction, /obj/item/mop/proc/attack_on_liquids_turf)

/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	var/turf/turf_to_clean = A

	// Disable normal cleaning if there are liquids.
	if(isturf(A) && turf_to_clean.liquids)
		SEND_SIGNAL(src, SIGNAL_CLEAN_LIQUIDS, turf_to_clean, user)
		return FALSE

	if(istype(A, /turf) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>Your mop is dry!</span>")
			return
		var/turf/T = get_turf(A)
		if(!T)
			return

		user.visible_message("<span class='warning'>[user] begins to clean \the [T].</span>")

		if(do_after(user, 40, T))
			if(T)
				T.clean(src, user)
			to_chat(user, "<span class='notice'>You have finished mopping!</span>")


/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	..()

/**
 * Proc to remove liquids from a turf using a mop.
 *
 * Arguments:
 * * tile - On which tile we're trying to absorb liquids
 * * user - Who tries to absorb liquids with this?
 * * liquids - Liquids we're trying to absorb.
 */
/obj/item/mop/proc/attack_on_liquids_turf(turf/tile, mob/user, obj/effect/abstract/liquid_turf/liquids)
	if(!in_range(user, tile))
		return FALSE

	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(free_space <= 0)
		to_chat(user, SPAN_WARNING("Your [src] can't absorb any more liquid!"))
		return TRUE

	var/datum/reagents/tempr = liquids.take_reagents_flat(free_space)
	tempr.trans_to_obj(src, tempr.total_volume)
	to_chat(user, SPAN_NOTICE("You soak \the [src] with some liquids."))
	qdel(tempr)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	return TRUE
