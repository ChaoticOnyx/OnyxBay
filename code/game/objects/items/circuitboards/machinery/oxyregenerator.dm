#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/oxyregenerator
	name = T_BOARD("oxygen regenerator")
	build_path = /obj/machinery/atmospherics/binary/oxyregenerator
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2)
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/matter_bin = 1)
