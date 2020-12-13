/datum/gear/security
	sort_category = "Security Equipment"
	slot = slot_tie

/datum/gear/security/pcarrier
	display_name = "plate carrier selection"
	path = /obj/item/clothing/suit/armor/pcarrier
	cost = 2
	slot = slot_wear_suit
	allowed_roles = ARMED_ROLES

/datum/gear/security/pcarrier/New()
	..()
	var/armors = list()
	armors["standard plate carrier"] = /obj/item/clothing/suit/armor/pcarrier
	armors["green plate carrier"] = /obj/item/clothing/suit/armor/pcarrier/green
	armors["navy blue plate carrier"] = /obj/item/clothing/suit/armor/pcarrier/navy
	armors["tan plate carrier"] = /obj/item/clothing/suit/armor/pcarrier/tan
	gear_tweaks += new /datum/gear_tweak/path(armors)

/datum/gear/security/armor_deco
	display_name = "armor customization"
	path = /obj/item/clothing/accessory/armor/tag
	flags = GEAR_HAS_SUBTYPE_SELECTION
	allowed_roles = ARMED_ROLES
	cost = 1

/datum/gear/security/helm_covers
	display_name = "helmet covers"
	path = /obj/item/clothing/accessory/armor/helmcover
	flags = GEAR_HAS_SUBTYPE_SELECTION
	allowed_roles = ARMED_ROLES
	cost = 1

/datum/gear/security/kneepads
	display_name = "kneepads"
	path = /obj/item/clothing/accessory/kneepads
	allowed_roles = ARMED_ROLES
	cost = 2

/datum/gear/storage/bandolier
	display_name = "bandolier"
	path = /obj/item/clothing/accessory/storage/bandolier
	allowed_roles = list(/datum/job/captain, /datum/job/hop, /datum/job/hos, /datum/job/officer, /datum/job/warden, /datum/job/detective, /datum/job/merchant, /datum/job/bartender)
	cost = 3
