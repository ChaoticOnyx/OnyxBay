///all stuff used by RCD for construction
GLOBAL_LIST_INIT(rcd_designs, list(
	//1ST ROOT CATEGORY
	"Construction" = list( //Stuff you use to make & decorate areas
		//Walls & Windows
		"Structures" = list(
			list(RCD_DESIGN_MODE = RCD_TURF, RCD_DESIGN_PATH = /turf/simulated/floor/plating/),
			list(RCD_DESIGN_MODE = RCD_WINDOWFRAME, RCD_DESIGN_PATH = /obj/structure/window_frame/glass),
			list(RCD_DESIGN_MODE = RCD_WINDOWFRAME, RCD_DESIGN_PATH = /obj/structure/window_frame/rglass),
			list(RCD_DESIGN_MODE = RCD_WINDOWFRAME, RCD_DESIGN_PATH = /obj/structure/window_frame/grille/glass),
			list(RCD_DESIGN_MODE = RCD_WINDOWFRAME, RCD_DESIGN_PATH = /obj/structure/window_frame/grille/rglass),
			list(RCD_DESIGN_MODE = RCD_WINDOWSMALL, RCD_DESIGN_PATH = /obj/structure/window/basic),
			list(RCD_DESIGN_MODE = RCD_WINDOWSMALL, RCD_DESIGN_PATH = /obj/structure/window/reinforced),
			list(RCD_DESIGN_MODE = RCD_WINDOWFRAME, RCD_DESIGN_PATH = /obj/structure/window/reinforced/full),
			list(RCD_DESIGN_MODE = RCD_TURF, RCD_DESIGN_PATH = /obj/structure/catwalk),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/girder),
		),


		//Computers & Machine Frames
		"Machines" = list(
			list(RCD_DESIGN_MODE = RCD_WALLFRAME, RCD_DESIGN_PATH = /obj/machinery/firealarm),
			list(RCD_DESIGN_MODE = RCD_WALLFRAME, RCD_DESIGN_PATH = /obj/machinery/power/apc),
			list(RCD_DESIGN_MODE = RCD_WALLFRAME, RCD_DESIGN_PATH = /obj/machinery/alarm),
			list(RCD_DESIGN_MODE = RCD_WALLFRAME, RCD_DESIGN_PATH = /obj/item/device/radio/intercom),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/computerframe),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/machinery/constructable_frame),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/machinery/vending_frame),
		),

		//Interior Design[construction_mode = RCD_FURNISHING is implied]
		"Furniture" = list(
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/bed/chair),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/bed),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/item/stool),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/item/stool/bar),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/table),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/table/reinforced),
		),
	),

	//2ND ROOT CATEGORY[construction_mode = RCD_AIRLOCK is implied,"icon=closed"]
	"Airlocks" = list( //used to seal/close areas
		//Window Doors[airlock_glass = TRUE is implied]
		"Windoors" = list(
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/window),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/window/brigdoor),
		),

		//Glass Airlocks[airlock_glass = TRUE is implied,do fill_closed overlay]
		"Glass Airlocks" = list(
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_engineering),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_atmos),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_security),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_command),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_medical),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_research),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_virology),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_mining),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass_external),
		),

		//Solid Airlocks[airlock_glass = FALSE is implied,no fill_closed overlay]
		"Solid Airlocks" = list(
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/engineering),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/atmos),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/security),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/command),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/medical),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/research),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/freezer),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/virology),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/mining),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/maintenance),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/external),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/hatch),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/maintenance_hatch),
		),
	),

	//3RD CATEGORY Airlock access,empty list cause airlock_electronics UI will be displayed  when this tab is selected
	"Airlock Access" = list()
))
