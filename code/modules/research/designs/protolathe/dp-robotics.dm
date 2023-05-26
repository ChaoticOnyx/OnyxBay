/datum/design/item/robot_scanner
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "robot_scanner"

	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	build_path = /obj/item/device/robotanalyzer
	sort_string = "MACFB"
	category_items = list("Robotics")

/datum/design/item/synthstorage/intelicard
	name = "InteliCard"
	desc = "AI preservation and transportation system."
	id = "intelicard"

	materials = list(MATERIAL_GLASS = 1000, MATERIAL_GOLD = 200)
	build_path = /obj/item/aicard
	sort_string = "VACAA"

/datum/design/item/synthstorage/posibrain
	name = "positronic brain"
	id = "posibrain"

	build_type = PROTOLATHE | MECHFAB
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 1000, MATERIAL_GOLD = 500, MATERIAL_PLASMA = 500, MATERIAL_DIAMOND = 100)
	build_path = /obj/item/organ/internal/posibrain
	category = "Misc"
	sort_string = "VACAB"

/datum/design/item/biostorage/mmi
	name = "man-machine interface"
	id = "mmi"

	build_type = PROTOLATHE | MECHFAB
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500)
	build_path = /obj/item/device/mmi
	category = "Misc"
	sort_string = "VACCA"

/datum/design/item/biostorage/mmi_radio
	name = "radio-enabled man-machine interface"
	id = "mmi_radio"

	build_type = PROTOLATHE | MECHFAB
	materials = list(MATERIAL_STEEL = 1200, MATERIAL_GLASS = 500)
	build_path = /obj/item/device/mmi/radio_enabled
	category = "Misc"
	sort_string = "VACCB"

/datum/design/item/mining/mecha_drill_resonant
	id = "mecha_drill_resonant"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 250, MATERIAL_GOLD = 250, MATERIAL_DIAMOND = 1250, MATERIAL_URANIUM = 500)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/resonant
	sort_string = "VADAA"
	category_items = list("Robotics")
