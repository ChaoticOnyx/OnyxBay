/decl/hierarchy/supply_pack/atmospherics
	name = "Atmospherics"
	containertype = /obj/structure/closet/crate/internals

/decl/hierarchy/supply_pack/atmospherics/internals
	name = "Internals crate"
	contains = list(/obj/item/clothing/mask/gas = 5,
					/obj/item/weapon/tank/air = 5)
	cost = 1000
	containername = "\improper Internals crate"

/decl/hierarchy/supply_pack/atmospherics/evacuation
	name = "Emergency equipment"
	contains = list(/obj/item/weapon/storage/toolbox/emergency = 2,
					/obj/item/clothing/suit/storage/hazardvest = 2,
					/obj/item/weapon/tank/emergency/oxygen/engi = 4,
			 		/obj/item/clothing/suit/space/emergency = 4,
					/obj/item/clothing/head/helmet/space/emergency = 4,
					/obj/item/clothing/mask/gas = 4,
					/obj/item/device/flashlight/glowstick = 5)
	cost = 3000

	containername = "\improper Emergency crate"

/decl/hierarchy/supply_pack/atmospherics/inflatable
	name = "Inflatable barriers"
	contains = list(/obj/item/weapon/storage/briefcase/inflatable = 5)
	cost = 2000
	containertype = /obj/structure/closet/crate
	containername = "\improper Inflatable Barrier Crate"

/decl/hierarchy/supply_pack/atmospherics/canister_empty
	name = "Empty gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister)
	cost = 500
	containername = "\improper Empty gas canister crate"
	containertype = /obj/structure/largecrate

/decl/hierarchy/supply_pack/atmospherics/canister_air
	name = "Air canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/air)
	cost = 1000
	containername = "\improper Air canister crate"
	containertype = /obj/structure/largecrate

/decl/hierarchy/supply_pack/atmospherics/canister_oxygen
	name = "Oxygen canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	cost = 1500
	containername = "\improper Oxygen canister crate"
	containertype = /obj/structure/largecrate

/decl/hierarchy/supply_pack/atmospherics/canister_nitrogen
	name = "Nitrogen canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	cost = 1000
	containername = "\improper Nitrogen canister crate"
	containertype = /obj/structure/largecrate

/decl/hierarchy/supply_pack/atmospherics/canister_plasma
	name = "Plasma gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/plasma)
	cost = 7000
	containername = "\improper Plasma gas canister crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_atmospherics

/decl/hierarchy/supply_pack/atmospherics/canister_hydrogen
	name = "Hydrogen canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/hydrogen)
	cost = 2500
	containername = "\improper Hydrogen canister crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_atmospherics

/decl/hierarchy/supply_pack/atmospherics/canister_sleeping_agent
	name = "N2O gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	cost = 4000
	containername = "\improper N2O gas canister crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_atmospherics

/decl/hierarchy/supply_pack/atmospherics/canister_carbon_dioxide
	name = "Carbon dioxide gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	cost = 4000
	containername = "\improper CO2 canister crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_atmospherics

/decl/hierarchy/supply_pack/atmospherics/fuel
	name = "Fuel tank crate"
	contains = list(/obj/item/weapon/tank/hydrogen = 4)
	cost = 1500
	containername = "\improper Fuel tank crate"

/decl/hierarchy/supply_pack/atmospherics/plasma
	name = "Plasma tank crate"
	contains = list(/obj/item/weapon/tank/plasma = 3)
	cost = 3000
	containername = "\improper Plasma tank crate"

/decl/hierarchy/supply_pack/atmospherics/voidsuit
	name = "Atmospherics voidsuit"
	contains = list(/obj/item/clothing/suit/space/void/atmos/alt,
					/obj/item/clothing/head/helmet/space/void/atmos/alt,
					/obj/item/clothing/shoes/magboots)
	cost = 6000
	containername = "\improper Atmospherics voidsuit crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_atmospherics
