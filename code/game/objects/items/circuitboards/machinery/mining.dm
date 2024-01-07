#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/miningdrill
	name = T_BOARD("mining drill head")
	build_path = /obj/machinery/mining/drill
	board_type = "machine"
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)
	req_components = list(	/obj/item/stock_parts/capacitor = 1,
							/obj/item/cell = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/miningdrillbrace
	name = T_BOARD("mining drill brace")
	build_path = /obj/machinery/mining/brace
	board_type = "machine"
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)
	req_components = list()

/obj/item/circuitboard/processing_unit_console
	name = T_BOARD("ore processor console")
	build_path = /obj/machinery/computer/processing_unit_console
	origin_tech = list(TECH_ENGINEERING = 2)

/obj/item/circuitboard/processing_unit
	name = T_BOARD("ore processor")
	build_path = /obj/machinery/mineral/processing_unit
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)
	req_components = list(	/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/stacking_machine_console
	name = T_BOARD("ore stacker console")
	build_path = /obj/machinery/computer/stacking_unit_console
	origin_tech = list(TECH_ENGINEERING = 2)

/obj/item/circuitboard/stacking_machine
	name = T_BOARD("ore stacker")
	build_path = /obj/machinery/mineral/stacking_machine
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)
	req_components = list(	/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/minting_machine
	name = T_BOARD("coin press")
	build_path = /obj/machinery/mineral/mint
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)
	req_components = list(	/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/unloading_machine
	name = T_BOARD("unloading machine")
	build_path = /obj/machinery/mineral/unloading_machine
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1)
	req_components = list(	/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/scanning_module = 1)
