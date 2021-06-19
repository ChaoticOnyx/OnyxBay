/***********
* Grenades *
************/
/datum/uplink_item/item/grenades
	category = /datum/uplink_category/grenades

/datum/uplink_item/item/grenades/anti_photon
	name = "Photon Disruption Grenade"
	item_cost = 1
	path = /obj/item/weapon/grenade/anti_photon

/datum/uplink_item/item/grenades/anti_photons
	name = "5 Photon Disruption Grenades"
	item_cost = 4
	path = /obj/item/weapon/storage/box/anti_photons

/datum/uplink_item/item/grenades/smoke
	name = "Smoke Grenade"
	item_cost = 1
	path = /obj/item/weapon/grenade/smokebomb

/datum/uplink_item/item/grenades/smokes
	name = "5 Smoke Grenades"
	item_cost = 4
	path = /obj/item/weapon/storage/box/smokes

/datum/uplink_item/item/grenades/emp
	name = "EMP Grenade"
	item_cost = 2
	path = /obj/item/weapon/grenade/empgrenade

/datum/uplink_item/item/grenades/emps
	name = "5 EMP Grenades"
	item_cost = 8
	path = /obj/item/weapon/storage/box/emps

/datum/uplink_item/item/grenades/manhack
	name = "Manhack Delivery Grenade"
	desc = "Releases a swarm of murderous manhacks. Be careful, they will be more than happy to chop YOU as well."
	item_cost = 3
	path = /obj/item/weapon/grenade/spawnergrenade/manhacks

/datum/uplink_item/item/grenades/frag_high_yield
	name = "Fragmentation Bomb"
	item_cost = 2
	antag_roles = list(MODE_NUKE) // yeah maybe regular traitors shouldn't be able to get these
	path = /obj/item/weapon/grenade/frag/high_yield

/datum/uplink_item/item/grenades/frag
	name = "Fragmentation Grenade"
	item_cost = 1
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/grenade/frag

/datum/uplink_item/item/grenades/frags
	name = "5 Fragmentation Grenades"
	item_cost = 4
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/storage/box/frags

/datum/uplink_item/item/grenades/supermatter
	name = "Supermatter Grenade"
	desc = "This grenade contains a small supermatter shard which will delaminate upon activation and pull in nearby objects, irradiate lifeforms, and eventually explode."
	item_cost = 2
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/grenade/supermatter

/datum/uplink_item/item/grenades/supermatters
	name = "5 Supermatter Grenades"
	desc = "These grenades contains a small supermatter shard which will delaminate upon activation and pull in nearby objects, irradiate lifeforms, and eventually explode."
	item_cost = 8
	antag_roles = list(MODE_NUKE)
	path = /obj/item/weapon/storage/box/supermatters
