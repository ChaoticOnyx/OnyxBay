
/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	alt_icons = list("sec", "sec_alt")
	use_alt_icons = TRUE
	use_vend_state = TRUE
	gen_rand_amount = FALSE
	vend_delay = 20 SECONDS
	req_access = list(access_security)
	component_types = list(/obj/item/vending_cartridge/security)
	legal = list(	/obj/item/handcuffs = 8,
					/obj/item/grenade/flashbang = 4,
					/obj/item/grenade/chem_grenade/teargas = 4,
					/obj/item/device/flash = 5,
					/obj/item/reagent_containers/food/donut/normal = 12,
					/obj/item/storage/box/evidence = 6)
	illegal = list(	/obj/item/clothing/glasses/sunglasses = 2,
					/obj/item/storage/box/donut = 2)

/obj/item/vending_cartridge/security
	name = "security"
	build_path = /obj/machinery/vending/security
