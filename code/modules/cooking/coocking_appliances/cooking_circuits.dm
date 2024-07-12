/obj/item/circuitboard/stove
	name = "Circuit board (Stovetop)"
	build_path = /obj/machinery/kitchen/stove
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/manipulator = 2, //Affects the food quality
	)

/obj/item/circuitboard/oven
	name = "Circuit board (Convection Oven)"
	build_path = /obj/machinery/kitchen/oven
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2, //Affects the food quality
	)

/obj/item/circuitboard/grill
	name = "Circuit board (Charcoal Grill)"
	build_path = /obj/machinery/kitchen/grill
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2, //Affects the food quality
		/obj/item/stock_parts/matter_bin = 2, //Affects wood hopper size
	)
