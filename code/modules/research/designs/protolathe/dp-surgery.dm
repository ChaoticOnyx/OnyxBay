/datum/design/item/surgery
	category_items = list("Surgery")

/datum/design/item/surgery/scalpel_laser1
	name = "basic laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks basic and could be improved."
	id = "scalpel_laser1"
	req_tech = list(TECH_BIO = 2, TECH_MATERIAL = 2, TECH_MAGNET = 2)
	materials = list(MATERIAL_STEEL = 12500, MATERIAL_GLASS = 7500)
	build_path = /obj/item/scalpel/laser1
	sort_string = "MBEAA"

/datum/design/item/surgery/scalpel_laser2
	name = "improved laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks somewhat advanced."
	id = "scalpel_laser2"
	req_tech = list(TECH_BIO = 3, TECH_MATERIAL = 4, TECH_MAGNET = 4)
	materials = list(MATERIAL_STEEL = 12500, MATERIAL_GLASS = 7500, MATERIAL_SILVER = 2500)
	build_path = /obj/item/scalpel/laser2
	sort_string = "MBEAB"

/datum/design/item/surgery/scalpel_laser3
	name = "advanced laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks to be the pinnacle of precision energy cutlery!"
	id = "scalpel_laser3"
	req_tech = list(TECH_BIO = 4, TECH_MATERIAL = 6, TECH_MAGNET = 5)
	materials = list(MATERIAL_STEEL = 12500, MATERIAL_GLASS = 7500, MATERIAL_SILVER = 2000, MATERIAL_GOLD = 1500)
	build_path = /obj/item/scalpel/laser3
	sort_string = "MBEAC"

/datum/design/item/surgery/scalpel_manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	id = "scalpel_manager"
	req_tech = list(TECH_BIO = 4, TECH_MATERIAL = 7, TECH_MAGNET = 5, TECH_DATA = 4)
	materials = list (MATERIAL_STEEL = 12500, MATERIAL_GLASS = 7500, MATERIAL_SILVER = 1500, MATERIAL_GOLD = 1500, MATERIAL_DIAMOND = 750)
	build_path = /obj/item/scalpel/manager
	sort_string = "MBEAD"

/datum/design/item/surgery/pico_grasper
	name = "precision grasper"
	desc = "A thin rod with pico manipulators embedded in it allowing for fast and precise extraction."
	id = "pico_grasper"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3, TECH_BIO = 4)
	materials = list (MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000, MATERIAL_PLASMA = 80)
	build_path = /obj/item/hemostat/pico
	sort_string = "MBEAE"

/datum/design/item/surgery/plasmasaw
	name = "plasma saw"
	desc = "Perfect for cutting through ice."
	id = "plasmasaw"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_BIO = 5, TECH_PLASMA = 3)
	materials = list (MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000, MATERIAL_PLASMA = 500)
	build_path = /obj/item/circular_saw/plasmasaw
	sort_string = "MBEAF"

/datum/design/item/surgery/bonemender
	name = "bone mender"
	desc = "A favorite among skeletons. It even sounds like a skeleton too."
	id = "bonemender"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_BIO = 5)
	materials = list (MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000, MATERIAL_GOLD = 500, MATERIAL_SILVER = 250)
	category = "Surgery"
	build_path = /obj/item/bonesetter/bone_mender
	sort_string = "MBEAG"

/datum/design/item/surgery/clot
	name = "capillary laying operation tool"
	desc = "A canister like tool that stores synthetic vein."
	id = "clot"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_BIO = 5)
	materials = list (MATERIAL_STEEL = 10000, MATERIAL_GLASS = 8000, MATERIAL_SILVER = 1000)
	category = "Surgery"
	build_path = /obj/item/FixOVein/clot
	sort_string = "MBEAH"

/datum/design/item/surgery/organfixer_adv
	name = "advanced organ fixer"
	desc = "A modification of QROF-26 organ fixer design. This model uses a cluster of advanced manipulators, which allows it to fix multiple organs at once, as well as an enlarged gel storage tank."
	id = "organfixer_advanced"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_BIO = 4)
	materials = list (MATERIAL_STEEL = 12500, MATERIAL_GLASS = 7500)
	build_path = /obj/item/organfixer/advanced/empty
	sort_string = "MBEAI"

/datum/design/item/surgery/organfixer_bluespace
	name = "bluespace organ fixer"
	desc = "A modification of QROF-26 organ fixer design. This prototype uses a bluespace engine to rebuild biological tissue, removing the need for somatic gel."
	id = "organfixer_bluespace"
	req_tech = list(TECH_MATERIAL = 7, TECH_ENGINEERING = 6, TECH_BIO = 6, TECH_BLUESPACE = 5)
	materials = list (MATERIAL_STEEL = 12500, MATERIAL_GLASS = 7500, MATERIAL_GOLD = 1500, MATERIAL_SILVER = 2000, MATERIAL_DIAMOND = 750)
	build_path = /obj/item/organfixer/advanced/bluespace
	sort_string = "MBEAJ"

/datum/design/item/surgery/advanced_roller
	name = "advanced roller bed"
	desc = "A more advanced version of the regular roller bed, with inbuilt surgical stabilisers and an improved folding system."
	id = "roller_bed"
	req_tech = list(TECH_BIO = 3, TECH_MATERIAL = 3, TECH_MAGNET = 3)
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 2000, MATERIAL_PLASMA = 2000)
	build_path = /obj/item/roller/adv
	sort_string = "MBEAK"

/datum/design/item/biostorage/neural_lace
	id = "neural lace"
	req_tech = list(TECH_BIO = 4, TECH_MATERIAL = 4, TECH_MAGNET = 2, TECH_DATA = 3)
	materials = list (MATERIAL_STEEL = 10000, MATERIAL_GLASS = 7500, MATERIAL_SILVER = 1000, MATERIAL_GOLD = 1000)
	build_path = /obj/item/organ/internal/stack
	sort_string = "VACBA"
	category_items = list("Surgery")
