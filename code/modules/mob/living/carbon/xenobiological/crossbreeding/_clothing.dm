//Rebreather mask - Chilling Blue
/obj/item/clothing/mask/nobreath
	name = "rebreather mask"
	desc = "A transparent mask, resembling a conventional breath mask, but made of bluish metroid. Seems to lack any air supply tube, though."
	icon_state = "halfgas"
	item_state = "halfgas"
	body_parts_covered = 0
	w_class = ITEM_SIZE_SMALL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 0, ACID = 0)

/obj/item/clothing/mask/nobreath/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(user.wear_mask == src)
		user.does_not_breathe = TRUE

/obj/item/clothing/mask/nobreath/dropped(mob/living/carbon/human/user)
	..()
	user.does_not_breathe = FALSE

//Prism Glasses - Chilling Pyrite
/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "prismglasses"
	var/actions = list()
	var/glasses_color = "#FFFFFF"

/obj/item/clothing/glasses/prism_glasses/Initialize()
	. = ..()
	actions += new /datum/action/item_action/prism_glasses/change_prism_colour(src)
	actions += new /datum/action/item_action/prism_glasses/place_light_prism(src)

/obj/item/clothing/glasses/prism_glasses/Destroy()
	QDEL_NULL_LIST(actions)
	return ..()

/obj/item/clothing/glasses/prism_glasses/equipped(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.get_equipped_item(slot_glasses) == src)
			for(var/datum/action/action in actions)
				action.Grant(H)

/obj/item/clothing/glasses/prism_glasses/dropped()
	for(var/datum/action/action in actions)
		if(!action.owner)
			continue
		action.Remove(action.owner)

/obj/structure/light_prism
	name = "light prism"
	desc = "A shining crystal of semi-solid light. Looks fragile."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	breakable = TRUE

/obj/structure/light_prism/Initialize(mapload, newcolor)
	. = ..()
	color = newcolor
	light_color = newcolor
	set_light(0.95, 2, 4, l_color = light_color)

/obj/structure/light_prism/attack_hand(mob/user, list/modifiers)
	to_chat(user, SPAN_NOTICE("You dispel [src]."))
	qdel(src)


/datum/action/item_action/prism_glasses/CheckRemoval()
	if(!istype(owner))
		return TRUE

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(!istype(H.get_equipped_item(slot_glasses), /obj/item/clothing/glasses/prism_glasses))
			return TRUE

	return FALSE

/datum/action/item_action/prism_glasses/change_prism_colour
	name = "Adjust Prismatic Lens"
	button_icon_state = "prismcolor"
	action_type = AB_INNATE

/datum/action/item_action/prism_glasses/change_prism_colour/Trigger(trigger_flags)
	if(!IsAvailable())
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = input(owner, "Choose the lens color:", "Color change",glasses.glasses_color) as color|null
	if(!new_color)
		return
	glasses.glasses_color = new_color
	action_type = AB_INNATE

/datum/action/item_action/prism_glasses/place_light_prism
	name = "Fabricate Light Prism"
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

/obj/item/clothing/head/hairflower/peaceflower
	name = "heroine bud"
	desc = "An extremely addictive flower, full of peace magic."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "peaceflower"
	body_parts_covered = 0
	var/cooldown = 30 SECOND

/obj/item/clothing/head/hairflower/peaceflower/equipped(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.head, src.type))
			ADD_TRAIT(H, TRAIT_PACIFISM)
			set_next_think(world.time + cooldown)

/obj/item/clothing/head/hairflower/peaceflower/can_be_unequipped_by(mob/M, slot, disable_warning)
	if(M == loc && slot == slot_head)
		to_chat(M, SPAN_WARNING("You feel at peace. <b style='color:pink'>Why would you want anything else?</b>"))
		return FALSE
	return ..()

/obj/item/clothing/head/hairflower/peaceflower/dropped()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(!istype(H.head, src.type))
			REMOVE_TRAIT(H, TRAIT_PACIFISM)
			set_next_think(0)

/obj/item/clothing/head/hairflower/peaceflower/think()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.reagents.add_reagent(/datum/reagent/space_drugs, 1)

	set_next_think(world.time + cooldown)

/obj/item/clothing/suit/armor/heavy/adamantine
	name = "adamantine armor"
	desc = "A full suit of adamantine plate armor. Impressively resistant to damage, but weighs about as much as you do."
	icon_state = "adamsuit"
	icon = 'icons/obj/clothing/suits.dmi'
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/armor/heavy/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 6
