/datum/design/item/robot_scanner
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "robot_scanner"
	req_tech = list(TECH_MAGNET = 3, TECH_BIO = 2, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	build_path = /obj/item/device/robotanalyzer
	sort_string = "MACFB"
	category_items = list("Robotics")

/datum/design/item/augment
	category_items = list("Augmentations")

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
	sort_string = "VACAB"

/datum/design/item/biostorage/mmi
	name = "man-machine interface"
	id = "mmi"
	req_tech = list(TECH_DATA = 2, TECH_BIO = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500)
	build_path = /obj/item/organ/internal/cerebrum/mmi
	sort_string = "VACCA"

/datum/design/item/mining/mecha_drill_resonant
	id = "mecha_drill_resonant"
	req_tech = list(TECH_MATERIAL = 6, TECH_POWER = 4, TECH_ENGINEERING = 4, TECH_BLUESPACE = 4)
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 250, MATERIAL_GOLD = 250, MATERIAL_DIAMOND = 1250, MATERIAL_URANIUM = 500)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/resonant
	sort_string = "VADAA"
	category_items = list("Robotics")

/datum/design/item/augment/armblade/wolverine
	id = "augment_wolverine"
	build_path = /obj/item/organ_module/active/simple/wolverine
	materials = list(MATERIAL_PLASTIC = 2000, MATERIAL_PLATINUM = 3000, MATERIAL_GOLD = 1500)
	req_tech = list(TECH_COMBAT = 4, TECH_ENGINEERING = 3)
	sort_string = "VADAC"

/datum/design/item/augment/armblade/wristshank
	id = "augment_wristshank"
	build_path = /obj/item/organ_module/active/simple/wristshank
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_PLASTIC = 3000, MATERIAL_GLASS = 1000)
	req_tech = list(TECH_COMBAT = 2, TECH_BIO = 3, TECH_MATERIAL = 2)
	sort_string = "VADAD"

/datum/design/item/augment/armblade/popout_shotgun
	id = "augment_popout_shotgun"
	build_path = /obj/item/organ_module/active/simple/shotgun
	materials = list(MATERIAL_DURANIUM = 1000, MATERIAL_PLASTEEL = 2000, MATERIAL_SILVER = 500, MATERIAL_GOLD = 500)
	req_tech = list(TECH_COMBAT = 8, TECH_ILLEGAL = 6, TECH_BIO = 5, TECH_MATERIAL = 4)
	sort_string = "VADAE"

/datum/design/item/augment/corrective_lenses
	id = "augment_corrective_lenses"
	build_path = /obj/item/organ_module/active/lenses/prescription
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 1000)
	req_tech = list(TECH_MATERIAL = 2)
	sort_string = "VADAF"

/datum/design/item/augment/adaptive_binoculars
	name = "Adaptive binoculars"
	build_path = /obj/item/organ_module/active/enhanced_vision
	materials = list(MATERIAL_GLASS = 500, MATERIAL_DIAMOND = 1000, MATERIAL_PLASTIC = 800, MATERIAL_GOLD = 500)
	req_tech = list(TECH_BIO = 6, TECH_MAGNET = 8, TECH_BLUESPACE = 9)
	id = "augment_adaptive_binoculars"
	sort_string = "VADAH"

/datum/design/item/augment/iatric_monitor
	id = "augment_iatric_monitor"
	build_path = /obj/item/organ_module/active/health_scanner
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	req_tech = list(TECH_BIO = 4, TECH_POWER = 3)
	sort_string = "VADAI"

/datum/design/item/augment/engineering
	id = "augment_toolset_engineering"
	build_path = /obj/item/organ_module/active/multitool
	materials = list(MATERIAL_STEEL = 100)
	req_tech = list(TECH_BIO = 3, TECH_POWER = 3)
	sort_string = "VADAJ"

/datum/design/item/augment/surgery
	id = "augment_toolset_surgery"
	build_path = /obj/item/organ_module/active/simple/surgical
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 2000)
	sort_string = "VADAK"

/datum/design/item/augment/muscle
	id = "augment_booster_muscles"
	build_path = /obj/item/organ_module/muscle
	materials = list(MATERIAL_GOLD = 1000, MATERIAL_PLASTEEL = 3000, MATERIAL_SILVER = 100)
	req_tech = list(TECH_COMBAT = 6, TECH_ENGINEERING = 6, TECH_BIO = 6)
	sort_string = "VADAL"

