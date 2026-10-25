/obj/item/circuitboard/cooking_with_jane/stove
	name = T_BOARD("Stovetop")
	icon_state = "id_mod_yellow"
	build_path = /obj/machinery/cooking_with_jane/stove
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/manipulator = 2
	)

/obj/item/circuitboard/cooking_with_jane/oven
	name = T_BOARD("Convection Oven")
	icon_state = "id_mod_yellow"
	build_path = /obj/machinery/cooking_with_jane/oven
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2
	)

/obj/item/circuitboard/cooking_with_jane/grill
	name = T_BOARD("Charcoal Grill")
	icon_state = "id_mod_yellow"
	build_path = /obj/machinery/cooking_with_jane/grill
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 2
	)
