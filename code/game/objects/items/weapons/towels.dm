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
	create_reagents(30)
	AddComponent(/datum/component/liquids_interaction, nameof(/obj/item/towel.proc/attack_on_liquids_turf))

/obj/item/towel/attack_self(mob/living/user as mob)
	user.visible_message(text("<span class='notice'>[] uses [] to towel themselves off.</span>", user, src))
	playsound(user, 'sound/weapons/towelwipe.ogg', 25, 1)

/obj/item/towel/random/Initialize()
	. = ..()
	color = get_random_colour()

/obj/item/towel/fleece // loot from the king of goats. it's a golden towel
	name = "golden fleece"
	desc = "The legendary Golden Fleece of Jason made real."
	color = "#ffd700"
	force = 1
	attack_verb = list("smote")

/obj/item/towel/proc/attack_on_liquids_turf(turf/tile, mob/user, atom/movable/liquid_turf/liquids)
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
