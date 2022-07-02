/obj/machinery/vending/coat_dispenser
	name = "Coat Dispenser"
	desc = "Classy vending machine designed to contribute to your comfort with warm."
	gen_rand_amount = FALSE
	vend_delay = 21 SECONDS
	icon_state = "Theater"
	use_vend_state = TRUE
	component_types = list(/obj/item/vending_cartridge/coat_dispenser)
	legal = list(/obj/item/clothing/suit/storage/hooded/wintercoat = 10)
	prices = list(/obj/item/clothing/suit/storage/hooded/wintercoat= 300)

/obj/item/vending_cartridge/coat_dispenser
	name = "coat"
	build_path = /obj/machinery/vending/coat_dispenser
