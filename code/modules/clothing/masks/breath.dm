/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	item_flags = ITEM_FLAG_AIRTIGHT
	body_parts_covered = FACE
	w_class = ITEM_SIZE_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	armor = list(melee = 5, bullet = 3, laser = 3, energy = 0, bomb = 0, bio = 25)
	down_gas_transfer_coefficient = 1
	down_item_flags = ITEM_FLAG_THICKMATERIAL
	down_icon_state = "breathdown"
	pull_mask = 1
	item_state_slots = list(
		slot_l_hand_str = "breathmask",
		slot_r_hand_str = "breathmask",
		)
	use_alt_layer = TRUE
	can_use_alt_layer = TRUE

	rad_resist_type = /datum/rad_resist/mask_breath

/datum/rad_resist/mask_breath
	alpha_particle_resist = 16 MEGA ELECTRONVOLT
	beta_particle_resist = 2.6 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be manually connected to an air supply for treatment."
	name = "medical mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01
	armor = list(melee = 5, bullet = 3, laser = 3, energy = 0, bomb = 0, bio = 35)

	item_state_slots = list(
		slot_l_hand_str = "m_mask",
		slot_r_hand_str = "m_mask",
		)
	use_alt_layer = FALSE
	can_use_alt_layer = FALSE

/obj/item/clothing/mask/breath/anesthetic
	desc = "A close-fitting sterile mask that is used by the anesthetic wallmounted pump."
	name = "anesthetic mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01

	item_state_slots = list(
		slot_l_hand_str = "m_mask",
		slot_r_hand_str = "m_mask",
		)
	use_alt_layer = FALSE
	can_use_alt_layer = FALSE

/obj/item/clothing/mask/breath/emergency
	desc = "A close-fitting  mask that is used by the wallmounted emergency oxygen pump."
	name = "emergency mask"
	icon_state = "breath"
	item_state = "breath"
	permeability_coefficient = 0.50
