//Contains: Engineering department jumpsuits
/obj/item/clothing/under/rank/chief_engineer
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpsuit"
	icon_state = "chiefengineer"
	item_state = "g_suit"
	worn_state = "chief"
	armor = list(melee = 10, bullet = 5, laser = 5, energy = 0, bomb = 10, bio = 0)
	siemens_coefficient = 0.6

	rad_resist_type = /datum/rad_resist/under_engineer

/obj/item/clothing/under/rank/atmospheric_technician
	desc = "It's a jumpsuit worn by atmospheric technicians."
	name = "atmospheric technician's jumpsuit"
	icon_state = "atmos"
	item_state = "atmos_suit"
	worn_state = "atmos"
	armor = list(melee = 20, bullet = 5, laser = 5, energy = 0, bomb = 10, bio = 0)

/obj/item/clothing/under/rank/engineer
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpsuit"
	icon_state = "engine"
	item_state = "engi_suit"
	worn_state = "engine"
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.7

	rad_resist_type = /datum/rad_resist/under_engineer

/datum/rad_resist/under_engineer
	alpha_particle_resist = 133 MEGA ELECTRONVOLT
	beta_particle_resist = 100 MEGA ELECTRONVOLT
	hawking_resist = 0.5 ELECTRONVOLT

/obj/item/clothing/under/rank/roboticist
	desc = "It's a slimming black jumpsuit with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon_state = "robotics"
	item_state = "bl_suit"
	worn_state = "robotics"

/obj/item/clothing/under/rank/roboticist/skirt
	desc = "It's a slimming black jumpskirt with reinforced seams; great for industrial work."
	name = "roboticist's jumpskirt"
	icon_state = "roboticsf"
	worn_state = "roboticsf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
