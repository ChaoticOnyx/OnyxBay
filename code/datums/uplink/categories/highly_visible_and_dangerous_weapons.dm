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
	path = /obj/item/gun/projectile/dartgun

/datum/uplink_item/item/visible_weapons/riggedlaser
	name = "Exosuit (APLU) Rigged Laser"
	desc = "An old, but reliable mining laser. Not as powerful as combat mecha lasers, it can be mounted on an APLU."
	item_cost = 5
	path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/riggedlaser

/datum/uplink_item/item/visible_weapons/smallenergy_gun
	name = "Small Energy Gun"
	desc = "A pocket-sized energy based sidearm with two options: stun and kill."
	item_cost = 5
	path = /obj/item/gun/energy/gun/small

/datum/uplink_item/item/badassery/money_cannon
	name = "Modified Money Cannon"
	desc = "Too much money? Not enough screaming? Try the Money Cannon."
	item_cost = 6
	path = /obj/item/gun/launcher/money/hacked

/datum/uplink_item/item/visible_weapons/chainsaw
	name = "Chainsaw"
	desc = "BRRR-BRRR-BRRR!"
	item_cost = 5
	path = /obj/item/storage/backpack/dufflebag/syndie_kit/chainsaw

/datum/uplink_item/item/visible_weapons/ionpistol
	name = "Ion pistol"
	item_cost = 6
	antag_costs = list(MODE_NUKE = 5)
	path = /obj/item/gun/energy/ionrifle/small

/datum/uplink_item/item/visible_weapons/sawnoff
	name = "Sawnoff Shotgun"
	desc = "A sawed-off double-barreled shotgun."
	item_cost = 6
	antag_costs = list(MODE_NUKE = 4)
	path = /obj/item/gun/projectile/shotgun/doublebarrel/sawn

/datum/uplink_item/item/visible_weapons/g9mm
	name = "Silenced Pistol"
	desc = "A 9mm pistol with silencer kit and ammunition."
	item_cost = 6
	antag_costs = list(MODE_NUKE = 4)
	path = /obj/item/storage/box/syndie_kit/g9mm

/datum/uplink_item/item/visible_weapons/crossbow
	name = "Energy Crossbow"
	desc = "A self-recharging, almost silent weapon employed by stealth operatives."
	item_cost = 6
	path = /obj/item/gun/energy/crossbow

/datum/uplink_item/item/visible_weapons/revolver
	name = "Revolver"
	desc = "A classic .357 relover. Trusty, deadly, loud as hell, it assures everyone around that you work for the Syndicate."
	item_cost = 7
	antag_costs = list(MODE_NUKE = 4)
	path = /obj/item/storage/backpack/satchel/syndie_kit/revolver

/datum/uplink_item/item/visible_weapons/energy_sword
	name = "Energy Sword"
	desc = "One of the best melee weapons known to the mankind, it can turn a living being into something less living and less being in just a few swings. It is also capable of reflecting any projectiles. Just don't forget to turn it on."
	item_cost = 8
	antag_costs = list(MODE_NUKE = 6)
	path = /obj/item/melee/energy/sword/one_hand

/datum/uplink_item/item/visible_weapons/submachinegun
	name = "Submachine Gun"
	desc = "C20-r, the standard issue 10mm submachine gun given to Syndicate Nuclear Ops. Rapid-firing, accurate, and unbeliveably lethal."
	item_cost = 12
	antag_costs = list(MODE_NUKE = 6)
	path = /obj/item/gun/projectile/automatic/c20r

// Nuke-only guns below
/datum/uplink_item/item/visible_weapons/energy_gun
	name = "Energy Gun"
	desc = "A generic energy gun."
	item_cost = 5
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/energy/egun

/datum/uplink_item/item/visible_weapons/assaultrifle
	name = "Assault Rifle"
	desc = "5.56mm assault rifle. Trusty, quite powerful, but requires excessive amount of praying while spraying."
	item_cost = 7
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/projectile/automatic/as75

/datum/uplink_item/item/visible_weapons/heavysniper
	name = "Anti-materiel Rifle"
	desc = "A 14.5mm heavy sniper rifle and ammunition."
	item_cost = 13
	antag_roles = list(MODE_NUKE)
	path = /obj/item/storage/secure/briefcase/heavysniper

/datum/uplink_item/item/visible_weapons/machinegun
	name = "Light Machine Gun"
	desc = "L6 SAW, a 5.56mm light machine gun, loaded with a 60-round box. Can also be loaded with standard 5.56 magazines."
	item_cost = 12
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/projectile/automatic/l6_saw

/datum/uplink_item/item/visible_weapons/combat_shotgun
	name = "Combat Shotgun"
	desc = "A combat shotgun. Useful for blowing people across the room Italian style."
	item_cost = 7
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/projectile/shotgun/pump/combat

/datum/uplink_item/item/visible_weapons/pulsecarbine
	name = "Pulse Carbine"
	desc = "A lightweight, rapid-firing pulse carbine."
	item_cost = 10
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/energy/pulse_rifle/carbine

/datum/uplink_item/item/visible_weapons/grenade_launcher
	name = "Grenade Launcher"
	desc = "In fact, it's just a slingshot for grenades. However, this thing might come in handy when used with fragmentation shells."
	item_cost = 3
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/launcher/grenade/loaded

/datum/uplink_item/item/visible_weapons/rocketlauncher
	name = "Rocket Launcher"
	desc = "Don't even try to perform rocket jumping."
	item_cost = 7
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/launcher/rocket

/datum/uplink_item/item/visible_weapons/flechetterifle
	name = "Flechette Rifle"
	item_cost = 10
	antag_roles = list(MODE_NUKE)
	path = /obj/item/gun/magnetic/railgun/flechette
