/obj/item/rig/unathi
	name = "NT breacher chassis control module"
	desc = "A cheap NT knock-off of an Unathi battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	suit_type = "NT breacher"
	icon_state = "breacher_rig_cheap"
	armor_type = /datum/armor/rig_unathi
	emp_protection = -20
	online_slowdown = 6
	offline_slowdown = 10
	vision_restriction = TINT_HEAVY
	offline_vision_restriction = TINT_BLIND

	chest_type = /obj/item/clothing/suit/space/rig/unathi
	helm_type = /obj/item/clothing/head/helmet/space/rig/unathi
	boot_type = /obj/item/clothing/shoes/magboots/rig/unathi
	glove_type = /obj/item/clothing/gloves/rig/unathi

/datum/armor/rig_unathi
	bio = 100
	bomb = 70
	bullet = 60
	energy = 60
	laser = 60
	melee = 60

/obj/item/rig/unathi/fancy
	name = "breacher chassis control module"
	desc = "An authentic Unathi breacher chassis. Huge, bulky and absurdly heavy. It must be like wearing a tank."
	suit_type = "breacher chassis"
	icon_state = "breacher_rig"
	armor_type = /datum/armor/rig_unathifancy
	vision_restriction = TINT_NONE

/datum/armor/rig_unathifancy
	bio = 100
	bomb = 90
	bullet = 90
	energy = 90
	laser = 90
	melee = 90

/obj/item/clothing/head/helmet/space/rig/unathi
	species_restricted = list(SPECIES_UNATHI)
	force = 5
	sharp = 1 //poking people with the horn

/obj/item/clothing/suit/space/rig/unathi
	species_restricted = list(SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/unathi
	species_restricted = list(SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/unathi
	species_restricted = list(SPECIES_UNATHI)
