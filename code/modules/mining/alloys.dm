GLOBAL_LIST_EMPTY(alloy_data)

/hook/startup/proc/initialize_alloy_data()
	ensure_alloy_data_initialised()

/proc/ensure_alloy_data_initialised()
	if(GLOB.alloy_data.len)
		return

	for(var/alloytype in subtypesof(/datum/alloy))
		GLOB.alloy_data += new alloytype()

//Alloys that contain subsets of each other's ingredients must be ordered in the desired sequence
//eg. steel comes after plasteel because plasteel's ingredients contain the ingredients for steel and
//it would be impossible to produce.

/datum/alloy
	var/list/requires
	var/product_mod = 1
	var/product
	var/metaltag

/datum/alloy/plasteel
	metaltag = MATERIAL_PLASTEEL
	requires = list(
		MATERIAL_PLATINUM = 1,
		MATERIAL_CARBON = 2,
		MATERIAL_IRON = 2
		)
	product_mod = 0.3
	product = /obj/item/stack/material/plasteel

/datum/alloy/ocp
	metaltag = MATERIAL_OSMIUM_CARBIDE_PLASTEEL
	requires = list(
		MATERIAL_PLATINUM = 1,
		MATERIAL_CARBON = 3,
		MATERIAL_IRON = 2,
		MATERIAL_OSMIUM = 2
		)
	product_mod = 0.3
	product = /obj/item/stack/material/ocp

/datum/alloy/steel
	metaltag = MATERIAL_STEEL
	requires = list(
		MATERIAL_CARBON = 1,
		MATERIAL_IRON = 1
		)
	product = /obj/item/stack/material/steel

/datum/alloy/plass
	metaltag = MATERIAL_PLASS
	requires = list(
		MATERIAL_PLASMA = 1,
		MATERIAL_SAND = 2
		)
	product = /obj/item/stack/material/glass/plass

/datum/alloy/black_glass
	metaltag = MATERIAL_BLACK_GLASS
	requires = list(
		MATERIAL_IRON = 1,
		MATERIAL_SAND = 2
		)
	product = /obj/item/stack/material/glass/black
