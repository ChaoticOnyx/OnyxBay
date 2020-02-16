/obj/var/donator_owner = null

/obj/examine(mob/user)
	. = ..()

	if (. && src.donator_owner)
		to_chat(user, SPAN_NOTICE("Hidden in an inconspicuous place is the logo of Donator Store and name of the recipient: [src.donator_owner]"))