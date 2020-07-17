/////////////////////////////////////////////////////////////////////////
// Some SPECIAL clothes for the exceptionally important onyx residents //
/////////////////////////////////////////////////////////////////////////

// Schutze88
/obj/item/clothing/suit/armor/hos/jensen/fieldcoat
	name = "military trenchcoat"
	desc = "A military trenchcoat with a leather belt and long, custom collar. Looks kinda old, but is kept in a good shape."
	icon_state = "dalek_coat"
	item_state = "dalek_coat"
	armor = list(melee = 45, bullet = 35, laser = 35, energy = 10, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/hos/jensen/fieldcoat/mob_can_equip(mob/user)
	.=..()
	if(user.gender == FEMALE)
		to_chat(user, SPAN("warning", "You aren't sure you'll fit in this fascist cloth..."))
		return 0

// TaTarin
/obj/item/clothing/head/helmet/police
	name = "police helmet"
	desc = "It's a helmet specifically designed for police use. Comfortable and robust."
	icon_state = "helmet_police"
	valid_accessory_slots = null
	body_parts_covered = HEAD|FACE|EYES //face shield
	armor = list(melee = 55, bullet = 55, laser = 55, energy = 25, bomb = 35, bio = 5, rad = 0)
	siemens_coefficient = 0.6
	action_button_name = "Toggle Visor"

/obj/item/clothing/head/helmet/police/attack_self(mob/user)
	togglevisor(user)

// Items below belong to i-dont-fucking-know-who
// Please, sign them ASAP
/obj/item/clothing/head/helmet/german
	name = "stahlhelm"
	desc = "A simple yet menacing looking steel helmet. Protects the head from bullets."
	icon_state = "wehrhelm"
	valid_accessory_slots = null
	body_parts_covered = HEAD
	armor = list(melee = 45, bullet = 60, laser = 45,energy = 10, bomb = 40, bio = 2, rad = 10)
	siemens_coefficient = 1
	has_visor = 0

/obj/item/clothing/suit/armor/hos/german
	name = "ancient trenchcoat"
	desc = "An ancient trenchcoat, how did it survived to these days? There's a label on the neck that reads 'Hergestellt von Hugo Boss'"
	icon_state = "trenchcoatger"
	item_state = "trenchcoatger"
	armor = list(melee = 35, bullet = 15, laser = 15, energy = 10, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/hos/german/mob_can_equip(mob/user)
	.=..()
	if(user.gender == FEMALE)
		to_chat(user, SPAN("warning", "You aren't sure you'll fit in this men's cloth..."))
		return 0
