/datum/design/item/stock_part
	build_type = PROTOLATHE
	category_items = list("Stock Parts")

/datum/design/item/stock_part/AssembleDesignDesc()
	if(!desc)
		desc = "A stock part used in the construction of various devices."

//Tier 1

/datum/design/item/stock_part/basic_sensor
	id = "basic_sensor"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 20)
	build_path = /obj/item/stock_parts/scanning_module
	sort_string = "CAAEA"

/datum/design/item/stock_part/micro_mani
	id = "micro_mani"

	materials = list(MATERIAL_STEEL = 30)
	build_path = /obj/item/stock_parts/manipulator
	sort_string = "CAABA"

/datum/design/item/stock_part/basic_micro_laser
	id = "basic_micro_laser"

	materials = list(MATERIAL_STEEL = 10, MATERIAL_GLASS = 20)
	build_path = /obj/item/stock_parts/micro_laser
	sort_string = "CAADA"

/datum/design/item/stock_part/basic_matter_bin
	id = "basic_matter_bin"

	materials = list(MATERIAL_STEEL = 80)
	build_path = /obj/item/stock_parts/matter_bin
	sort_string = "CAACA"

/datum/design/item/stock_part/basic_capacitor
	id = "basic_capacitor"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	build_path = /obj/item/stock_parts/capacitor
	sort_string = "CAAAA"

//Tier 2

/datum/design/item/stock_part/adv_sensor
	id = "adv_sensor"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 20)
	build_path = /obj/item/stock_parts/scanning_module/adv
	sort_string = "CAAEB"

/datum/design/item/stock_part/nano_mani
	id = "nano_mani"

	materials = list(MATERIAL_STEEL = 30)
	build_path = /obj/item/stock_parts/manipulator/nano
	sort_string = "CAABB"

/datum/design/item/stock_part/high_micro_laser
	id = "high_micro_laser"

	materials = list(MATERIAL_STEEL = 10, MATERIAL_GLASS = 20)
	build_path = /obj/item/stock_parts/micro_laser/high
	sort_string = "CAADB"

/datum/design/item/stock_part/adv_matter_bin
	id = "adv_matter_bin"

	materials = list(MATERIAL_STEEL = 80)
	build_path = /obj/item/stock_parts/matter_bin/adv
	sort_string = "CAACB"

/datum/design/item/stock_part/adv_capacitor
	id = "adv_capacitor"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	build_path = /obj/item/stock_parts/capacitor/adv
	sort_string = "CAAAB"

//Tier 3

/datum/design/item/stock_part/phasic_sensor
	id = "phasic_sensor"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 20, MATERIAL_SILVER = 10)
	build_path = /obj/item/stock_parts/scanning_module/phasic
	sort_string = "CAAEC"

/datum/design/item/stock_part/pico_mani
	id = "pico_mani"

	materials = list(MATERIAL_STEEL = 30)
	build_path = /obj/item/stock_parts/manipulator/pico
	sort_string = "CAABC"

/datum/design/item/stock_part/ultra_micro_laser
	id = "ultra_micro_laser"

	materials = list(MATERIAL_STEEL = 10, MATERIAL_GLASS = 20, MATERIAL_URANIUM = 10)
	build_path = /obj/item/stock_parts/micro_laser/ultra
	sort_string = "CAADC"

/datum/design/item/stock_part/super_matter_bin
	id = "super_matter_bin"

	materials = list(MATERIAL_STEEL = 80)
	build_path = /obj/item/stock_parts/matter_bin/super
	sort_string = "CAACC"

/datum/design/item/stock_part/super_capacitor
	id = "super_capacitor"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50, MATERIAL_GOLD = 20)
	build_path = /obj/item/stock_parts/capacitor/super
	sort_string = "CAAAC"

//Tier 4

/datum/design/item/stock_part/triphasic_scanning
	id = "triphasic_scanning"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 30, MATERIAL_SILVER = 20, MATERIAL_DIAMOND = 20)
	build_path = /obj/item/stock_parts/scanning_module/triphasic
	sort_string = "CAAED"

/datum/design/item/stock_part/femto_mani
	id = "femto_mani"

	materials = list(MATERIAL_STEEL = 30, MATERIAL_DIAMOND = 50)
	build_path = /obj/item/stock_parts/manipulator/femto
	sort_string = "CAABD"

/datum/design/item/stock_part/quadultra_micro_laser
	id = "quadultra_micro_laser"

	materials = list(MATERIAL_STEEL = 10, MATERIAL_GLASS = 30, MATERIAL_URANIUM = 20, MATERIAL_DIAMOND = 20)
	build_path = /obj/item/stock_parts/micro_laser/quadultra
	sort_string = "CAADD"

/datum/design/item/stock_part/bluespace_matter_bin
	id = "bluespace_matter_bin"

	materials = list(MATERIAL_STEEL = 80, MATERIAL_DIAMOND = 50)
	build_path = /obj/item/stock_parts/matter_bin/bluespace
	sort_string = "CAACD"

/datum/design/item/stock_part/rectangular_capacitor
	id = "rectangular_capacitor"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50, MATERIAL_GOLD = 30, MATERIAL_DIAMOND = 20)
	build_path = /obj/item/stock_parts/capacitor/rectangular
	sort_string = "CAAAD"

/datum/design/item/stock_part/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	id = "rped"

	materials = list(MATERIAL_STEEL = 15000, MATERIAL_GLASS = 5000)
	build_path = /obj/item/storage/part_replacer
	sort_string = "CBAAA"

/datum/design/item/stock_part/subspace_ansible
	id = "s-ansible"

	materials = list(MATERIAL_STEEL = 80, MATERIAL_SILVER = 20)
	build_path = /obj/item/stock_parts/subspace/ansible
	sort_string = "UAAAA"

/datum/design/item/stock_part/hyperwave_filter
	id = "s-filter"

	materials = list(MATERIAL_STEEL = 40, MATERIAL_SILVER = 10)
	build_path = /obj/item/stock_parts/subspace/filter
	sort_string = "UAAAB"

/datum/design/item/stock_part/subspace_amplifier
	id = "s-amplifier"

	materials = list(MATERIAL_STEEL = 10, MATERIAL_GOLD = 30, MATERIAL_URANIUM = 15)
	build_path = /obj/item/stock_parts/subspace/amplifier
	sort_string = "UAAAC"

/datum/design/item/stock_part/subspace_treatment
	id = "s-treatment"

	materials = list(MATERIAL_STEEL = 10, MATERIAL_SILVER = 20)
	build_path = /obj/item/stock_parts/subspace/treatment
	sort_string = "UAAAD"

/datum/design/item/stock_part/subspace_analyzer
	id = "s-analyzer"

	materials = list(MATERIAL_STEEL = 10, MATERIAL_GOLD = 15)
	build_path = /obj/item/stock_parts/subspace/analyzer
	sort_string = "UAAAE"

/datum/design/item/stock_part/subspace_crystal
	id = "s-crystal"

	materials = list(MATERIAL_GLASS = 1000, MATERIAL_SILVER = 20, MATERIAL_GOLD = 20)
	build_path = /obj/item/stock_parts/subspace/crystal
	sort_string = "UAAAF"

/datum/design/item/stock_part/subspace_transmitter
	id = "s-transmitter"

	materials = list(MATERIAL_GLASS = 100, MATERIAL_SILVER = 10, MATERIAL_URANIUM = 15)
	build_path = /obj/item/stock_parts/subspace/transmitter
	sort_string = "UAAAG"
