/obj/item/welding_cover
	name = "welding helmet cover"
	desc = "A decorative covering for a standard welding mask. It may be easily clipped on and removed later."
	icon = 'icons/obj/welding_covers.dmi'
	w_class = ITEM_SIZE_SMALL
	var/cover_desc = "This one looks exactly like a standard welding mask - what's the point?"

/obj/item/welding_cover/_examine_text(mob/user)
	. = ..()
	. += " [cover_desc]"

/obj/item/welding_cover/knight
	name = "welding helmet cover (knight)"
	icon_state = "knight"
	cover_desc = "This one looks like a knights helmet."

/obj/item/welding_cover/engie
	name = "welding helmet cover (engie)"
	icon_state = "engie"
	cover_desc = "This one has been painted the engineering colours."

/obj/item/welding_cover/demon
	name = "welding helmet cover (demon)"
	icon_state = "demon"
	cover_desc = "This one has a demonic face on it."

/obj/item/welding_cover/fancy
	name = "welding helmet cover (fancy)"
	icon_state = "fancy"
	cover_desc = "The black and gold make this one look very fancy."

/obj/item/welding_cover/carp
	name = "welding helmet cover (carp)"
	icon_state = "carp"
	cover_desc = "This one has a carp face on it."

/obj/item/welding_cover/hockey
	name = "welding helmet cover (hockey)"
	icon_state = "hockey"
	cover_desc = "This one looks like a rather creepy hockey mask."

/obj/item/welding_cover/blue
	name = "welding helmet cover (blue)"
	icon_state = "blue"
	cover_desc = "This one is painted bright blue."

/obj/item/welding_cover/flame
	name = "welding helmet cover (flame)"
	icon_state = "flame"
	cover_desc = "This one has flame on it."

/obj/item/welding_cover/white
	name = "welding helmet cover (white)"
	icon_state = "white"
	cover_desc = "This one has been painted white and orange."
