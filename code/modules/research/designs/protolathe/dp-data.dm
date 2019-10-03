/datum/design/item/disk
	req_tech = list(TECH_DATA = 1)
	materials = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)
	category_items = "Data"

/datum/design/item/disk/design
	name = "component design disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	build_path = /obj/item/weapon/disk/design_disk
	sort_string = "AAAAA"

/datum/design/item/disk/tech
	name = "fabricator data disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	build_path = /obj/item/weapon/disk/tech_disk
	sort_string = "AAAAB"