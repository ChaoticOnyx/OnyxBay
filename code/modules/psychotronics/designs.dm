/* PROTOLATHE */

/datum/design/item/optical/Psychoscope
	name = "psychoscope"
	desc = "Use psychoscope for researching lifeforms (carbon/silicon), a lifeform must be alive."
	id = "psychoscope"
	req_tech = list(TECH_MAGNET = 3, TECH_BIO = 3)
	build_path = /obj/item/clothing/glasses/hud/Psychoscope
	sort_string = "GBAAA"
	category_items = "Misc"
	materials = list(MATERIAL_STEEL = 1500, MATERIAL_REINFORCED_GLASS = 500, MATERIAL_GOLD = 200)