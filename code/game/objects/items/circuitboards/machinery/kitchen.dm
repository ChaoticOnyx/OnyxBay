#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/gibber
	name = T_BOARD("Gibber")
	board_type = "machine"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 1
	)
	build_path = /obj/machinery/gibber
	origin_tech = list(TECH_ENGINEERING = 3, TECH_POWER = 2)

/obj/item/circuitboard/industrial_gibber
	name = T_BOARD("Industrial Gibber")
	board_type = "machine"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 1
	)
	build_path = /obj/machinery/gibber/industrial
	origin_tech = list(TECH_ENGINEERING = 4, TECH_POWER = 3, TECH_BLUESPACE = 3)

/obj/item/circuitboard/coffeemaker
	name = T_BOARD("Coffeemaker")
	board_type = "machine"
	build_path = /obj/machinery/coffeemaker
	origin_tech = list(TECH_ENGINEERING = 2, TECH_POWER = 1)
