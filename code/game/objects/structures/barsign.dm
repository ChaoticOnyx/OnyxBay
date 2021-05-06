/obj/structure/sign/double/barsign
	desc = "A jumbo-sized LED sign. This one seems to be showing its age."
	description_info = "If your ID has bar access, you may swipe it on this sign to alter its display."
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	appearance_flags = 0
	anchored = 1
	var/emagged = FALSE

<<<<<<< HEAD
/obj/structure/sign/double/barsign/proc/get_valid_states(initial=1, mob/living/user = null, var/roundstart = FALSE)
=======
/obj/structure/sign/double/barsign/proc/get_valid_states(initial = FALSE, mob/living/user = null)
>>>>>>> d41e202dedf4092eefdb3d8ce6d6b25048dcaa13
	. = icon_states(icon)
	. -= "on"
	if(!user || !iscultist(user))
		. -= "Nar-sie Bistro"
	if(!emagged)
		. -= "The Syndi Cat"
		. -= "Vlad's Salad Bar"
		. -= "Combo Cafe"
		. -= "???"
<<<<<<< HEAD
	if(roundstart)
		. -= "CybersSylph"
=======
>>>>>>> d41e202dedf4092eefdb3d8ce6d6b25048dcaa13
	. -= "empty"
	if(initial)  // We don't want this to be picked by random
		. -= "Off"
		. -= "CybersSylph"

/obj/structure/sign/double/barsign/examine(mob/user)
	. = ..()
	switch(icon_state)
		if("Off")
			. += "\nIt appears to be switched off."
		if("Nar-sie Bistro")
			. += "\nIt shows a picture of a large black and red being. Spooky!"
		if("on", "empty")
			. += "\nThe lights are on, but there's no picture."
		else
			. += "\nIt says '[icon_state]'"

/obj/structure/sign/double/barsign/Initialize()
	. = ..()
<<<<<<< HEAD
	icon_state = pick(get_valid_states(roundstart = TRUE))
=======
	icon_state = pick(get_valid_states(initial = TRUE))
>>>>>>> d41e202dedf4092eefdb3d8ce6d6b25048dcaa13

/obj/structure/sign/double/barsign/attackby(obj/item/I, mob/living/user)

	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
<<<<<<< HEAD
		emagged = TRUE
		to_chat(user, "<span class='notice'>You overload the access verification system and open access to special propaganda.</span>")
		return

	if(emagged)
		var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in get_valid_states(0, user)
		if(!sign_type)
			return
		icon_state = sign_type
		to_chat(user, "<span class='notice'>You change the barsign.</span>")
=======
		var/obj/item/weapon/card/emag/emag_card = I
		emagged = TRUE
		emag_card.uses -= 1
		to_chat(user, SPAN("notice", "You overload the access verification system and open access to special propaganda."))
		return

	if(emagged)
		var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in get_valid_states(FALSE, user)
		if(!sign_type || !Adjacent(user))
			return
		icon_state = sign_type
		to_chat(user, SPAN("notice", "You change the barsign."))
>>>>>>> d41e202dedf4092eefdb3d8ce6d6b25048dcaa13
		return

	var/obj/item/weapon/card/id/card = I.GetIdCard()
	if(istype(card))
		if(access_bar in card.GetAccess())
			var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in get_valid_states(FALSE, user)
			if(!sign_type || !Adjacent(user))
				return
			icon_state = sign_type
			to_chat(user, SPAN("notice", "You change the barsign."))
		else
			to_chat(user, SPAN("warning", "Access denied."))
		return
	return ..()

