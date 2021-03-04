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
	armor = list(melee = 50, bullet = 50, laser = 50,energy = 25, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEEARS|BLOCKHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6
	w_class = ITEM_SIZE_NORMAL
	var/has_visor = 1

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
	body_parts_covered = HEAD|FACE|EYES //face shield
	armor = list(melee = 85, bullet = 50, laser = 50, energy = 25, bomb = 35, bio = 5, rad = 0)
	siemens_coefficient = 0.5
	action_button_name = "Toggle Visor"

/obj/item/clothing/head/helmet/ablative
	name = "ablative helmet"
	desc = "A helmet made from advanced materials which protects against concentrated energy weapons."
	icon_state = "helmet_reflect"
	valid_accessory_slots = null
	armor = list(melee = 50, bullet = 50, laser = 90, energy = 60, bomb = 35, bio = 2, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/head/helmet/ballistic
	name = "ballistic helmet"
	desc = "A helmet with reinforced plating to protect against ballistic projectiles."
	icon_state = "helmet_bulletproof"
	valid_accessory_slots = null
	armor = list(melee = 50, bullet = 90, laser = 50, energy = 5, bomb = 35, bio = 2, rad = 0)
	siemens_coefficient = 0.6

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
	armor = list(melee = 65, bullet = 65, laser = 65,energy = 35, bomb = 45, bio = 10, rad = 10)
	siemens_coefficient = 0.5
	has_visor = 0

//Non-hardsuit ERT helmets.
//Commander
/obj/item/clothing/head/helmet/ert
	name = "asset protection command helmet"
	desc = "An in-atmosphere helmet worn by many corporate and private asset protection forces. Has blue highlights."
	icon_state = "erthelmet_cmd"
	valid_accessory_slots = null
	item_state_slots = list(
		slot_l_hand_str = "syndicate-helm-green",
		slot_r_hand_str = "syndicate-helm-green",
		)
	armor = list(melee = 62, bullet = 50, laser = 50,energy = 35, bomb = 10, bio = 2, rad = 0)
	siemens_coefficient = 0.5
	has_visor = 0

//Security
/obj/item/clothing/head/helmet/ert/security
	name = "asset protection security helmet"
	desc = "An in-atmosphere helmet worn by many corporate and private asset protection forces. Has red highlights."
	icon_state = "erthelmet_sec"

//Engineer
/obj/item/clothing/head/helmet/ert/engineer
	name = "asset protection engineering helmet"
	desc = "An in-atmosphere helmet worn by many corporate and private asset protection forces. Has orange highlights."
	icon_state = "erthelmet_eng"

//Medical
/obj/item/clothing/head/helmet/ert/medical
	name = "asset protection medical helmet"
	desc = "An in-atmosphere helmet worn by many corporate and private asset protection forces. Has red and white highlights."
	icon_state = "erthelmet_med"

//All of the armor below is mostly unused
/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained SWAT Members."
	icon_state = "swat"
	armor = list(melee = 85, bullet = 85, laser = 85,energy = 55, bomb = 50, bio = 50, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	has_visor = 0

/obj/item/clothing/head/helmet/augment
	name = "Augment Array"
	desc = "A helmet with optical and cranial augments coupled to it."
	icon_state = "v62"
	valid_accessory_slots = null
	armor = list(melee = 70, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	body_parts_covered = HEAD|EYES|BLOCKHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4
	has_visor = 0

/obj/item/clothing/head/helmet/syndi
	name = "heavy helmet"
	desc = "A heavily reinforced helmet painted with red markings. Feels like it could take a lot of punishment."
	icon_state = "helmet_merc"
	armor = list(melee = 75, bullet = 75, laser = 75, energy = 50, bomb = 50, bio = 50, rad = 0)
	siemens_coefficient = 0.4

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	valid_accessory_slots = null
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 1
	has_visor = 0
