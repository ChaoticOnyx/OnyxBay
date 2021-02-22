#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif
// New vortex suppressor
/obj/item/weapon/circuitboard/vortex_suppressor
	name = T_BOARD("advanced vortex suppressor")
	board_type = "machine"
	build_path = /obj/machinery/power/vortex_suppressor
	origin_tech = list(TECH_BLUESPACE = 3, TECH_POWER = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stack/cable_coil = 15,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/weapon/stock_parts/subspace/filter = 1,
		/obj/item/weapon/stock_parts/subspace/crystal = 1,
		/obj/item/weapon/smes_coil = 1)