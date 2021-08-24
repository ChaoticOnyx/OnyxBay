/var/global/list/bioprinter_recipes
/var/global/list/bioprinter_categories

/proc/populate_bioprinter_recipes()
	bioprinter_recipes = list()
	bioprinter_categories = list()
	for(var/R in typesof(/datum/bioprinter/recipe)-/datum/bioprinter/recipe)
		var/datum/bioprinter/recipe/recipe = new R
		bioprinter_recipes += recipe
		bioprinter_categories |= recipe.category

// Organs
/datum/bioprinter/recipe
	var/name = "object"
	var/id
	var/category
	var/time
	var/biomass
	var/build_path

/datum/bioprinter/recipe/heart
	name = "Heart"
	id = BP_HEART
	category = "Organs"
	time = 40
	biomass = 3500
	build_path = /obj/item/organ/internal/heart

/datum/bioprinter/recipe/lungs
	name = "Lungs"
	id = BP_LUNGS
	category = "Organs"
	time = 40
	biomass = 3500
	build_path = /obj/item/organ/internal/lungs

/datum/bioprinter/recipe/kidneys
	name = "Kidneys"
	id = BP_KIDNEYS
	category = "Organs"
	time = 40
	biomass = 3500
	build_path = /obj/item/organ/internal/kidneys

/datum/bioprinter/recipe/eyes
	name = "Eyes"
	id = BP_EYES
	category = "Organs"
	time = 40
	biomass = 3500
	build_path = /obj/item/organ/internal/eyes

/datum/bioprinter/recipe/liver
	name = "Liver"
	id = BP_LIVER
	category = "Organs"
	time = 40
	biomass = 3500
	build_path = /obj/item/organ/internal/liver

/datum/bioprinter/recipe/stomach
	name = "Stomach"
	id = BP_STOMACH
	category = "Organs"
	time = 40
	biomass = 3500
	build_path = /obj/item/organ/internal/stomach

// Limbs
/datum/bioprinter/recipe/l_arm
	name = "Left Arm"
	id = BP_L_ARM
	category = "Limbs"
	time = 60
	biomass = 10100
	build_path = /obj/item/organ/external/arm

/datum/bioprinter/recipe/r_arm
	name = "Right Arm"
	id = BP_R_ARM
	category = "Limbs"
	time = 60
	biomass = 10100
	build_path = /obj/item/organ/external/arm/right

/datum/bioprinter/recipe/l_hand
	name = "Left Hand"
	id = BP_L_HAND
	category = "Limbs"
	time = 60
	biomass = 5600
	build_path = /obj/item/organ/external/hand

/datum/bioprinter/recipe/r_hand
	name = "Right Hand"
	id = BP_R_HAND
	category = "Limbs"
	time = 60
	biomass = 5600
	build_path = /obj/item/organ/external/hand/right

/datum/bioprinter/recipe/l_leg
	name = "Left Leg"
	id = BP_L_LEG
	category = "Limbs"
	time = 60
	biomass = 10100
	build_path = /obj/item/organ/external/leg

/datum/bioprinter/recipe/r_leg
	name = "Right Leg"
	id = BP_R_LEG
	category = "Limbs"
	time = 60
	biomass = 10100
	build_path = /obj/item/organ/external/leg/right

/datum/bioprinter/recipe/l_foot
	name = "Left Foot"
	id = BP_L_FOOT
	category = "Limbs"
	time = 60
	biomass = 5600
	build_path = /obj/item/organ/external/foot

/datum/bioprinter/recipe/r_foot
	name = "Right Foot"
	id = BP_R_FOOT
	category = "Limbs"
	time = 60
	biomass = 5600
	build_path = /obj/item/organ/external/foot/right
