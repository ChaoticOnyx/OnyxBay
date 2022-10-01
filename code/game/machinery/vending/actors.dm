
//FOR ACTORS GUILD - mainly props that cannot be spawned otherwise
/obj/machinery/vending/props
	name = "prop dispenser"
	desc = "All the props an actor could need. Probably."
	icon_state = "Theater"
	component_types = list(/obj/item/vending_cartridge/props)
	legal = list(/obj/structure/flora/pottedplant = 2,
					/obj/item/device/flashlight/lamp = 2,
					/obj/item/device/flashlight/lamp/green = 2,
					/obj/item/reagent_containers/vessel/jar = 1,
					/obj/item/nullrod = 1,
					/obj/item/toy/cultsword = 4,
					/obj/item/toy/katana = 2)

/obj/item/vending_cartridge/props
	name = "props"
	build_path = /obj/machinery/vending/props

//FOR ACTORS GUILD - Containers
/obj/machinery/vending/containers
	name = "container dispenser"
	desc = "A container that dispenses containers."
	icon_state = "robotics"
	component_types = list(/obj/item/vending_cartridge/containers)
	legal = list(/obj/structure/closet/crate/freezer = 2,
					/obj/structure/closet = 3,
					/obj/structure/closet/crate = 3)

/obj/item/vending_cartridge/containers
	name = "containers"
	build_path = /obj/machinery/vending/containers
