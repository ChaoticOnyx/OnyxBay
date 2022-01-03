/decl/hierarchy/supply_pack/science
	name = "Science"

/decl/hierarchy/supply_pack/science/virus
	name = "Virus sample crate"
	contains = list(/obj/item/virusdish/random = 4)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/science
	containername = "\improper Virus sample crate"
	access = access_virology

/decl/hierarchy/supply_pack/science/coolanttank
	name = "Coolant tank crate"
	contains = list(/obj/structure/reagent_dispensers/coolanttank)
	cost = 16
	containertype = /obj/structure/largecrate
	containername = "\improper coolant tank crate"

/decl/hierarchy/supply_pack/science/mecha_ripley
	name = "Circuit Crate (\"Ripley\" APLU)"
	contains = list(/obj/item/book/wiki/robotics_cyborgs,
					/obj/item/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer,
					/obj/item/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 30
	containertype = /obj/structure/closet/crate/secure/science
	containername = "\improper APLU \"Ripley\" Circuit Crate"
	access = access_robotics

/decl/hierarchy/supply_pack/science/mecha_odysseus
	name = "Circuit Crate (\"Odysseus\")"
	contains = list(/obj/item/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer,
					/obj/item/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 25
	containertype = /obj/structure/closet/crate/secure/science
	containername = "\improper \"Odysseus\" Circuit Crate"
	access = access_robotics

/decl/hierarchy/supply_pack/science/plasma
	name = "Plasma assembly crate"
	contains = list(/obj/item/tank/plasma = 3,
					/obj/item/device/assembly/igniter = 3,
					/obj/item/device/assembly/prox_sensor = 3,
					/obj/item/device/assembly/timer = 3,
					/obj/item/device/transfer_valve = 3)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "\improper Plasma assembly crate"
	access = access_tox_storage

/decl/hierarchy/supply_pack/science/amirig
	name = "AMI RIG crate"
	contains = list(/obj/item/rig/hazmat)
	cost = 480
	containertype = /obj/structure/closet/crate/secure/science
	containername = "\improper AMI RIG crate"
	access = access_research
