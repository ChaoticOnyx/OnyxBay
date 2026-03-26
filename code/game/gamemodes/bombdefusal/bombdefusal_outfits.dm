// ========== BOMB DEFUSAL - OUTFITS ==========

/decl/hierarchy/outfit/bombdefusal
	name = "Bomb Defusal - Base"
	hierarchy_type = /decl/hierarchy/outfit/bombdefusal

// ===== COSMETIC VARIANTS (no armor) =====

/obj/item/clothing/mask/gas/swat/cosmetic
	name = "\improper SWAT mask"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

// ===== TERRORIST OUTFITS =====

/decl/hierarchy/outfit/bombdefusal/terrorist
	name = "Bomb Defusal - Terrorist (Rifleman)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/swat
	back = /obj/item/storage/backpack/satchel
	l_ear = /obj/item/device/radio/headset/bombdefusal_t
	belt = /obj/item/storage/belt/security/tactical
	r_hand = /obj/item/gun/projectile/pistol/secgun
	l_hand = /obj/item/material/hatchet/tacknife
	backpack_contents = list(/obj/item/ammo_magazine/c45m = 3)

/decl/hierarchy/outfit/bombdefusal/terrorist/post_equip(mob/living/carbon/human/H)
	..()
	randomize_t_look(H)

/decl/hierarchy/outfit/bombdefusal/terrorist/medic
	name = "Bomb Defusal - T Medic"
	backpack_contents = list(/obj/item/ammo_magazine/c45m = 2, /obj/item/bombdefusal_injector = 1)

/decl/hierarchy/outfit/bombdefusal/terrorist/support
	name = "Bomb Defusal - T Support"
	backpack_contents = list(/obj/item/ammo_magazine/c45m = 2, /obj/item/grenade/frag = 1, /obj/item/grenade/smokebomb = 1)

// ===== COUNTER-TERRORIST OUTFITS =====

/decl/hierarchy/outfit/bombdefusal/counter_terrorist
	name = "Bomb Defusal - Counter-Terrorist (Rifleman)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/swat
	back = /obj/item/storage/backpack/satchel
	l_ear = /obj/item/device/radio/headset/bombdefusal_ct
	belt = /obj/item/storage/belt/security/tactical
	r_hand = /obj/item/gun/projectile/pistol/secgun
	l_hand = /obj/item/material/hatchet/tacknife
	glasses = /obj/item/clothing/glasses/sunglasses
	backpack_contents = list(/obj/item/ammo_magazine/c45m = 3)

/decl/hierarchy/outfit/bombdefusal/counter_terrorist/post_equip(mob/living/carbon/human/H)
	..()
	randomize_ct_look(H)

/decl/hierarchy/outfit/bombdefusal/counter_terrorist/medic
	name = "Bomb Defusal - CT Medic"
	backpack_contents = list(/obj/item/ammo_magazine/c45m = 2, /obj/item/bombdefusal_injector = 1)

/decl/hierarchy/outfit/bombdefusal/counter_terrorist/support
	name = "Bomb Defusal - CT Support"
	backpack_contents = list(/obj/item/ammo_magazine/c45m = 2, /obj/item/grenade/frag = 1, /obj/item/grenade/smokebomb = 1)

// ===== RANDOMIZED APPEARANCE =====

/proc/randomize_t_look(mob/living/carbon/human/H)
	// Terrorists: rugged, mixed gear, guerrilla style
	var/list/t_uniforms = list(
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/syndicate/combat,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/clothing/under/tactical
	)
	var/list/t_suits = list(
		null,
		null,
		/obj/item/clothing/suit/storage/toggle/hoodie/black,
		/obj/item/clothing/suit/storage/toggle/bomber,
		/obj/item/clothing/suit/storage/toggle/leathercoat
	)
	var/list/t_masks = list(
		null,
		null,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/mask/balaclava/tactical,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/mask/bandana,
		/obj/item/clothing/mask/bandana/red,
		/obj/item/clothing/mask/bandana/skull,
		/obj/item/clothing/mask/bandana/camo,
		/obj/item/clothing/mask/gas/german
	)
	var/list/t_heads = list(
		null,
		null,
		null,
		/obj/item/clothing/head/beret/sec,
		/obj/item/clothing/head/bandana,
		/obj/item/clothing/head/bandana/green,
		/obj/item/clothing/head/ushanka,
		/obj/item/clothing/head/flatcap
	)

	// Apply random uniform
	var/uniform_type = pick(t_uniforms)
	var/obj/item/clothing/under/U = new uniform_type(H)
	H.equip_to_slot_if_possible(U, slot_w_uniform, disable_warning = TRUE)

	// Random cosmetic suit (no armor)
	var/suit_type = pick(t_suits)
	if(suit_type)
		var/obj/item/clothing/suit/S = new suit_type(H)
		H.equip_to_slot_if_possible(S, slot_wear_suit, disable_warning = TRUE)

	// Random mask
	var/mask_type = pick(t_masks)
	if(mask_type)
		var/obj/item/clothing/mask/M = new mask_type(H)
		H.equip_to_slot_if_possible(M, slot_wear_mask, disable_warning = TRUE)

	// Random head
	var/head_type = pick(t_heads)
	if(head_type)
		var/obj/item/clothing/head/HD = new head_type(H)
		H.equip_to_slot_if_possible(HD, slot_head, disable_warning = TRUE)

