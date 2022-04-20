
// Normal
/obj/item/clothing/head/helmet/space/void/security
	name = "security voidhelmet"
	desc = "A somewhat tacky voidsuit helmet, a fact mitigated by heavy armor plating."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	item_state_slots = list(
		slot_l_hand_str = "sec_helm",
		slot_r_hand_str = "sec_helm",
		)
	armor = list(melee = 60, bullet = 40, laser = 40, energy = 5, bomb = 45, bio = 100, rad = 10)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/void/security
	icon_state = "rig-sec"
	name = "security voidsuit"
	desc = "A heavily armored voidsuit, designed to intimidate people who find black intimidating. Surprisingly slimming."
	item_state_slots = list(
		slot_l_hand_str = "sec_voidsuit",
		slot_r_hand_str = "sec_voidsuit",
	)
	armor = list(melee = 60, bullet = 40, laser = 40, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/void/security/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security
	boots = /obj/item/clothing/shoes/magboots

// Advanced
/obj/item/clothing/head/helmet/space/void/security/alt
	name = "riot security voidhelmet"
	desc = "A comfortable voidsuit helmet with cranial armor and eight-channel surround sound."
	icon_state = "rig0-secalt"
	item_state = "secalt_helm"
	armor = list(melee = 70, bullet = 50, laser = 50, energy = 5, bomb = 35, bio = 100, rad = 10)

/obj/item/clothing/suit/space/void/security/alt
	icon_state = "rig-secalt"
	name = "riot security voidsuit"
	desc = "A somewhat clumsy voidsuit layered with impact and laser-resistant armor plating. Specially designed to dissipate minor electrical charges."
	armor = list(melee = 70, bullet = 50, laser = 50, energy = 5, bomb = 35, bio = 100, rad = 10)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)

/obj/item/clothing/suit/space/void/security/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security/alt
	boots = /obj/item/clothing/shoes/magboots

// HoS
/obj/item/clothing/head/helmet/space/void/security/hos
	name = "security commander voidhelmet"
	desc = "A heavily armored voidsuit helmet. Gold trimming radiates its owner's eliteness."
	icon_state = "rig0-sechos"
	item_state = "sechos_helm"
	armor = list(melee = 70, bullet = 55, laser = 55, energy = 25, bomb = 45, bio = 100, rad = 40)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/security/hos
	icon_state = "rig-sechos"
	name = "security commander voidsuit"
	desc = "A heavily armored voidsuit. Gold trimming shows who's the boss here, while heavy pauldrons and kama make it extra durable."
	armor = list(melee = 70, bullet = 55, laser = 55, energy = 25, bomb = 45, bio = 100, rad = 40)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)

/obj/item/clothing/suit/space/void/security/hos/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security/hos
	boots = /obj/item/clothing/shoes/magboots
