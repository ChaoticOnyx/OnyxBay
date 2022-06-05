/obj/structure/sign/double/barsign
	desc = "A jumbo-sized LED sign. This one seems to be showing its age."
	description_info = "If your ID has bar access, you may swipe it on this sign to alter its display."
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	appearance_flags = DEFAULT_APPEARANCE_FLAGS
	anchored = 1
	var/emagged = FALSE

/obj/structure/sign/double/barsign/proc/get_valid_states(initial = FALSE, mob/living/user = null)
	. = icon_states(icon)
	. -= "on"
	if(!user || !iscultist(user))
		. -= "Nar-sie Bistro"
	if(!emagged)
		. -= "The Syndi Cat"
		. -= "Vlad's Salad Bar"
		. -= "Combo Cafe"
	. -= "???"
	. -= "empty"
	if(initial)  // We don't want this to be picked by random
		. -= "Off"

/obj/structure/sign/double/barsign/_examine_text(mob/user)
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
	icon_state = pick(get_valid_states(initial = TRUE))

/obj/structure/sign/double/barsign/attackby(obj/item/I, mob/living/user)
	var/obj/item/card/id/card = I.GetIdCard()
	if(istype(card) || emagged)
		if(access_bar in card.GetAccess() || emagged)
			var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in get_valid_states(FALSE, user)
			if(!sign_type || !Adjacent(user))
				return
			icon_state = sign_type
			to_chat(user, SPAN("notice", "You change the barsign."))
		else
			to_chat(user, SPAN("warning", "Access denied."))
		return
	return ..()

/obj/structure/sign/double/barsign/emag_act(remaining_charges, mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, SPAN("notice", "You overload the access verification system and open access to special propaganda."))
		return 1
	return

/obj/structure/sign/double/barsign/emp_act(severity)
	icon_state = "???"
	..(severity)
