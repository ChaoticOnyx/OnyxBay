/datum/gear/tactical
	sort_category = "Tactical Equipment"
	slot = slot_tie

/datum/gear/tactical/pcarrier
	display_name = "plate carrier selection"
	path = /obj/item/clothing/suit/armor/pcarrier
	cost = 2
	slot = slot_wear_suit
	allowed_roles = ARMORED_ROLES

/datum/gear/tactical/pcarrier/New()
	..()
	var/armors = list()
	armors["green plate carrier"] = /obj/item/clothing/suit/armor/pcarrier/green
	armors["navy blue plate carrier"] = /obj/item/clothing/suit/armor/pcarrier/navy
	armors["tan plate carrier"] = /obj/item/clothing/suit/armor/pcarrier/tan
	gear_tweaks += new /datum/gear_tweak/path(armors)

/datum/gear/tactical/armor_pouches
	display_name = "armor pouches"
	path = /obj/item/clothing/accessory/storage/pouches
	cost = 2
	flags = GEAR_HAS_SUBTYPE_SELECTION
	allowed_roles = ARMORED_ROLES

/datum/gear/tactical/large_pouches
	display_name = "armor large pouches"
	path = /obj/item/clothing/accessory/storage/pouches/large
	cost = 5
	flags = GEAR_HAS_SUBTYPE_SELECTION
	allowed_roles = ARMORED_ROLES

/datum/gear/tactical/armor_deco
	display_name = "armor customization"
	path = /obj/item/clothing/accessory/armor/tag
	flags = GEAR_HAS_SUBTYPE_SELECTION
	allowed_roles = ARMORED_ROLES
	cost = 2

/datum/gear/tactical/helm_covers
	display_name = "helmet covers"
	path = /obj/item/clothing/accessory/armor/helmcover
	flags = GEAR_HAS_SUBTYPE_SELECTION
	allowed_roles = ARMORED_ROLES
	cost = 2

/datum/gear/tactical/kneepads
	display_name = "kneepads"
	path = /obj/item/clothing/accessory/kneepads
	allowed_roles = ARMORED_ROLES
	cost = 2

/datum/gear/tactical/holster
	display_name = "holster selection"
	path = /obj/item/clothing/accessory/holster
	cost = 4
	flags = GEAR_HAS_TYPE_SELECTION
	allowed_roles = ARMORED_ROLES

/datum/gear/uniform/tactical
	sort_category = "Tactical Equipment"
	cost = 2

/datum/gear/uniform/tactical/tacticool_turtleneck
	display_name = "tacticool turtleneck"
	path = /obj/item/clothing/under/syndicate/tacticool

/datum/gear/uniform/tactical/jumpsuit
	display_name = "tactical jumpsuit"
	path = /obj/item/clothing/under/tactical
	price = 15
