//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

/// Do not call this proc directly. Use 'update_inv_mob'
/mob/proc/_update_inv_slot(slot)
	switch(slot)
		if(slot_back)
			update_inv_back()
		if(slot_wear_mask)
			update_inv_wear_mask()
		if(slot_handcuffed)
			update_inv_handcuffed()
		if(slot_l_hand)
			update_inv_l_hand()
		if(slot_r_hand)
			update_inv_r_hand()
		if(slot_belt)
			update_inv_belt()
		if(slot_wear_id)
			update_inv_wear_id()
		if(slot_l_ear, slot_r_ear)
			update_inv_ears()
		if(slot_glasses)
			update_inv_glasses()
		if(slot_gloves)
			update_inv_gloves()
		if(slot_head)
			update_inv_head()
		if(slot_shoes)
			update_inv_shoes()
		if(slot_wear_suit)
			update_inv_wear_suit()
		if(slot_w_uniform)
			update_inv_w_uniform()
		if(slot_l_store, slot_r_store)
			update_inv_pockets()
		if(slot_s_store)
			update_inv_s_store()

/mob/proc/regenerate_icons()		//TODO: phase this out completely if possible
	return

/mob/proc/update_icons()
	return

/mob/proc/update_hud()
	return

/mob/proc/update_inv_handcuffed()
	return

/mob/proc/update_inv_back()
	return

/mob/proc/update_inv_l_hand()
	return

/mob/proc/update_inv_r_hand()
	return

/mob/proc/update_inv_wear_mask()
	return

/mob/proc/update_inv_wear_suit()
	return

/mob/proc/update_inv_w_uniform()
	return

/mob/proc/update_inv_belt()
	return

/mob/proc/update_inv_head()
	return

/mob/proc/update_inv_gloves()
	return

/mob/proc/update_mutations()
	return

/mob/proc/update_inv_wear_id()
	return

/mob/proc/update_inv_shoes()
	return

/mob/proc/update_inv_glasses()
	return

/mob/proc/update_inv_s_store()
	return

/mob/proc/update_inv_pockets()
	return

/mob/proc/update_inv_ears()
	return

/mob/proc/update_targeted()
	return
