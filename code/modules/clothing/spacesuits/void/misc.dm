
//Deathsquad suit
/obj/item/clothing/suit/space/void/swat
	name = "\improper SWAT suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/weapon/gun, /obj/item/ammo_magazine, /obj/item/ammo_casing, /obj/item/weapon/melee/baton, /obj/item/weapon/handcuffs, /obj/item/weapon/tank)
	armor = list(melee = 80, bullet = 70, laser = 70, energy = 45, bomb = 65, bio = 100, rad = 100)
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0.6

/obj/item/clothing/suit/space/void/swat/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state_slots = list(
		slot_l_hand_str = "syndicate-helm-black-red",
		slot_r_hand_str = "syndicate-helm-black-red",
		)
	armor = list(melee = 80, bullet = 70, laser = 70, energy = 45, bomb = 65, bio = 100, rad = 100)
	item_flags = ITEM_FLAG_STOPPRESSUREDAMAGE | ITEM_FLAG_THICKMATERIAL
	flags_inv = BLOCKHAIR
	siemens_coefficient = 0.6
