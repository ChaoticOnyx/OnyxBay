/datum/gear/storage
	sort_category = "Storage"
	slot = slot_tie

/datum/gear/storage/brown_drop_pouches
	display_name = "brown drop pouches"
	path = /obj/item/clothing/accessory/storage/drop_pouches/brown
	cost = 4

/datum/gear/storage/black_drop_pouches
	display_name = "black drop pouches"
	path = /obj/item/clothing/accessory/storage/drop_pouches/black
	cost = 4

/datum/gear/storage/white_drop_pouches
	display_name = "white drop pouches"
	path = /obj/item/clothing/accessory/storage/drop_pouches/white
	cost = 4

/datum/gear/storage/webbing
	display_name = "webbing"
	path = /obj/item/clothing/accessory/storage/webbing
	allowed_roles = list(/datum/job/hos, /datum/job/warden, /datum/job/detective, /datum/job/officer, /datum/job/chief_engineer, /datum/job/engineer)
	cost = 5

/datum/gear/storage/waistpack
	display_name = "waist pack"
	path = /obj/item/storage/belt/waistpack
	cost = 4
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/storage/waistpack/big
	display_name = "large waist pack"
	path = /obj/item/storage/belt/waistpack/big
	cost = 5

/datum/gear/storage/santabag
	display_name = "santabag"
	slot = slot_back
	path = /obj/item/storage/backpack/santabag/fake
	cost = 2
	price = 20

/datum/gear/storage/carppack
	display_name = "space carp backpack"
	slot = slot_back
	path = /obj/item/storage/backpack/carppack
	cost = 2
	price = 50

/datum/gear/storage/shoulder_bag
	display_name = "shoulder bag"
	slot = slot_back
	path = /obj/item/storage/backpack/messenger/shoulder_bag
	cost = 2
	price = 15

