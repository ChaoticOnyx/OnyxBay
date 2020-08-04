/obj/var/donator_owner = null

/obj/examine(mob/user, distance = -1, infix = "", suffix = "")
	. = ..()

	if (. && src.donator_owner)
		. = to_chat_or_concat(., user, SPAN_NOTICE("Hidden in an inconspicuous place is the logo of Donator Store and name of the recipient: [src.donator_owner]"))