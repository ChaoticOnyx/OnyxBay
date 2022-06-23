//Wizard Rig
/obj/item/clothing/head/helmet/space/void/wizard
	name = "gem-encrusted voidsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state_slots = list(
		slot_l_hand_str = "wiz_helm",
		slot_r_hand_str = "wiz_helm",
		)
	unacidable = TRUE //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 30, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
	sprite_sheets_obj = null
	wizard_garb = TRUE
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC, SPECIES_UNATHI)

/obj/item/clothing/suit/space/void/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted voidsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	w_class = ITEM_SIZE_LARGE //normally voidsuits are bulky but this one is magic I suppose
	unacidable = TRUE
	armor = list(melee = 50, bullet = 30, laser = 30,energy = 30, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
	sprite_sheets_obj = null
	wizard_garb = TRUE
	flags_inv = HIDESHOES|HIDEJUMPSUIT|HIDETAIL //For gloves.
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS
	allowed = list(/obj/item/device/flashlight,
				/obj/item/tank,
				/obj/item/device/suit_cooling_unit,
				/obj/item/spellbook,
				/obj/item/contract,
				/obj/item/teleportation_scroll,
				/obj/item/gun/energy/staff,
				/obj/item/magic_rock,
				/obj/item/scrying,
				/obj/item/monster_manual,
				/obj/item/dice/d20/cursed)
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_IPC, SPECIES_UNATHI)

/obj/item/clothing/suit/space/void/wizard/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

/obj/item/clothing/shoes/magboots/wizard
	name = "magic magboots"
	desc = "A pair of reinforced boots that radiate energy. They resemble regular magboots but don't seem to have any magnets."
	icon_state = "magboots-magic0"
	icon_base = "magboots-magic"
	traction_system = "magic"
	wizard_garb = TRUE

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
	unacidable = TRUE
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
