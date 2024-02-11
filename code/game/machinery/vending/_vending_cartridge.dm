/obj/item/vending_cartridge
	name = "generic cartridge"
	desc = "Simple, yet bulky piece of tech that used to store ite"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_generic"

	w_class = ITEM_SIZE_LARGE

	/// Determines what kind of vending machine we want to build.
	var/build_path = /obj/machinery/vending

	var/list/legal = list()
	var/list/extra = list()
	var/list/illegal = list()
	var/list/premium = list()
	var/list/prices = list()

	/// List of `datum/stored_items/vending_products` used by vending machines.
	var/list/product_records = list()

/obj/item/vending_cartridge/Initialize()
	. = ..()

	name =  "[initial(build_path["name"])] cartridge"
	build_inventory()

/obj/item/vending_cartridge/Destroy()
	QDEL_NULL_LIST(product_records)
	return ..()

/obj/item/vending_cartridge/proc/build_inventory(random = FALSE)
	if(length(extra))
		legal |= extra

	var/list/all_products = list(list(legal, CAT_NORMAL), list(illegal, CAT_HIDDEN), list(premium, CAT_COIN))
	for(var/current_list in all_products)
		var/category = current_list[2]
		for(var/entry in current_list[1])
			var/datum/stored_items/vending_products/product = new /datum/stored_items/vending_products(src, entry)
			product.price = (entry in prices) ? prices[entry] : 0
			product.category = category

			var/amount = current_list[1][entry]
			if(random)
				product.amount = amount ? max(0, amount - rand(0, round(amount * 1.5))) : 1
			else
				product.amount = amount || 1

			product_records.Add(product)
