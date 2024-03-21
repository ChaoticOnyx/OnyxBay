GLOBAL_LIST_INIT(minevendor_prison_list, list(
	new /datum/data/mining_equipment("Soy Dope",                  	 /obj/item/reagent_containers/food/soydope,		              	   20,     5),
	new /datum/data/mining_equipment("Match", 						 /obj/item/flame/match ,                 						   -1,    10),
	new /datum/data/mining_equipment("Cigarette Trans-Stellar Duty-frees", /obj/item/clothing/mask/smokable/cigarette,                 30,    15),
	new /datum/data/mining_equipment("Cigarette Jerichos", 			 /obj/item/clothing/mask/smokable/cigarette/jerichos,          	   20,    20),
	new /datum/data/mining_equipment("Cigarette Professional 120s",  /obj/item/clothing/mask/smokable/cigarette/professionals,         15,    25),
	new /datum/data/mining_equipment("Boiled rice",       			 /obj/item/reagent_containers/food/boiledrice,                     30,    25),
	new /datum/data/mining_equipment("Synthetic meat",       		 /obj/item/reagent_containers/food/meat/syntiflesh,                30,    30),
	new /datum/data/mining_equipment("Space Cola",		       		 /obj/item/reagent_containers/vessel/can/cola,		               30,    30),
	new /datum/data/mining_equipment("Thermostabilizine Pill",       /obj/item/reagent_containers/pill/leporazine,                     15,    35),
	new /datum/data/mining_equipment("Dexalin Pill",		         /obj/item/reagent_containers/pill/dexalin,			               15,    35),
	new /datum/data/mining_equipment("Radfi-X",                      /obj/item/reagent_containers/hypospray/autoinjector/antirad/mine, 15,    35),
	new /datum/data/mining_equipment("Breath mask",		             /obj/item/clothing/mask/breath/emergency,                         -1,    30),
	new /datum/data/mining_equipment("Basic oxygen tank",            /obj/item/tank/emergency/oxygen,                                  -1,    30),
	new /datum/data/mining_equipment("Oxygen tank",                  /obj/item/tank/emergency/oxygen/engi,                             -1,    50),
	new /datum/data/mining_equipment("Double oxygen tank",           /obj/item/tank/emergency/oxygen/double,                           -1,    70),
	new /datum/data/mining_equipment("5 Red Flags",                  /obj/item/stack/flag/red,                                         10,    50),
	new /datum/data/mining_equipment("Meat Pizza",                   /obj/item/pizzabox/meat,                                          25,    60),
	new /datum/data/mining_equipment("Ore-bag",                      /obj/item/storage/ore,                                            25,    60),
	new /datum/data/mining_equipment("Ore Scanner Pad",              /obj/item/ore_radar,                                              10,    60),
	new /datum/data/mining_equipment("Lantern",                      /obj/item/device/flashlight/lantern,                              10,    75),
	new /datum/data/mining_equipment("Wrench",                       /obj/item/wrench,                              		 		   5,     80),
	new /datum/data/mining_equipment("Screwdriver",                  /obj/item/screwdriver,                           		 		   5,     80),
	new /datum/data/mining_equipment("Shovel",                       /obj/item/shovel,                                                 15,   100),
	new /datum/data/mining_equipment("The meson goggles HUD",		 /obj/item/clothing/glasses/hud/standard/meson,					   10,   100),
	new /datum/data/mining_equipment("Silver Pickaxe",               /obj/item/pickaxe/silver,                                         10,   100),
	new /datum/data/mining_equipment("The work gloves",              /obj/item/clothing/gloves/thick,                                  10,   110),
	new /datum/data/mining_equipment("The workboots",                /obj/item/clothing/shoes/workboots,                               10,   110),
	new /datum/data/mining_equipment("Hard hat",                	 /obj/item/clothing/head/hardhat/orange,                           10,   150),
	new /datum/data/mining_equipment("Ore Box",                      /obj/structure/ore_box,                                           -1,   150,  1),
	new /datum/data/mining_equipment("Emergency Floodlight",         /obj/item/floodlight_diy,                                         -1,   150,  1),
	new /datum/data/mining_equipment("Premium Cigar",                /obj/item/clothing/mask/smokable/cigarette/cigar/havana,          30,   150),
	new /datum/data/mining_equipment("Lottery Chip",                 /obj/item/spacecash/ewallet/lotto,                                50,   200),
	new /datum/data/mining_equipment("Mining Drill",                 /obj/item/pickaxe,                                                10,   200),
	new /datum/data/mining_equipment("Deep Ore Scanner",             /obj/item/mining_scanner,                                         10,   250),
	new /datum/data/mining_equipment("Autochisel",                   /obj/item/autochisel,                                             10,   400),
	new /datum/data/mining_equipment("The advanced power cell",      /obj/item/cell/high,		                                        3,   450),
	new /datum/data/mining_equipment("Industrial Drill Brace",       /obj/machinery/mining/brace,                                      -1,   500,  1),
	new /datum/data/mining_equipment("Point Transfer Card",          /obj/item/card/mining_point_card,                                 -1,   500),
	new /datum/data/mining_equipment("The gas mask",	             /obj/item/clothing/mask/gas/clear,                            	   10,   500),
	new /datum/data/mining_equipment("Explorer's Belt",              /obj/item/storage/belt/mining,                                    10,   500),
	new /datum/data/mining_equipment("First-Aid Kit",                /obj/item/storage/firstaid/regular,                               30,   600),
	new /datum/data/mining_equipment("Ore Magnet",                   /obj/item/oremagnet,                                              10,   600),
	new /datum/data/mining_equipment("Minecart",                     /obj/structure/closet/crate/miningcar,                            -1,   600,  1),
	new /datum/data/mining_equipment("Sonic Jackhammer",             /obj/item/pickaxe/jackhammer,                                      2,   700),
	new /datum/data/mining_equipment("Ore Summoner",                 /obj/item/oreportal,                                               3,   800),
	new /datum/data/mining_equipment("Heavy-duty cell charger",		 /obj/machinery/cell_charger,                                       1,   800),
	new /datum/data/mining_equipment("Lazarus Injector",             /obj/item/lazarus_injector,                                       25,  1000),
	new /datum/data/mining_equipment("Industrial Drill Head",        /obj/machinery/mining/drill,                                      -1,  1000,  1),
	new /datum/data/mining_equipment("Diamond Pickaxe",              /obj/item/pickaxe/diamond,                                        10,  1500)
))

/obj/machinery/equipment_vendor/prison
	name = "mining prison equipment vendor"
	desc = "An equipment vendor for prisoner, points collected at an ore redemption machine can be spent here."
	icon_state = "mining-prison"

/obj/machinery/equipment_vendor/prison/Initialize()
	. = ..()
	equipment_list = GLOB.minevendor_prison_list

/obj/item/circuitboard/machine/mining_equipment_vendor/prison
	name = "circuit board (Mining Prison Equipment Vendor)"
	build_path = /obj/machinery/equipment_vendor/prison
