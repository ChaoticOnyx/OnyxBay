#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/weapon/circuitboard/resleever
	name = T_BOARD("neural lace resleever")
	build_path = /obj/machinery/resleever
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 3)
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 3,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/bioprinter
	name = T_BOARD("bioprinter")
	build_path = /obj/machinery/organ_printer/flesh
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1, TECH_BIO = 3, TECH_DATA = 3)
	req_components = list(
							/obj/item/device/healthanalyzer = 1,
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							)

/obj/item/weapon/circuitboard/roboprinter
	name = T_BOARD("prosthetic organ fabricator")
	build_path = /obj/machinery/organ_printer/robot
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3)
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							)

/obj/item/weapon/circuitboard/cryo_cell
	name = T_BOARD("cryo chamber")
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1, TECH_BIO = 3, TECH_DATA = 3)
	req_components = list(
							/obj/item/device/healthanalyzer = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/manipulator = 3,
							)

/obj/item/weapon/circuitboard/body_scanner
	name = T_BOARD("body scanner")
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 5, TECH_DATA = 5)
	req_components = list(
							/obj/item/device/healthanalyzer = 1,
							/obj/item/weapon/stock_parts/scanning_module = 3,
							/obj/item/weapon/stock_parts/manipulator = 4,
							)

/obj/item/weapon/circuitboard/optable
	name = T_BOARD("operating table")
	build_path = /obj/machinery/optable
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 3)
	req_components = list(/obj/item/weapon/stock_parts/manipulator = 4)

/obj/item/weapon/circuitboard/bodyscanner_console
	name = T_BOARD("body scanner console")
	board_type = "machine"
	build_path = /obj/machinery/body_scanconsole
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 5, TECH_DATA = 5)

/obj/item/weapon/circuitboard/chemmaster
	name = T_BOARD("chem Master 3000")
	board_type = "machine"
	build_path = /obj/machinery/chem_master
	req_components = list(
		/obj/item/device/healthanalyzer = 1,
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/manipulator = 4,
		/obj/item/weapon/stock_parts/console_screen = 1,
	)
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 3, TECH_DATA = 3)

/obj/item/weapon/circuitboard/grinder
	name = T_BOARD("All-In-One Grinder")
	board_type = "machine"
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 1,
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/weapon/stock_parts/console_screen = 1,
	)
	build_path = /obj/machinery/reagentgrinder
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 2)

/obj/item/weapon/circuitboard/chemical_dispenser
	name = T_BOARD("chemical dispenser")
	board_type = "machine"
	build_path = /obj/machinery/chemical_dispenser
	req_components = list(
		/obj/item/device/healthanalyzer = 1,
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/manipulator = 4,
		/obj/item/weapon/stock_parts/console_screen = 1,
	)
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 3, TECH_DATA = 3)
