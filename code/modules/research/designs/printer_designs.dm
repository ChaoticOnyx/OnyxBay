GLOBAL_LIST_EMPTY(printer_recipes)
GLOBAL_LIST_EMPTY(printer_categories)

/proc/populate_printer_recipes()
	GLOB.printer_recipes = list()
	GLOB.printer_categories = list()
	for(var/R in subtypesof(/datum/printer/recipe)
		var/datum/printer/recipe/recipe = new R
		GLOB.printer_recipes += recipe
		GLOB.printer_categories |= recipe.category

// Organs
/datum/printer/recipe
	var/name = "object"
	var/id
	var/category
	var/time
	var/matter
	var/build_path

/datum/printer/recipe/heart
	name = "Heart"
	id = BP_HEART
	category = "Organs"
	time = 40
	matter = 3500
	build_path = /obj/item/organ/internal/heart

/datum/printer/recipe/lungs
	name = "Lungs"
	id = BP_LUNGS
	category = "Organs"
	time = 40
	matter = 3500
	build_path = /obj/item/organ/internal/lungs

/datum/printer/recipe/kidneys
	name = "Kidneys"
	id = BP_KIDNEYS
	category = "Organs"
	time = 40
	matter = 3500
	build_path = /obj/item/organ/internal/kidneys

/datum/printer/recipe/eyes
	name = "Eyes"
	id = BP_EYES
	category = "Organs"
	time = 40
	matter = 3500
	build_path = /obj/item/organ/internal/eyes

/datum/printer/recipe/liver
	name = "Liver"
	id = BP_LIVER
	category = "Organs"
	time = 40
	matter = 3500
	build_path = /obj/item/organ/internal/liver

/datum/printer/recipe/stomach
	name = "Stomach"
	id = BP_STOMACH
	category = "Organs"
	time = 40
	matter = 3500
	build_path = /obj/item/organ/internal/stomach

// Limbs
/datum/printer/recipe/l_arm
	name = "Left Arm"
	id = BP_L_ARM
	category = "Limbs"
	time = 60
	matter = 8500
	build_path = /obj/item/organ/external/arm

/datum/printer/recipe/r_arm
	name = "Right Arm"
	id = BP_R_ARM
	category = "Limbs"
	time = 60
	matter = 8500
	build_path = /obj/item/organ/external/arm/right

/datum/printer/recipe/l_hand
	name = "Left Hand"
	id = BP_L_HAND
	category = "Limbs"
	time = 60
	matter = 5500
	build_path = /obj/item/organ/external/hand

/datum/printer/recipe/r_hand
	name = "Right Hand"
	id = BP_R_HAND
	category = "Limbs"
	time = 60
	matter = 5500
	build_path = /obj/item/organ/external/hand/right

/datum/printer/recipe/l_leg
	name = "Left Leg"
	id = BP_L_LEG
	category = "Limbs"
	time = 60
	matter = 8500
	build_path = /obj/item/organ/external/leg

/datum/printer/recipe/r_leg
	name = "Right Leg"
	id = BP_R_LEG
	category = "Limbs"
	time = 60
	matter = 8500
	build_path = /obj/item/organ/external/leg/right

/datum/printer/recipe/l_foot
	name = "Left Foot"
	id = BP_L_FOOT
	category = "Limbs"
	time = 60
	matter = 5500
	build_path = /obj/item/organ/external/foot

/datum/printer/recipe/r_foot
	name = "Right Foot"
	id = BP_R_FOOT
	category = "Limbs"
	time = 60
	matter = 5500
	build_path = /obj/item/organ/external/foot/right
