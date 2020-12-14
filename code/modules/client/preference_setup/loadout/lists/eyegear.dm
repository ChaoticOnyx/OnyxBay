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
