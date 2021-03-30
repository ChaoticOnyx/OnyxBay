/* PROTOLATHE */

/datum/design/item/optical/psychoscope
	name = "psychoscope"
	desc = "Use psychoscope for researching lifeforms (carbon/silicon), lifeforms must be alive."
	id = "psychoscope"
	req_tech = list(TECH_MAGNET = 6, TECH_BIO = 6, TECH_DATA = 4)
	build_path = /obj/item/clothing/glasses/psychoscope
	sort_string = "GBAAA"
	category_items = "Misc"
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_REINFORCED_GLASS = 1000, MATERIAL_GOLD = 4000, MATERIAL_DIAMOND = 500)

/datum/design/circuit/neuromod_rnd
	name = "neuromod RnD console"
	desc = "Use to research a neural data and produce working neuromods."
	id = "neuromod_rnd"
	req_tech = list(TECH_DATA = 4, TECH_BIO = 6, TECH_MAGNET = 5)
	build_path = /obj/item/weapon/circuitboard/neuromod_rnd
	sort_string = "HACAC"

/datum/design/item/implant/neuromod
	name = "neuromod shell"
	desc = "Fill this shell in a 'Neuromod RnD Console'."
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_GOLD = 4000)
	req_tech = list(TECH_DATA = 4, TECH_BIO = 5, TECH_MAGNET = 4)
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
