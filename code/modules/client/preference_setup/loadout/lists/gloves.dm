/datum/gear/gloves
	cost = 2
	slot = slot_gloves
	sort_category = "Gloves"

/datum/gear/gloves/colored
	display_name = "gloves, colored"
	flags = GEAR_HAS_COLOR_SELECTION
	path = /obj/item/clothing/gloves/color

/datum/gear/gloves/rainbow
	display_name = "gloves, rainbow"
	path = /obj/item/clothing/gloves/rainbow

/datum/gear/ring
	display_name = "ring"
	path = /obj/item/clothing/ring
	cost = 1

/datum/gear/ring/New()
	..()
	var/ringtype = list()
	ringtype["CTI ring"] = /obj/item/clothing/ring/cti
	ringtype["Mariner University ring"] = /obj/item/clothing/ring/mariner
	ringtype["engagement ring"] = /obj/item/clothing/ring/engagement
	ringtype["signet ring"] = /obj/item/clothing/ring/seal/signet
	ringtype["masonic ring"] = /obj/item/clothing/ring/seal/mason
	ringtype["ring, steel"] = /obj/item/clothing/ring/material/steel
	ringtype["ring, bronze"] = /obj/item/clothing/ring/material/bronze
	ringtype["ring, silver"] = /obj/item/clothing/ring/material/silver
	ringtype["ring, gold"] = /obj/item/clothing/ring/material/gold
	ringtype["ring, platinum"] = /obj/item/clothing/ring/material/platinum
	ringtype["ring, glass"] = /obj/item/clothing/ring/material/glass
	ringtype["ring, wood"] = /obj/item/clothing/ring/material/wood
	ringtype["ring, plastic"] = /obj/item/clothing/ring/material/plastic
	gear_tweaks += new /datum/gear_tweak/path(ringtype)

/datum/gear/gloves/boxing
	display_name = "boxing gloves"
	path = /obj/item/clothing/gloves/boxing
	price = 12

/datum/gear/gloves/long_evening_gloves
	display_name = "long evening gloves"
	path = /obj/item/clothing/gloves/color/long_evening_gloves
	price = 8
	flags = GEAR_HAS_COLOR_SELECTION
	
