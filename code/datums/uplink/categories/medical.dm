/**********
* Medical *
**********/
/datum/uplink_item/item/medical
	category = /datum/uplink_category/medical

/datum/uplink_item/item/medical/sinpockets
	name = "Box of Sin-Pockets"
	desc = "The healthiest snack around, only for the best. Don't you forget to heat it up!"
	item_cost = 2
	path = /obj/item/storage/box/sinpockets

/datum/uplink_item/item/medical/stasis
	name = "Modified Stasis Bag"
	desc = "Unlike a regular stasis bag, this one actually heals whomever lies inside."
	item_cost = 2
	path = /obj/item/bodybag/cryobag/syndi

/datum/uplink_item/item/medical/defib
	name = "Combat Defibrillator"
	desc = "Capable of restarting people's hearts. Or stopping them, if you will."
	item_cost = 3
	path = /obj/item/defibrillator/compact/combat/loaded

/datum/uplink_item/item/medical/combat
	name = "Combat medical kit"
	desc = "Filled with a range of helpful drugs."
	item_cost = 3
	path = /obj/item/storage/firstaid/combat

/datum/uplink_item/item/medical/surgery
	name = "Surgery kit"
	desc = "Filled with everything you need to reattach limbs and remove shrapnels."
	item_cost = 3
	path = /obj/item/storage/firstaid/surgery/syndie

/datum/uplink_item/item/medical/serum
	name = "Resurrection Serum"
	desc = "One-use injector filled with a substance capable of bringing corpses back to life."
	item_cost = DEFAULT_TELECRYSTAL_AMOUNT
	path = /obj/item/stack/medical/advanced/resurrection_serum
	antag_roles = list(MODE_NUKE)
