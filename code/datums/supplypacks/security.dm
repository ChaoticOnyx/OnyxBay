/decl/hierarchy/supply_pack/security
	name = "Security"

/decl/hierarchy/supply_pack/security/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb = 3,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 20
	containername = "\improper Special Ops crate"
	hidden = 1

/decl/hierarchy/supply_pack/security/lightarmor
	name = "Armor - Standard"
	contains = list(/obj/item/clothing/suit/armor/vest = 4,
					/obj/item/clothing/head/helmet =4)
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Armor crate"
	access = access_security

/decl/hierarchy/supply_pack/security/armor
	name = "Armor - Modular"
	contains = list(/obj/item/clothing/suit/armor/pcarrier/medium = 2,
					/obj/item/clothing/head/helmet = 2,
					/obj/item/device/radio/headset/tactical = 2)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Modular armor crate"
	access = access_security

/decl/hierarchy/supply_pack/security/blackguards
	name = "Armor - Arm and leg guards, black"
	contains = list(/obj/item/clothing/accessory/armguards = 2,
					/obj/item/clothing/accessory/legguards = 2)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Arm and leg guards crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/blueguards
	name = "Armor - Arm and leg guards, blue"
	contains = list(/obj/item/clothing/accessory/armguards/blue = 2,
					/obj/item/clothing/accessory/legguards/blue = 2)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Arm and leg guards crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/greenguards
	name = "Armor - Arm and leg guards, green"
	contains = list(/obj/item/clothing/accessory/armguards/green = 2,
					/obj/item/clothing/accessory/legguards/green = 2)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Arm and leg guards crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/navyguards
	name = "Armor - Arm and leg guards, navy blue"
	contains = list(/obj/item/clothing/accessory/armguards/navy = 2,
					/obj/item/clothing/accessory/legguards/navy = 2)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Arm and leg guards crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/tanguards
	name = "Armor - Arm and leg guards, tan"
	contains = list(/obj/item/clothing/accessory/armguards/tan = 2,
					/obj/item/clothing/accessory/legguards/tan = 2)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Arm and leg guards crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/riotarmor
	name = "Armor - Riot gear"
	contains = list(/obj/item/shield/riot = 4,
					/obj/item/clothing/head/helmet/riot = 4,
					/obj/item/clothing/suit/armor/riot = 4,
					/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas)
	cost = 80
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Riot armor crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/ballisticarmor
	name = "Armor - Ballistic"
	contains = list(/obj/item/clothing/head/helmet/ballistic = 4,
					/obj/item/clothing/suit/armor/bulletproof = 4)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Ballistic suit crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/ablativearmor
	name = "Armor - Ablative"
	contains = list(/obj/item/clothing/head/helmet/ablative = 4,
					/obj/item/clothing/suit/armor/laserproof = 4)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Ablative suit crate"
	access = access_armory

/decl/hierarchy/supply_pack/security/voidsuit
	name = "Armor - Security voidsuit"
	contains = list(/obj/item/clothing/suit/space/void/security/alt,
					/obj/item/clothing/head/helmet/space/void/security/alt,
					/obj/item/clothing/shoes/magboots)
	cost = 120
	containername = "\improper Security voidsuit crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_brig

/decl/hierarchy/supply_pack/security/rig
	name = "Armor - Security RIG"
	contains = list(/obj/item/rig/security)
	cost = 480
	containername = "\improper Security RIG crate"
	containertype = /obj/structure/closet/crate/secure
	access = access_brig

/decl/hierarchy/supply_pack/security/weapons
	name = "Weapons - Security basic"
	contains = list(/obj/item/device/flash = 4,
					/obj/item/reagent_containers/spray/pepper = 4,
					/obj/item/storage/secure/guncase/security = 4)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Weapons crate"
	access = access_security

/decl/hierarchy/supply_pack/security/nonlethal
	name = "Weapons - Non-lethal energy weapons"
	contains = list(/obj/item/gun/energy/taser/carbine = 2,
					/obj/item/gun/energy/stunrevolver/rifle = 2)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Non-lethal energy weapons crate"
	access = access_security

/decl/hierarchy/supply_pack/security/egun
	name = "Weapons - Energy sidearms"
	contains = list(/obj/item/gun/energy/egun = 4)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Energy sidearms crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_ELEVATED

