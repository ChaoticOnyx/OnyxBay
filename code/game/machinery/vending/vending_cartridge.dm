/obj/item/vending_cartridge
	name = "generic"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos1"
	w_class = ITEM_SIZE_NORMAL
	var/build_path = /obj/machinery/vending // Determines what kind of vending machine we want to build.
	var/list/legal = list()
	var/list/illegal = list()
	var/list/premium = list()
	var/list/prices = list()
	var/list/extra = list()
	var/list/product_records = list() // Final list used by vending machines.

/obj/item/vending_cartridge/Initialize()
	. = ..()
	name =  "[initial(build_path["name"])] cartridge"
	build_inventory()

/obj/item/vending_cartridge/proc/build_inventory(gen_rand_amount)
	if(extra.len)
		legal |= extra
	var/list/all_products = list(list(legal, CAT_NORMAL), list(illegal, CAT_HIDDEN), list(premium, CAT_COIN))
	for(var/current_list in all_products)
		var/category = current_list[2]
		for(var/entry in current_list[1])
			var/datum/stored_items/vending_products/product = new /datum/stored_items/vending_products(src, entry)
			product.price = (entry in prices) ? prices[entry] : 0
			product.category = category
			var/amount = current_list[1][entry]
			if(gen_rand_amount)
				product.amount = amount ? max(0, amount - rand(0, round(amount * 1.5))) : 1
			else
				product.amount = amount || 1
			product_records.Add(product)
