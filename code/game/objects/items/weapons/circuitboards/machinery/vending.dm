#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

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

/obj/item/weapon/circuitboard/smartfridge/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isScrewdriver(W))
		var/circuit = input(user, "Select a circuit type.") as null|anything in bpath
		if(circuit)
			to_chat(user, SPAN("notice", "You've readjusted the circuit."))
			build_path = bpath[circuit]
		else
			return