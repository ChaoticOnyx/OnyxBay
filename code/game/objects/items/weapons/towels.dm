/obj/item/towel
	name = "towel"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "towel"
	item_flags = ITEM_FLAG_IS_BELT
	slot_flags = SLOT_HEAD | SLOT_BELT | SLOT_OCLOTHING
	force = 0.5
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 0.5
	mod_reach = 0.75
	mod_handy = 0.25
	attack_verb = list("whipped")
	hitsound = 'sound/weapons/towelwhip.ogg'
	desc = "A soft cotton towel."
	drop_sound = SFX_DROP_CLOTH
	pickup_sound = SFX_PICKUP_CLOTH

/obj/item/towel/Initialize()
	. = ..()
	AddComponent(/datum/component/liquids_interaction, /obj/item/towel/proc/attack_on_liquids_turf)

/obj/item/towel/attack_self(mob/living/user as mob)
	user.visible_message(text("<span class='notice'>[] uses [] to towel themselves off.</span>", user, src))
	playsound(user, 'sound/weapons/towelwipe.ogg', 25, 1)

/obj/item/towel/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	var/turf/turf_to_clean = A

	// Disable normal cleaning if there are liquids.
	if(isturf(A) && turf_to_clean.liquids)
		SEND_SIGNAL(src, SIGNAL_CLEAN_LIQUIDS, turf_to_clean, user)
		return

/obj/item/towel/random/New()
	..()
	color = get_random_colour()

/obj/item/towel/fleece // loot from the king of goats. it's a golden towel
	name = "golden fleece"
	desc = "The legendary Golden Fleece of Jason made real."
	color = "#ffd700"
	force = 1
	attack_verb = list("smote")

/**
 * The procedure for remove liquids from turf
 *
 * The object is called from liquid_interaction element.
 * The procedure check range of mop owner and tile, then check reagents in mop, if reagents volume < mop capacity - liquids absorbs from tile
 * In another way, input a chat about mop capacity
 * Arguments:
 * * towel - Towel used to absorb liquids
 * * tile - On which tile the towel will try to absorb liquids
 * * user - Who tries to absorb liquids with the towel
 * * liquids - Liquids that user tries to absorb with the towel
 */
/obj/item/towel/proc/attack_on_liquids_turf(turf/tile, mob/user, obj/effect/abstract/liquid_turf/liquids)
	if(!in_range(user, tile))
		return FALSE

	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(free_space <= 0)
		to_chat(user, SPAN_WARNING("Your [src] can't absorb any more liquid!"))
		return TRUE

	var/datum/reagents/temp_holder = liquids.take_reagents_flat(free_space)
	temp_holder.trans_to_obj(src, temp_holder.total_volume)

	to_chat(user, SPAN_NOTICE("You soak \the [src] with some liquids."))

	qdel(temp_holder)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	return TRUE
