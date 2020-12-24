#define REMOVE_INTERNALS if(internal){ if(internals){ internals.icon_state = "internal0" }; internal = null }
/*
Add fingerprints to items when we put them in our hands.
This saves us from having to call add_fingerprint() any time something is put in a human's hands programmatically.
*/
/mob/living/carbon/human
	var/list/null_n_update = list(
		head      = /mob/living/carbon/human/update_inv_head,
		l_ear     = /mob/living/carbon/human/update_inv_ears,
		r_ear     = /mob/living/carbon/human/update_inv_ears,
		glasses   = /mob/living/carbon/human/update_inv_glasses,
		wear_mask = /mob/living/carbon/human/update_inv_wear_mask,
		w_uniform = /mob/living/carbon/human/update_inv_w_uniform,
		wear_suit = /mob/living/carbon/human/update_inv_wear_suit,
		gloves    = /mob/living/carbon/human/update_inv_gloves,
		shoes     = /mob/living/carbon/human/update_inv_shoes,

		s_store    = /mob/living/carbon/human/update_inv_s_store,
		wear_id    = /mob/living/carbon/human/update_inv_wear_id,
		belt       = /mob/living/carbon/human/update_inv_belt,
		back       = /mob/living/carbon/human/update_inv_back,
		l_hand     = /mob/living/carbon/human/update_inv_l_hand,
		r_hand     = /mob/living/carbon/human/update_inv_r_hand,
		l_store    = /mob/living/carbon/human/update_inv_pockets,
		r_store    = /mob/living/carbon/human/update_inv_pockets,
		handcuffed = /mob/living/carbon/human/update_inv_handcuffed,
	)
	var/list/has_slots_by_organ = list(
		BP_HEAD   = list(slot_head, slot_glasses, slot_wear_mask, slot_l_ear, slot_r_ear),
		BP_L_HAND = list(slot_l_hand),
		BP_R_HAND = list(slot_r_hand),
		BP_CHEST  = list(slot_w_uniform, slot_wear_suit, slot_s_store, slot_belt, slot_back, slot_l_store, slot_r_store),
	)

/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		if(!I)
			to_chat(H, "<span class='notice'>You are not holding anything to equip.</span>")
			return
		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand(0)
			else
				update_inv_r_hand(0)
		else
			to_chat(H, "<span class='warning'>You are unable to equip that.</span>")

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if(del_on_fail)
		qdel(W)
	return null

//Puts the item into our active hand if possible. returns 1 on success.
/mob/living/carbon/human/put_in_active_hand(obj/item/W)
	return (hand ? put_in_l_hand(W) : put_in_r_hand(W))

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/living/carbon/human/put_in_inactive_hand(obj/item/W)
	return (hand ? put_in_r_hand(W) : put_in_l_hand(W))

/mob/living/carbon/human/put_in_hands(obj/item/W)
	if(!W)
		return 0
	if(put_in_active_hand(W) || put_in_inactive_hand(W))
		W.update_held_icon()
		return 1
	return ..()

/mob/living/carbon/human/put_in_l_hand(obj/item/W)
	if(!..() || l_hand)
		return 0
	var/obj/item/organ/external/hand = organs_by_name["l_hand"]
	if(!hand || !hand.is_usable())
		return 0
	equip_to_slot(W,slot_l_hand)
	W.add_fingerprint(src)
	return 1

/mob/living/carbon/human/put_in_r_hand(obj/item/W)
	if(!..() || r_hand)
		return 0
	var/obj/item/organ/external/hand = organs_by_name["r_hand"]
	if(!hand || !hand.is_usable())
		return 0

	equip_to_slot(W,slot_r_hand)
	W.add_fingerprint(src)
	return 1

/mob/living/carbon/human/proc/has_organ(name)
	var/obj/item/organ/external/O = organs_by_name[name]
	return (O && !O.is_stump())

/mob/living/carbon/human/proc/has_organ_for_slot(slot)
	switch(slot)
		if(slot_gloves, slot_handcuffed)
			return has_organ(BP_L_HAND) && has_organ(BP_R_HAND)
		if(slot_shoes, slot_legcuffed)
			return has_organ(BP_L_FOOT) && has_organ(BP_R_FOOT)
		if(slot_wear_id, slot_tie, slot_in_backpack)
			return 1
	for(var/organ in has_slots_by_organ)
		if(slot in has_slots_by_organ[organ])
			return has_organ(organ)

