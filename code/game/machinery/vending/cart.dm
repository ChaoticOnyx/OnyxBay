
//This one's from bay12
/obj/machinery/vending/cart
	name = "PTech"
	desc = "Cartridges for PDAs."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	use_vend_state = TRUE
	vend_delay = 23
	products = list(/obj/item/cartridge/medical = 10,
					/obj/item/cartridge/engineering = 10,
					/obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/science = 10)