/datum/design/item/augment/armor
	id = "augment_armor"
	build_path = /obj/item/organ_module/armor
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_PLASTIC = 6000)
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_COMBAT = 2)
	sort_string = "VADAM"

/datum/design/item/augment/armor/mk2
	id = "augment_armor_mk2"
	build_path = /obj/item/organ_module/armor/mk2
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_SILVER = 4000, MATERIAL_PLASTIC = 2000)
	req_tech = list(TECH_MATERIAL = 3, TECH_BIO = 4, TECH_COMBAT = 4)
	sort_string = "VADAM1"

/datum/design/item/augment/armor/mk3
	id = "augment_armor_mk3"
	build_path = /obj/item/organ_module/armor/mk3
	materials = list(MATERIAL_PLASTEEL = 4000, MATERIAL_GOLD = 2500, MATERIAL_PLASTIC = 1500, MATERIAL_SILVER = 1000)
	req_tech = list(TECH_MATERIAL = 5, TECH_BIO = 6, TECH_COMBAT = 5)
	sort_string = "VADAM2"

/datum/design/item/augment/armor/mk4
	id = "augment_armor_mk4"
	build_path = /obj/item/organ_module/armor/mk4
	materials = list(MATERIAL_DURANIUM = 2000, MATERIAL_PLASTEEL = 2500, MATERIAL_DIAMOND = 2000, MATERIAL_PLASTIC = 1000, MATERIAL_SILVER = 500, MATERIAL_GOLD = 500)
	req_tech = list(TECH_MATERIAL = 7, TECH_BIO = 8, TECH_COMBAT = 7)
	sort_string = "VADAM3"

/datum/design/item/augment/hud/health
	id = "augment_med_hud"
	build_path = /obj/item/organ_module/active/lenses/hud/med
	materials = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 3)
	sort_string = "VADAN"

/datum/design/item/augment/hud/security
	id = "augment_sec_hud"
	build_path = /obj/item/organ_module/active/lenses/hud/sec
	materials = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)
	req_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 2)
	sort_string = "VADAO"

/datum/design/item/augment/hair
	id = "augment_hair"
	build_path = /obj/item/organ_module/active/cyber_hair
	materials = list(MATERIAL_PLASTIC = 2000, MATERIAL_GLASS = 2000)
	req_tech = list(TECH_POWER = 2, TECH_BIO = 2)
	sort_string = "VADAP"

/datum/design/item/augment/resuscitator
	id = "augment_resuscitator"
	build_path = /obj/item/organ_module/passive/resuscitator
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_PLASTIC = 2000, MATERIAL_GLASS = 500)
	req_tech = list(TECH_BIO = 3)
	sort_string = "VADAQ"

/datum/design/item/augment/translator
	id = "augment_translator"
	build_path = /obj/item/organ_module/active/translator
	materials = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 2000)
	req_tech = list(TECH_BIO = 4, TECH_DATA = 3)
	sort_string = "VADAR"

/datum/design/item/augment/armblade
	id = "augment_armblade"
	build_path = /obj/item/organ_module/active/simple/armblade
	materials = list(MATERIAL_PLASTIC = 2000, MATERIAL_PLATINUM = 3000, MATERIAL_GOLD = 1500, MATERIAL_PLASTEEL = 2000)
	req_tech = list(TECH_COMBAT = 4, TECH_ENGINEERING = 3)
	sort_string = "VADAS"

/datum/design/item/augment/armpistol
	id = "augment_armpistol"
	build_path = /obj/item/organ_module/active/simple/armsmg
	materials = list(MATERIAL_PLASTEEL = 2000, MATERIAL_PLASTIC = 5000, MATERIAL_SILVER = 1000)
	req_tech = list(TECH_ILLEGAL = 4, TECH_COMBAT = 6, TECH_BIO = 4)
	sort_string = "VADAT"

/datum/design/item/augment/armshield
	id = "augment_armshield"
	build_path = /obj/item/organ_module/active/simple/armshield
	materials = list(MATERIAL_DURANIUM = 2000, MATERIAL_GOLD = 5000, MATERIAL_DIAMOND = 2000)
	req_tech = list(TECH_COMBAT = 9, TECH_ILLEGAL = 5)
	sort_string = "VADAU"

