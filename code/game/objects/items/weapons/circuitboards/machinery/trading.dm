/obj/item/weapon/circuitboard/trading
	name = T_BOARD("Trading")
	board_type = "machine"
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen = 1,
	)
	build_path = /obj/machinery/vending/trading
	origin_tech = list(TECH_ENGINEERING = 1)
