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
		/obj/item/clothing/head/caphat/cap,
		/obj/item/clothing/head/caphat/formal,
		/obj/item/clothing/head/helmet/captain,
		/obj/item/clothing/suit/captunic,
		/obj/item/clothing/suit/captunic/capjacket,
		/obj/item/clothing/suit/captunic/formal,
		/obj/item/clothing/suit/armor/vest/capcarapace,
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/under/dress/dress_cap,
		/obj/item/clothing/under/captainformal,
		/obj/item/clothing/gloves/captain,
		/obj/item/clothing/shoes/brown,
		/obj/item/device/radio/headset/heads/captain,
		/obj/item/gun/energy/egun,
		/obj/item/melee/telebaton,
		/obj/item/cartridge/captain,
	)

/obj/structure/closet/secure_closet/hop
	name = "head of personnel's locker"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop/WillContain()
	return list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/head/helmet,
		/obj/item/cartridge/hop,
		/obj/item/device/radio/headset/heads/hop,
		/obj/item/storage/box/ids = 2,
		/obj/item/gun/energy/classictaser,
		/obj/item/device/flash
	)

/obj/structure/closet/secure_closet/hop2
	name = "head of personnel's attire"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop2/WillContain()
	return list(
		/obj/item/clothing/under/rank/head_of_personnel,
		/obj/item/clothing/under/dress/dress_hop,
		/obj/item/clothing/under/dress/dress_hr,
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/lawyer/black,
		/obj/item/clothing/under/lawyer/red,
		/obj/item/clothing/under/lawyer/oldman,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/shoes/leather,
		/obj/item/clothing/shoes/white,
		/obj/item/clothing/under/rank/head_of_personnel_whimsy,
		/obj/item/clothing/head/caphat/hop
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
		/obj/item/clothing/head/beret/sec/corporate/hos,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/HoS,
		/obj/item/clothing/head/HoS/dermal,
		/obj/item/clothing/suit/armor/vest/hos_heavy,
		/obj/item/clothing/suit/armor/hos,
		/obj/item/clothing/suit/armor/hos/jensen,
		/obj/item/clothing/under/rank/head_of_security/jensen,
		/obj/item/clothing/under/rank/head_of_security/corp,
		/obj/item/clothing/glasses/hud/aviators/security,
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/shoes/swat,
		/obj/item/clothing/mask/gas/clear,
		/obj/item/device/flash,
		/obj/item/shield/riot,
		/obj/item/gun/energy/egun,
		/obj/item/melee/telebaton,
		/obj/item/melee/baton/loaded,
		/obj/item/clothing/accessory/holster/waist,
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
		/obj/item/clothing/head/warden,
		/obj/item/clothing/head/warden/drill,
		/obj/item/clothing/head/beret/sec/corporate/warden,
		/obj/item/clothing/suit/armor/vest/warden_heavy,
		/obj/item/clothing/suit/armor/vest/warden,
		/obj/item/clothing/under/rank/warden,
		/obj/item/clothing/under/rank/warden/corp,
		/obj/item/clothing/glasses/hud/aviators/security,
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/accessory/holster/waist,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/box/teargas,
		/obj/item/storage/belt/security,
		/obj/item/storage/box/chalk,
		/obj/item/storage/box/holobadge,
		/obj/item/taperoll/police,
		/obj/item/device/holowarrant,
		/obj/item/cartridge/security,
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
		/obj/item/device/holowarrant
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
		/obj/item/clothing/glasses/hud/standard/thermal,
		/obj/item/clothing/head/det,
		/obj/item/clothing/head/det/grey,
		/obj/item/clothing/under/det,
		/obj/item/clothing/under/det/grey,
		/obj/item/clothing/under/det/black,
		/obj/item/clothing/suit/storage/toggle/det_trench,
		/obj/item/clothing/suit/storage/toggle/det_trench/grey,
		/obj/item/clothing/suit/storage/toggle/forensics/blue,
		/obj/item/clothing/suit/storage/toggle/forensics/red,
		/obj/item/clothing/suit/armor/vest/detective,
		/obj/item/clothing/gloves/thick,
		/obj/item/clothing/shoes/laceup,
		/obj/item/storage/box/evidence,
		/obj/item/storage/box/chalk,
		/obj/item/device/radio/headset/headset_sec,
		/obj/item/taperoll/police,
		/obj/item/clothing/accessory/holster/armpit,
		/obj/item/reagent_containers/vessel/flask/detflask,
		/obj/item/storage/briefcase/crimekit,
		/obj/item/device/holowarrant,
		/obj/item/storage/secure/guncase/detective
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

	//too small to put a man in
	large = 0

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
