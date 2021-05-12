//Wizard Rig
/obj/item/clothing/head/helmet/space/void/wizard
	name = "gem-encrusted voidsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state_slots = list(
		slot_l_hand_str = "wiz_helm",
		slot_r_hand_str = "wiz_helm",
		)
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
	sprite_sheets_obj = null
	wizard_garb = 1

/obj/item/clothing/suit/space/void/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted voidsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	w_class = ITEM_SIZE_LARGE //normally voidsuits are bulky but this one is magic I suppose
	unacidable = 1
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
	sprite_sheets_obj = null
	wizard_garb = 1
	flags_inv = HIDESHOES|HIDEJUMPSUIT|HIDETAIL //For gloves.
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS
	allowed = list(/obj/item/device/flashlight,
				/obj/item/weapon/tank,
				/obj/item/device/suit_cooling_unit,
				/obj/item/weapon/spellbook,
				/obj/item/weapon/contract,
				/obj/item/weapon/teleportation_scroll,
				/obj/item/weapon/gun/energy/staff,
				/obj/item/weapon/magic_rock,
				/obj/item/weapon/scrying,
				/obj/item/weapon/monster_manual,
				/obj/item/weapon/dice/d20/cursed)

/obj/item/clothing/suit/space/void/wizard/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

/obj/item/clothing/shoes/magboots/magic
	name = "magic magboots"
	desc = "A pair of reinforced boots that radiate energy. They resemble regular magboots but don't seem to have any magnets."
	icon_state = "magboots-magic0"
	icon_base = "magboots-magic"
	traction_system = "magic"
	wizard_garb = 1

/obj/item/clothing/gloves/wizard
	name = "mystical gloves"
	desc = "Reinforced, gem-studded gloves that radiate energy. They look like they go along with a matching voidsuit."
	icon_state = "mystical"
	item_state = "purplegloves"
	item_flags = ITEM_FLAG_THICKMATERIAL
	body_parts_covered = HANDS
	cold_protection =    HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	species_restricted = null
	gender = PLURAL
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	unacidable = 1
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
