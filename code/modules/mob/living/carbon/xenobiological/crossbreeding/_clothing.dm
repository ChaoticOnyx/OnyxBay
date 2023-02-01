//Rebreather mask - Chilling Blue
/obj/item/clothing/mask/nobreath
	name = "rebreather mask"
	desc = "A transparent mask, resembling a conventional breath mask, but made of bluish slime. Seems to lack any air supply tube, though."
	icon_state = "slime"
	item_state = "b_mask"
	body_parts_covered = 0
	w_class = ITEM_SIZE_SMALL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 0, ACID = 0)

/obj/item/clothing/mask/nobreath/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot & SLOT_MASK)
		user.does_not_breathe = TRUE

/obj/item/clothing/mask/nobreath/dropped(mob/living/carbon/human/user)
	..()
	user.does_not_breathe = FALSE
