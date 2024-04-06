
/obj/item/clothing/accessory/pin
	name = "NT pin"
	desc = "A Nanotrasen holographic pin to show off your loyalty to the company, reminding the crew of your unwavering commitment to whatever NanoTrasen's up to!"
	icon_state = "nt"
	slot_flags = SLOT_TIE
	slot = ACCESSORY_SLOT_INSIGNIA

/obj/item/clothing/accessory/pin/pig
	name = "pig pin"
	desc = "A holographic pin to show off your true nature."
	icon_state = "pig"

/obj/item/clothing/accessory/pin/skull
	name = "skull pin"
	desc = "A holographic pin to show off your edgy nature."
	icon_state = "skull"

/obj/item/clothing/accessory/pin/pride
	name = "rainbow pin"
	desc = "A Nanotrasen Diversity & Inclusion Center-sponsored holographic pin to show off your pride, reminding the crew of their unwavering commitment to equity, diversity, and inclusion!"
	icon_state = "pride"

	var/pride = 0
	var/static/list/prides = list(
		"rainbow:pride",
		"bisexual:pride_bi",
		"pansexual:pride_pan",
		"asexual:pride_ace",
		"non-binary:pride_enby",
		"transgender:pride_trans",
		"intersex:pride_intersex",
		"lesbian:pride_lesbian"
	)

/obj/item/clothing/accessory/pin/pride/Initialize()
	. = ..()
	for(var/i = 1 to length(prides))
		if(findtext(prides, icon_state))
			pride = i
			break

/obj/item/clothing/accessory/pin/pride/attack_self(mob/user)
	if(!pride)
		return

	to_chat(user, "You toggle the pin.")
	add_fingerprint(user)

	pride = pride >= length(prides) ? 1 : pride + 1
	var/sep_pos = findtext(prides[pride], ":")
	name = copytext(prides[pride], 1, sep_pos) + " pin"
	icon_state = copytext(prides[pride], sep_pos + 1)

/obj/item/clothing/accessory/pin/pride/bi
	name = "bisexual pin"
	icon_state = "pride_bi"

/obj/item/clothing/accessory/pin/pride/pan
	name = "pansexual pin"
	icon_state = "pride_pan"

/obj/item/clothing/accessory/pin/pride/ace
	name = "asexual pin"
	icon_state = "pride_ace"

/obj/item/clothing/accessory/pin/pride/enby
	name = "non-binary pin"
	icon_state = "pride_enby"

/obj/item/clothing/accessory/pin/pride/trans
	name = "transgender pin"
	icon_state = "pride_trans"

/obj/item/clothing/accessory/pin/pride/intersex
	name = "intersex pin"
	icon_state = "pride_intersex"

/obj/item/clothing/accessory/pin/pride/lesbian
	name = "lesbian pin"
	icon_state = "pride_lesbian"
