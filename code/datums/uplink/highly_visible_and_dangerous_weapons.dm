/***************************************
* Highly Visible and Dangerous Weapons *
***************************************/
/datum/uplink_item/item/visible_weapons
	category = /datum/uplink_category/visible_weapons

/datum/uplink_item/item/visible_weapons/smallenergy_gun // Needs to be reworked into
	name = "Small Energy Gun"
	desc = "A pocket-sized energy based sidearm with three different lethality settings."
	item_cost = 32
	path = /obj/item/weapon/gun/energy/egun/small

/datum/uplink_item/item/visible_weapons/dartgun
	name = "Dart Gun"
	desc = "A gas-powered dart gun capable of silently delivering chemical payloads across short distances. \
			Uses a unique cartridge loaded with hollow darts."
	item_cost = 32
	path = /obj/item/weapon/gun/projectile/dartgun

/datum/uplink_item/item/visible_weapons/crossbow
	name = "Energy Crossbow"
	desc = "A self-recharging, almost silent weapon employed by stealth operatives."
	item_cost = 40
	path = /obj/item/weapon/gun/energy/crossbow

/datum/uplink_item/item/visible_weapons/g9mm
	name = "Silenced Holdout Pistol"
	item_cost = 32
	path = /obj/item/weapon/storage/box/syndie_kit/g9mm

/datum/uplink_item/item/badassery/money_cannon
	name = "Modified Money Cannon"
	item_cost = 48
	path = /obj/item/weapon/gun/launcher/money/hacked
	desc = "Too much money? Not enough screaming? Try the Money Cannon."

/datum/uplink_item/item/visible_weapons/riggedlaser
	name = "Exosuit (APLU) Rigged Laser"
	item_cost = 32
	path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/riggedlaser

/datum/uplink_item/item/visible_weapons/revolver
	name = "Revolver, .357"
	item_cost = 56
	antag_costs = list(MODE_MERCENARY = 14)
	path = /obj/item/weapon/storage/backpack/satchel/syndie_kit/revolver

//These are for traitors (or other antags, perhaps) to have the option of purchasing some merc gear.
/datum/uplink_item/item/visible_weapons/submachinegun
	name = "C20-r Submachine Gun"
	item_cost = 60
	antag_costs = list(MODE_MERCENARY = 20)
	path = /obj/item/weapon/gun/projectile/automatic/c20r

/*datum/uplink_item/item/visible_weapons/advanced_energy_gun // I'm only leaving it here for history. This is FUCKING HILARIOUS.
	name = "Advanced Energy Gun"
	item_cost = 60
	path = /obj/item/weapon/gun/energy/gun/nuclear
*/

/datum/uplink_item/item/visible_weapons/energy_sword
	name = "Energy Sword"
	item_cost = 60
	antag_costs = list(MODE_MERCENARY = 30)
	path = /obj/item/weapon/melee/energy/sword

/datum/uplink_item/item/visible_weapons/heavysniper
	name = "Anti-materiel Rifle with ammunition"
	item_cost = 60
	antag_roles = list(MODE_MERCENARY)
	path = /obj/item/weapon/storage/secure/briefcase/heavysniper

/datum/uplink_item/item/visible_weapons/machine_pistol
	name = "Machine Pistol"
	item_cost = 25
	antag_roles = list(MODE_MERCENARY)
	path = /obj/item/weapon/gun/projectile/automatic/machine_pistol

/datum/uplink_item/item/visible_weapons/combat_shotgun
	name = "Combat Shotgun"
	item_cost = 40
	antag_roles = list(MODE_MERCENARY)
	path = /obj/item/weapon/gun/projectile/shotgun/pump/combat

/datum/uplink_item/item/visible_weapons/pulsecarbine
	name = "Pulse Carbine"
	item_cost = 40
	antag_roles = list(MODE_MERCENARY)
	path = /obj/item/weapon/gun/energy/pulse_rifle/carbine

/datum/uplink_item/item/visible_weapons/pulserifle
	name = "Pulse Rifle"
	item_cost = 45
	antag_roles = list(MODE_MERCENARY)
	path = /obj/item/weapon/gun/energy/pulse_rifle

/datum/uplink_item/item/visible_weapons/rocketlauncher
	name = "Rocket Launcher"
	item_cost = 40
	antag_roles = list(MODE_MERCENARY)
	path = /obj/item/weapon/gun/launcher/rocket

/datum/uplink_item/item/visible_weapons/flechetterifle
	name = "Flechette Rifle"
	item_cost = 50
	antag_roles = list(MODE_MERCENARY)
	path = /obj/item/weapon/gun/magnetic/railgun/flechette

/datum/uplink_item/item/visible_weapons/ionrifle
	name = "Ion pistol"
	item_cost = 32
	antag_costs = list(MODE_MERCENARY = 15)
	path = /obj/item/weapon/gun/energy/ionrifle/small
