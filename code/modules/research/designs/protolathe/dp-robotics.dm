/datum/design/item/robot_scanner
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "robot_scanner"
	req_tech = list(TECH_MAGNET = 3, TECH_BIO = 2, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	build_path = /obj/item/device/robotanalyzer
	sort_string = "MACFB"
	category_items = list("Robotics")

/datum/design/item/synthstorage/intelicard
	name = "InteliCard"
	desc = "AI preservation and transportation system."
	id = "intelicard"
	req_tech = list(TECH_DATA = 4, TECH_MATERIAL = 4)
	materials = list(MATERIAL_GLASS = 1000, MATERIAL_GOLD = 200)
	build_path = /obj/item/aicard
	sort_string = "VACAA"

/datum/design/item/synthstorage/posibrain
	name = "positronic brain"
	id = "posibrain"
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 6, TECH_BLUESPACE = 2, TECH_DATA = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 1000, MATERIAL_GOLD = 500, MATERIAL_PLASMA = 500, MATERIAL_DIAMOND = 100)
	build_path = /obj/item/organ/internal/cerebrum/posibrain
	category = "Misc"
	sort_string = "VACAB"

/datum/design/item/biostorage/mmi
	name = "man-machine interface"
	id = "mmi"
	req_tech = list(TECH_DATA = 2, TECH_BIO = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500)
	build_path = /obj/item/organ/internal/cerebrum/mmi
	category = "Misc"
	sort_string = "VACCA"

/datum/design/item/mining/mecha_drill_resonant
	id = "mecha_drill_resonant"
	req_tech = list(TECH_MATERIAL = 6, TECH_POWER = 4, TECH_ENGINEERING = 4, TECH_BLUESPACE = 4)
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 250, MATERIAL_GOLD = 250, MATERIAL_DIAMOND = 1250, MATERIAL_URANIUM = 500)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/resonant
	sort_string = "VADAA"
	category_items = list("Robotics")

/datum/design/item/augment/armblade
	id = "augment_armblade"
	build_path = /obj/item/organ_module/active/simple/armblade
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 750)
	req_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 2, TECH_MATERIAL = 4, TECH_BIO = 3)
	sort_string = "VADAB"

/datum/design/item/augment/armblade/wolverine
	id = "augment_wolverine"
	build_path = /obj/item/organ_module/active/simple/wolverine
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_DIAMOND = 250)
	req_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 4, TECH_MATERIAL = 4, TECH_BIO = 3)
	sort_string = "VADAC"

/datum/design/item/augment/augment/armblade/wristshank
	id = "augment_wristshank"
	build_path = /obj/item/organ_module/active/simple/wristshank
	materials = list(MATERIAL_SILVER = 4000, MATERIAL_DIAMOND = 250)
	sort_string = "VADAD"

/datum/design/item/augment/augment/armblade/popout_shotgun
	id = "augment_popout_shotgun"
	build_path = /obj/item/organ/internal/augment/active/item/popout_shotgun
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_SILVER = 500)
	req_tech = list(TECH_ESOTERIC = 5, TECH_COMBAT = 6, TECH_BIO = 4)
	sort_string = "VADAE"

/datum/design/item/augment/augment/corrective_lenses
	id = "augment_corrective_lenses"
	build_path = /obj/item/organ_module/active/lenses/prescription
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 1000)
	req_tech = list(TECH_MATERIAL = 2)
	sort_string = "VADAF"

/datum/design/item/augment/augment/langprocessor
	id = "augment_langprocessor"
	build_path = /obj/item/organ_module/active/language
	materials = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 2000)
	req_tech = list(TECH_MATERIAL = 3, TECH_ENGINEERING = 3)
	sort_string = "VADAG"

/datum/design/item/augment/augment/adaptive_binoculars
	name = "Adaptive binoculars"
	build_path = /obj/item/organ_module/active/enhanced_vision
	materials = list(MATERIAL_DIAMOND = 100, MATERIAL_GOLD = 100, MATERIAL_GLASS = 2000)
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 4, TECH_COMBAT = 4)
	id = "augment_adaptive_binoculars"
	sort_string = "VADAH"

/datum/design/item/augment/augment/iatric_monitor
	id = "augment_iatric_monitor"
	build_path = /obj/item/organ_module/active/health_scanner
	materials = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 2000)
	req_tech = list(TECH_BIO = 3)
	sort_string = "VADAI"

/datum/design/item/augment/augment/engineering
	id = "augment_toolset_engineering"
	build_path = /obj/item/organ_module/active/multitool
	materials = list(MATERIAL_STEEL = 3000, MATERIAL_GLASS = 1000)
	sort_string = "VADAJ"

/datum/design/item/augment/augment/surgery
	id = "augment_toolset_surgery"
	build_path = /obj/item/organ_module/active/simple/surgical
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 2000)
	sort_string = "VADAK"

/datum/design/item/augment/augment/muscle
	id = "augment_booster_muscles"
	build_path = /obj/item/organ_module/muscle
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000)
	sort_string = "VADAL"

/datum/design/item/augment/augment/armor
	id = "augment_armor"
	build_path = /obj/item/organ_module/armor
	materials = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 750)
	sort_string = "VADAM"

/datum/design/item/augment/augment/hud/health
	id = "augment_med_hud"
	build_path = /obj/item/organ_module/active/lenses/hud/med
	materials = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 3)
	sort_string = "VADAN"

/datum/design/item/augment/augment/hud/security
	id = "augment_sec_hud"
	build_path = /obj/item/organ_module/active/lenses/hud/sec
	materials = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)
	req_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 2)
	sort_string = "VADAO"

/datum/design/item/augment/augment/hair
	id = "augment_hair"
	build_path = /obj/item/organ_module/active/cyber_hair
	materials = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)
	req_tech = list(TECH_MAGNET = 3, TECH_BIO = 4)
	sort_string = "VADAP"

/datum/design/item/augment/augment/resuscitator
	id = "augment_resuscitator"
	build_path = /obj/item/organ_module/passive/resuscitator
	materials = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)
	req_tech = list(TECH_MAGNET = 3, TECH_BIO = 4)
	sort_string = "VADAQ"
