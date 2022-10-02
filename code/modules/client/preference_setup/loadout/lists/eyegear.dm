/datum/gear/eyes
	sort_category = "Glasses"
	slot = slot_glasses
	cost = 2

/datum/gear/eyes/glasses
	display_name = "prescription glasses"
	path = /obj/item/clothing/glasses/regular
	cost = 1

/datum/gear/eyes/eyepatch
	display_name = "eyepatch"
	path = /obj/item/clothing/glasses/eyepatch

/datum/gear/eyes/fashionglasses
	display_name = "glasses selection"
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

/datum/gear/eyes/hud
	display_name = "HUDs selection"
	path = /obj/item/clothing/glasses/hud/standard

/datum/gear/eyes/hud/New()
	..()
	var/huds = list()
	huds["goggles HUD"] = /obj/item/clothing/glasses/hud/standard
	huds["dual HUD"] = /obj/item/clothing/glasses/hud/dual
	huds["clear HUD"] = /obj/item/clothing/glasses/hud/monoglass
	huds["glasses HUD"] = /obj/item/clothing/glasses/hud/glasses
	huds["aviators HUD"] = /obj/item/clothing/glasses/hud/aviators
	huds["visor HUD"] = /obj/item/clothing/glasses/hud/visor
	huds["clip-on HUD"] = /obj/item/clothing/glasses/hud/shades
	huds["over-eye HUD"] = /obj/item/clothing/glasses/hud/one_eyed/oneye
	huds["patch HUD"] = /obj/item/clothing/glasses/hud/one_eyed/patch
	gear_tweaks += new /datum/gear_tweak/path(huds)

/datum/gear/eyes/prescriptionlenses
	display_name = "HUD prescription lenses"
	path = /obj/item/device/hudlenses/prescription
	cost = 1

/datum/gear/eyes/psychoscope
	display_name = "psychoscope"
	path = /obj/item/clothing/glasses/hud/psychoscope
	cost = 3
	price = 50
	allowed_roles = list(/datum/job/rd)
