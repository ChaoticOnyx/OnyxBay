
/datum/gear/neck_accessory
	sort_category = "Neck Accessories"

/datum/gear/neck_accessory/cross
	display_name = "crosses selection"
	path = /obj/item/underwear/neck/cross

/datum/gear/neck_accessory/cross/New()
	..()
	var/crosstypes = list()
	crosstypes["Silver cross"] = /obj/item/underwear/neck/cross/silver
	crosstypes["Golden cross"] = /obj/item/underwear/neck/cross/gold
	crosstypes["Wooden cross"] = /obj/item/underwear/neck/cross/wood
	crosstypes["Plain cross"]  = /obj/item/underwear/neck/cross
	gear_tweaks += new /datum/gear_tweak/path(crosstypes)

/datum/gear/neck_accessory/choker_color
	display_name = "choker"
	path = /obj/item/underwear/neck/choker
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/neck_accessory/locket
	display_name = "locket"
	path = /obj/item/underwear/neck/locket
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/neck_accessory/aquila
	display_name = "aquila"
	path = /obj/item/underwear/neck/necklace/aquila
	slot = slot_tie

/datum/gear/neck_accessory/necklace
	display_name = "necklace"
	path = /obj/item/underwear/neck/necklace
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/neck_accessory/tooth_necklace
	display_name = "tooth necklace"
	path = /obj/item/underwear/neck/tooth

/datum/gear/neck_accessory/dogtag
	display_name = "dogtag"
	path = /obj/item/underwear/neck/dogtag

/datum/gear/neck_accessory/dogtag/spawn_item(mob/living/carbon/human/H, metadata)
	. = .. ()
	var/obj/item/underwear/neck/dogtag/dogtag = .
	if(!istype(dogtag))
		return

	dogtag.stored_name = H.real_name
	dogtag.religion = H.religion
	dogtag.stored_blood_type = H.b_type
