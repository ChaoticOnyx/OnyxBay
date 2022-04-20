/datum/design/item/powercell
	build_type = PROTOLATHE | MECHFAB
	category = "Misc"
	category_items = list("Engineering")

/datum/design/item/powercell/AssembleDesignDesc()
	if(build_path)
		var/obj/item/cell/C = build_path
		desc = "Allows the construction of power cells that can hold [initial(C.maxcharge)] units of energy."


/datum/design/item/powercell/basic
	name = "basic cell"
	id = "basic_cell"
	req_tech = list(TECH_POWER = 1)
	materials = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 50)
	build_path = /obj/item/cell/empty
	sort_string = "DAAAA"

/datum/design/item/powercell/high
	name = "high-capacity cell"
	id = "high_cell"
	req_tech = list(TECH_POWER = 2)
	materials = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 60)
	build_path = /obj/item/cell/high/empty
	sort_string = "DAAAB"

/datum/design/item/powercell/super
	name = "super-capacity cell"
	id = "super_cell"
	req_tech = list(TECH_POWER = 3, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 70)
	build_path = /obj/item/cell/super/empty
	sort_string = "DAAAC"

/datum/design/item/powercell/hyper
	name = "hyper-capacity cell"
	id = "hyper_cell"
	req_tech = list(TECH_POWER = 5, TECH_MATERIAL = 4)
	materials = list(MATERIAL_STEEL = 400, MATERIAL_GOLD = 150, MATERIAL_SILVER = 150, MATERIAL_GLASS = 80)
	build_path = /obj/item/cell/hyper/empty
	sort_string = "DAAAD"

/datum/design/item/powercell/apex
	name = "apex-capacity cell"
	id = "apex_cell"
	req_tech = list(TECH_POWER = 7, TECH_MATERIAL = 7, TECH_MAGNET = 5, TECH_ENGINEERING = 5)
	materials = list(MATERIAL_STEEL = 400, MATERIAL_GOLD = 300, MATERIAL_GLASS = 90, MATERIAL_DIAMOND = 100)
	build_path = /obj/item/cell/apex/empty
	sort_string = "DAAAE"

/datum/design/item/powercell/quantum
	name = "bluespace cell"
	id = "bluespace_cell"
	req_tech = list(TECH_POWER = 6, TECH_MATERIAL = 6, TECH_BLUESPACE = 3, TECH_MAGNET = 5)
	materials = list(MATERIAL_STEEL = 400, MATERIAL_GOLD = 150, MATERIAL_SILVER = 150, MATERIAL_GLASS = 70, MATERIAL_DIAMOND = 100)
	build_path = /obj/item/cell/quantum
	sort_string = "DAAAF"

/datum/design/item/tool/airlock_brace
	name = "airlock brace"
	desc = "Special door attachment that can be used to provide extra security."
	id = "brace"
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 50)
	build_path = /obj/item/airlock_brace
	sort_string = "VAGAD"
	category_items = list("Engineering")

/datum/design/item/tool/brace_jack
	name = "maintenance jack"
	desc = "A special maintenance tool that can be used to remove airlock braces."
	id = "bracejack"
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 120)
	build_path = /obj/item/crowbar/brace_jack
	sort_string = "VAGAE"
	category_items = list("Engineering")

/datum/design/item/tool/clamp
	name = "stasis clamp"
	desc = "A magnetic clamp which can halt the flow of gas in a pipe, via a localised stasis field."
	id = "stasis_clamp"
	req_tech = list(TECH_ENGINEERING = 4, TECH_MAGNET = 4)
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 500)
	build_path = /obj/item/clamp
	sort_string = "VAGAF"
	category_items = list("Engineering")

/datum/design/item/tool/experimental_welder
	name = "experimental welding tool"
	desc = "This welding tool feels heavier in your possession than is normal. There appears to be no external fuel port."
	id = "experimental_welder"
	req_tech = list(TECH_ENGINEERING = 5, TECH_PLASMA = 4)
	materials = list(MATERIAL_STEEL = 120, MATERIAL_GLASS = 50)
	build_path = /obj/item/weldingtool/experimental
	sort_string = "VAGAH"
	category_items = list("Engineering")

/datum/design/item/tool/shield_diffuser
	name = "portable shield diffuser"
	desc = "A small handheld device designed to disrupt energy barriers."
	id = "portable_shield_diffuser"
	req_tech = list(TECH_MAGNET = 5, TECH_POWER = 5, TECH_ILLEGAL = 2)
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 5000, MATERIAL_GOLD = 2000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/shield_diffuser
	sort_string = "VAGAI"
	category_items = list("Engineering")

/datum/design/tool/t_ray_scanner
	name = "T-Ray Scanner"
	desc = "A terahertz ray device used to pick up the faintest traces of energy, used to detect the invisible."
	id = "tray_scanner"
	req_tech = list(TECH_ENGINEERING = 1, TECH_MAGNET = 1)
	build_type = PROTOLATHE
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 100)
	build_path = /obj/item/device/t_scanner
	sort_string = "VAGBA"
	category_items = list("Engineering")

/datum/design/tool/p_ray_scanner
	name = "P-Ray Scanner"
	desc = "A petahertz ray device used to pick up the faintest traces of energy, used to detect the invisible."
	id = "pray_scanner"
	req_tech = list(TECH_ENGINEERING = 3, TECH_MAGNET = 3)
	build_type = PROTOLATHE
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000)
	build_path = /obj/item/device/t_scanner/advanced
	sort_string = "VAGBB"
	category_items = list("Engineering")

// Superconductive magnetic coils
/datum/design/item/smes_coil
	category_items = list("Engineering")

/datum/design/item/smes_coil
	desc = "A superconductive magnetic coil used to store power in magnetic fields."
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 2000, MATERIAL_GOLD = 1000, MATERIAL_SILVER = 1000)

/datum/design/item/smes_coil/standard
	name = "SMES coil standard"
	id = "smes_coil_standard"
	req_tech = list(TECH_MATERIAL = 7, TECH_POWER = 7, TECH_ENGINEERING = 5)
	build_path = /obj/item/smes_coil
	sort_string = "VAXAA"

/datum/design/item/smes_coil/super_capacity
	name = "SMES coil super capacity"
	id = "smes_coil_super_capacity"
	req_tech = list(TECH_MATERIAL = 7, TECH_POWER = 8, TECH_ENGINEERING = 6)
	build_path = /obj/item/smes_coil/super_capacity
	sort_string = "VAXAB"

/datum/design/item/smes_coil/super_io
	name = "SMES coil super IO"
	id = "smes_coil_super_io"
	req_tech = list(TECH_MATERIAL = 7, TECH_POWER = 8, TECH_ENGINEERING = 6)
	build_path = /obj/item/smes_coil/super_io
	sort_string = "VAXAC"
