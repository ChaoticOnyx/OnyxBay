
/obj/machinery/vending/fashionvend
	name = "Smashing Fashions"
	desc = "For all your cheap knockoff needs."
	product_slogans = "Look smashing for your darling!;Be rich! Dress rich!"
	icon_state = "Theater"
	vend_delay = 15 SECONDS
	vend_reply = "Absolutely smashing!"
	product_ads = "Impress the love of your life!;Don't look poor, look rich!;100% authentic designers!;All sales are final!;Lowest prices guaranteed!"
	component_types = list(/obj/item/vending_cartridge/fashionvend)
	legal = list(	/obj/item/mirror = 8,
					/obj/item/haircomb = 8,
					/obj/item/clothing/glasses/monocle = 5,
					/obj/item/clothing/glasses/sunglasses = 5,
					/obj/item/lipstick = 3,
					/obj/item/lipstick/black = 3,
					/obj/item/lipstick/purple = 3,
					/obj/item/lipstick/jade = 3,
					/obj/item/storage/bouquet = 3,
					/obj/item/storage/wallet/poly = 2)
	illegal = list(	/obj/item/clothing/glasses/eyepatch = 2,
						/obj/item/clothing/accessory/horrible = 2,
						/obj/item/clothing/under/monkey/color/random = 3)
	premium = list(/obj/item/clothing/mask/smokable/pipe = 3)
	prices = list(	/obj/item/mirror = 60,
					/obj/item/haircomb = 40,
					/obj/item/clothing/glasses/monocle = 700,
					/obj/item/clothing/glasses/sunglasses = 500,
					/obj/item/lipstick = 100,
					/obj/item/lipstick/black = 100,
					/obj/item/lipstick/purple = 100,
					/obj/item/lipstick/jade = 100,
					/obj/item/storage/bouquet = 800,
					/obj/item/storage/wallet/poly = 600)

/obj/item/vending_cartridge/fashionvend
	name = "fashion"
	build_path = /obj/machinery/vending/fashionvend