/decl/hierarchy/supply_pack/security/laser
	name = "Weapons - Laser carbines"
	contains = list(/obj/item/gun/energy/laser = 2)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Laser carbines crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_ELEVATED

/decl/hierarchy/supply_pack/security/marksman
	name = "Weapons - Energy marksman rifles"
	contains = list(/obj/item/gun/energy/sniperrifle = 2)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Energy marksman rifles crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_HIGH

/decl/hierarchy/supply_pack/security/ion
	name = "Weapons - Electromagnetic"
	contains = list(/obj/item/gun/energy/ionrifle,
					/obj/item/gun/energy/ionrifle/small,
					/obj/item/storage/box/emps)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Electromagnetic weapons crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_ELEVATED

/decl/hierarchy/supply_pack/security/pistol
	name = "Weapons - Ballistic sidearms"
	contains = list(/obj/item/gun/projectile/pistol/vp78 = 4)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Ballistic sidearms crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_ELEVATED

/decl/hierarchy/supply_pack/security/shotgun
	name = "Weapons - Shotgun"
	contains = list(/obj/item/gun/projectile/shotgun/pump = 2)
	cost = 70
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Shotgun crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_HIGH

/decl/hierarchy/supply_pack/security/smg
	name = "Weapons - SMG"
	contains = list(/obj/item/gun/projectile/automatic/wt550 = 2)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper SMG crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_HIGH

/decl/hierarchy/supply_pack/security/rifle
	name = "Weapons - Ballistic rifles"
	contains = list(/obj/item/gun/projectile/automatic/z8 = 2)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Ballistic rifles crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_HIGH

/decl/hierarchy/supply_pack/security/flashbang
	name = "Weapons - Flashbangs"
	contains = list(/obj/item/storage/box/flashbangs = 2)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Flashbang crate"
	access = access_security

/decl/hierarchy/supply_pack/security/teargas
	name = "Weapons - Tear gas grenades"
	contains = list(/obj/item/storage/box/teargas = 2)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Tear gas grenades crate"
	access = access_security

/decl/hierarchy/supply_pack/security/frag
	name = "Weapons - Frag grenades"
	contains = list(/obj/item/storage/box/frags = 2)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Frag grenades crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_HIGH

/decl/hierarchy/supply_pack/security/pistolammo
	name = "Ammunition - .45 magazines"
	contains = list(/obj/item/ammo_magazine/c45m = 4)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper .45 ammunition crate"
	access = access_security
	security_level = SUPPLY_SECURITY_ELEVATED

/decl/hierarchy/supply_pack/security/pistolammorubber
	name = "Ammunition - .45 rubber"
	contains = list(/obj/item/ammo_magazine/c45m/rubber = 4)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper .45 rubber ammunition crate"
	access = access_security

/decl/hierarchy/supply_pack/security/pistolammostun
	name = "Ammunition - .45 stun"
	contains = list(/obj/item/ammo_magazine/c45m/stun = 4)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper .45 stun ammunition crate"
	access = access_security

/decl/hierarchy/supply_pack/security/pistolammopractice
	name = "Ammunition - .45 practice"
	contains = list(/obj/item/ammo_magazine/c45m/practice = 8)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper .45 practice ammunition crate"
	access = access_security

/decl/hierarchy/supply_pack/security/shotgunammo
	name = "Ammunition - Lethal shells"
	contains = list(/obj/item/storage/box/shotgun/slugs = 2,
					/obj/item/storage/box/shotgun/shells = 2)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Lethal shotgun shells crate"
	access = access_security
	security_level = SUPPLY_SECURITY_ELEVATED

/decl/hierarchy/supply_pack/security/shotgunbeanbag
	name = "Ammunition - Beanbag shells"
	contains = list(/obj/item/storage/box/shotgun/beanbags = 3)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Beanbag shotgun shells crate"
	access = access_security

/decl/hierarchy/supply_pack/security/pdwammo
	name = "Ammunition - 9mm top mounted"
	contains = list(/obj/item/ammo_magazine/mc9mmt = 4)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper 9mm ammunition crate"
	access = access_security
	security_level = SUPPLY_SECURITY_HIGH

/decl/hierarchy/supply_pack/security/pdwammorubber
	name = "Ammunition - 9mm top mounted rubber"
	contains = list(/obj/item/ammo_magazine/mc9mmt/rubber = 4)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper 9mm rubber ammunition crate"
	access = access_security

