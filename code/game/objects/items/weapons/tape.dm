/obj/item/tape_roll
	name = "duct tape"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	var/tape_speed = 30
	w_class = ITEM_SIZE_SMALL

/obj/item/tape_roll/attack(mob/living/carbon/human/H, mob/user)
	if(istype(H))
		if(user.zone_sel.selecting == BP_EYES)

			if(!H.organs_by_name[BP_HEAD])
				to_chat(user, "<span class='warning'>\The [H] doesn't have a head.</span>")
				return
			if(!H.has_eyes())
				to_chat(user, "<span class='warning'>\The [H] doesn't have any eyes.</span>")
				return
			if(H.glasses)
				to_chat(user, "<span class='warning'>\The [H] is already wearing somethign on their eyes.</span>")
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				to_chat(user, "<span class='warning'>Remove their [H.head] first.</span>")
				return
			user.visible_message("<span class='danger'>\The [user] begins taping over \the [H]'s eyes!</span>")

			if(!do_mob(user, H, tape_speed))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name[BP_HEAD] || !H.has_eyes() || H.glasses || (H.head && (H.head.body_parts_covered & FACE)))
				return

			user.visible_message("<span class='danger'>\The [user] has taped up \the [H]'s eyes!</span>")
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/blindfold/tape(H), slot_glasses)

		else if(user.zone_sel.selecting == BP_MOUTH || user.zone_sel.selecting == BP_HEAD)
			if(!H.organs_by_name[BP_HEAD])
				to_chat(user, "<span class='warning'>\The [H] doesn't have a head.</span>")
				return
			if(!H.check_has_mouth())
				to_chat(user, "<span class='warning'>\The [H] doesn't have a mouth.</span>")
				return
			if(H.wear_mask)
				to_chat(user, "<span class='warning'>\The [H] is already wearing a mask.</span>")
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				to_chat(user, "<span class='warning'>Remove their [H.head] first.</span>")
				return
			user.visible_message("<span class='danger'>\The [user] begins taping up \the [H]'s mouth!</span>")

			if(!do_mob(user, H, tape_speed))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name[BP_HEAD] || !H.check_has_mouth() || H.wear_mask || (H.head && (H.head.body_parts_covered & FACE)))
				return

			user.visible_message("<span class='danger'>\The [user] has taped up \the [H]'s mouth!</span>")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/muzzle/tape(H), slot_wear_mask)

		else if(user.zone_sel.selecting == BP_R_HAND || user.zone_sel.selecting == BP_L_HAND)
			var/obj/item/handcuffs/cable/tape/T = new(user)
			if(!T.place_handcuffs(H, user))
				user.unEquip(T)
				qdel(T)

		else if(user.zone_sel.selecting == BP_CHEST)
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit/space))
				if(H == user || do_mob(user, H, (tape_speed /3 )))	//Skip the time-check if patching your own suit, that's handled in attackby()
					H.wear_suit.attackby(src, user)
			else
				to_chat(user, "<span class='warning'>\The [H] isn't wearing a spacesuit for you to reseal.</span>")

		else
			return ..()
		return 1

/obj/item/tape_roll/syndie
	desc = "A roll of sticky tape. This one is suspiciously sticky."
	icon_state = "syndietape"
	tape_speed = 5
