var/list/outfits_decls_
var/list/outfits_decls_root_
var/list/outfits_decls_by_type_

/proc/outfit_by_type(outfit_type)
	if(!outfits_decls_root_)
		init_outfit_decls()
	return outfits_decls_by_type_[outfit_type]

/proc/outfits()
	if(!outfits_decls_root_)
		init_outfit_decls()
	return outfits_decls_

/proc/init_outfit_decls()
	if(outfits_decls_root_)
		return
	outfits_decls_ = list()
	outfits_decls_by_type_ = list()
	outfits_decls_root_ = new /decl/hierarchy/outfit()

/decl/hierarchy/outfit
	name = "Naked"

	var/uniform = null
	var/suit = null
	var/back = null
	var/belt = null
	var/gloves = null
	var/shoes = null
	var/head = null
	var/mask = null
	var/l_ear = null
	var/r_ear = null
	var/glasses = null
	var/id = null
	var/l_pocket = null
	var/r_pocket = null
	var/suit_store = null
	var/r_hand = null
	var/l_hand = null
	var/list/backpack_contents = list() // In the list(path=count,otherpath=count) format

	var/id_type
	var/id_desc
	var/id_slot

	var/pda_type
	var/pda_slot

	var/id_pda_assignment

	var/list/backpack_overrides
	var/flags = OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/New()
	..()
	backpack_overrides = backpack_overrides || list()

	if(is_hidden_category())
		return
	outfits_decls_by_type_[type] = src
	dd_insertObjectList(outfits_decls_, src)

/decl/hierarchy/outfit/proc/pre_equip(mob/living/carbon/human/H)
	if(flags & OUTFIT_RESET_EQUIPMENT)
		H.delete_inventory(TRUE)

/decl/hierarchy/outfit/proc/post_equip(mob/living/carbon/human/H)
	if(flags & OUTFIT_HAS_JETPACK)
		var/obj/item/tank/jetpack/J = locate(/obj/item/tank/jetpack) in H
		if(!J)
			return
		J.toggle()
		J.toggle_valve()
	if(H.getBruteLoss() > 50)
		var/list/clothing_items = list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes)
		for(var/obj/item/C in clothing_items)
			if(prob(H.getBruteLoss()))
				C.is_bloodied = TRUE
				C.blood_color = COLOR_BLOOD_HUMAN
				C.generate_blood_overlay()
				C.update_blood_overlay()

// A proc for non-human species, specially Unathi and Tajara, since they e.g.
// can't normally wear gloves as humans. Correct this issue by trying again, but
// apply some changes to the said item.
//
// Currently checks for gloves
//
// If you want to add more items that has species restriction, consider follow-
// ing the same format as the gloves shown in the code below. Thanks.
/decl/hierarchy/outfit/proc/check_and_try_equip_xeno(mob/living/carbon/human/H)
	var/datum/species/S = H.species
	if (!S || istype(S, /datum/species/human)) // null failcheck & get out here you damn humans
		return

	// Gloves
	if (gloves && !H.get_equipped_item(slot_gloves)) // does mob not have gloves, despite the outfit has one specified?
		var/obj/item/clothing/gloves/G = new gloves(H) // we've no use of a null object, instantize one
		if (S.name in G.species_restricted) // what was the problem?
			if ("exclude" in G.species_restricted) // are they excluded?
				G.cut_fingertops()
				// I could optimize this bit when we are trying to apply the gloves to e.g. Vox, a species still restricted despite G.cut_fingertops(). But who cares if this is codebase is like a plate of spaghetti twice over the brim, right? RIGHT?
				H.equip_to_slot_or_del(G,slot_gloves) // try again
		else
			qdel(G)
	// end Gloves

// end of check_and_try_equip_xeno

/decl/hierarchy/outfit/proc/equip(mob/living/carbon/human/H, rank, assignment, equip_adjustments)
	equip_base(H, equip_adjustments)

	rank = id_pda_assignment || rank
	assignment = id_pda_assignment || assignment || rank
	var/obj/item/card/id/W = equip_id(H, rank, assignment, equip_adjustments)
	if(W)
		rank = W.rank
		assignment = W.assignment
	equip_pda(H, rank, assignment, equip_adjustments)

	for(var/path in backpack_contents)
		var/number = backpack_contents[path]
		for(var/i=0,i<number,i++)
			H.equip_to_slot_or_store_or_drop(new path(H), slot_in_backpack)

	if(!(OUTFIT_ADJUSTMENT_SKIP_POST_EQUIP & equip_adjustments))
		post_equip(H)
	H.regenerate_icons()
	if(W) // We set ID info last to ensure the ID photo is as correct as possible.
		H.set_id_info(W)
	return 1

