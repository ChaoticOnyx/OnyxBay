
/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	use_vend_state = TRUE
	vend_delay = 18 SECONDS
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(access_medical_equip)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	component_types = list(/obj/item/vending_cartridge/medical)
	legal = list(	/obj/item/reagent_containers/vessel/bottle/chemical/antitoxin = 4,
					/obj/item/reagent_containers/vessel/bottle/chemical/inaprovaline = 4,
					/obj/item/reagent_containers/vessel/bottle/chemical/stoxin = 4,
					/obj/item/reagent_containers/vessel/bottle/chemical/toxin = 4,
					/obj/item/reagent_containers/vessel/bottle/chemical/spaceacillin = 2,
					/obj/item/reagent_containers/syringe = 12,
					/obj/item/device/healthanalyzer = 5,
					/obj/item/reagent_containers/vessel/beaker = 4,
					/obj/item/reagent_containers/dropper = 2,
					/obj/item/stack/medical/advanced/bruise_pack = 3,
					/obj/item/stack/medical/advanced/ointment = 3,
					/obj/item/stack/medical/splint = 2,
					/obj/item/reagent_containers/hypospray/autoinjector/pain = 4)
	illegal = list(	/obj/item/reagent_containers/pill/tox = 3,
					/obj/item/reagent_containers/pill/stox = 4,
					/obj/item/reagent_containers/pill/dylovene = 6,
					/obj/item/reagent_containers/hypospray/autoinjector/combatpain = 2)

/obj/item/vending_cartridge/medical
	name = "medical"
	build_path = /obj/machinery/vending/medical

/obj/machinery/vending/wallmed1
	name = "NanoMed"
	desc = "A wall-mounted version of the NanoMed."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	component_types = list(/obj/item/vending_cartridge/wallmed1)
	legal = list(	/obj/item/stack/medical/bruise_pack = 2,
					/obj/item/stack/medical/ointment = 2,
					/obj/item/reagent_containers/hypospray/autoinjector = 4)
	illegal = list(	/obj/item/reagent_containers/syringe/antitoxin/packaged = 4,
					/obj/item/reagent_containers/syringe/antiviral/packaged = 4,
					/obj/item/reagent_containers/pill/tox = 1)

/obj/item/vending_cartridge/wallmed1
	name = "wallmed1"
	build_path = /obj/machinery/vending/wallmed1

/obj/machinery/vending/wallmed2
	name = "NanoMed Mini"
	desc = "A wall-mounted version of the NanoMed, containing only vital first aid equipment."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	component_types = list(/obj/item/vending_cartridge/wallmed2)
	legal = list(	/obj/item/reagent_containers/hypospray/autoinjector = 5,
					/obj/item/reagent_containers/syringe/antitoxin/packaged = 1,
					/obj/item/stack/medical/bruise_pack = 3,
					/obj/item/stack/medical/ointment =3)
	illegal = list(	/obj/item/reagent_containers/pill/tox = 3,
					/obj/item/reagent_containers/hypospray/autoinjector/pain = 2)

/obj/item/vending_cartridge/wallmed2
	name = "wallmed2"
	build_path = /obj/machinery/vending/wallmed2
