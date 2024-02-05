/obj/structure/closet/secure_closet/scientist
	name = "scientist's locker"
	req_one_access = list(access_tox,access_tox_storage)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/scientist/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/messenger/tox, /obj/item/storage/backpack/satchel/tox)),
		/obj/item/clothing/under/rank/scientist,
		/obj/item/clothing/suit/storage/toggle/labcoat,
		/obj/item/clothing/shoes/white,
		/obj/item/device/radio/headset/headset_sci,
		/obj/item/clothing/glasses/hud/standard/science,
		/obj/item/clothing/mask/gas,
		/obj/item/clipboard
	)

/obj/structure/closet/secure_closet/xenobio
	name = "xenobiologist's locker"
	req_access = list(access_xenobiology)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/xenobio/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/messenger/tox, /obj/item/storage/backpack/satchel/tox)),
		/obj/item/clothing/under/rank/scientist,
		/obj/item/clothing/suit/storage/toggle/labcoat,
		/obj/item/clothing/shoes/white,
		/obj/item/device/radio/headset/headset_sci,
		/obj/item/clothing/glasses/hud/standard/science,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/gloves/latex,
		/obj/item/clipboard
	)

/obj/structure/closet/secure_closet/RD
	name = "research director's locker"
	req_access = list(access_rd)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_off = "rdsecureoff"

/obj/structure/closet/secure_closet/RD/WillContain()
	return list(
		/obj/item/storage/garment/research_director,
		/obj/item/clothing/suit/bio_suit/scientist,
		/obj/item/clothing/head/bio_hood/scientist,
		/obj/item/device/radio/headset/heads/rd,
		/obj/item/cartridge/rd,
		/obj/item/device/flash,
		/obj/item/clipboard,
		/obj/item/melee/telebaton,
		/obj/item/paper/monitorkey
	)

/obj/structure/closet/secure_closet/animal
	name = "animal control closet"
	req_access = list(access_research)

/obj/structure/closet/secure_closet/animal/WillContain()
	return list(
		/obj/item/device/assembly/signaler,
		/obj/item/device/radio/electropack = 3,
		/obj/item/gun/launcher/syringe/rapid,
		/obj/item/storage/box/syringegun,
		/obj/item/storage/box/syringes,
		/obj/item/reagent_containers/vessel/bottle/chemical/small/chloralhydrate,
		/obj/item/reagent_containers/vessel/bottle/chemical/stoxin
	)
