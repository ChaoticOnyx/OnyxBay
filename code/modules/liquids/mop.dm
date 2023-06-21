/obj/item/mop/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/liquids_interaction, /obj/item/mop/proc/attack_on_liquids_turf)

/obj/item/mop/afterattack(atom/atom_to_clean, mob/cleaner, proximity)
	if(!proximity)
		return

	var/turf/turf_to_clean = atom_to_clean

	// Disable normal cleaning if there are liquids.
	if(isturf(atom_to_clean) && turf_to_clean.liquids)
		return FALSE

	return ..()

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
	tempr.trans_to(reagents, tempr.total_volume)
	to_chat(user, SPAN_NOTICE("You soak \the [src] with some liquids."))
	qdel(tempr)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	return TRUE
