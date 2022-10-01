
//This one's from bay12
/obj/machinery/vending/plasmaresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	component_types = list(/obj/item/vending_cartridge/plasmaresearch)
	legal = list(	/obj/item/clothing/suit/bio_suit = 6,
					/obj/item/clothing/head/bio_hood = 6,
					/obj/item/device/transfer_valve = 6,
					/obj/item/device/assembly/timer = 6,
					/obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/voice = 6,
					/obj/item/device/assembly/prox_sensor = 6,
					/obj/item/device/assembly/igniter = 6)

/obj/item/vending_cartridge/plasmaresearch
	name = "plasmaresearch"
	build_path = /obj/machinery/vending/plasmaresearch
