/obj/structure/sign/double/barsign
	desc = "A jumbo-sized LED sign. This one seems to be showing its age."
	description_info = "If your ID has bar access, you may swipe it on this sign to alter its display."
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	appearance_flags = 0
	anchored = 1
	var/emagged = FALSE

/obj/structure/sign/double/barsign/proc/get_valid_states(initial=1, mob/living/user = null, var/roundstart = FALSE)
	. = icon_states(icon)
	. -= "on"
	if(!user || !iscultist(user))
		. -= "Nar-sie Bistro"
	if(!emagged)
		. -= "The Syndi Cat"
		. -= "Vlad's Salad Bar"
		. -= "Combo Cafe"
		. -= "???"
	if(roundstart)
		. -= "CybersSylph"
	. -= "empty"
	if(initial)
		. -= "Off"

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
	icon_state = pick(get_valid_states(roundstart = TRUE))

/obj/structure/sign/double/barsign/attackby(obj/item/I, mob/living/user)

	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You overload the access verification system and open access to special propaganda.</span>")
		return

	if(emagged)
		var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in get_valid_states(0, user)
		if(!sign_type)
			return
		icon_state = sign_type
		to_chat(user, "<span class='notice'>You change the barsign.</span>")
		return

	var/obj/item/weapon/card/id/card = I.GetIdCard()
	if(istype(card))
		if(access_bar in card.GetAccess())
			var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in get_valid_states(0, user)
			if(!sign_type)
				return
			icon_state = sign_type
			to_chat(user, "<span class='notice'>You change the barsign.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	return ..()

