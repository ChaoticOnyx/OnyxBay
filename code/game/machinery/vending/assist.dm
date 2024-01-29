
/obj/machinery/vending/assist
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"

	vending_sound = SFX_VENDING_GENERIC

	component_types = list(
		/obj/item/vending_cartridge/assist
		)

	legal = list(
		/obj/item/device/assembly/prox_sensor = 5,
		/obj/item/device/assembly/igniter = 3,
		/obj/item/device/assembly/signaler = 4,
		/obj/item/wirecutters = 1,
		/obj/item/cartridge/signal = 4
		)

	illegal = list(
		/obj/item/device/flashlight = 5,
		/obj/item/device/assembly/timer = 2,
		/obj/item/device/assembly/voice = 2
		)

/obj/item/vending_cartridge/assist
	icon_state = "refill_parts"
	build_path = /obj/machinery/vending/props

/obj/machinery/vending/assist/antag
	name = "AntagCorpVend"

	component_types = list(
		/obj/item/vending_cartridge/antag
		)

	legal = list(
		/obj/item/device/assembly/prox_sensor = 5,
		/obj/item/device/assembly/signaler = 4,
		/obj/item/device/assembly/voice = 4,
		/obj/item/device/assembly/infra = 4,
		/obj/item/device/assembly/prox_sensor = 4,
		/obj/item/handcuffs = 8,
		/obj/item/device/flash = 4,
		/obj/item/cartridge/signal = 4,
		/obj/item/clothing/glasses/sunglasses = 4
		)

/obj/item/vending_cartridge/antag
	icon_state = "refill_parts"
	build_path = /obj/machinery/vending/props
