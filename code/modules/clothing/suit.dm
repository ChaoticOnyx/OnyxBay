///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits.dmi'
	w_class = ITEM_SIZE_NORMAL

	siemens_coefficient = 0.9
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/tank/emergency)
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
	slot_flags = SLOT_OCLOTHING
	coverage = 1.0

	blood_overlay_type = "suitblood"
	drop_sound = SFX_DROP_CLOTH
	pickup_sound = SFX_PICKUP_CLOTH

	var/fire_resist = 100 CELSIUS

/obj/item/clothing/suit/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_suit()

/obj/item/clothing/suit/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	if(item_state_slots && item_state_slots[slot])
		ret.icon_state = item_state_slots[slot]
	else
		ret.icon_state = icon_state
	return ret

/obj/item/clothing/suit/proc/get_collar()
	var/icon/C = new('icons/mob/collar.dmi')
	if(icon_state in C.IconStates())
		var/image/I = image(C, icon_state)
		I.color = color
		return I
