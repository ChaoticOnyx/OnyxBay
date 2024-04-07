/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Reinforced headgear. Protects the head from impacts."
	icon_state = "helmet"
	item_state_slots = list(
		slot_l_hand_str = "helmet",
		slot_r_hand_str = "helmet",
		)
	valid_accessory_slots = list(ACCESSORY_SLOT_HELM_C, ACCESSORY_SLOT_HELM_H)
	restricted_accessory_slots = list(ACCESSORY_SLOT_HELM_C, ACCESSORY_SLOT_HELM_H)
	item_flags = ITEM_FLAG_THICKMATERIAL
	body_parts_covered = HEAD|EYES
	armor = list(melee = 70, bullet = 90, laser = 70, energy = 25, bomb = 35, bio = 0)
	flags_inv = HIDEEARS|BLOCKHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6
	w_class = ITEM_SIZE_NORMAL
	var/visor_body_parts_covered = EYES //body parts covered by visor, switches them if you switch visor
	ear_protection = 1
	drop_sound = SFX_DROP_HELMET
	pickup_sound = SFX_PICKUP_HELMET
	coverage = 0.8

	rad_resist_type = /datum/rad_resist/helmet

/datum/rad_resist/helmet
	alpha_particle_resist = 25 MEGA ELECTRONVOLT
	beta_particle_resist = 5 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/head/helmet/attack_self(mob/user)
	if(visor_body_parts_covered)
		togglevisor(user)
	else
		..()

/obj/item/clothing/head/helmet/proc/togglevisor(mob/user)
	if(icon_state == initial(icon_state))
		icon_state = "[icon_state]_up"
		to_chat(user, "You raise the visor on \the [src].")
		body_parts_covered &= ~visor_body_parts_covered
	else
		icon_state = initial(icon_state)
		to_chat(user, "You lower the visor on \the [src].")
		body_parts_covered |= visor_body_parts_covered
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
	visor_body_parts_covered = FACE|EYES
	armor = list(melee = 140, bullet = 55, laser = 50, energy = 25, bomb = 35, bio = 5)
	siemens_coefficient = 0.5
	action_button_name = "Toggle Visor"
	coverage = 1.0

/obj/item/clothing/head/helmet/ablative
	name = "ablative helmet"
	desc = "A helmet made from advanced materials which protects against concentrated energy weapons."
	icon_state = "helmet_reflect"
	valid_accessory_slots = null
	body_parts_covered = HEAD|EYES
	visor_body_parts_covered = EYES
	armor = list(melee = 55, bullet = 50, laser = 160, energy = 60, bomb = 35, bio = 2)
	siemens_coefficient = 0
	coverage = 0.9

/obj/item/clothing/head/helmet/ballistic
	name = "ballistic helmet"
	desc = "A helmet with reinforced plating to protect against ballistic projectiles."
	icon_state = "helmet_bulletproof"
	valid_accessory_slots = null
	body_parts_covered = HEAD|EYES
	visor_body_parts_covered = EYES
	armor = list(melee = 60, bullet = 160, laser = 40, energy = 5, bomb = 35, bio = 2)
	siemens_coefficient = 0.6
	coverage = 0.9

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	valid_accessory_slots = null
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|BLOCKHAIR
	body_parts_covered = HEAD|FACE
	visor_body_parts_covered = NO_BODYPARTS
	siemens_coefficient = 1
	coverage = 1.0

/obj/item/clothing/head/helmet/captain
	name = "captain's helmet"
	icon_state = "caphelmet"
	item_state = "caphelmet"
	desc = "A special extra-durable helmet designed for the most fashionable of military figureheads."
	body_parts_covered = HEAD|EYES
	visor_body_parts_covered = NO_BODYPARTS
	flags_inv = HIDEFACE|BLOCKHAIR
	armor = list(melee = 110, bullet = 140, laser = 130, energy = 25, bomb = 35, bio = 0)
	siemens_coefficient = 0.5
	coverage = 1.0

//Non-powersuit ERT helmets.
//Commander
/obj/item/clothing/head/helmet/ert
	name = "ERT commander helmet"
	desc = "An in-atmosphere helmet worn by NanoTrasen's elite Emergency Response Teams. Has blue highlights."
	icon_state = "erthelmet_cmd"
	body_parts_covered = HEAD|EYES
	visor_body_parts_covered = NO_BODYPARTS
	valid_accessory_slots = null
	item_state_slots = list(
		slot_l_hand_str = "syndicate-helm-green",
		slot_r_hand_str = "syndicate-helm-green",
		)
	armor = list(melee = 100, bullet = 130, laser = 120, energy = 40, bomb = 20, bio = 0)
	siemens_coefficient = 0.5
	coverage = 0.9

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
	body_parts_covered = HEAD|EYES
	visor_body_parts_covered = NO_BODYPARTS
	armor = list(melee = 120, bullet = 150, laser = 150, energy = 65, bomb = 90, bio = 50)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	coverage = 1.0

/obj/item/clothing/head/helmet/augment
	name = "Augment Array"
	desc = "A helmet with optical and cranial augments coupled to it."
	icon_state = "v62"
	valid_accessory_slots = null
	armor = list(melee = 70, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10)
	flags_inv = HIDEEARS|HIDEEYES
	body_parts_covered = HEAD|EYES|BLOCKHEADHAIR
	visor_body_parts_covered = NO_BODYPARTS
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4

/obj/item/clothing/head/helmet/syndi
	name = "heavy helmet"
	desc = "A heavily reinforced helmet painted with red markings. Feels like it could take a lot of punishment."
	icon_state = "helmet_merc"
	body_parts_covered = HEAD|EYES
	visor_body_parts_covered = EYES
	siemens_coefficient = 0.4
	armor = list(melee = 100, bullet = 130, laser = 120, energy = 50, bomb = 50, bio = 50)
	coverage = 0.95

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	body_parts_covered = HEAD
	visor_body_parts_covered = NO_BODYPARTS
	valid_accessory_slots = null
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 1
