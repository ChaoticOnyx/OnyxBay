/datum/design/item/surgery
	category_items = "Surgery"

/datum/design/item/surgery/scalpel_laser1
	name = "Basic Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks basic and could be improved."
	id = "scalpel_laser1"
	req_tech = list(TECH_BIO = 2, TECH_MATERIAL = 2, TECH_MAGNET = 2)
	materials = list(DEFAULT_WALL_MATERIAL = 12500, "glass" = 7500)
	build_path = /obj/item/weapon/scalpel/laser1
	sort_string = "MBEAA"

/datum/design/item/surgery/scalpel_laser2
	name = "Improved Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks somewhat advanced."
	id = "scalpel_laser2"
	req_tech = list(TECH_BIO = 3, TECH_MATERIAL = 4, TECH_MAGNET = 4)
	materials = list(DEFAULT_WALL_MATERIAL = 12500, "glass" = 7500, "silver" = 2500)
	build_path = /obj/item/weapon/scalpel/laser2
	sort_string = "MBEAB"

/datum/design/item/surgery/scalpel_laser3
	name = "Advanced Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks to be the pinnacle of precision energy cutlery!"
	id = "scalpel_laser3"
	req_tech = list(TECH_BIO = 4, TECH_MATERIAL = 6, TECH_MAGNET = 5)
	materials = list(DEFAULT_WALL_MATERIAL = 12500, "glass" = 7500, "silver" = 2000, "gold" = 1500)
	build_path = /obj/item/weapon/scalpel/laser3
	sort_string = "MBEAC"

/datum/design/item/surgery/scalpel_manager
	name = "Incision Management System"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	id = "scalpel_manager"
	req_tech = list(TECH_BIO = 4, TECH_MATERIAL = 7, TECH_MAGNET = 5, TECH_DATA = 4)
	materials = list (DEFAULT_WALL_MATERIAL = 12500, "glass" = 7500, "silver" = 1500, "gold" = 1500, "diamond" = 750)
	build_path = /obj/item/weapon/scalpel/manager
	sort_string = "MBEAD"

/datum/design/item/surgery/pico_grasper
	name = "Precision Grasper"
	desc = "A thin rod with pico manipulators embedded in it allowing for fast and precise extraction."
	id = "pico_grasper"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3, TECH_BIO = 4)
	materials = list (DEFAULT_WALL_MATERIAL = 10000, "glass" = 5000, "phoron" = 80)
	build_path = /obj/item/weapon/hemostat/pico
	sort_string = "MBEAE"

/datum/design/item/surgery/plasmasaw
	name = "Plasma Saw"
	desc = "Perfect for cutting through ice."
	id = "plasmasaw"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_BIO = 5, TECH_PHORON = 3)
	materials = list (DEFAULT_WALL_MATERIAL = 10000, "glass" = 5000, "phoron" = 500)
	build_path = /obj/item/weapon/circular_saw/plasmasaw
	sort_string = "MBEAF"

/datum/design/item/surgery/bonemender
	name = "Bone Mender"
	desc = "A favorite among skeletons. It even sounds like a skeleton too."
	id = "bonemender"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_BIO = 5)
	materials = list (DEFAULT_WALL_MATERIAL = 10000, "glass" = 5000, "gold" = 500, "silver" = 250)
	category = "Surgery"
	build_path = /obj/item/weapon/bonesetter/bone_mender
	sort_string = "MBEAG"

/datum/design/item/surgery/clot
	name = "Capillary Laying Operation Tool"
	desc = "A canister like tool that stores synthetic vein."
	id = "clot"
	req_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 4, TECH_BIO = 5)
	materials = list (DEFAULT_WALL_MATERIAL = 10000, "glass" = 8000, "silver" = 1000)
	category = "Surgery"
	build_path = /obj/item/weapon/FixOVein/clot
	sort_string = "MBEAH"

/datum/design/item/surgery/advanced_roller
	name = "advanced roller bed"
	desc = "A more advanced version of the regular roller bed, with inbuilt surgical stabilisers and an improved folding system."
	id = "roller_bed"
	req_tech = list(TECH_BIO = 3, TECH_MATERIAL = 3, TECH_MAGNET = 3)
	materials = list(DEFAULT_WALL_MATERIAL = 4000, "glass" = 2000, "phoron" = 2000)
	build_path = /obj/item/roller/adv
	sort_string = "MBEAI"

/datum/design/item/biostorage/neural_lace
	id = "neural lace"
	req_tech = list(TECH_BIO = 4, TECH_MATERIAL = 4, TECH_MAGNET = 2, TECH_DATA = 3)
	materials = list (DEFAULT_WALL_MATERIAL = 10000, "glass" = 7500, "silver" = 1000, "gold" = 1000)
	build_path = /obj/item/organ/internal/stack
	sort_string = "VACBA"
	category_items = "Surgery"