/decl/hierarchy/supply_pack/security/pdwammopractice
	name = "Ammunition - 9mm top mounted practice"
	contains = list(/obj/item/ammo_magazine/mc9mmt/practice = 8)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper 9mm practice ammunition crate"
	access = access_security

/decl/hierarchy/supply_pack/security/bullpupammo
	name = "Ammunition - 7.62"
	contains = list(/obj/item/ammo_magazine/a762 = 4)
	cost = 60
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper 7.62 ammunition crate"
	access = access_security
	security_level = SUPPLY_SECURITY_HIGH

/decl/hierarchy/supply_pack/security/bullpupammopractice
	name = "Ammunition - 7.62 practice"
	contains = list(/obj/item/ammo_magazine/a762/practice = 8)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper 7.62 practice ammunition crate"
	access = access_security

/decl/hierarchy/supply_pack/security/c38spec
	name = "Ammunition - .38 SPEC 3in1"
	contains = list(/obj/item/ammo_magazine/c38/spec = 3)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper .38 SPEC ammunition crate"
	access = access_forensics_lockers

/decl/hierarchy/supply_pack/security/c38chem
	name = "Ammunition - .38 CHEM 3in1"
	contains = list(/obj/item/ammo_magazine/c38/chem = 3)
	cost = 45
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper .38 CHEM ammunition crate"
	access = access_forensics_lockers

/decl/hierarchy/supply_pack/security/forensics //Not access-restricted so PIs can use it.
	name = "Forensics - Auxiliary tools"
	contains = list(/obj/item/forensics/sample_kit,
					/obj/item/forensics/sample_kit/powder,
					/obj/item/storage/box/swabs = 3,
					/obj/item/reagent_containers/spray/luminol)
	cost = 30
	containername = "\improper Auxiliary forensic tools crate"

/decl/hierarchy/supply_pack/security/detectivegear
	name = "Forensics - investigation equipment"
	contains = list(/obj/item/storage/box/evidence = 2,
					/obj/item/cartridge/detective,
					/obj/item/device/radio/headset/headset_sec,
					/obj/item/taperoll/police,
					/obj/item/clothing/glasses/sunglasses,
					/obj/item/device/camera,
					/obj/item/folder/red,
					/obj/item/folder/blue,
					/obj/item/clothing/gloves/forensic,
					/obj/item/device/taperecorder,
					/obj/item/device/mass_spectrometer,
					/obj/item/device/camera_film = 2,
					/obj/item/storage/photo_album,
					/obj/item/device/reagent_scanner,
					/obj/item/storage/briefcase/crimekit = 2)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Forensic equipment crate"
	access = access_forensics_lockers

/decl/hierarchy/supply_pack/security/securitybarriers
	name = "Misc - Barrier crate"
	contains = list(/obj/structure/barricade/security = 4)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/large
	containername = "\improper Security barrier crate"
	access = access_security

/decl/hierarchy/supply_pack/security/securitybarriers
	name = "Misc - Wall shield Generators"
	contains = list(/obj/machinery/shieldwallgen = 2)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/large
	containername = "\improper wall shield generators crate"
	access = access_brig

/decl/hierarchy/supply_pack/security/securitybiosuit
	name = "Misc - Security biohazard gear"
	contains = list(/obj/item/clothing/head/bio_hood/security,
					/obj/item/clothing/suit/bio_suit/security,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/oxygen,
					/obj/item/clothing/gloves/latex)
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Security biohazard gear crate"
	access = access_security

/decl/hierarchy/supply_pack/security/surplusfirearms
	name = "Weapons - Surplus firearms"
	contains = list(/obj/item/gun/projectile/bolt_action = 2,
					/obj/item/gun/projectile/bolt_action/mauser = 2,
					/obj/item/ammo_magazine/c792 = 4
					)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Surplus Firearms"
	access = access_security
	security_level = SUPPLY_SECURITY_ELEVATED

/decl/hierarchy/supply_pack/security/surplusammo
	name = "Misc - Surplus ammo"
	contains = list(/obj/item/ammo_magazine/c792 = 8)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Surplus Ammo"
	access = access_security
	security_level = SUPPLY_SECURITY_ELEVATED