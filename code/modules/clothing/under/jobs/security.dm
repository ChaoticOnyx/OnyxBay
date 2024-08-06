/*
 * Contains:
 *		Security
 *		Detective
 *		Head of Security
 */

/*
 * Security
 */
/obj/item/clothing/under/rank/warden
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	name = "warden's jumpsuit"
	icon_state = "warden_red"
	item_state_slots = list(
		slot_hand_str = "red"
		)
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.8

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "officer_red"
	item_state_slots = list(
		slot_hand_str = "red"
		)
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.8

/obj/item/clothing/under/tactical
	name = "tactical jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "swatunder"
	item_state_slots = list(
		slot_hand_str = "black"
		)
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.9

/*
 * Detective
 */
/obj/item/clothing/under/det
	name = "detective's suit"
	desc = "A rumpled white dress shirt paired with well-worn grey slacks."
	icon_state = "detective"
	armor = list(melee = 10, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.9
	starting_accessories = list(/obj/item/clothing/accessory/blue_clip)

/obj/item/clothing/under/det/grey
	icon_state = "det_grey"
	item_state_slots = list(
		slot_hand_str = "detective"
		)
	desc = "A serious-looking tan dress shirt paired with freshly-pressed black slacks."
	starting_accessories = list(/obj/item/clothing/accessory/red_long)

/obj/item/clothing/under/det/black
	icon_state = "det_black"
	item_state_slots = list(
		slot_hand_str = "sl_suit"
		)
	desc = "An immaculate white dress shirt, paired with a pair of dark grey dress pants, a red tie, and a charcoal vest."
	starting_accessories = list(/obj/item/clothing/accessory/red_long, /obj/item/clothing/accessory/toggleable/vest)

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/head_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hos_red"
	item_state_slots = list(
		slot_hand_str = "red"
		)
	armor = list(melee = 20, bullet = 25, laser = 25, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.7

/obj/item/clothing/under/rank/head_of_security/jensen
	desc = "You never asked for anything that stylish."
	name = "head of security's jumpsuit"
	icon_state = "jensen"
	item_state_slots = list(
		slot_hand_str = "jensen"
		)
	siemens_coefficient = 0.6

/obj/item/clothing/under/security_pants
	name = "security officer's trousers"
	desc = "Red pants made of a slightly sturdier material, to allow for robust protection."
	icon_state = "secpants"
	gender = PLURAL
	body_parts_covered = LOWER_TORSO|LEGS
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/security_pants/equipped // Preequipped w/ a shirt
	starting_accessories = list(/obj/item/clothing/accessory/security_shirt)
