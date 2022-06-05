/datum/design/item/disk
	req_tech = list(TECH_DATA = 1)
	materials = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)
	category_items = list("Data")

/datum/design/item/disk/design
	name = "component design disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	build_path = /obj/item/disk/design_disk
	sort_string = "AAAAA"

/datum/design/item/disk/tech
	name = "fabricator data disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	build_path = /obj/item/disk/tech_disk
	sort_string = "AAAAB"

/datum/design/item/holopad
	name = "Holopad"
	desc = "A holografic communication device."
	id = "holopad_comm"
	req_tech = list(TECH_BLUESPACE = 2, TECH_DATA = 1, TECH_BLUESPACE = 3)
	materials = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 70)
	build_path = /obj/item/device/holopad
	sort_string = "AAAAC"