/proc/randomize_ct_look(mob/living/carbon/human/H)
	// Counter-Terrorists: professional, uniformed, tactical
	var/list/ct_uniforms = list(
		/obj/item/clothing/under/rank/security,
		/obj/item/clothing/under/ert,
		/obj/item/clothing/under/tactical,
		/obj/item/clothing/under/syndicate/tacticool
	)
	var/list/ct_suits = list(
		null,
		null,
		/obj/item/clothing/suit/storage/vest/police,
		/obj/item/clothing/suit/storage/toggle/bomber
	)
	var/list/ct_masks = list(
		null,
		null,
		null,
		/obj/item/clothing/mask/gas/swat/cosmetic,
		/obj/item/clothing/mask/gas/tactical,
		/obj/item/clothing/mask/gas/police
	)
	var/list/ct_heads = list(
		null,
		null,
		/obj/item/clothing/head/beret/sec,
		/obj/item/clothing/head/beret/sec/navy/officer,
		/obj/item/clothing/head/beret/sec/corporate/officer,
		/obj/item/clothing/head/beret/centcom/officer
	)

	// Apply random uniform
	var/uniform_type = pick(ct_uniforms)
	var/obj/item/clothing/under/U = new uniform_type(H)
	H.equip_to_slot_if_possible(U, slot_w_uniform, disable_warning = TRUE)

	// Random cosmetic suit (no armor)
	var/suit_type = pick(ct_suits)
	if(suit_type)
		var/obj/item/clothing/suit/S = new suit_type(H)
		H.equip_to_slot_if_possible(S, slot_wear_suit, disable_warning = TRUE)

	// Random mask
	var/mask_type = pick(ct_masks)
	if(mask_type)
		var/obj/item/clothing/mask/M = new mask_type(H)
		H.equip_to_slot_if_possible(M, slot_wear_mask, disable_warning = TRUE)

	// Random cosmetic headwear (no armor value)
	var/head_type = pick(ct_heads)
	if(head_type)
		var/obj/item/clothing/head/HD = new head_type(H)
		H.equip_to_slot_if_possible(HD, slot_head, disable_warning = TRUE)

// ===== OUTFIT APPLICATION =====

/datum/bombdefusal_match/proc/equip_player(datum/bombdefusal_player_data/pd)
	if(!pd.owner || !pd.owner.current)
		return
	var/mob/living/carbon/human/H = pd.owner.current
	if(!istype(H))
		return

	// Determine outfit path
	var/outfit_path
	if(pd.team.current_side == BOMBDEFUSAL_TEAM_T)
		switch(pd.role)
			if(BOMBDEFUSAL_ROLE_MEDIC)
				outfit_path = /decl/hierarchy/outfit/bombdefusal/terrorist/medic
			if(BOMBDEFUSAL_ROLE_SUPPORT)
				outfit_path = /decl/hierarchy/outfit/bombdefusal/terrorist/support
			else
				outfit_path = /decl/hierarchy/outfit/bombdefusal/terrorist
	else
		switch(pd.role)
			if(BOMBDEFUSAL_ROLE_MEDIC)
				outfit_path = /decl/hierarchy/outfit/bombdefusal/counter_terrorist/medic
			if(BOMBDEFUSAL_ROLE_SUPPORT)
				outfit_path = /decl/hierarchy/outfit/bombdefusal/counter_terrorist/support
			else
				outfit_path = /decl/hierarchy/outfit/bombdefusal/counter_terrorist

	// Initialize component lookup if missing (prevents signal errors on fresh/transferred mobs)
	if(!H.comp_lookup)
		H.comp_lookup = list()
	if(!H.signal_procs)
		H.signal_procs = list()

	// Strip existing equipment (preserves organs, appearance, hair, name)
	H.delete_inventory(include_carried = TRUE)

	// Apply outfit (includes randomized look via post_equip)
	var/decl/hierarchy/outfit/O = outfit_by_type(outfit_path)
	if(O)
		O.equip(H)
