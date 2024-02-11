/obj/machinery/vending/coat_dispenser
	name = "Coat Dispenser"
	desc = "Classy vending machine designed to contribute to your comfort with warm."

	icon_state = "Theater"

	vend_delay = 21
	use_vend_state = TRUE
	gen_rand_amount = FALSE

	vending_sound = SFX_VENDING_DROP

	component_types = list(
		/obj/item/vending_cartridge/coat_dispenser
		)

	legal = list(
		/obj/item/clothing/suit/storage/hooded/wintercoat = 10
		)

	prices = list(
		/obj/item/clothing/suit/storage/hooded/wintercoat= 300
		)

/obj/item/vending_cartridge/coat_dispenser
	icon_state = "refill_clothes"
	build_path = /obj/machinery/vending/coat_dispenser