/decl/hierarchy/outfit/proc/equip_base(mob/living/carbon/human/H, equip_adjustments)
	pre_equip(H)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		if(uniform == /obj/item/clothing/under)
			uniform = subtypesof(/obj/item/clothing/under)
		var/U = DEFAULTPICK(uniform, uniform)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_w_uniform)
	if(suit)
		if(suit == /obj/item/clothing/suit)
			suit = subtypesof(/obj/item/clothing/suit)
		var/U = DEFAULTPICK(suit, suit)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_wear_suit)
	if(back)
		var/U = DEFAULTPICK(back, back)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_back)
	if(belt)
		if(belt == /obj/item/storage/belt)
			belt = subtypesof(/obj/item/storage/belt)
		var/U = DEFAULTPICK(belt, belt)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_belt)
	if(gloves)
		if(gloves == /obj/item/clothing/gloves)
			gloves = subtypesof(/obj/item/clothing/gloves)
		var/U = DEFAULTPICK(gloves, gloves)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_gloves)
	if(shoes)
		if(shoes == /obj/item/clothing/shoes)
			shoes = subtypesof(/obj/item/clothing/shoes)
		var/U = DEFAULTPICK(shoes, shoes)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_shoes)
	if(mask)
		if(mask == /obj/item/clothing/mask)
			mask = subtypesof(/obj/item/clothing/mask)
		var/U = DEFAULTPICK(mask, mask)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_wear_mask)
	if(head)
		if(head == /obj/item/clothing/head)
			head = subtypesof(/obj/item/clothing/head)
		var/U = DEFAULTPICK(head, head)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_head)
	if(l_ear)
		var/U = DEFAULTPICK(l_ear, l_ear)
		var/l_ear_path = (OUTFIT_ADJUSTMENT_PLAIN_HEADSET & equip_adjustments) && ispath(U , /obj/item/device/radio/headset) ? /obj/item/device/radio/headset : U
		if(U)
			H.equip_to_slot_or_del(new l_ear_path(H),slot_l_ear)
	if(r_ear)
		var/U = DEFAULTPICK(r_ear, r_ear)
		var/r_ear_path = (OUTFIT_ADJUSTMENT_PLAIN_HEADSET & equip_adjustments) && ispath(U , /obj/item/device/radio/headset) ? /obj/item/device/radio/headset : U
		if(U)
			H.equip_to_slot_or_del(new r_ear_path(H),slot_r_ear)
	if(glasses)
		if(glasses == /obj/item/clothing/glasses)
			glasses = subtypesof(/obj/item/clothing/glasses)
		var/U = DEFAULTPICK(glasses, glasses)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_glasses)
	if(id)
		var/U = DEFAULTPICK(id, id)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_wear_id)
	if(l_pocket)
		var/U = DEFAULTPICK(l_pocket, l_pocket)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_l_store)
	if(r_pocket)
		var/U = DEFAULTPICK(r_pocket, r_pocket)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_r_store)
	if(suit_store)
		var/U = DEFAULTPICK(suit_store, suit_store)
		if(U)
			H.equip_to_slot_or_del(new U(H),slot_s_store)
	if(l_hand)
		var/U = DEFAULTPICK(l_hand, l_hand)
		if(U)
			H.put_in_l_hand(new U(H))
	if(r_hand)
		var/U = DEFAULTPICK(r_hand, r_hand)
		if(U)
			H.put_in_r_hand(new U(H))

	if((flags & OUTFIT_HAS_BACKPACK))
		var/decl/backpack_outfit/bo
		var/metadata

		if(H.backpack_setup)
			bo = H.backpack_setup.backpack
			metadata = H.backpack_setup.metadata
		else
			bo = get_default_outfit_backpack()

		var/override_type = backpack_overrides[bo.type]
		var/backpack = bo.spawn_backpack(H, metadata, override_type)

		if(backpack)
			if(back)
				if(!H.put_in_hands(backpack))
					H.equip_to_appropriate_slot(backpack)
			else
				H.equip_to_slot_or_del(backpack, slot_back)

	if(H.species && !(OUTFIT_ADJUSTMENT_SKIP_SURVIVAL_GEAR & equip_adjustments))
		if(flags & OUTFIT_COMBAT_SURVIVAL)
			H.species.equip_survival_gear(H, 2)
		else if(flags & OUTFIT_EXTENDED_SURVIVAL)
			H.species.equip_survival_gear(H, 1)
		else if(!(flags & OUTFIT_NO_SURVIVAL))
			H.species.equip_survival_gear(H)
	check_and_try_equip_xeno(H)

/decl/hierarchy/outfit/proc/equip_id(mob/living/carbon/human/H, rank, assignment, equip_adjustments)
	if(!id_slot || !id_type)
		return
	if(OUTFIT_ADJUSTMENT_SKIP_ID_PDA & equip_adjustments)
		return
	var/obj/item/card/id/W = new id_type(H)
	if(id_desc)
		W.desc = id_desc
	if(rank)
		W.rank = rank
	if(assignment)
		W.assignment = assignment
	H.set_id_info(W)
	if(H.equip_to_slot_or_store_or_drop(W, id_slot))
		return W

/decl/hierarchy/outfit/proc/equip_pda(mob/living/carbon/human/H, rank, assignment, equip_adjustments)
	if(!pda_slot || !pda_type)
		return
	if(OUTFIT_ADJUSTMENT_SKIP_ID_PDA & equip_adjustments)
		return
	var/obj/item/device/pda/heads/pda = new pda_type(H)
	pda.set_owner_rank_job(H.real_name, rank, assignment)
	if(H.equip_to_slot_or_store_or_drop(pda, pda_slot))
		return pda

/decl/hierarchy/outfit/dd_SortValue()
	return name
