/**********
* Medical *
**********/
/datum/uplink_item/item/medical
	category = /datum/uplink_category/medical

/datum/uplink_item/item/medical/sinpockets
	name = "Box of Sin-Pockets"
	item_cost = 2
	path = /obj/item/weapon/storage/box/sinpockets

/datum/uplink_item/item/medical/stasis
	name = "Modified Stasis Bag"
	item_cost = 2
	path = /obj/item/bodybag/cryobag/syndi

/datum/uplink_item/item/medical/defib
	name = "Combat Defibrillator"
	item_cost = 3
	path = /obj/item/weapon/defibrillator/compact/combat/loaded

/datum/uplink_item/item/medical/combat
	name = "Combat medical kit"
	item_cost = 3
	path = /obj/item/weapon/storage/firstaid/combat

/datum/uplink_item/item/medical/surgery
	name = "Surgery kit"
	item_cost = 3
	path = /obj/item/weapon/storage/firstaid/surgery/syndie

/datum/uplink_item/item/medical/serum
	name = "Resurrection Serum"
	desc = "One-use injector filled with a substance capable of bringing corpses back to life."
	item_cost = DEFAULT_TELECRYSTAL_AMOUNT
	path = /obj/item/stack/medical/advanced/resurrection_serum
	antag_roles = list(MODE_NUKE)
