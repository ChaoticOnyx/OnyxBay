/* PROTOLATHE */

/datum/design/item/optical/psychoscope
	name = "psychoscope"
	desc = "Use psychoscope for researching lifeforms (carbon/silicon), a lifeform must be alive."
	id = "psychoscope"
	req_tech = list(TECH_MAGNET = 4, TECH_BIO = 4)
	build_path = /obj/item/clothing/glasses/hud/psychoscope
	sort_string = "GBAAA"
	category_items = "Misc"
	materials = list(MATERIAL_STEEL = 1500, MATERIAL_REINFORCED_GLASS = 500, MATERIAL_GOLD = 200)

/datum/design/circuit/neuromod_rnd
	name = "neuromod RnD console"
	desc = "Use to research neuromod data disks and produce working neuromod."
	materials = list(MATERIAL_GLASS = 2000, MATERIAL_GOLD = 100)
	req_tech = list(TECH_DATA = 3, TECH_BIO = 3, TECH_MAGNET = 3)
	build_path = /obj/item/weapon/circuitboard/neuromod_rnd

/datum/design/item/implant/neuromod
	name = "neuromod shell"
	desc = "Fill this shell in a 'Neuromod RnD Console'."
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GOLD = 50)
	req_tech = list(TECH_DATA = 3, TECH_BIO = 3)
	build_path = /obj/item/weapon/reagent_containers/neuromod_shell

/datum/design/item/disk/neuromod
	name = "neuromod data disk"
	desc = "A disk for storing neuromod data."
	id = "neuromod_disk"
	req_tech = list(TECH_DATA = 3)
	build_path = /obj/item/weapon/disk/neuromod_disk
	sort_string = "AAAAB"

/datum/design/item/disk/lifeform
	name = "lifeform data disk"
	desc = "A disk for storing lifeform data."
	id = "lifeform_disk"
	req_tech = list(TECH_DATA = 3)
	build_path = /obj/item/weapon/disk/lifeform_disk
	sort_string = "AAAAB"