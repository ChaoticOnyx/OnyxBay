#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/weapon/circuitboard/replicator
	name = T_BOARD("Food Replicator")
	build_path = /obj/machinery/food_replicator
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2)
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1
	)

//SMARTFRIDGES
/obj/item/weapon/circuitboard/smartfridge
	name = T_BOARD("Smartfridge")
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2)
	build_path = /obj/machinery/smartfridge
	var/list/bpath = list(
		"Smartfridge" = /obj/machinery/smartfridge,
		"MegaSeed Servitor" = /obj/machinery/smartfridge/seeds,
		"Smart Virus Storage" = /obj/machinery/smartfridge/chemistry/virology,
		"Smart Chemical Storage" = /obj/machinery/smartfridge/chemistry,
		"Metroid Extract Storage" = /obj/machinery/smartfridge/secure/extract,
		"Refrigerated Food Showcase" = /obj/machinery/smartfridge/secure/food,
		"Refrigerated Medicine Storage" = /obj/machinery/smartfridge/secure/medbay,
		"Refrigerated Virus Storage" = /obj/machinery/smartfridge/secure/virology
	)

	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
	)

/obj/item/weapon/circuitboard/smartfridge/attackby(obj/item/weapon/W, mob/user)
	if(isScrewdriver(W))
		var/circuit = input(user, "Select a circuit type.") as null|anything in bpath
		if(circuit)
			to_chat(user, SPAN("notice", "You've readjusted the circuit. Now you can assemble [circuit]!"))
			build_path = bpath[circuit]
		else
			return

