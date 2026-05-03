//Contains: Engineering department jumpsuits
/obj/item/clothing/under/rank/chief_engineer
	name = "chief engineer's jumpsuit"
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	icon_state = "chiefengineer"
	item_state = "chief"
	worn_state = "chief"
	armor_values = alist(melee = 10, bullet = 5, laser = 5, energy = 0, bomb = 10, bio = 0)
	siemens_coefficient = 0.6

	rad_resist_type = /datum/rad_resist/under_engineer

/obj/item/clothing/under/rank/chief_engineer/skirt
	name = "chief engineer's jumpskirt"
	desc = "It's a high visibility jumpskirt given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	icon_state = "chiefengineer_skirt"
	item_state = "chiefengineer_skirt"
	worn_state = "chiefengineer_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chief_engineer/dress
	name = "chief engineer's jumpdress"
	desc = "It's a high visibility jumpdress given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	icon_state = "chiefengineer_dress"
	item_state = "chiefengineer_dress"
	worn_state = "chiefengineer_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineer
	name = "engineer's jumpsuit"
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	icon_state = "engine"
	item_state = "engine"
	worn_state = "engine"
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.7

	rad_resist_type = /datum/rad_resist/under_engineer

/obj/item/clothing/under/rank/engineer/skirt
	name = "engineer's jumpskirt"
	desc = "It's an orange high visibility jumpskirt worn by engineers. It has minor radiation shielding."
	icon_state = "engine_skirt"
	item_state = "engine_skirt"
	worn_state = "engine_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineer/dress
	name = "engineer's jumpdress"
	desc = "It's an orange high visibility jumpdress worn by engineers. It has minor radiation shielding."
	icon_state = "engine_dress"
	item_state = "engine_dress"
	worn_state = "engine_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/atmospheric_technician
	name = "atmospheric technician's jumpsuit"
	desc = "It's a jumpsuit worn by atmospheric technicians."
	icon_state = "atmos"
	item_state = "atmos_suit"
	worn_state = "atmos"
	armor_values = alist(melee = 20, bullet = 5, laser = 5, energy = 0, bomb = 10, bio = 0)

	rad_resist_type = /datum/rad_resist/under_engineer

/obj/item/clothing/under/rank/atmospheric_technician/skirt
	name = "atmospheric technician's jumpskirt"
	desc = "It's a jumpskirt worn by atmospheric technicians."
	icon_state = "atmos_skirt"
	item_state = "atmos_skirt"
	worn_state = "atmos_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/atmospheric_technician/dress
	name = "atmospheric technician's jumpdress"
	desc = "It's a jumpdress worn by atmospheric technicians."
	icon_state = "atmos_dress"
	item_state = "atmos_dress"
	worn_state = "atmos_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/datum/rad_resist/under_engineer
	alpha_particle_resist = 133 MEGA ELECTRONVOLT
	beta_particle_resist = 100 MEGA ELECTRONVOLT
	hawking_resist = 0.5 ELECTRONVOLT
