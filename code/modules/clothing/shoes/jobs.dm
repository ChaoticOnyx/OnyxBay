/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots."
	name = "galoshes"
	icon_state = "galoshes"
	item_state_slots = null
	permeability_coefficient = 0.05
	item_flags = ITEM_FLAG_NOSLIP
	can_hold_knife = 1
	species_restricted = null
	siemens_coefficient = 0.3

	armor = list(melee = 55, bullet = 20, laser = 20, energy = 35, bomb = 25, bio = 70)

	drop_sound = SFX_DROP_BOOTS
	pickup_sound = SFX_PICKUP_BOOTS

/obj/item/clothing/shoes/galoshes/Initialize()
	. = ..()
	slowdown_per_slot[slot_shoes] = 1

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Tall synthleather boots with an artificial shine."
	icon_state = "jackboots"
	item_state_slots = null
	force = 3
	armor = list(melee = 70, bullet = 70, laser = 60, energy = 25, bomb = 20, bio = 30)
	siemens_coefficient = 0.5
	can_hold_knife = 1
	cold_protection = FEET
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE

	drop_sound = SFX_DROP_BOOTS
	pickup_sound = SFX_PICKUP_BOOTS

/obj/item/clothing/shoes/jackboots/tactical
	name = "tactical jackboots"
	desc = "Tall synthleather boots with an artificial shine. These ones seem to be reinforced with some sort of plating."
	armor = list(melee = 80, bullet = 80, laser = 70, energy = 25, bomb = 50, bio = 30)
	siemens_coefficient = 0.4

/obj/item/clothing/shoes/jackboots/unathi
	name = "toe-less jackboots"
	desc = "Modified pair of jackboots, particularly comfortable for those species whose toes hold claws."
	item_state = "digiboots"
	siemens_coefficient = 0.7
	species_restricted = null
	coverage = 0.8

/obj/item/clothing/shoes/workboots
	name = "workboots"
	desc = "A pair of steel-toed work boots designed for use in industrial settings. Safety first."
	icon_state = "workboots"
	armor = list(melee = 80, bullet = 40, laser = 50, energy = 25, bomb = 40, bio = 0)
	siemens_coefficient = 0.4
	can_hold_knife = 1

	drop_sound = SFX_DROP_BOOTS
	pickup_sound = SFX_PICKUP_BOOTS

	item_state_slots = list(
		slot_l_hand_str = "jackboots",
		slot_r_hand_str = "jackboots",
		)

/obj/item/clothing/shoes/workboots/toeless
	name = "toe-less workboots"
	desc = "A pair of toeless work boots designed for use in industrial settings. Modified for species whose toes have claws."
	icon_state = "workbootstoeless"
	siemens_coefficient = 0.6
	species_restricted = null
	coverage = 0.8
