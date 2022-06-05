/obj/item/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick_closed"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	var/open = FALSE
	var/colour = COLOR_NT_RED

/obj/item/lipstick/white
	name = "white lipstick"
	colour = COLOR_WHITE

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = COLOR_VIOLET

/obj/item/lipstick/jade
	name = "jade lipstick"
	colour = COLOR_PAKISTAN_GREEN

/obj/item/lipstick/black
	name = "black lipstick"
	colour = COLOR_BLACK


/obj/item/lipstick/random
	name = "lipstick"

/obj/item/lipstick/random/Initialize()
	. = ..()
	var/list/possible_colours = list("red" = COLOR_NT_RED, "purple" = COLOR_VIOLET, "jade" = COLOR_PAKISTAN_GREEN, "black" = COLOR_BLACK, "white" = COLOR_WHITE)
	var/key = pick("red", "purple", "jade", "black", "white")
	name = "[key] lipstick"
	colour = possible_colours[key]

/obj/item/lipstick/update_icon()
	overlays.Cut()
	if(open)
		icon_state = "lipstick_open"
		var/icon/lipstick_icon = icon(icon, "lipstick_mask")
		if(colour)
			lipstick_icon.Blend(colour, ICON_ADD)
		overlays += lipstick_icon
	else
		icon_state = initial(icon_state)

/obj/item/lipstick/attack_self(mob/user)
	open = !open
	to_chat(user, SPAN_NOTICE("You twist \the [src] [open ? "closed" : "open"]."))
	update_icon()

/obj/item/lipstick/attack(atom/A, mob/user as mob, target_zone)
	if(!open)
		return

	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		var/obj/item/organ/external/head/head = H.organs_by_name[BP_HEAD]

		if(!istype(head))
			return

		if(user.a_intent == I_HELP && target_zone == BP_HEAD)
			head.write_on(user, src.name)
		else if(head.has_lips)
			if(H.lip_style)	// If they already have lipstick on.
				to_chat(user, SPAN_NOTICE("You need to wipe off the old lipstick first!"))
				return
			if(H == user)
				user.visible_message(SPAN_NOTICE("[user] does their lips with \the [src]."), \
									 SPAN_NOTICE("You take a moment to apply \the [src]. Perfect!"))
				H.lip_style = colour
				H.update_body()
			else
				user.visible_message(SPAN_WARNING("[user] begins to do [H]'s lips with \the [src]."), \
									 SPAN_NOTICE("You begin to apply \the [src]."))
				// User needs to keep their active hand, H does not.
				if(do_after(user, 20, H) && do_after(H, 20, needhand = 0, progress = 0, incapacitation_flags = INCAPACITATION_NONE))	
					user.visible_message(SPAN_NOTICE("[user] does [H]'s lips with \the [src]."), \
										 SPAN_NOTICE("You apply \the [src]."))
					H.lip_style = colour
					H.update_body()
	else if(istype(A, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/head = A
		head.write_on(user, src)

// You can wipe off lipstick with paper! See code/modules/paperwork/paper.dm, paper/attack()

// Sparklysheep's comb
/obj/item/haircomb
	name = "plastic comb"
	desc = "A pristine comb made from flexible plastic."
	icon = 'icons/obj/items.dmi'
	icon_state = "comb"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

/obj/item/haircomb/attack_self(mob/user)
	user.visible_message(SPAN_NOTICE("[user] uses [src] to comb their hair with incredible style and sophistication. What a [user.gender == FEMALE ? "lady" : "guy"]."))
