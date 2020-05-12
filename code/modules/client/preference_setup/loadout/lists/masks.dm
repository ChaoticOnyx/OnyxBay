
/datum/gear/mask
	sort_category = "Masks"
	slot = slot_wear_mask

/datum/gear/mask/surgical
	display_name = "sterile mask"
	path = /obj/item/clothing/mask/surgical
	cost = 2

/datum/gear/mask/scarf
	display_name ="neck scarf"
	path = /obj/item/clothing/mask/bluescarf

/datum/gear/mask/scarf/New()
	..()
	var/scarfs = list()
	scarfs["blue scarf"] = /obj/item/clothing/mask/bluescarf
	scarfs["green scarf"] = /obj/item/clothing/mask/greenscarf
	scarfs["red scarf"] = /obj/item/clothing/mask/redscarf
	scarfs["red white scarf"] = /obj/item/clothing/mask/redwscarf
	scarfs["ninja scarf"] = /obj/item/clothing/mask/ninjascarf
	scarfs["stripped blue scarf"] = /obj/item/clothing/mask/sbluescarf
	scarfs["stripped green scarf"] = /obj/item/clothing/mask/sgreenscarf
	scarfs["stipped red scarf"] = /obj/item/clothing/mask/sredscarf
	gear_tweaks += new /datum/gear_tweak/path(scarfs)

/datum/gear/mask/fakemoustache
	display_name = "fake moustache"
	path = /obj/item/clothing/mask/fakemoustache
	price = 3

/datum/gear/mask/horsehead
	display_name = "horse head"
	path = /obj/item/clothing/mask/horsehead
	price = 5

/datum/gear/mask/pig
	display_name = "pig head"
	path = /obj/item/clothing/mask/pig
	price = 5

/datum/gear/mask/skullmask
	display_name = "skullmask"
	path = /obj/item/clothing/mask/skullmask
	price = 10

/datum/gear/mask/plaguedoctor
	display_name = "plaguedoctor mask"
	path = /obj/item/clothing/mask/gas/plaguedoctor
	price = 18

/datum/gear/mask/monkeymask
	display_name = "monkey mask"
	path = /obj/item/clothing/mask/gas/monkeymask
	price = 18

/datum/gear/mask/owl_mask
	display_name = "owl mask"
	path = /obj/item/clothing/mask/gas/owl_mask
	price = 18