/mob/living/carbon/human/u_equip(obj/W as obj)
	if(!W)	return 0

	// handle speecial droping
	if(W == wear_suit)
		if(s_store)
			drop_from_inventory(s_store)
	else if(W == w_uniform)
		for(var/slot in list("r_store", "l_store", "wear_id", "belt"))
			if(src.vars[slot])
				drop_from_inventory(src.vars[slot])
				call(src, null_n_update[slot])()
	else if(W == head)
		if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & (HIDEMASK|BLOCKHAIR|BLOCKHEADHAIR))
				update_hair(0)	//rebuild hair
				update_inv_ears(0)
				update_inv_wear_mask(0)
		if(src)
			var/obj/item/clothing/mask/wear_mask = src.get_equipped_item(slot_wear_mask)
			if(!(wear_mask && (wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)))
				REMOVE_INTERNALS
	else if(W == wear_mask)
		if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & (BLOCKHAIR|BLOCKHEADHAIR))
				update_hair(0)	//rebuild hair
				update_inv_ears(0)
		REMOVE_INTERNALS
	else if(W == handcuffed)
		if(handcuffed.on_restraint_removal(src)) //If this returns 1, then the unquipping action was interrupted
			return 0
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
	else if(W == r_hand)
		if(l_hand)
			l_hand.update_twohanding()
			update_inv_l_hand()
	else if(W == l_hand)
		if(r_hand)
			r_hand.update_twohanding()
			update_inv_r_hand()
	// end handling

	for(var/slot in null_n_update)
		if(W == src.vars[slot])
			src.vars[slot] = null
			equipment_slowdown -= get_equipment_slowdown_by_item(W, slot)
			call(src, null_n_update[slot])()

	update_action_buttons()
	return 1

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)

	if(!slot)
		return
	if(!istype(W))
		return
	if(!has_organ_for_slot(slot))
		return
	if(!species || !species.hud || !(slot in species.hud.equip_slots))
		return
	W.forceMove(src)

	var/obj/item/old_item = get_equipped_item(slot)

	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			if(wear_mask.flags_inv & (BLOCKHAIR|BLOCKHEADHAIR))
				update_hair(redraw_mob)	//rebuild hair
				update_inv_ears(0)
			W.equipped(src, slot)
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			drop_r_hand()
			drop_l_hand()
			stop_pulling()
			update_inv_handcuffed(redraw_mob)
		if(slot_l_hand)
			src.l_hand = W
			W.equipped(src, slot)
			W.screen_loc = ui_lhand
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			src.r_hand = W
			W.equipped(src, slot)
			W.screen_loc = ui_rhand
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			src.belt = W
			W.equipped(src, slot)
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			src.wear_id = W
			W.equipped(src, slot)
			update_inv_wear_id(redraw_mob)
		if(slot_l_ear)
			src.l_ear = W
			if(l_ear.slot_flags & SLOT_TWOEARS)
				src.r_ear = W
			W.equipped(src, slot)
			update_inv_ears(redraw_mob)
		if(slot_r_ear)
			src.r_ear = W
			if(r_ear.slot_flags & SLOT_TWOEARS)
				src.l_ear = W
			W.equipped(src, slot)
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			src.glasses = W
			W.equipped(src, slot)
			update_inv_glasses(redraw_mob)
		if(slot_gloves)
			src.gloves = W
			W.equipped(src, slot)
			update_inv_gloves(redraw_mob)
		if(slot_head)
			src.head = W
			if(head.flags_inv & (BLOCKHAIR|BLOCKHEADHAIR|HIDEMASK))
				update_hair(redraw_mob)	//rebuild hair
				update_inv_ears(0)
				update_inv_wear_mask(0)
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
			update_inv_head(redraw_mob)
		if(slot_shoes)
			src.shoes = W
			W.equipped(src, slot)
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			src.wear_suit = W
			if(wear_suit.flags_inv & HIDESHOES)
				update_inv_shoes(0)
			if(wear_suit.flags_inv & HIDEGLOVES)
				update_inv_gloves(0)
			if(wear_suit.flags_inv & HIDEJUMPSUIT)
				update_inv_w_uniform(0)
			W.equipped(src, slot)
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			src.w_uniform = W
			if(w_uniform.flags_inv & HIDESHOES)
				update_inv_shoes(0)
			W.equipped(src, slot)
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			src.l_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			src.s_store = W
			W.equipped(src, slot)
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(src.get_active_hand() == W)
				src.remove_from_mob(W)
			W.forceMove(src.back)
		if(slot_tie)
			var/obj/item/clothing/under/uniform = src.w_uniform
			if(uniform)
				uniform.attackby(W,src)
		else
			to_chat(src, "<span class='danger'>You are trying to eqip this item to an unsupported inventory slot. If possible, please write a ticket with steps to reproduce. Slot was: [slot]</span>")
			return

	if((W == src.l_hand) && (slot != slot_l_hand))
		src.l_hand = null
		update_inv_l_hand() //So items actually disappear from hands.
	else if((W == src.r_hand) && (slot != slot_r_hand))
		src.r_hand = null
		update_inv_r_hand()

	W.hud_layerise()
	for(var/s in species.hud.gear)
		var/list/gear = species.hud.gear[s]
		if(gear["slot"] == slot)
			W.screen_loc = gear["loc"]
	if(W.action_button_name)
		update_action_buttons()

	// if we replaced an item, delete the old item. do this at the end to make the replacement seamless
	if(old_item)
		qdel(old_item)

	equipment_slowdown += get_equipment_slowdown_by_item(W, slot)
	return 1

