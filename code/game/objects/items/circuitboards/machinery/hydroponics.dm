#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/genemod
	name = T_BOARD("Genetic Forge")
	board_type = "machine"
	req_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	build_path = /obj/machinery/genemod
	origin_tech = list(TECH_ENGINEERING = 2, TECH_BIO = 1)

/obj/item/circuitboard/biogenerator
	name = T_BOARD("biogenerator")
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	origin_tech = list(TECH_DATA = 2)
