/obj/machinery/computer/shuttle_control/mining
	name = "mining shuttle control console"
	shuttle_tag = "Mining"
	//req_access = list(access_mining)
	circuit = /obj/item/circuitboard/mining_shuttle

/obj/machinery/computer/shuttle_control/engineering
	name = "engineering shuttle control console"
	shuttle_tag = "Engineering"
	//req_one_access = list(access_engine_equip,access_atmospherics)
	circuit = /obj/item/circuitboard/engineering_shuttle

/obj/machinery/computer/shuttle_control/research
	name = "research shuttle control console"
	shuttle_tag = "Research"
	//req_access = list(access_research)
	circuit = /obj/item/circuitboard/research_shuttle

/obj/machinery/computer/shuttle_control/merchant
	name = "merchant shuttle control console"
	icon_keyboard = "power_key"
	icon_screen = "shuttle"
	req_access = list(access_merchant)
	shuttle_tag = "Merchant"

/obj/machinery/computer/shuttle_control/administration
	name = "administration shuttle control console"
	icon_keyboard = "power_key"
	icon_screen = "shuttle"
	req_access = list(access_cent_general)
	shuttle_tag = "Administration"

/obj/machinery/computer/shuttle_control/transport
	name = "transport shuttle control console"
	icon_keyboard = "power_key"
	icon_screen = "shuttle"
	req_access = list(access_cent_general)
	shuttle_tag = "Transport"

/obj/machinery/computer/shuttle_control/elevator
	name = "cargo elevator control"
	shuttle_tag = "Cargo Elevator"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = 0

/*
/obj/machinery/computer/shuttle_control/multi/turbolift
	name = "turbolift control console"
	icon_state = "tcstation"
	icon_keyboard = "tcstation_key"
	icon_screen = "syndie"
	shuttle_tag = "turbolift"
	density = 0
*/
