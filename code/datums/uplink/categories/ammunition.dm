/*************
* Ammunition *
*************/
/datum/uplink_item/item/ammo
	category = /datum/uplink_category/ammunition
	item_cost = 1

/datum/uplink_item/item/ammo/c45m
	name = ".45 Magazine"
	item_cost = 1
	path = /obj/item/ammo_magazine/c45m

/datum/uplink_item/item/ammo/mc9mm
	name = "9mm Magazine"
	item_cost = 1
	path = /obj/item/ammo_magazine/mc9mm

/datum/uplink_item/item/ammo/a10mm
	name = "10mm Magazine"
	item_cost = 1
	path = /obj/item/ammo_magazine/a10mm

/datum/uplink_item/item/ammo/darts
	name = "Darts"
	item_cost = 1
	path = /obj/item/ammo_magazine/chemdart

/datum/uplink_item/item/ammo/a357
	name = ".357 Speedloader"
	item_cost = 2
	path = /obj/item/ammo_magazine/a357

/datum/uplink_item/item/ammo/a556
	name = "5.56mm Magazine"
	item_cost = 2
	path = /obj/item/ammo_magazine/c556

/datum/uplink_item/item/ammo/bullpup //for zipguns
	name = "7.62 Magazine"
	item_cost = 2
	path = /obj/item/ammo_magazine/a762

/datum/uplink_item/item/ammo/shotgun_shells
	name = "Shotgun Shells box"
	item_cost = 2
	path = /obj/item/storage/box/shotgun/shells

/datum/uplink_item/item/ammo/shotgun_slugs
	name = "Shotgun Slugs box"
	item_cost = 2
	path = /obj/item/storage/box/shotgun/slugs

/datum/uplink_item/item/ammo/c45uzi
	name = ".45 SMG Magazine"
	item_cost = 2
	path = /obj/item/ammo_magazine/c45uzi

/datum/uplink_item/item/ammo/a50
	name = ".50 AE Magazine"
	item_cost = 3
	path = /obj/item/ammo_magazine/a50

/datum/uplink_item/item/ammo/c50
	name = ".50 AE Speedloader"
	item_cost = 3
	path = /obj/item/ammo_magazine/c50

/datum/uplink_item/item/ammo/c38
	name = ".38 Speedloader"
	item_cost = 1
	path = /obj/item/ammo_magazine/c38

// Nuke-only ammo below
/datum/uplink_item/item/ammo/a556box
	name = "5.56mm Magazine Box"
	item_cost = 3
	antag_roles = list(MODE_NUKE)
	path = /obj/item/ammo_magazine/box/a556

/datum/uplink_item/item/ammo/rocket
	name = "Rocket"
	item_cost = 2
	antag_roles = list(MODE_NUKE)
	path = /obj/item/ammo_casing/rocket

/datum/uplink_item/item/ammo/sniperammo
	name = "14.5mm"
	item_cost = 3
	antag_roles = list(MODE_NUKE)
	path = /obj/item/storage/box/sniperammo

/datum/uplink_item/item/ammo/sniperammo/apds
	name = "14.5mm APDS"
	item_cost = 4
	antag_roles = list(MODE_NUKE)
	path = /obj/item/storage/box/sniperammo/apds

/datum/uplink_item/item/ammo/flechette
	name = "Flechette Magazine"
	item_cost = 3
	antag_roles = list(MODE_NUKE)
	path = /obj/item/rcd_ammo/magnetic_ammo
