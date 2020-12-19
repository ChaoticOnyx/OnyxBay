/datum/gear/eyes
	sort_category = "Glasses"
	slot = slot_glasses
	cost = 2

/datum/gear/eyes/glasses
	display_name = "prescription glasses"
	path = /obj/item/clothing/glasses/regular

/datum/gear/eyes/eyepatch
	display_name = "eyepatch"
	path = /obj/item/clothing/glasses/eyepatch

/datum/gear/eyes/fashionglasses
	display_name = "glasses"
	path = /obj/item/clothing/glasses/regular/hipster

/datum/gear/eyes/fashionglasses/New()
	..()
	var/glasses = list()
	glasses["green glasses"] = /obj/item/clothing/glasses/gglasses
	glasses["hipster glasses"] = /obj/item/clothing/glasses/regular/hipster
	glasses["red glasses"] = /obj/item/clothing/glasses/rglasses
	glasses["monocle"] = /obj/item/clothing/glasses/monocle
	glasses["scanning goggles"] = /obj/item/clothing/glasses/regular/scanners
	gear_tweaks += new /datum/gear_tweak/path(glasses)

/datum/gear/eyes/security/prescription
	display_name = "security HUD, prescription"
	path = /obj/item/clothing/glasses/hud/security/prescription
	cost = 3
	allowed_roles = SECURITY_ROLES

/datum/gear/eyes/medical/prescription
	display_name = "medical HUD, prescription"
	path = /obj/item/clothing/glasses/hud/health/prescription
	cost = 	3
	allowed_roles = MEDICAL_ROLES

/datum/gear/eyes/medical/visor
	display_name = "medical HUD, visor"
	path = /obj/item/clothing/glasses/hud/health/visor
	allowed_roles = MEDICAL_ROLES
	cost = 3

/datum/gear/eyes/meson/ipatch
	display_name = "meson patch"
	path = /obj/item/clothing/glasses/eyepatch/hud/meson
	allowed_roles = TECHNICAL_ROLES
	cost = 3

/datum/gear/eyes/meson/prescription
	display_name = "meson Goggles, prescription"
	path = /obj/item/clothing/glasses/meson/prescription
	cost = 3
	allowed_roles = TECHNICAL_ROLES
