/obj/item/vending_cartridge
	name = "generic cartridge"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos1"
	w_class = ITEM_SIZE_NORMAL
	var/gen_rand_amount = FALSE // If we want to generate random amount of items in our cartridge.
	var/build_path = null // Determines what kind of vending machine we want to build.
	var/list/legal = list()
	var/list/illegal = list()
	var/list/premium = list()
	var/list/product_records = list() // Final list used by vending machines.

/obj/item/vending_cartridge/Initialize(mapload)
	. = ..()
	if(mapload)
		gen_rand_amount = TRUE
	else
		gen_rand_amount = FALSE
	build_inventory()

/obj/item/vending_cartridge/proc/build_inventory()
	var/list/all_products = list(list(legal, CAT_NORMAL), list(illegal, CAT_HIDDEN), list(premium, CAT_COIN))
	for(var/current_list in all_products)
		var/category = current_list[2]
		for(var/entry in current_list[1])
			var/datum/stored_items/vending_products/product = new /datum/stored_items/vending_products(src, entry)
			product.price = 0
			product.category = category
			var/amount = current_list[1][entry]
			if(gen_rand_amount)
				product.amount = amount ? max(0, amount - rand(0, round(amount * 1.5))) : 1
			else
				product.amount = amount || 1
			product_records.Add(product)