/datum/design/item/augment/energy_blade
	id = "augment_energy_blade"
	build_path = /obj/item/organ_module/active/simple/armblade/energy_blade/nt
	materials = list(MATERIAL_DURANIUM = 2500, MATERIAL_GOLD = 5000, MATERIAL_URANIUM = 2500, MATERIAL_DIAMOND = 5000)
	req_tech = list(TECH_COMBAT = 10, TECH_ENGINEERING = 3, TECH_MATERIAL = 3, TECH_MAGNET = 3, TECH_ILLEGAL = 5)
	sort_string = "VADAV"

/datum/design/item/augment/cyborg_analyzer
	id = "augment_cyborg_analyzer"
	build_path = /obj/item/organ_module/active/simple/cyborg_analyzer
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_PLASTIC = 3000, MATERIAL_GOLD = 50)
	req_tech = list(TECH_ENGINEERING = 4, TECH_BIO = 2, TECH_MATERIAL = 4)
	sort_string = "VADAW"

/datum/design/item/augment/drill
	id = "augment_drill"
	build_path = /obj/item/organ_module/active/simple/drill
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_PLASTIC = 2000, MATERIAL_PLASTEEL = 1000)
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 2, TECH_BIO = 2)
	sort_string = "VADAX"

/datum/design/item/augment/gustatorial
	id = "augment_gustatorial"
	build_path = /obj/item/organ_module/active/gustatorial
	materials = list(MATERIAL_GOLD = 250, MATERIAL_SILVER = 250, MATERIAL_PLATINUM = 250, MATERIAL_PLASTIC = 250)
	req_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6)
	sort_string = "VADAY"

/datum/design/item/augment/nerve_dampeners
	id = "augment_nerve_dampeners"
	build_path = /obj/item/organ_module/active/nerve_dampeners
	materials = list(MATERIAL_PLASTIC = 4000, MATERIAL_SILVER = 8000)
	req_tech = list(TECH_BIO = 6, TECH_COMBAT = 7)
	sort_string = "VADAZ"

/datum/design/item/augment/cochlear
	id = "augment_cochlear"
	build_path = /obj/item/organ_module/cochlear
	materials = list(MATERIAL_SILVER = 800, MATERIAL_PLASTIC = 500)
	req_tech = list(TECH_BIO = 4, TECH_COMBAT = 4, TECH_ENGINEERING = 4)
	sort_string = "VADA0"

/datum/design/item/augment/resuscitator_theranos
	id = "augment_resuscitator_theranos"
	build_path = /obj/item/organ_module/passive/resuscitator/theranos
	materials = list(MATERIAL_URANIUM = 50, MATERIAL_GOLD = 500, MATERIAL_DIAMOND = 500, MATERIAL_PLASTEEL = 1000)
	req_tech = list(TECH_BIO = 6, TECH_COMBAT = 6, TECH_ENGINEERING = 7, TECH_BLUESPACE = 4, TECH_PLASMA = 4)
	sort_string = "VADA1"

/datum/design/item/augment/actuator
	id = "augment_actuator"
	build_path = /obj/item/organ_module/actuators
	materials = list(MATERIAL_PLASTIC = 2000, MATERIAL_STEEL = 2000, MATERIAL_GLASS = 2000)
	req_tech = list(TECH_ENGINEERING = 2, TECH_MAGNET = 2)
	sort_string = "VADA2"

/datum/design/item/augment/processor
	id = "augment_processor"
	build_path = /obj/item/organ_module/processor
	materials = list(MATERIAL_GOLD = 50, MATERIAL_PLASTEEL = 1000, MATERIAL_PLASTIC = 1000)
	req_tech = list(TECH_BIO = 1, TECH_DATA = 1)
	sort_string = "VADA3"

/datum/design/item/augment/processor_advanced
	id = "augment_processor_advanced"
	build_path = /obj/item/organ_module/processor/advanced
	materials = list(MATERIAL_GOLD = 150, MATERIAL_PLASTEEL = 3000, MATERIAL_PLASTIC = 3000, MATERIAL_GLASS = 1000)
	req_tech = list(TECH_BIO = 3, TECH_DATA = 3)
	sort_string = "VADA4"

/datum/design/item/augment/processor_super
	id = "augment_processor_super"
	build_path = /obj/item/organ_module/processor/super
	materials = list(MATERIAL_GOLD = 150, MATERIAL_PLASTEEL = 3000, MATERIAL_PLASTIC = 3000, MATERIAL_GLASS = 1000, MATERIAL_DIAMOND = 1500)
	req_tech = list(TECH_BIO = 6, TECH_DATA = 6, TECH_BLUESPACE = 6)
	sort_string = "VADA5"
