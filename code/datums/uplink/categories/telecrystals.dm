/***************
* Telecrystals *
***************/
/datum/uplink_item/item/telecrystal
	category = /datum/uplink_category/telecrystals
	desc = "Acquire the uplink crystals in pure form."

/datum/uplink_item/item/telecrystal/get_goods(obj/item/device/uplink/U, loc)
	return new /obj/item/stack/telecrystal(loc, cost(U.uses, U))

/datum/uplink_item/item/telecrystal/one
	name = "Telecrystal - 1"
	item_cost = 1

/datum/uplink_item/item/telecrystal/three
	name = "Telecrystals - 3"
	item_cost = 3

/datum/uplink_item/item/telecrystal/six
	name = "Telecrystals - 6"
	item_cost = 6

/datum/uplink_item/item/telecrystal/twelve
	name = "Telecrystals - 12"
	item_cost = 12

/datum/uplink_item/item/telecrystal/all
	name = "Telecrystals - Empty Uplink"

/datum/uplink_item/item/telecrystal/all/cost(telecrystals, obj/item/device/uplink/U)
	return max(1, telecrystals)
