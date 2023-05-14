/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Reinforced headgear. Protects the head from impacts."
	icon_state = "helmet"
	item_state_slots = list(
		slot_l_hand_str = "helmet",
		slot_r_hand_str = "helmet",
		)
	valid_accessory_slots = list(ACCESSORY_SLOT_HELM_C)
	restricted_accessory_slots = list(ACCESSORY_SLOT_HELM_C)
	item_flags = ITEM_FLAG_THICKMATERIAL
	body_parts_covered = HEAD
	armor_type = /datum/armor/head_helmet
	flags_inv = HIDEEARS|BLOCKHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6
	w_class = ITEM_SIZE_NORMAL
	var/has_visor = 1
	ear_protection = 1
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 25 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 5 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

/datum/armor/head_helmet
	bomb = 35
	bullet = 50
	energy = 25
	laser = 50
	melee = 50

/obj/item/clothing/head/helmet/attack_self(mob/user)
	if(has_visor)
		togglevisor(user)
	else
		..()

/obj/item/clothing/head/helmet/proc/togglevisor(mob/user)
	if(icon_state == initial(icon_state))
		src.icon_state = "[icon_state]_up"
		to_chat(user, "You raise the visor on the [src].")
	else
		icon_state = initial(icon_state)
		to_chat(user, "You lower the visor on the [src].")
	add_fingerprint(user)
	update_clothing_icon()

/obj/item/clothing/head/helmet/nt
	starting_accessories = list(/obj/item/clothing/accessory/armor/helmcover/nt)

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "helmet_riot"
	valid_accessory_slots = null
	body_parts_covered = HEAD|FACE|EYES
	armor_type = /datum/armor/head_helmet_riot
	siemens_coefficient = 0.5
	action_button_name = "Toggle Visor"

/datum/armor/head_helmet_riot
	bio = 5
	bomb = 35
	bullet = 50
	energy = 25
	laser = 50
	melee = 85

/obj/item/clothing/head/helmet/ablative
	name = "ablative helmet"
	desc = "A helmet made from advanced materials which protects against concentrated energy weapons."
	icon_state = "helmet_reflect"
	valid_accessory_slots = null
	armor_type = /datum/armor/head_helmet_ablative
	siemens_coefficient = 0

/datum/armor/head_helmet_ablative
	bio = 2
	bomb = 35
	bullet = 50
	energy = 60
	laser = 90
	melee = 50

/obj/item/clothing/head/helmet/ballistic
	name = "ballistic helmet"
	desc = "A helmet with reinforced plating to protect against ballistic projectiles."
	icon_state = "helmet_bulletproof"
	valid_accessory_slots = null
	armor_type = /datum/armor/head_helmet_ballistic
	siemens_coefficient = 0.6

/datum/armor/head_helmet_ballistic
	bio = 2
	bomb = 35
	bullet = 90
	energy = 5
	laser = 50
	melee = 50

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	valid_accessory_slots = null
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|BLOCKHAIR
	body_parts_covered = HEAD|FACE
	siemens_coefficient = 1
	has_visor = 0

/obj/item/clothing/head/helmet/captain
	name = "captain's helmet"
	icon_state = "caphelmet"
	item_state = "caphelmet"
	desc = "A special extra-durable helmet designed for the most fashionable of military figureheads."
	flags_inv = HIDEFACE|BLOCKHAIR
	armor_type = /datum/armor/head_helmet_captain
	siemens_coefficient = 0.5
	has_visor = 0

/datum/armor/head_helmet_captain
	bio = 10
	bomb = 45
	bullet = 65
	energy = 35
	laser = 65
	melee = 65

//Non-powersuit ERT helmets.
//Commander
/obj/item/clothing/head/helmet/ert
	name = "ERT commander helmet"
	desc = "An in-atmosphere helmet worn by NanoTrasen's elite Emergency Response Teams. Has blue highlights."
	icon_state = "erthelmet_cmd"
	valid_accessory_slots = null
	item_state_slots = list(
		slot_l_hand_str = "syndicate-helm-green",
		slot_r_hand_str = "syndicate-helm-green",
		)
	armor_type = /datum/armor/head_helmet_ert
	siemens_coefficient = 0.5
	has_visor = 0

/datum/armor/head_helmet_ert
	bio = 2
	bomb = 10
	bullet = 50
	energy = 35
	laser = 50
	melee = 62

//Security
/obj/item/clothing/head/helmet/ert/security
	name = "ERT security helmet"
	desc = "An in-atmosphere helmet worn by NanoTrasen's elite Emergency Response Teams. Has red highlights."
	icon_state = "erthelmet_sec"

//Engineer
/obj/item/clothing/head/helmet/ert/engineer
	name = "ERT engineering helmet"
	desc = "An in-atmosphere helmet worn by NanoTrasen's elite Emergency Response Teams. Has orange highlights."
	icon_state = "erthelmet_eng"

//Medical
/obj/item/clothing/head/helmet/ert/medical
	name = "ERT medical helmet"
	desc = "An in-atmosphere helmet worn by NanoTrasen's elite Emergency Response Teams. Has red and white highlights."
	icon_state = "erthelmet_med"

//All of the armor below is mostly unused
/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained SWAT Members."
	icon_state = "swat"
	armor_type = /datum/armor/head_helmet_swat
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	has_visor = 0

/datum/armor/head_helmet_swat
	bio = 50
	bomb = 50
	bullet = 85
	energy = 55
	laser = 85
	melee = 85

/obj/item/clothing/head/helmet/augment
	name = "Augment Array"
	desc = "A helmet with optical and cranial augments coupled to it."
	icon_state = "v62"
	valid_accessory_slots = null
	armor_type = /datum/armor/head_helmet_augment
	flags_inv = HIDEEARS|HIDEEYES
	body_parts_covered = HEAD|EYES|BLOCKHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4
	has_visor = 0

/datum/armor/head_helmet_augment
	bio = 10
	bomb = 50
	bullet = 60
	energy = 25
	laser = 05
	melee = 70

/obj/item/clothing/head/helmet/syndi
	name = "heavy helmet"
	desc = "A heavily reinforced helmet painted with red markings. Feels like it could take a lot of punishment."
	icon_state = "helmet_merc"
	armor_type = /datum/head_helmet_syndi
	siemens_coefficient = 0.4

/datum/armor/head_helmet_syndi
	bio = 50
	bomb = 50
	bullet = 75
	energy = 50
	laser = 75
	melee = 75

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	valid_accessory_slots = null
	armor_type = /datum/armor/head_helmet_thunerdome
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 1
	has_visor = 0

/datum/armor/head_helmet_thunerdome
	bio = 10
	bomb = 25
	bullet = 60
	energy = 10
	laser = 50
	melee = 90
