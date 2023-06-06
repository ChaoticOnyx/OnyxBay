#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/teleporter_gate
	name = T_BOARD("Teleporter Gate")
	build_path = /obj/machinery/teleporter_gate
	board_type = "machine"
	origin_tech = list(
	TECH_DATA = 2,
	TECH_BLUESPACE = 2
	)
	req_components = list(
	/obj/item/stock_parts/manipulator = 2,
	/obj/item/stock_parts/capacitor = 2
	)
