// ========== BOMB DEFUSAL - OUTFITS ==========

/decl/hierarchy/outfit/bombdefusal
	name = "Bomb Defusal - Base"
	hierarchy_type = /decl/hierarchy/outfit/bombdefusal

// ===== COSMETIC VARIANTS (no armor) =====

/obj/item/clothing/mask/gas/swat/imba
	name = "\improper SWAT mask"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/gloves/swat/imba
	name = "\improper SWAT gloves"
	armor = list(melee = 150, bullet = 150, laser = 150, energy = 150, bomb = 150, bio = 0)
	body_parts_covered = HANDS | ARMS

/obj/item/clothing/shoes/combat/imba
	name = "\improper SWAT boots"
	armor = list(melee = 150, bullet = 150, laser = 150, energy = 150, bomb = 150, bio = 0)
	body_parts_covered = FEET | LEGS

// Undersuit cosmetics
/obj/item/clothing/under/syndicate/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/under/syndicate/combat/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/under/syndicate/tacticool/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/under/tactical/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/under/rank/security/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/under/ert/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

// Suit cosmetics
/obj/item/clothing/suit/storage/vest/police/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

// Mask cosmetics
/obj/item/clothing/mask/gas/syndicate/imba
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

// ===== ARENA ARMOR (50 across all types) =====

// T vest - dark military ballistic vest
/obj/item/clothing/suit/armor/vest/bombdefusal_t
	name = "ballistic vest"
	desc = "A sturdy ballistic vest. Worn by terrorists."
	icon_state = "mercwebvest"
	item_state = "armor"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 0)

// CT vest - security tactical vest
/obj/item/clothing/suit/armor/vest/bombdefusal_ct
	name = "tactical vest"
	desc = "A tactical armored vest. Standard counter-terrorist issue."
	icon_state = "ertarmor_sec"
	item_state = "armor"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 0)

// T helmet - mercenary combat helmet
/obj/item/clothing/head/helmet/bombdefusal_t
	name = "combat helmet"
	desc = "A battered combat helmet favored by mercenaries."
	icon_state = "helmet_merc"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 0)
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE

// CT helmet - ERT security helmet
/obj/item/clothing/head/helmet/bombdefusal_ct
	name = "tactical helmet"
	desc = "A reinforced tactical helmet worn by security response teams."
	icon_state = "erthelmet_sec"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 0)
	body_parts_covered = HEAD|EYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE

// ===== TERRORIST OUTFITS =====

/decl/hierarchy/outfit/bombdefusal/terrorist
	name = "Bomb Defusal - Terrorist (Rifleman)"
	shoes = /obj/item/clothing/shoes/combat/imba
	gloves = /obj/item/clothing/gloves/swat/imba
	back = /obj/item/storage/backpack/satchel
	l_ear = /obj/item/device/radio/headset/bombdefusal/bombdefusal_t
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
	shoes = /obj/item/clothing/shoes/combat/imba
	gloves = /obj/item/clothing/gloves/swat/imba
	back = /obj/item/storage/backpack/satchel
	l_ear = /obj/item/device/radio/headset/bombdefusal/bombdefusal_ct
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
		/obj/item/clothing/under/syndicate/imba,
		/obj/item/clothing/under/syndicate/combat/imba,
		/obj/item/clothing/under/syndicate/tacticool/imba,
		/obj/item/clothing/under/tactical/imba
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
		/obj/item/clothing/mask/gas/syndicate/imba,
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
		/obj/item/clothing/under/rank/security/imba,
		/obj/item/clothing/under/ert/imba,
		/obj/item/clothing/under/tactical/imba,
		/obj/item/clothing/under/syndicate/tacticool/imba
	)
	var/list/ct_suits = list(
		null,
		null,
		/obj/item/clothing/suit/storage/vest/police/imba,
		/obj/item/clothing/suit/storage/toggle/bomber
	)
	var/list/ct_masks = list(
		null,
		null,
		null,
		/obj/item/clothing/mask/gas/swat/imba,
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
	var/mob/living/carbon/human/bombdefusal/H = pd.owner.current
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

// Give back pistol + ammo + knife without touching clothing or armor.
// Called when a player respawns after dying in a non-first round.
/datum/bombdefusal_match/proc/give_basic_kit(datum/bombdefusal_player_data/pd)
	if(!pd.owner || !pd.owner.current)
		return
	var/mob/living/carbon/human/H = pd.owner.current
	if(!istype(H))
		return

	// Delete anything in hands and belt
	for(var/slot in list(slot_r_hand, slot_l_hand))
		var/obj/item/I = H.get_equipped_item(slot)
		if(I)
			H.drop(I)
			qdel(I)
	var/obj/item/belt = H.get_equipped_item(slot_belt)
	if(belt)
		H.drop(belt)
		qdel(belt)

	// Give pistol, knife, ammo belt
	var/obj/item/gun/pistol = new /obj/item/gun/projectile/pistol/secgun(H)
	H.equip_to_slot_if_possible(pistol, slot_r_hand, disable_warning = TRUE)
	var/obj/item/knife = new /obj/item/material/hatchet/tacknife(H)
	H.equip_to_slot_if_possible(knife, slot_l_hand, disable_warning = TRUE)
	var/obj/item/new_belt = new /obj/item/storage/belt/security/tactical(H)
	H.equip_to_slot_if_possible(new_belt, slot_belt, disable_warning = TRUE)

	// Refill backpack with ammo mags
	var/obj/item/back = H.get_equipped_item(slot_back)
	if(istype(back, /obj/item/storage))
		var/obj/item/storage/S = back
		for(var/i = 1 to 3)
			S.handle_item_insertion(new /obj/item/ammo_magazine/c45m(S), prevent_warning = TRUE)
