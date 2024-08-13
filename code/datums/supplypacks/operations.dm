/decl/hierarchy/supply_pack/operations
	name = "Operations"

/decl/hierarchy/supply_pack/operations/arts
	name = "Arts Supplies"
	cost = 10
	contains = list(
		/obj/structure/easel,
		/obj/item/canvas/twentythree_twentythree,
		/obj/item/canvas/twentythree_nineteen,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/twentyfour_twentyfour,
		/obj/item/canvas = 2,
		/obj/item/pen/crayon/rainbow = 2
	)
	containername = "Arts Crate"

/decl/hierarchy/supply_pack/operations/mule
	name = "MULEbot Crate"
	contains = list(/mob/living/bot/mulebot)
	cost = 20
	containertype = /obj/structure/largecrate/animal/mulebot
	containername = "Mulebot Crate"

/decl/hierarchy/supply_pack/operations/cargotrain
	name = "Cargo Train Tug"
	contains = list(/obj/vehicle/train/cargo/engine)
	cost = 45
	containertype = /obj/structure/largecrate
	containername = "\improper Cargo Train Tug Crate"

/decl/hierarchy/supply_pack/operations/cargotrailer
	name = "Cargo Train Trolley"
	contains = list(/obj/vehicle/train/cargo/trolley)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "\improper Cargo Train Trolley Crate"

/decl/hierarchy/supply_pack/operations/artscrafts
	name = "Arts and Crafts supplies"
	contains = list(/obj/item/storage/fancy/crayons,
	/obj/item/device/camera,
	/obj/item/device/camera_film = 2,
	/obj/item/storage/photo_album,
	/obj/item/packageWrap,
	/obj/item/reagent_containers/vessel/paint/red,
	/obj/item/reagent_containers/vessel/paint/green,
	/obj/item/reagent_containers/vessel/paint/blue,
	/obj/item/reagent_containers/vessel/paint/yellow,
	/obj/item/reagent_containers/vessel/paint/purple,
	/obj/item/reagent_containers/vessel/paint/black,
	/obj/item/reagent_containers/vessel/paint/white,
	/obj/item/contraband/poster,
	/obj/item/wrapping_paper = 3)
	cost = 10
	containername = "\improper Arts and Crafts crate"

/decl/hierarchy/supply_pack/operations/contraband
	num_contained = 5
	contains = list(/obj/item/seeds/bloodtomatoseed,
					/obj/item/storage/pill_bottle/zoom,
					/obj/item/storage/pill_bottle/happy,
					/obj/item/reagent_containers/vessel/bottle/pwine)

	name = "Contraband crate"
	cost = 30
	containername = "\improper Unlabeled crate"
	contraband = 1
	supply_method = /decl/supply_method/randomized

/decl/hierarchy/supply_pack/operations/hoverpod
	name = "Hoverpod Shipment"
	contains = list(/obj/mecha/working/hoverpod)
	cost = 80
	containertype = /obj/structure/largecrate/hoverpod
	containername = "\improper Hoverpod Crate"

/decl/hierarchy/supply_pack/operations/webbing
	name = "Webbing crate"
	num_contained = 4
	contains = list(/obj/item/clothing/accessory/storage/black_vest,
					/obj/item/clothing/accessory/storage/black_vest/alt
					/obj/item/clothing/accessory/storage/brown_vest,
					/obj/item/clothing/accessory/storage/brown_vest/alt,
					/obj/item/clothing/accessory/storage/white_vest,
					/obj/item/clothing/accessory/storage/white_vest/alt,
					/obj/item/clothing/accessory/storage/drop_pouches/black,
					/obj/item/clothing/accessory/storage/drop_pouches/brown,
					/obj/item/clothing/accessory/storage/drop_pouches/white,
					/obj/item/clothing/accessory/storage/webbing)
	cost = 15
	containername = "\improper Webbing crate"

/decl/hierarchy/supply_pack/operations/holsters
	name = "Holster crate"
	contains = list(/obj/item/clothing/accessory/holster = 2,
					/obj/item/clothing/accessory/holster/thigh = 2,
					/obj/item/clothing/accessory/holster/hip = 2)
	cost = 15
	containername = "\improper Holster crate"

/decl/hierarchy/supply_pack/operations/syndicate
	name = "Special Ops Equipment crate"
	contains = list(/obj/item/clothing/head/helmet/swat,
					/obj/item/device/radio/headset/binary,
					/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/under/syndicate,
					/obj/item/storage/belt/security,
					/obj/item/clothing/gloves/thick/swat,
					/obj/item/clothing/shoes/combat,
					/obj/item/storage/backpack)
	cost = 40
	containername = "\improper Spec Ops Equipment crate"
	contraband = 1
