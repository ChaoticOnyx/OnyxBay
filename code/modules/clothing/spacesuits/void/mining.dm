
// Normal
/obj/item/clothing/head/helmet/space/void/mining
	name = "mining voidhelmet"
	desc = "A scuffed voidsuit helmet with a boosted communication system and reinforced armor plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	item_state_slots = list(
		slot_l_hand_str = "mining_helm",
		slot_r_hand_str = "mining_helm",
		)
	armor = list(melee = 110, bullet = 75, laser = 45, energy = 5, bomb = 55, bio = 100)
	light_overlay = "helmet_light_dual_low"
	rad_resist_type = /datum/rad_resist/deathsquad

/obj/item/clothing/suit/space/void/mining
	icon_state = "rig-mining"
	name = "mining voidsuit"
	desc = "A grimy, decently armored voidsuit with purple blazes and extra insulation."
	item_state_slots = list(
		slot_l_hand_str = "mining_voidsuit",
		slot_r_hand_str = "mining_voidsuit",
	)
	armor = list(melee = 110, bullet = 75, laser = 45, energy = 5, bomb = 55, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/stack/flag,/obj/item/device/suit_cooling_unit,/obj/item/storage/ore,/obj/item/device/t_scanner,/obj/item/pickaxe, /obj/item/construction/rcd)
	rad_resist_type = /datum/rad_resist/deathsquad

/obj/item/clothing/suit/space/void/mining/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/mining

// Advanced
/obj/item/clothing/head/helmet/space/void/mining/alt
	name = "frontier mining voidhelmet"
	desc = "An armored voidsuit helmet. Someone must have through they were pretty cool when they painted a mohawk on it."
	icon_state = "rig0-miningalt"
	item_state = "miningalt_helm"
	armor = list(melee = 50, bullet = 15, laser = 20,energy = 5, bomb = 55, bio = 100)

/obj/item/clothing/suit/space/void/mining/alt
	icon_state = "rig-miningalt"
	name = "frontier mining voidsuit"
	desc = "A cheap prospecting voidsuit. What it lacks in comfort it makes up for in armor plating and street cred."
	armor = list(melee = 50, bullet = 15, laser = 20,energy = 5, bomb = 55, bio = 100)

/obj/item/clothing/suit/space/void/mining/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/mining/alt

// Reinforced
/obj/item/clothing/head/helmet/space/void/mining/reinforced
	name = "mining hardsuit helmet"
	desc = "An armored hardsuit helmet. Provides exceptionally good protection against aggressive asteroid dwellers."
	icon_state = "rig0-miningref"
	item_state = "miningref_helm"
	armor = list(melee = 125, bullet = 80, laser = 65, energy = 15, bomb = 65, bio = 100)

/obj/item/clothing/suit/space/void/mining/reinforced
	icon_state = "rig-miningref"
	name = "mining hardsuit"
	desc = "A heavy-duty prospecting hardsuit. What it lacks in comfort it makes up for in armor plating and street cred."
	armor = list(melee = 125, bullet = 80, laser = 65, energy = 15, bomb = 65, bio = 100)

/obj/item/clothing/suit/space/void/mining/reinforced/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/mining/reinforced
