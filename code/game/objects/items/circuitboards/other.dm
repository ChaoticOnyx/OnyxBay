#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

//Stuff that doesn't fit into any category goes here

/obj/item/circuitboard/aicore
	name = T_BOARD("AI core")
	origin_tech = list(TECH_DATA = 4, TECH_BIO = 2)
	board_type = "other"

/obj/item/circuitboard/pole
	name = T_BOARD("Pole")
	board_type = "other"
	build_path = /obj/machinery/pole
	origin_tech = list(TECH_ENGINEERING = 1, TECH_POWER = 1)
