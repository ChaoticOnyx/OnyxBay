/************
* Badassery *
************/
/datum/uplink_item/item/badassery
	category = /datum/uplink_category/badassery

/datum/uplink_item/item/badassery/balloon
	name = "For showing that You Are The BOSS"
	desc = "A beautiful balloon."
	item_cost = DEFAULT_TELECRYSTAL_AMOUNT
	path = /obj/item/toy/balloon

/datum/uplink_item/item/badassery/balloon/NT
	name = "For showing that you love NT SOO much"
	path = /obj/item/toy/balloon/nanotrasen

/datum/uplink_item/item/badassery/balloon/snail
	name = "For showing that you know what you're doing"
	path = /obj/item/toy/balloon/snail

/datum/uplink_item/item/badassery/balloon/random
	name = "For showing 'Whatevah~'"
	desc = "Randomly selects a ballon for you!"
	path = /obj/item/toy/balloon

/datum/uplink_item/item/badassery/balloon/random/get_goods(datum/component/uplink/U, loc)
	var/balloon_type = pick(typesof(path))
	var/obj/item/I = new balloon_type(loc)
	return I

/datum/uplink_item/item/badassery/food/packaged/surstromming
	name = "Old canned food"
	desc = "Default operative field food ration for your needs."
	path = /obj/item/reagent_containers/food/packaged/surstromming
	item_cost = 2

/datum/uplink_item/item/badassery/lighter
	name = "For lighting cigarettes in a badass manner"
	desc = "An extremely fancy zippo lighter. Only Syndicate members are properly trained to deal with such a fashionable thing."
	item_cost = DEFAULT_TELECRYSTAL_AMOUNT - 1
	path = /obj/item/flame/lighter/zippo/syndie

/datum/uplink_item/item/badassery/stamp
	name = "For showing that You Love Bureaucracy"
	desc = "A beautiful stamp."
	item_cost = DEFAULT_TELECRYSTAL_AMOUNT/2
	path = /obj/item/stamp/syndicate

/**************
* Random Item *
**************/
/datum/uplink_item/item/badassery/random_one
	name = "Random Item"
	desc = "Buys you a random item for at least 1TC. Careful: No upper price cap!"
	item_cost = 1

/datum/uplink_item/item/badassery/random_one/buy(datum/component/uplink/U, mob/user)
	var/datum/uplink_random_selection/uplink_selection = get_uplink_random_selection_by_type(/datum/uplink_random_selection/default)
	var/datum/uplink_item/item = uplink_selection.get_random_item(U.telecrystals, U)
	return item && item.buy(U, user)

/datum/uplink_item/item/badassery/random_one/can_buy(datum/component/uplink/U)
	return U.telecrystals

/datum/uplink_item/item/badassery/random_many
	name = "Random Items"
	desc = "Buys you as many random items as you can afford. Convenient packaging NOT included!"

/datum/uplink_item/item/badassery/random_many/cost(telecrystals, datum/component/uplink/U)
	return max(1, telecrystals)

/datum/uplink_item/item/badassery/random_many/get_goods(datum/component/uplink/U, loc)
	var/list/bought_items = list()
	for(var/datum/uplink_item/UI in get_random_uplink_items(U, U.telecrystals, loc))
		UI.purchase_log(U)
		var/obj/item/I = UI.get_goods(U, loc)
		if(istype(I))
			bought_items += I

	return bought_items

/datum/uplink_item/item/badassery/random_many/purchase_log(datum/component/uplink/U)
	feedback_add_details("traitor_uplink_items_bought", "[src]")
	log_and_message_admins("used \the [U.parent] to buy \a [src]")

/****************
* Surplus Crate *
****************/
/datum/uplink_item/item/badassery/surplus
	name = "Surplus Crate"
	item_cost = DEFAULT_TELECRYSTAL_AMOUNT * 2
	var/item_worth = DEFAULT_TELECRYSTAL_AMOUNT * 3
	var/icon

/datum/uplink_item/item/badassery/surplus/New()
	..()
	antag_roles = list(MODE_NUKE)
	desc = "A crate containing [item_worth] telecrystal\s worth of surplus leftovers."

/datum/uplink_item/item/badassery/surplus/get_goods(datum/component/uplink/U, loc)
	var/obj/structure/largecrate/C = new(loc)
	var/random_items = get_random_uplink_items(U, item_worth, C)
	for(var/datum/uplink_item/I in random_items)
		I.purchase_log(U)
		I.get_goods(U, C)

	return C

/datum/uplink_item/item/badassery/surplus/log_icon()
	if(!icon)
		var/obj/structure/largecrate/C = /obj/structure/largecrate
		icon = image(initial(C.icon), initial(C.icon_state))

	return "\icon[icon]"
