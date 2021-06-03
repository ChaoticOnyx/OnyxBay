/***************************************
* Highly Visible and Dangerous Weapons *
***************************************/
/datum/uplink_item/item/visible_weapons
	category = /datum/uplink_category/visible_weapons

/datum/uplink_item/item/visible_weapons/dartgun
	name = "Dart Gun"
	desc = "A gas-powered dart gun capable of delivering chemical payloads across short distances. \
			Uses unique cartridges loaded with hollow darts."
	item_cost = 5
	path = /obj/item/weapon/gun/projectile/dartgun

/datum/uplink_item/item/visible_weapons/riggedlaser
	name = "Exosuit (APLU) Rigged Laser"
	desc = "An old, but reliable mining laser. Not as powerful as combat mecha lasers, it can be mounted on an APLU."
	item_cost = 5
	path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/riggedlaser

/datum/uplink_item/item/visible_weapons/smallenergy_gun
	name = "Small Energy Gun"
	desc = "A pocket-sized energy based sidearm with two options: stun and kill."
	item_cost = 5
	path = /obj/item/weapon/gun/energy/gun/small

/datum/uplink_item/item/badassery/money_cannon
	name = "Modified Money Cannon"
	desc = "Too much money? Not enough screaming? Try the Money Cannon."
	item_cost = 6
	path = /obj/item/weapon/gun/launcher/money/hacked

/datum/uplink_item/item/visible_weapons/ionpistol
	name = "Ion pistol"
	item_cost = 6
	antag_costs = list(MODE_NUKE = 5)
	path = /obj/item/weapon/gun/energy/ionrifle/small

/datum/uplink_item/item/visible_weapons/sawnoff
	name = "Sawnoff Shotgun"
	desc = "A sawed-off double-barreled shotgun."
	item_cost = 6
	antag_costs = list(MODE_NUKE = 3)
	path = /obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawn

/datum/uplink_item/item/visible_weapons/g9mm
	name = "Silenced Pistol"
	desc = "A 9mm pistol with silencer kit and ammunition."
	item_cost = 6
	antag_costs = list(MODE_NUKE = 4)
	path = /obj/item/weapon/storage/box/syndie_kit/g9mm

/datum/uplink_item/item/visible_weapons/crossbow
	name = "Energy Crossbow"
	desc = "A self-recharging, almost silent weapon employed by stealth operatives."
	item_cost = 6
	path = /obj/item/weapon/gun/energy/crossbow

/datum/uplink_item/item/visible_weapons/revolver
	name = "Revolver"
	desc = "A classic .357 relover. Trusty, deadly, loud as hell, it assures everyone around that you work for the Syndicate."
	item_cost = 7
	antag_costs = list(MODE_NUKE = 4)
	path = /obj/item/weapon/storage/backpack/satchel/syndie_kit/revolver

/datum/uplink_item/item/visible_weapons/energy_sword
	name = "Energy Sword"
	item_cost = 8
	antag_costs = list(MODE_NUKE = 6)
	path = /obj/item/weapon/melee/energy/sword/one_hand

/datum/uplink_item/item/visible_weapons/submachinegun
	name = "Submachine Gun"
	item_cost = 12
	antag_costs = list(MODE_NUKE = 6)
	path = /obj/item/weapon/gun/projectile/automatic/c20r

// Nuke-only guns below
/datum/uplink_item/item/visible_weapons/energy_gun
	name = "Energy Gun"
	desc = "A generic energy gun."
	item_cost = 5
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/gun/energy/egun

/datum/uplink_item/item/visible_weapons/assaultrifle
	name = "Assault Rifle"
	item_cost = 6
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/gun/projectile/automatic/sts35

/datum/uplink_item/item/visible_weapons/heavysniper
	name = "Anti-materiel Rifle"
	desc = "A 14.5mm heavy sniper rifle and ammunition."
	item_cost = 10
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/storage/secure/briefcase/heavysniper

/datum/uplink_item/item/visible_weapons/combat_shotgun
	name = "Combat Shotgun"
	desc = "A combat shotgun."
	item_cost = 7
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/gun/projectile/shotgun/pump/combat

/datum/uplink_item/item/visible_weapons/pulsecarbine
	name = "Pulse Carbine"
	item_cost = 9
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/gun/energy/pulse_rifle/carbine

/datum/uplink_item/item/visible_weapons/grenade_launcher
	name = "Grenade Launcher"
	item_cost = 3
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/gun/launcher/grenade/loaded

/datum/uplink_item/item/visible_weapons/rocketlauncher
	name = "Rocket Launcher"
	item_cost = 7
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/gun/launcher/rocket

/datum/uplink_item/item/visible_weapons/flechetterifle
	name = "Flechette Rifle"
	item_cost = 9
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/gun/magnetic/railgun/flechette