/mob/living/carbon/human/proc/get_equipment_slowdown_by_item(obj/item/I as obj, slot)
	var/item_slowdown = I.slowdown_general + I.slowdown_per_slot[slot] + I.slowdown_accessory
	if(item_slowdown >= 0)
		var/size_mod = 0
		if(!(mob_size == MOB_MEDIUM))
			size_mod = log(2, mob_size / MOB_MEDIUM)
		if(species.strength + size_mod + 1 > 0)
			item_slowdown = item_slowdown / (species.strength + size_mod + 1)
		else
			item_slowdown = item_slowdown - species.strength - size_mod
	return item_slowdown

// older verision
/mob/living/carbon/human/update_equipment_slowdown()
	equipment_slowdown = -1
	for(var/slot = slot_first to slot_last)
		var/obj/item/I = get_equipped_item(slot)
		if(I)
			equipment_slowdown += get_equipment_slowdown_by_item(I, slot)

//Checks if a given slot can be accessed at this time, either to equip or unequip I
/mob/living/carbon/human/slot_is_accessible(slot, obj/item/I, mob/user=null)
	var/obj/item/covering = null
	var/check_flags = 0

	switch(slot)
		if(slot_wear_mask)
			covering = src.head
			check_flags = FACE
		if(slot_glasses)
			covering = src.head
			check_flags = EYES
		if(slot_gloves, slot_w_uniform)
			covering = src.wear_suit

	if(covering && (covering.body_parts_covered & (I.body_parts_covered|check_flags)))
		to_chat(user, "<span class='warning'>\The [covering] is in the way.</span>")
		return 0
	return 1

/mob/living/carbon/human/get_equipped_item(slot)
	switch(slot)
		if(slot_back)       return back
		if(slot_handcuffed) return handcuffed
		if(slot_l_store)    return l_store
		if(slot_r_store)    return r_store
		if(slot_wear_mask)  return wear_mask
		if(slot_l_hand)     return l_hand
		if(slot_r_hand)     return r_hand
		if(slot_wear_id)    return wear_id
		if(slot_glasses)    return glasses
		if(slot_gloves)     return gloves
		if(slot_head)       return head
		if(slot_shoes)      return shoes
		if(slot_belt)       return belt
		if(slot_wear_suit)  return wear_suit
		if(slot_w_uniform)  return w_uniform
		if(slot_s_store)    return s_store
		if(slot_l_ear)      return l_ear
		if(slot_r_ear)      return r_ear
	return ..()

/mob/living/carbon/human/get_equipped_items(include_carried = 0)
	. = ..()
	for(var/I in list(head, l_ear, r_ear, glasses, w_uniform, wear_suit, gloves, shoes, wear_id, belt))
		if(I)
			. += I
	if(include_carried)
		for(var/I in list(s_store, l_store, r_store, handcuffed))
			if(I)
				. += I
#undef REMOVE_INTERNALS
