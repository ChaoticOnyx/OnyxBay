/obj/item/storage/box/swabs
	name = "box of swab kits"
	desc = "Sterilized equipment within. Do not contaminate."
	icon_state = "swabs"
	inspect_state = "det-open"
	startswith = list(/obj/item/forensics/swab = DEFAULT_BOX_STORAGE)

/obj/item/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	icon_state = "evidencebox"
	inspect_state = "det-open"
	startswith = list(/obj/item/evidencebag = 7)

/obj/item/storage/box/fingerprints
	name = "box of fingerprint cards"
	desc = "Sterilized equipment within. Do not contaminate."
	icon_state = "detective"
	inspect_state = "det-open"
	startswith = list(/obj/item/sample/print = DEFAULT_BOX_STORAGE)
