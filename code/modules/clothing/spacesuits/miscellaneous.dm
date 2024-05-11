//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	item_state = "santahat"

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_flags = ITEM_FLAG_STOPPRESSUREDAMAGE
	allowed = list(/obj/item) //for stuffing exta special presents

/obj/item/clothing/suit/space/santa/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

//Space pirate outfit
/obj/item/clothing/head/helmet/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30)
	flags_inv = BLOCKHAIR
	body_parts_covered = HEAD
	visor_body_parts_covered = NO_BODYPARTS
	siemens_coefficient = 0.9

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	w_class = ITEM_SIZE_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/handcuffs,/obj/item/tank/emergency)
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30)
	siemens_coefficient = 0.9
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/space/pirate/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

//Orange emergency space suit
/obj/item/clothing/head/helmet/space/emergency
	name = "Emergency Space Helmet"
	icon_state = "emergencyhelm"
	item_state = "emergencyhelm"
	desc = "A simple helmet with a built in light, smells like mothballs."
	flash_protection = FLASH_PROTECTION_NONE
	rad_resist_type = /datum/rad_resist/space_emergency

/datum/rad_resist/space_emergency
	alpha_particle_resist = 31.8 MEGA ELECTRONVOLT
	beta_particle_resist = 5.7 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/suit/space/emergency
	name = "Emergency Softsuit"
	icon_state = "syndicate-orange"
	desc = "A thin, ungainly softsuit colored in blaze orange for rescuers to easily locate, looks pretty fragile."
	rad_resist_type = /datum/rad_resist/space_emergency

/obj/item/clothing/suit/space/emergency/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 3

//Alpha Goliath's tailplate
/obj/item/clothing/head/helmet/space/goliath
	name = "goliath tailplate"
	desc = "An old goliath's tailplate. It's exceptionally tough, yet quite soft on the inside and, surprisingly, matches a human head's size."
	icon_state = "goliathhelm"
	armor = list(melee = 85, bullet = 65, laser = 65, energy = 35, bomb = 65, bio = 85)
	siemens_coefficient = 0.5
	flash_protection = FLASH_PROTECTION_MODERATE
	action_button_name = null
	rad_resist_type = /datum/rad_resist/space_goliath

/datum/rad_resist/space_goliath
	alpha_particle_resist = 40 MEGA ELECTRONVOLT
	beta_particle_resist = 2.8 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/head/helmet/space/goliath/attack_self(mob/user)
	return
