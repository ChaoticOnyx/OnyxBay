// Network cards
/datum/design/item/modularcomponent/netcard/basic
	name = "basic network card"
	id = "netcard_basic"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 100)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/computer_hardware/network_card
	sort_string = "VBABA"

/datum/design/item/modularcomponent/netcard/advanced
	name = "advanced network card"
	id = "netcard_advanced"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/computer_hardware/network_card/advanced
	sort_string = "VBABB"

/datum/design/item/modularcomponent/netcard/wired
	name = "wired network card"
	id = "netcard_wired"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 2500, MATERIAL_GLASS = 400)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/computer_hardware/network_card/wired
	sort_string = "VBABC"

// inteliCard Slot
/datum/design/item/modularcomponent/accessory/aislot
	name = "inteliCard slot"
	id = "aislot"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 2000)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/computer_hardware/ai_slot
	sort_string = "VBADB"

// Processor unit
/datum/design/item/modularcomponent/cpu/
	name = "computer processor unit"
	id = "cpu_normal"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 1600)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/computer_hardware/processor_unit
	sort_string = "VBAFA"

/datum/design/item/modularcomponent/cpu/small
	name = "computer microprocessor unit"
	id = "cpu_small"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 800)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/computer_hardware/processor_unit/small
	sort_string = "VBAFB"

/datum/design/item/modularcomponent/cpu/photonic
	name = "computer photonic processor unit"
	id = "pcpu_normal"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 6400, glass = 2000)
	chemicals = list(/datum/reagent/acid = 40)
	build_path = /obj/item/computer_hardware/processor_unit/photonic
	sort_string = "VBAFC"

/datum/design/item/modularcomponent/cpu/photonic/small
	name = "computer photonic microprocessor unit"
	id = "pcpu_small"

	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 3200, glass = 1000)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/computer_hardware/processor_unit/photonic/small
	sort_string = "VBAFD"
