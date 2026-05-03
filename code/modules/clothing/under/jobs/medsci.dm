/*
 * Science
 */
/obj/item/clothing/under/rank/research_director
	name = "research director's jumpsuit"
	desc = "It's a jumpsuit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director"
	item_state = "director"
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 10)

/obj/item/clothing/under/rank/research_director/rdalt
	name = "head researcher uniform"
	desc = "A dress suit and slacks stained with hard work and dedication to science. Perhaps other things as well, but mostly hard work and dedication."
	icon_state = "rdalt"
	item_state = "rdalt"

/obj/item/clothing/under/rank/research_director/skirt
	name = "research director's jumpskirt"
	desc = "Feminine fashion for the style concious RD. Its fabric provides minor protection from biological contaminants."
	icon_state = "director_skirt"
	item_state = "director_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/research_director/dress
	name = "research director's jumpdress"
	desc = "Feminine fashion for the style concious RD. Its fabric provides minor protection from biological contaminants."
	icon_state = "director_dress"
	item_state = "director_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist
	name = "scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has markings that denote the wearer as a scientist."
	icon_state = "science"
	item_state = "science"
	permeability_coefficient = 0.50
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 10, bio = 0)

/obj/item/clothing/under/rank/scientist/skirt
	name = "scientist's jumpskirt"
	icon_state = "science_skirt"
	item_state = "science_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/dress
	name = "scientist's jumpdress"
	icon_state = "science_dress"
	item_state = "science_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/roboticist
	name = "roboticist's jumpsuit"
	desc = "It's a slimming black jumpsuit with reinforced seams; great for industrial work."
	icon_state = "robotics"
	item_state = "robotics"
	worn_state = "robotics"

/obj/item/clothing/under/rank/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black jumpskirt with reinforced seams; great for industrial work."
	icon_state = "robotics_skirt"
	item_state = "robotics_skirt"
	worn_state = "robotics_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/roboticist/dress
	name = "roboticist's jumpdress"
	desc = "It's a slimming black jumpdress with reinforced seams; great for industrial work."
	icon_state = "robotics_dress"
	item_state = "robotics_dress"
	worn_state = "robotics_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/*
 * Medical
 */
/obj/item/clothing/under/rank/chief_medical_officer
	name = "chief medical officer's jumpsuit"
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo"
	item_state = "cmo"
	permeability_coefficient = 0.50
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 10)

/obj/item/clothing/under/rank/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo_skirt"
	item_state = "cmo_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chief_medical_officer/dress
	name = "chief medical officer's jumpdress"
	desc = "It's a jumpdress worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo_dress"
	item_state = "cmo_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/geneticist
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon_state = "genetics"
	item_state = "genetics"
	permeability_coefficient = 0.50
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 10)

/obj/item/clothing/under/rank/geneticist/skirt
	name = "geneticist's jumpskirt"
	icon_state = "genetics_skirt"
	item_state = "genetics_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/geneticist/dress
	name = "geneticist's jumpdress"
	icon_state = "genetics_dress"
	item_state = "genetics_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/virologist
	name = "virologist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virology"
	item_state = "virology"
	permeability_coefficient = 0.50
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 10)

/obj/item/clothing/under/rank/virologist/skirt
	name = "virologist's jumpskirt"
	icon_state = "virology_skirt"
	item_state = "virology_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/virologist/dress
	name = "virologist's jumpdress"
	icon_state = "virology_dress"
	item_state = "virology_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chemist
	name = "chemist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistry"
	item_state = "chemistry"
	permeability_coefficient = 0.50
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 10)

/obj/item/clothing/under/rank/chemist/skirt
	name = "chemist's jumpskirt"
	icon_state = "chemistry_skirt"
	item_state = "chemistry_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chemist/dress
	name = "chemist's jumpdress"
	icon_state = "chemistry_dress"
	item_state = "chemistry_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/nursesuit
	name = "nurse's suit"
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	icon_state = "nursesuit"
	item_state = "nursesuit"
	permeability_coefficient = 0.50
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 10)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/nurse
	name = "nurse's dress"
	desc = "A dress commonly worn by the nursing staff in the medical department."
	icon_state = "nurse"
	item_state = "nurse"
	permeability_coefficient = 0.50
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 10)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/medical
	name = "medical doctor's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.5
	armor_values = alist(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 30)

/obj/item/clothing/under/rank/medical/skirt
	name = "medical doctor's jumpskirt"
	icon_state = "medical_skirt"
	item_state = "medical_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/dress
	name = "medical doctor's jumpdress"
	icon_state = "medical_skirt"
	item_state = "medical_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/paramedic
	name = "paramedic jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "paramedic"
	item_state = "paramedic"

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic jumpskirt"
	icon_state = "paramedic_skirt"
	item_state = "paramedic_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/paramedic/dress
	name = "paramedic jumpdress"
	icon_state = "paramedic_dress"
	item_state = "paramedic_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/scrubs
	name = "scrubs"
	desc = "A loose-fitting garment designed to provide minor protection against biohazards."
	icon_state = "scrubs"
	item_state = "scrubs"

/obj/item/clothing/under/rank/medical/scrubs/blue
	name = "blue scrubs"
	icon_state = "scrubsblue"
	item_state = "scrubsblue"

/obj/item/clothing/under/rank/medical/scrubs/green
	name = "green scrubs"
	icon_state = "scrubsgreen"
	item_state = "scrubsgreen"

/obj/item/clothing/under/rank/medical/scrubs/purple
	name = "purple scrubs"
	icon_state = "scrubspurple"
	item_state = "scrubspurple"

/obj/item/clothing/under/rank/medical/scrubs/black
	name = "black scrubs"
	icon_state = "scrubsblack"
	item_state = "scrubsblack"

/obj/item/clothing/under/rank/medical/scrubs/navyblue
	name = "navy blue scrubs"
	icon_state = "scrubsnavyblue"
	item_state = "scrubsnavyblue"

/obj/item/clothing/under/rank/psych
	name = "psychiatrist's jumpsuit"
	desc = "A basic white jumpsuit. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psych"
	item_state = "psych"

/obj/item/clothing/under/rank/psych/skirt
	name = "psychiatrist's jumpskirt"
	desc = "A basic white jumpskirt. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psych_skirt"
	item_state = "psych_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/psych/dress
	name = "psychiatrist's jumpdress"
	desc = "A basic white jumpdress. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psych_dress"
	item_state = "psych_dress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/psych/turtleneck
	name = "turqouise turtleneck"
	desc = "A turqouise sweater and a pair of dark blue slacks."
	icon_state = "psychturtle"
	item_state = "psychturtle"
