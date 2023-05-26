/datum/design/item/mining
	category_items = list("Mining")

/datum/design/item/mining/jackhammer
	id = "jackhammer"

	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 500, MATERIAL_SILVER = 500)
	build_path = /obj/item/pickaxe/jackhammer
	sort_string = "KAAAA"

/datum/design/item/mining/drill
	id = "drill"

	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GLASS = 1000) //expensive, but no need for miners.
	build_path = /obj/item/pickaxe/drill/adv
	sort_string = "KAAAB"

/datum/design/item/mining/plasmacutter
	id = "plasmacutter"

	materials = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500, MATERIAL_GOLD = 500, MATERIAL_PLASMA = 500)
	build_path = /obj/item/gun/energy/plasmacutter
	sort_string = "KAAAC"

/datum/design/item/mining/pick_diamond
	id = "pick_diamond"

	materials = list(MATERIAL_DIAMOND = 3000)
	build_path = /obj/item/pickaxe/diamond
	sort_string = "KAAAD"

/datum/design/item/mining/drill_diamond
	id = "drill_diamond"

	materials = list(MATERIAL_STEEL = 3000, MATERIAL_GLASS = 1000, MATERIAL_DIAMOND = 2000)
	build_path = /obj/item/pickaxe/drill/diamonddrill
	sort_string = "KAAAE"

/datum/design/item/mining/depth_scanner
	desc = "Used to check spatial depth and density of rock outcroppings."
	id = "depth_scanner"

	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 1000)
	build_path = /obj/item/device/depth_scanner
	sort_string = "KAAAF"

/datum/design/item/mining/ano_scanner
	name = "Alden-Saraspova counter"
	id = "ano_scanner"
	desc = "Aids in triangulation of exotic particles."

	materials = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000)
	build_path = /obj/item/device/ano_scanner
	sort_string = "VAEAA"
