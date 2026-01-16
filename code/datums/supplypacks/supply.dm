/decl/hierarchy/supply_pack/supply
	name = "Supply"

/decl/hierarchy/supply_pack/supply/food
	name = "Kitchen supply crate"
	contains = list(/obj/item/reagent_containers/vessel/condiment/flour = 6,
					/obj/item/reagent_containers/vessel/plastic/milk = 4,
					/obj/item/reagent_containers/vessel/plastic/soymilk = 2,
					/obj/item/storage/fancy/egg_box = 2,
					/obj/item/reagent_containers/food/tofu = 4,
					/obj/item/reagent_containers/food/meat = 4
					)
	cost = 25
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper Food crate"

/decl/hierarchy/supply_pack/supply/toner
	name = "Toner cartridges"
	contains = list(/obj/item/device/toner = 6)
	cost = 10
	containername = "\improper Toner cartridges"

/decl/hierarchy/supply_pack/supply/janitor
	name = "Janitorial supplies"
	contains = list(/obj/item/reagent_containers/vessel/bucket,
					/obj/item/mop,
					/obj/item/caution = 4,
					/obj/item/storage/bag/trash,
					/obj/item/device/lightreplacer,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/storage/box/cleanerpods,
					/obj/item/reagent_containers/rag,
					/obj/item/grenade/chem_grenade/cleaner = 3,
					/obj/structure/mopbucket)
	cost = 10
	containertype = /obj/structure/closet/crate/large
	containername = "\improper Janitorial supplies"

/decl/hierarchy/supply_pack/supply/boxes
	name = "Empty boxes"
	contains = list(/obj/item/storage/box = 10)
	cost = 10
	containername = "\improper Empty box crate"

/decl/hierarchy/supply_pack/supply/bureaucracy
	contains = list(/obj/item/clipboard,
					 /obj/item/clipboard,
					 /obj/item/pen/red,
					 /obj/item/pen/blue = 2,
					 /obj/item/device/camera_film,
					 /obj/item/folder/blue,
					 /obj/item/folder/red,
					 /obj/item/folder/yellow,
					 /obj/item/hand_labeler,
					 /obj/item/tape_roll,
					 /obj/structure/filingcabinet/chestdrawer{anchored = 0},
					 /obj/item/paper_bin)
	name = "Office supplies"
	cost = 15
	containertype = /obj/structure/closet/crate/large
	containername = "\improper Office supplies crate"

/decl/hierarchy/supply_pack/supply/spare_pda
	name = "Spare PDAs"
	contains = list(/obj/item/device/pda = 5)
	cost = 10
	containername = "\improper Spare PDA crate"

/decl/hierarchy/supply_pack/supply/minergear
	name = "Shaft miner equipment"
	contains = list(/obj/item/storage/backpack/industrial,
					/obj/item/storage/backpack/satchel/eng,
					/obj/item/device/radio/headset/headset_cargo,
					/obj/item/clothing/under/rank/miner,
					/obj/item/clothing/gloves/thick,
					/obj/item/clothing/shoes/black,
					/obj/item/device/analyzer,
					/obj/item/storage/ore,
					/obj/item/device/flashlight/lantern,
					/obj/item/shovel,
					/obj/item/pickaxe,
					/obj/item/mining_scanner,
					/obj/item/clothing/glasses/hud/standard/meson)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Shaft miner equipment"
	access = access_mining

/decl/hierarchy/supply_pack/supply/plastic_cup_bags
	name = "Plastic cup bags"
	contains = list(/obj/item/storage/plastic_cup_bag = 2)
	cost = 10
	containername = "\improper Plastic cup bags"
