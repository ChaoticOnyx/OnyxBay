/obj/structure/closet/secure_closet/captains
	name = "captain's locker"
	req_access = list(access_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_off = "capsecureoff"

/obj/structure/closet/secure_closet/captains/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/captain, /obj/item/storage/backpack/satchel/cap)),
		new /datum/atom_creator/simple(/obj/item/storage/backpack/dufflebag/captain, 50),
		/obj/item/storage/garment/captain,
		/obj/item/device/radio/headset/heads/captain,
		/obj/item/gun/energy/egun/elite,
		/obj/item/melee/telebaton,
		/obj/item/cartridge/captain,
	)

/obj/structure/closet/secure_closet/hop
	name = "head of provisioning's locker"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack = 75,  /obj/item/storage/backpack/satchel/grey = 25)),
		new /datum/atom_creator/simple(/obj/item/storage/backpack/dufflebag, 25),
		/obj/item/storage/garment/head_of_provisioning,
		/obj/item/melee/telebaton,
		/obj/item/device/radio/headset/heads/hop,
		/obj/item/cartridge/hop,
		/obj/item/device/flash,
		/obj/item/tank/emergency/oxygen,
		/obj/item/material/coin/silver = 2
	)

/obj/structure/closet/secure_closet/hos
	name = "head of security's locker"
	req_access = list(access_hos)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_off = "hossecureoff"

/obj/structure/closet/secure_closet/hos/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/security, /obj/item/storage/backpack/satchel/sec)),
		/obj/item/storage/garment/hos,
		/obj/item/device/flash,
		/obj/item/shield/riot,
		/obj/item/gun/energy/egun/elite,
		/obj/item/melee/telebaton,
		/obj/item/melee/baton/loaded,
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/belt/security,
		/obj/item/taperoll/police,
		/obj/item/device/holowarrant,
		/obj/item/cartridge/hos,
		/obj/item/device/radio/headset/heads/hos,
		/obj/item/device/radio/headset/tactical/hos
	)

/obj/structure/closet/secure_closet/warden
	name = "warden's locker"
	req_access = list(access_armory)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_off = "wardensecureoff"

/obj/structure/closet/secure_closet/warden/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/security, /obj/item/storage/backpack/satchel/sec)),
		new /datum/atom_creator/simple(/obj/item/storage/backpack/dufflebag/sec, 50),
		/obj/item/storage/garment/warden,
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/box/teargas,
		/obj/item/storage/belt/security,
		/obj/item/storage/box/chalk,
		/obj/item/storage/box/holobadge,
		/obj/item/taperoll/police,
		/obj/item/device/holowarrant,
		/obj/item/cartridge/security,
		/obj/item/storage/secure/guncase/security,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/device/radio/headset/headset_sec,
		/obj/item/device/radio/headset/tactical/sec
	)

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(access_brig)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_off = "secoff"

/obj/structure/closet/secure_closet/security/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/security, /obj/item/storage/backpack/satchel/sec)),
		new /datum/atom_creator/simple(/obj/item/storage/backpack/dufflebag/sec, 50),
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/soft/sec,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/under/rank/security,
		/obj/item/clothing/glasses/hud/aviators/security,
		/obj/item/storage/belt/security,
		/obj/item/device/radio/headset/headset_sec,
		/obj/item/device/flash,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/taperoll/police,
		/obj/item/device/hailer,
		/obj/item/device/holowarrant,
		/obj/item/storage/secure/guncase/security
	)

/obj/structure/closet/secure_closet/security/cargo/WillContain()
	return MERGE_ASSOCS_WITH_NUM_VALUES(..(), list(
		/obj/item/clothing/accessory/armband/cargo,
		/obj/item/device/encryptionkey/headset_cargo
	))

/obj/structure/closet/secure_closet/security/engine/WillContain()
	return MERGE_ASSOCS_WITH_NUM_VALUES(..(), list(
			/obj/item/clothing/accessory/armband/engine,
			/obj/item/device/encryptionkey/headset_eng
		))

/obj/structure/closet/secure_closet/security/science/WillContain()
	return MERGE_ASSOCS_WITH_NUM_VALUES(..(), list(/obj/item/device/encryptionkey/headset_sci))

/obj/structure/closet/secure_closet/security/med/WillContain()
	return MERGE_ASSOCS_WITH_NUM_VALUES(..(), list(
			/obj/item/clothing/accessory/armband/medgreen,
			/obj/item/device/encryptionkey/headset_med
		))

/obj/structure/closet/secure_closet/detective
	name = "detective's cabinet"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_sparks"
	icon_off = "cabinetdetective_broken"
	dremovable = 0

/obj/structure/closet/secure_closet/detective/WillContain()
	return list(
		/obj/item/storage/garment/detective,
		/obj/item/storage/box/evidence,
		/obj/item/storage/box/chalk,
		/obj/item/device/radio/headset/headset_sec,
		/obj/item/taperoll/police,
		/obj/item/reagent_containers/vessel/flask/detflask,
		/obj/item/storage/briefcase/crimekit,
		/obj/item/device/holowarrant,
		/obj/item/storage/secure/guncase/detective,
		/obj/item/storage/csmarkers
	)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections locker"
	req_access = list(access_captain)

/obj/structure/closet/secure_closet/injection/WillContain()
	return list(/obj/item/reagent_containers/syringe/ld50_syringe/potassium_chlorophoride = 2)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(access_brig)
	anchored = 1
	var/id = null

/obj/structure/closet/secure_closet/brig/WillContain()
	return list(
		/obj/item/clothing/under/color/orange,
		/obj/item/clothing/shoes/orange
	)

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_one_access = list(access_lawyer, access_iaa)

/obj/structure/closet/secure_closet/courtroom/WillContain()
	return list(
		/obj/item/clothing/shoes/brown,
		/obj/item/paper/Court = 3,
		/obj/item/pen ,
		/obj/item/clothing/suit/judgerobe,
		/obj/item/clothing/head/powdered_wig ,
		/obj/item/storage/briefcase,
	)

/obj/structure/closet/secure_closet/wall
	name = "wall locker"
	req_access = list(access_security)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"
	dremovable = 0

/obj/structure/closet/secure_closet/iaa
	name = "internal affairs secure closet"
	req_access = list(access_iaa)

/obj/structure/closet/secure_closet/iaa/WillContain()
	return list(
		/obj/item/device/flash = 2,
		/obj/item/device/camera = 2,
		/obj/item/device/camera_film = 2,
		/obj/item/device/taperecorder = 2,
		/obj/item/storage/secure/briefcase = 2,
	)

/obj/structure/closet/secure_closet/lawyer
	name = "lawyer secure closet"
	req_access = list(access_lawyer)

/obj/structure/closet/secure_closet/lawyer/WillContain()
	return list(
		/obj/item/device/camera = 2,
		/obj/item/device/camera_film = 2,
		/obj/item/device/taperecorder = 2,
		/obj/item/storage/secure/briefcase = 2,
		/obj/item/clipboard,
		/obj/item/folder/blue,
		/obj/item/folder/red,
		/obj/item/folder/white,
		/obj/item/folder/yellow,
		/obj/item/storage/box/evidence = 2
	)
