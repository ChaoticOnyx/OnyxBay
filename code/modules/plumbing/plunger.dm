/obj/item/plunger
	name = "plunger"
	desc = "It's a plunger for plunging."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"
	slot_flags = SLOT_MASK

/obj/item/plunger/throw_impact(atom/hit_atom)
	. = ..()
	if(iscarbon(hit_atom) && prob(1))
		var/mob/living/carbon/H = hit_atom
		if(!H.wear_mask)
			H.equip_to_slot_if_possible(src, slot_wear_mask)
			H.visible_message(SPAN_WARNING("The plunger slams into [H]'s face!"), SPAN_WARNING("The plunger suctions to your face!"))
