
// Normal
/obj/item/clothing/head/helmet/space/void/security
	name = "security voidhelmet"
	desc = "A somewhat tacky voidsuit helmet, a fact mitigated by heavy armor plating."
	icon_state = "sec_helm"
	item_state = "sec_helm"
	armor = list(melee = 70, bullet = 100, laser = 70, energy = 5, bomb = 45, bio = 100)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/void/security
	name = "security voidsuit"
	desc = "A heavily armored voidsuit, designed to intimidate people who find black intimidating. Surprisingly slimming."
	icon_state = "sec_voidsuit"
	item_state = "sec_voidsuit"
	armor = list(melee = 70, bullet = 100, laser = 70, energy = 5, bomb = 45, bio = 100)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/void/security/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security
	boots = /obj/item/clothing/shoes/magboots

// Advanced
/obj/item/clothing/head/helmet/space/void/security/alt
	name = "riot security voidhelmet"
	desc = "A comfortable voidsuit helmet with cranial armor and eight-channel surround sound."
	icon_state = "secalt_helm"
	item_state = "secalt_helm"
	armor = list(melee = 90, bullet = 90, laser = 80, energy = 25, bomb = 35, bio = 100)

/obj/item/clothing/suit/space/void/security/alt
	name = "riot security voidsuit"
	desc = "A somewhat clumsy voidsuit layered with impact and laser-resistant armor plating. Specially designed to dissipate minor electrical charges."
	icon_state = "secalt_voidsuit"
	item_state = "secalt_voidsuit"
	armor = list(melee = 90, bullet = 90, laser = 80, energy = 25, bomb = 35, bio = 100)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)

/obj/item/clothing/suit/space/void/security/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security/alt
	boots = /obj/item/clothing/shoes/magboots

// HoS
/obj/item/clothing/head/helmet/space/void/security/hos
	name = "security commander voidhelmet"
	desc = "A heavily armored voidsuit helmet. Gold trimming radiates its owner's eliteness."
	icon_state = "sechos_helm"
	item_state = "sechos_helm"
	armor = list(melee = 80, bullet = 120, laser = 90, energy = 35, bomb = 45, bio = 100)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/security/hos
	name = "security commander voidsuit"
	desc = "A heavily armored voidsuit. Gold trimming shows who's the boss here, while heavy pauldrons and kama make it extra durable."
	icon_state = "sechos_voidsuit"
	item_state = "sechos_voidsuit"
	armor = list(melee = 80, bullet = 120, laser = 90, energy = 35, bomb = 45, bio = 100)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)

/obj/item/clothing/suit/space/void/security/hos/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security/hos
	boots = /obj/item/clothing/shoes/magboots
