#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/cell_charger
	name = T_BOARD("cell charger")
	build_path = /obj/machinery/cell_charger
	board_type = "machine"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/recharger
	name = T_BOARD("recharger")
	build_path = /obj/machinery/recharger
	board_type = "machine"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/honey_extractor
	name = T_BOARD("honey extractor")
	build_path = /obj/machinery/honey_extractor
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1)
	req_components = list(/obj/item/stock_parts/manipulator = 3)

/obj/item/circuitboard/sleeper
	name = T_BOARD("sleeper")
	desc = "The circuitboard for a sleeper."
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2, TECH_ENGINEERING = 2)
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/reagent_containers/vessel/beaker/large = 1)

/obj/item/circuitboard/microwave
	name = T_BOARD("microwave")
	desc = "The circuitboard for a microwave."
	build_path = /obj/machinery/microwave
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1)
	req_components = list(
							/obj/item/stock_parts/micro_laser = 3,
							/obj/item/stock_parts/manipulator = 1)
