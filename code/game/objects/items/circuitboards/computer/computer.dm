#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/message_monitor
	name = T_BOARD("message monitor console")
	icon_state = "id_mod_blue"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = list(TECH_DATA = 3)

/obj/item/circuitboard/aiupload
	name = T_BOARD("AI upload console")
	icon_state = "id_mod_purple"
	build_path = /obj/machinery/computer/aiupload
	origin_tech = list(TECH_DATA = 4)

/obj/item/circuitboard/borgupload
	name = T_BOARD("cyborg upload console")
	icon_state = "id_mod_purple"
	build_path = /obj/machinery/computer/borgupload
	origin_tech = list(TECH_DATA = 4)

/obj/item/circuitboard/teleporter
	name = T_BOARD("teleporter control console")
	icon_state = "id_mod_blue"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = list(TECH_DATA = 2, TECH_BLUESPACE = 2)

/obj/item/circuitboard/atmos_alert
	name = T_BOARD("atmospheric alert console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/pod
	name = T_BOARD("massdriver control")
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/robotics
	name = T_BOARD("robotics control console")
	icon_state = "id_mod_purple"
	build_path = /obj/machinery/computer/robotics
	origin_tech = list(TECH_DATA = 3)

/obj/item/circuitboard/drone_control
	name = T_BOARD("drone control console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/drone_control
	origin_tech = list(TECH_DATA = 3)

/obj/item/circuitboard/arcade/battle
	name = T_BOARD("battle arcade machine")
	icon_state = "id_mod_yellow"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = list(TECH_DATA = 1)

/obj/item/circuitboard/arcade/orion_trail
	name = T_BOARD("orion trail arcade machine")
	icon_state = "id_mod_yellow"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = list(TECH_DATA = 1)

/obj/item/circuitboard/turbine_control
	name = T_BOARD("turbine control console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/solar_control
	name = T_BOARD("solar control console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/power/solar_control
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 2)

/obj/item/circuitboard/powermonitor
	name = T_BOARD("power monitoring console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/power_monitor

/obj/item/circuitboard/olddoor
	name = T_BOARD("DoorMex")
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/syndicatedoor
	name = T_BOARD("ProComp Executive")
	icon_state = "id_mod_black"
	build_path = /obj/machinery/computer/pod/old/syndicate

/obj/item/circuitboard/swfdoor
	name = T_BOARD("Magix")
	build_path = /obj/machinery/computer/pod/old/swf

/obj/item/circuitboard/prisoner
	name = T_BOARD("prisoner management console")
	icon_state = "id_mod_red"
	build_path = /obj/machinery/computer/prisoner

/obj/item/circuitboard/mecha_control
	name = T_BOARD("exosuit control console")
	icon_state = "id_mod_purple"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/rdservercontrol
	name = T_BOARD("R&D server control console")
	icon_state = "id_mod_purple"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/crew
	name = T_BOARD("crew monitoring console")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/computer/crew
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 2, TECH_MAGNET = 2)

/obj/item/circuitboard/operating
	name = T_BOARD("patient monitoring console")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/computer/operating
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)

/obj/item/circuitboard/operating/small
	name = T_BOARD("surgical console")
	build_path = /obj/machinery/computer/operating/small

/obj/item/circuitboard/curefab
	name = T_BOARD("cure fabricator")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/computer/curer

/obj/item/circuitboard/splicer
	name = T_BOARD("disease splicer")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/computer/diseasesplicer

/obj/item/circuitboard/mining_shuttle
	name = T_BOARD("mining shuttle console")
	icon_state = "id_mod_brown"
	build_path = /obj/machinery/computer/shuttle_control/mining
	origin_tech = list(TECH_DATA = 2)

/obj/item/circuitboard/engineering_shuttle
	name = T_BOARD("engineering shuttle console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/shuttle_control/engineering
	origin_tech = list(TECH_DATA = 2)

/obj/item/circuitboard/research_shuttle
	name = T_BOARD("research shuttle console")
	icon_state = "id_mod_purple"
	build_path = /obj/machinery/computer/shuttle_control/research
	origin_tech = list(TECH_DATA = 2)

/obj/item/circuitboard/security_shuttle
	name = T_BOARD("security shuttle console")
	icon_state = "id_mod_red"
	build_path = /obj/machinery/computer/shuttle_control/security
	origin_tech = list(TECH_DATA = 2)

/obj/item/circuitboard/area_atmos
	name = T_BOARD("area air control console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = list(TECH_DATA = 2)

/obj/item/circuitboard/rcon_console
	name = T_BOARD("RCON remote control console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/rcon
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3, TECH_POWER = 5)

/obj/item/circuitboard/account_database
	name = T_BOARD("accounts uplink terminal")
	icon_state = "id_mod_blue"
	build_path = /obj/machinery/computer/account_database
