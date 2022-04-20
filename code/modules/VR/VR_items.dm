GLOBAL_LIST_EMPTY(thunderfield_items)

/proc/get_thunderfield_items()
	if(!GLOB.thunderfield_items.len)
		for(var/item in typesof(/datum/thunderfield_item))
			var/datum/thunderfield_item/I = new item()
			if(!I.item)
				continue
			GLOB.thunderfield_items += I
	return GLOB.thunderfield_items

/datum/thunderfield_item
	var/name = "item name"
	var/category = "item category"
	var/item = null
	var/cost = 0

/datum/thunderfield_item/colt_pistol
	name = "Colt pistol"
	item = /obj/item/gun/projectile/revolver/coltpython
	cost = 2

/datum/thunderfield_item/colt_pistol_magazine
	name = ".357 magazine"
	item = /obj/item/ammo_magazine/a357
	cost = 1

/datum/thunderfield_item/sts_gun
	name = "AS-75 automatic gun"
	item = /obj/item/gun/projectile/automatic/as75
	cost = 3

/datum/thunderfield_item/sts_gun_magazine
	name = "STS-35 magazine"
	item = /obj/item/ammo_magazine/c556
	cost = 2

/datum/thunderfield_item/uzi_gun
	name = "UZI"
	item = /obj/item/gun/projectile/automatic/machine_pistol
	cost = 5

/datum/thunderfield_item/uzi_gun_magazine
	name = "UZI magazine"
	item =  /obj/item/ammo_magazine/c45uzi
	cost = 3

/datum/thunderfield_item/shotgun
	name = "Shotgun"
	item = /obj/item/gun/projectile/shotgun/pump/combat
	cost = 6

/datum/thunderfield_item/shotgun_magazine
	name = "Shotgun ammo"
	item = /obj/item/storage/box/shotgun/slugs
	cost = 4

/datum/thunderfield_item/l6_gun
	name = "L6 S A W "
	item = /obj/item/gun/projectile/automatic/l6_saw/mag
	cost = 11

/datum/thunderfield_item/l6_gun_magazine
	name = "L6 magazine"
	item = /obj/item/ammo_magazine/c556
	cost = 2

/datum/thunderfield_item/gyro_gun
	name = "Gyro pystol"
	item = /obj/item/gun/projectile/pistol/gyropistol
	cost = 7

/datum/thunderfield_item/gyro_gun_magazine
	name = "Gyro ammo"
	item = /obj/item/ammo_magazine/a75
	cost = 3

/datum/thunderfield_item/toolbox
	name = "Toolbox"
	item = /obj/item/storage/toolbox
	cost = 0

/datum/thunderfield_item/extinguisher
	name = "Fire extinguisher"
	item = /obj/item/extinguisher
	cost = 0

/datum/thunderfield_item/hatchet
	name = "Small hatchet"
	item = /obj/item/material/hatchet
	cost = 0

/datum/thunderfield_item/telescopic
	name = "Telescopic baton"
	item = /obj/item/melee/telebaton
	cost = 1

/datum/thunderfield_item/fireaxe
	name = "Fire axe"
	item = /obj/item/material/twohanded/fireaxe
	cost = 2

/datum/thunderfield_item/medkit
	name = "Advanced medkit"
	item = /obj/item/storage/firstaid/adv
	cost = 2

/datum/thunderfield_item/backpack
	name = "Backpack"
	item = /obj/item/storage/backpack
	cost = 1

/datum/thunderfield_item/belt
	name = "Combat belt"
	item = /obj/item/storage/belt/military
	cost = 1

/datum/thunderfield_item/medkit
	name = "Combat medkit"
	item = /obj/item/storage/firstaid/combat
	cost = 2

/datum/thunderfield_item/thermal
	name = "Thermal glasses"
	item = /obj/item/clothing/glasses/hud/standard/thermal/syndie
	cost = 9

/datum/thunderfield_item/armor
	name = "Armor"
	item = /obj/item/clothing/suit/armor/vest
	cost = 3

/datum/thunderfield_item/helmet
	name = "Helmet"
	item = /obj/item/clothing/head/helmet
	cost = 3

/datum/thunderfield_item/barmor
	name = "Bulletproof armor"
	item = /obj/item/clothing/suit/armor/bulletproof
	cost = 4

/datum/thunderfield_item/bhelmet
	name = "Bulletproof helmet"
	item = /obj/item/clothing/head/helmet/ballistic
	cost = 4
