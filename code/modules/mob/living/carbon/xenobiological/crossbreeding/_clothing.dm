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

//Prism Glasses - Chilling Pyrite
/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "prismglasses"
	var/actions = list(/datum/action/item_action/prism_glasses/change_prism_colour, /datum/action/item_action/prism_glasses/place_light_prism)
	var/glasses_color = "#FFFFFF"

/obj/item/clothing/glasses/prism_glasses/equipped(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.get_equipped_item(slot_glasses)==src)
			for(var/datum/action/action in actions)
				action.Grant(H)

/obj/item/clothing/glasses/prism_glasses/dropped()

/obj/structure/light_prism
	name = "light prism"
	desc = "A shining crystal of semi-solid light. Looks fragile."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	breakable = TRUE

/obj/structure/light_prism/Initialize(mapload, newcolor)
	. = ..()
	color = newcolor
	light_color = newcolor
	set_light(5)

/obj/structure/light_prism/attack_hand(mob/user, list/modifiers)
	to_chat(user, SPAN_NOTICE("You dispel [src]."))
	qdel(src)


/datum/action/item_action/prism_glasses/CheckRemoval()
	if(!istype(owner))
		return TRUE

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(!istype(H.get_equipped_item(slot_glasses),/obj/item/clothing/glasses/prism_glasses))
			return TRUE

	return FALSE

/datum/action/item_action/prism_glasses/change_prism_colour
	name = "Adjust Prismatic Lens"
	button_icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	button_icon_state = "prismcolor"


/datum/action/item_action/prism_glasses/change_prism_colour/Trigger(trigger_flags)
	if(!IsAvailable())
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = input(owner, "Choose the lens color:", "Color change",glasses.glasses_color) as color|null
	if(!new_color)
		return
	glasses.glasses_color = new_color

/datum/action/item_action/prism_glasses/place_light_prism
	name = "Fabricate Light Prism"
	button_icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	button_icon_state = "lightprism"

/datum/action/item_action/prism_glasses/place_light_prism/Trigger(trigger_flags)
	if(!IsAvailable())
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	if(locate(/obj/structure/light_prism) in get_turf(owner))
		to_chat(owner, SPAN_WARNING("There isn't enough ambient energy to fabricate another light prism here."))
		return
	if(istype(glasses))
		if(!glasses.glasses_color)
			to_chat(owner, SPAN_WARNING("The lens is oddly opaque..."))
			return
		to_chat(owner, SPAN_NOTICE("You channel nearby light into a glowing, ethereal prism."))
		new /obj/structure/light_prism(get_turf(owner), glasses.glasses_color)
