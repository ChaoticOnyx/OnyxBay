// human things

/mob/observer/imaginary_friend/proc/Show()
	if(!client) //nobody home
		return

	//Remove old image from owner and friend
	if(owner.client)
		owner.client.images.Remove(ghost_image)

	client.images.Remove(ghost_image)

	//Generate image from virtual human
	ghost_image = image(virtual_human.icon, src, virtual_human.icon_state, MOB_LAYER, dir=src.dir)
	ghost_image.overlays = virtual_human.overlays
	ghost_image.override = TRUE
	ghost_image.name = name
	if(hidden)
		ghost_image.alpha = 150

	//Add new image to owner and friend
	if(!hidden && owner.client)
		owner.client.images |= ghost_image

	client.images |= ghost_image

/mob/observer/imaginary_friend/proc/handle_items(var/mob/living/carbon/human/H, job_tittle)
	// equip friend with friend's clothing
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/chameleon/friend(H), slot_back)
	equip_to_slot_or_del(new /obj/item/clothing/mask/chameleon/friend(H), slot_wear_mask)
	//slot_belt
	//slot_wear_id
	equip_to_slot_or_del(new /obj/item/clothing/glasses/chameleon/friend(H), slot_glasses)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/chameleon/friend(H), slot_gloves)
	equip_to_slot_or_del(new /obj/item/clothing/head/chameleon/friend(H), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/chameleon/friend(H), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/suit/chameleon/friend(H), slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/under/chameleon/friend(H), slot_w_uniform)
	// disguise friend's items to job items
	var/datum/job/job = job_master.GetJob(job_tittle)
	var/decl/hierarchy/outfit/outfit = job.get_outfit(user, job)
	for(var/slot in list(slot_back, slot_wear_mask, slot_glasses, slot_gloves, slot_head, slot_shoes, slot_wear_suit, slot_w_uniform))
		switch (slot)
			if(slot_w_uniform)
				var/obj/item/clothing/under/chameleon/friend/C = get_equipped_item(slot_w_uniform)
				outfit.uniform ? disguise(outfit.uniform, user)
			if(slot_wear_suit)
				var/obj/item/clothing/suit/chameleon/friend/C = get_equipped_item(slot_wear_suit)
				outfit.suit ? disguise(outfit.suit, user)
			if(slot_gloves)
				var/obj/item/clothing/gloves/chameleon/friend/C = get_equipped_item(slot_gloves)
				outfit.gloves ? disguise(outfit.gloves, user)
			if(slot_shoes)
				var/obj/item/clothing/shoes/chameleon/friend/C = get_equipped_item(slot_shoes)
				outfit.shoes ? disguise(outfit.shoes, user)
			if(slot_wear_mask)
				var/obj/item/clothing/mask/chameleon/friend/C = get_equipped_item(slot_wear_mask)
				outfit.mask ? disguise(outfit.mask, user)
			if(slot_head)
				var/obj/item/clothing/head/chameleon/friend/C = get_equipped_item(slot_head)
				outfit.head ? disguise(outfit.head, user)
			if(slot_glasses)
				var/obj/item/clothing/glasses/chameleon/friend/C = get_equipped_item(slot_glasses)
				outfit.glasses ? disguise(outfit.glasses, user)
			if(slot_back)
				var/obj/item/weapon/storage/backpack/chameleon/friend/C = get_equipped_item(slot_back)
				outfit.back ? disguise(outfit.back, user)
	// handle custom items
	// maybe next time.

/mob/observer/imaginary_friend/proc/setup_friend()
	if(friend_initialized)
		return
	if(virtual_human)
		qdel(virtual_human)
	if(src.client && src.client.prefs)
		virtual_human = new(src)
		if(!virtual_human)
			return
		friend_initialized = TRUE
		var/datum/preferences/character_pref = src.client.prefs
		var/datum/job/job
		if(character_pref.job_high)
			job = job_master.GetJob(character_pref.job_high)
		else if(length(character_pref.job_medium))
			job = job_master.GetJob(pick(character_pref.job_medium))
		else if(length(character_pref.job_low))
			job = job_master.GetJob(pick(character_pref.job_low))
		else
			job = job_master.GetJob("Assistant")
		virtual_human.SetName(real_name)
		virtual_human.dna.ready_dna(virtual_human)
		virtual_human.dna.b_type = character_pref.b_type
		virtual_human.sync_organ_dna()

		// Do the initial caching of the player's body icons.
		virtual_human.force_update_limbs()
		virtual_human.update_eyes()
		virtual_human.regenerate_icons()

		handle_items(virtual_human, job.title)
