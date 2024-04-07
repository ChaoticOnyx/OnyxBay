
// Normal
/obj/item/clothing/head/helmet/space/void/engineering
	name = "engineering voidhelmet"
	desc = "A sturdy looking voidsuit helmet rated to protect against radiation."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	item_state_slots = list(
		slot_l_hand_str = "eng_helm",
		slot_r_hand_str = "eng_helm",
		)
	siemens_coefficient = 0.3
	armor = list(melee = 60, bullet = 50, laser = 60, energy = 45, bomb = 35, bio = 100)
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/obj/item/clothing/suit/space/void/engineering
	name = "engineering voidsuit"
	desc = "A run-of-the-mill service voidsuit with all the plating and radiation protection required for industrial work in vacuum."
	icon_state = "rig-engineering"
	item_state_slots = list(
		slot_l_hand_str = "eng_voidsuit",
		slot_r_hand_str = "eng_voidsuit",
	)
	siemens_coefficient = 0.3
	armor = list(melee = 60, bullet = 50, laser = 60, energy = 45, bomb = 35, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/construction/rcd)
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/obj/item/clothing/suit/space/void/engineering/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/obj/item/clothing/suit/space/void/engineering/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering
	boots = /obj/item/clothing/shoes/magboots

// Advanced
/obj/item/clothing/head/helmet/space/void/engineering/alt
	name = "engineering hardsuit helmet"
	desc = "A heavy, radiation-shielded voidsuit helmet with a surprisingly comfortable interior."
	icon_state = "rig0-engineeringalt"
	item_state = "engalt_helm"
	armor = list(melee = 80, bullet = 70, laser = 60, energy = 65, bomb = 35, bio = 100)
	light_overlay = "helmet_light_dual_low"

/obj/item/clothing/suit/space/void/engineering/alt
	name = "engineering hardsuit"
	desc = "A bulky industrial voidsuit. It's a few generations old, but a reliable design and radiation shielding make up for the lack of climate control."
	icon_state = "rig-engineeringalt"
	armor = list(melee = 80, bullet = 70, laser = 60, energy = 65, bomb = 35, bio = 100)

/obj/item/clothing/suit/space/void/engineering/alt/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 2

/obj/item/clothing/suit/space/void/engineering/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/alt
	boots = /obj/item/clothing/shoes/magboots
