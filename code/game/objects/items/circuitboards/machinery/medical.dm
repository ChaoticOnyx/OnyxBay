#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/resleever
	name = T_BOARD("neural lace resleever")
	build_path = /obj/machinery/resleever
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 3)
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stock_parts/console_screen = 1)
/obj/item/circuitboard/bioprinter
	name = T_BOARD("bioprinter")
	build_path = /obj/machinery/organ_printer/flesh
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1, TECH_BIO = 3, TECH_DATA = 3)
	req_components = list(
							/obj/item/device/healthanalyzer = 1,
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							)

/obj/item/circuitboard/roboprinter
	name = T_BOARD("prosthetic organ fabricator")
	build_path = /obj/machinery/organ_printer/robot
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							)

/obj/item/circuitboard/cryo_cell
	name = T_BOARD("cryo chamber")
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1, TECH_BIO = 3, TECH_DATA = 3)
	req_components = list(
							/obj/item/device/healthanalyzer = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/manipulator = 3,
							)

/obj/item/circuitboard/body_scanner
	name = T_BOARD("body scanner")
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 5, TECH_DATA = 5)
	req_components = list(
							/obj/item/device/healthanalyzer = 1,
							/obj/item/stock_parts/scanning_module = 3,
							/obj/item/stock_parts/manipulator = 4,
							)

/obj/item/circuitboard/optable
	name = T_BOARD("operating table")
	build_path = /obj/machinery/optable
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 3)
	req_components = list(/obj/item/stock_parts/manipulator = 4)

/obj/item/circuitboard/bodyscanner_console
	name = T_BOARD("body scanner console")
	board_type = "machine"
	build_path = /obj/machinery/body_scanconsole
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 5, TECH_DATA = 5)

/obj/item/circuitboard/chemmaster
	name = T_BOARD("chem Master 3000")
	board_type = "machine"
	build_path = /obj/machinery/chem_master
	req_components = list(
		/obj/item/device/healthanalyzer = 1,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/console_screen = 1,
	)
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 3, TECH_DATA = 3)

/obj/item/circuitboard/grinder
	name = T_BOARD("All-In-One Grinder")
	board_type = "machine"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/console_screen = 1,
	)
	build_path = /obj/machinery/reagentgrinder
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 2)

/obj/item/circuitboard/chemical_dispenser
	name = T_BOARD("chemical dispenser")
	board_type = "machine"
	build_path = /obj/machinery/chemical_dispenser
	req_components = list(
		/obj/item/device/healthanalyzer = 1,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/console_screen = 1,
	)
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 3, TECH_DATA = 3)

// Virology
/obj/item/circuitboard/centrifuge
	name = T_BOARD("isolation centrifuge")
	board_type = "machine"
	build_path = /obj/machinery/computer/centrifuge
	req_components = list(
		/obj/item/stock_parts/manipulator = 3
	)
	origin_tech = list(TECH_ENGINEERING = 2, TECH_BIO = 2)

/obj/item/circuitboard/dishincubator
	name = T_BOARD("pathogenic incubator")
	board_type = "machine"
	build_path = /obj/machinery/disease2/incubator
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/vessel/beaker = 1,
		/obj/item/stock_parts/scanning_module  = 1
	)
	origin_tech = list(TECH_ENGINEERING = 2, TECH_BIO = 4, TECH_MAGNET = 2)

/obj/item/circuitboard/isolator
	name = T_BOARD("pathogenic isolator")
	board_type = "machine"
	build_path = /obj/machinery/disease2/isolator
	req_components = list(
		/obj/item/stock_parts/micro_laser = 3
	)
	origin_tech = list(TECH_ENGINEERING = 2, TECH_BIO = 2)

/obj/item/circuitboard/diseasesplicer
	name = T_BOARD("disease splicer")
	board_type = "machine"
	build_path = /obj/machinery/computer/diseasesplicer
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/scanning_module  = 1,
		/obj/item/stock_parts/manipulator  = 1
	)
	origin_tech = list(TECH_ENGINEERING = 2, TECH_BIO = 5, TECH_DATA = 3, TECH_MAGNET = 4)

/obj/item/circuitboard/analyser
	name = T_BOARD("disease analyser")
	board_type = "machine"
	build_path = /obj/machinery/disease2/diseaseanalyser
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/console_screen  = 1
	)
	origin_tech = list(TECH_ENGINEERING = 2, TECH_BIO = 2)
