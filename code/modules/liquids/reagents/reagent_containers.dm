/obj/item/reagent_containers/Initialize(mapload, vol)
	. = ..()

	AddComponent(/datum/component/liquids_interaction, /obj/item/reagent_containers/vessel/proc/attack_on_liquids_turf)

/**
 * Proc to remove liquids from a turf using a reagent container.
 *
 * Arguments:
 * * tile - On which tile we're trying to absorb liquids
 * * user - Who tries to absorb liquids with this?
 * * liquids - Liquids we're trying to absorb.
 */
/obj/item/reagent_containers/vessel/proc/attack_on_liquids_turf(turf/target_turf, mob/living/user, obj/effect/abstract/liquid_turf/liquids)
	if(user.a_intent == I_HURT)
		return FALSE

	if(!can_be_splashed)
		return FALSE

	if(!user.Adjacent(target_turf))
		return FALSE

	if(liquids.fire_state) //Use an extinguisher first
		to_chat(user, SPAN_WARNING("You can't scoop up anything while it's on fire!"))
		return TRUE

	if(liquids.height == 1)
		to_chat(user, SPAN_WARNING("The puddle is too shallow to scoop anything up!"))
		return TRUE

	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(free_space <= 0)
		to_chat(user, SPAN_WARNING("You can't fit any more liquids inside [src]!"))
		return TRUE

	var/desired_transfer = amount_per_transfer_from_this
	if(desired_transfer > free_space)
		desired_transfer = free_space

	var/datum/reagents/tempr = liquids.take_reagents_flat(desired_transfer)
	tempr.trans_to(reagents, tempr.total_volume)
	to_chat(user, SPAN_NOTICE("You scoop up around [amount_per_transfer_from_this] units of liquids with [src]."))
	qdel(tempr)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	return TRUE