//Vendomats
/obj/item/weapon/circuitboard/vendomat
	name = T_BOARD("Vendomat")
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2)
	build_path = /obj/machinery/vending/assist
	var/list/bpath = list(
		"Robust Softdrinks" = list("path" = /obj/machinery/vending/cola, "components" = list(/obj/item/weapon/vendcart/cola = 1)),
		"BODA" = list("path" = /obj/machinery/vending/sovietsoda, "components" = list(/obj/item/weapon/vendcart/sovietsoda = 1)),

		"Cigarette Machine" = list("path" = /obj/machinery/vending/cigarette, "components" = list(/obj/item/weapon/vendcart/cigarette = 1)),
		"Cigarette Machine (Wall)" = list("path" = /obj/machinery/vending/cigarette/wallcigs, "components" = list(/obj/item/weapon/vendcart/cigarette = 1)),
		"Cigars Midcentury Machine" = list("path" = /obj/machinery/vending/cigarette/cigars, "components" = list(/obj/item/weapon/vendcart/cigarette = 1)),

		"Getmore Chocolate Corp" = list("path" = /obj/machinery/vending/snack, "components" = list(/obj/item/weapon/vendcart/snack = 1)),
		"Getmore Chocolate Corp (Wall)" = list("path" = /obj/machinery/vending/snack/wallsnack, "components" = list(/obj/item/weapon/vendcart/snack = 1)),
		"Getmore Healthy Snacks" = list("path" = /obj/machinery/vending/snack/medbay, "components" = list(/obj/item/weapon/vendcart/medbay = 1)),
		"SweatMAX" = list("path" = /obj/machinery/vending/fitness, "components" = list(/obj/item/weapon/vendcart/fitness = 1)),

		"NanoMed Plus" = list("path" = /obj/machinery/vending/medical, "components" = list(/obj/item/weapon/vendcart/medical = 1)),
		"NanoMed (Wall)" = list("path" = /obj/machinery/vending/wallmed1, "components" = list(/obj/item/weapon/vendcart/wallmed1 = 1)),
		"NanoMed Mini (Wall)" = list("path" = /obj/machinery/vending/wallmed2, "components" = list(/obj/item/weapon/vendcart/wallmed2 = 1)),

		"Vendomat" = list("path" = /obj/machinery/vending/assist, "components" = list(/obj/item/weapon/vendcart/assist = 1)),

		"Hot Drinks machine" = list("path" = /obj/machinery/vending/coffee, "components" = list(/obj/item/weapon/vendcart/coffee = 1)),

		"Booze-O-Mat" = list("path" = /obj/machinery/vending/boozeomat, "components" = list(/obj/item/weapon/vendcart/boozeomat = 1)),

		"Container Dispenser" = list("path" = /obj/machinery/vending/containers, "components" = list(/obj/item/weapon/vendcart/containers = 1)),
		"Prop Dispenser" = list("path" = /obj/machinery/vending/props, "components" = list(/obj/item/weapon/vendcart/props = 1)),
		"Smashing Fashions" = list("path" = /obj/machinery/vending/fashionvend, "components" = list(/obj/item/weapon/vendcart/fashionvend = 1)),
		"Good Clean Fun" = list("path" = /obj/machinery/vending/games, "components" = list(/obj/item/weapon/vendcart/games = 1)),
		"Dinnerware" = list("path" = /obj/machinery/vending/dinnerware, "components" = list(/obj/item/weapon/vendcart/dinnerware = 1)),

		"SecTech" = list("path" = /obj/machinery/vending/security, "components" = list(/obj/item/weapon/vendcart/security = 1)),

		"Seed Storage" = list("path" = /obj/machinery/seed_storage/standard, "components" = list(/obj/item/weapon/vendcart/seed_storage = 1)),
		"Advanced Seed Storage" = list("path" = /obj/machinery/seed_storage/advanced, "components" = list(/obj/item/weapon/vendcart/seed_storage = 1)),

		"Computer Vendor" = list("path" = /obj/machinery/lapvend, "components" = list()),

		"YouTool" = list("path" = /obj/machinery/vending/tool, "components" = list(/obj/item/weapon/vendcart/tool = 1)),
		"NutriMax" = list("path" = /obj/machinery/vending/hydronutrients, "components" = list(/obj/item/weapon/vendcart/hydronutrients = 1)),
		"Engi-Vend" = list("path" = /obj/machinery/vending/engivend, "components" = list(/obj/item/weapon/vendcart/engivend = 1)),
		"Toximate 3000" = list("path" = /obj/machinery/vending/plasmaresearch, "components" = list(/obj/item/weapon/vendcart/plasmaresearch = 1)),
		"Robotech Deluxe" = list("path" = /obj/machinery/vending/robotics, "components" = list(/obj/item/weapon/vendcart/robotics = 1)),
		"Robco Tool Maker" = list("path" = /obj/machinery/vending/engineering, "components" = list(/obj/item/weapon/vendcart/engineering = 1))
	)

	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/weapon/vendcart/assist = 1
	)

/obj/item/weapon/circuitboard/vendomat/antagmat
	origin_tech = list(TECH_DATA = 2, TECH_ILLEGAL = 1)
	build_path = /obj/machinery/vending/assist/antag
	bpath = list(
		"AntagCorpVend" = list("path" = /obj/machinery/vending/assist/antag, "components" = list(/obj/item/weapon/vendcart/antag = 1)),
		"MagiVend" = list("path" = /obj/machinery/vending/magivend, "components" = list(/obj/item/weapon/vendcart/magivend = 1))
	)

	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/weapon/vendcart/antag = 1
	)

/obj/item/weapon/circuitboard/vendomat/attackby(obj/item/weapon/W, mob/user)
	if(isScrewdriver(W))
		var/circuit = input(user, "Select a circuit type.") as null|anything in bpath
		if(circuit)
			to_chat(user, SPAN("notice", "You've readjusted the circuit. Now you can assemble [circuit]!"))

			req_components = list(
				/obj/item/weapon/stock_parts/matter_bin = 2,
				/obj/item/weapon/stock_parts/console_screen = 1,
			)

			build_path = bpath[circuit]["path"]
			req_components += bpath[circuit]["components"]
		else
			return
