decl/hierarchy/sell_order/mining/
	name = "Mining Item"

decl/hierarchy/sell_order/mining/add_item(var/atom/A)
	if(istype(A, /obj/item/stack))
		var/obj/item/stack/P = A
		if(wanted[A.type])
			wanted[A.type] -= P.amount
			if(wanted[A.type] < 0)
				wanted[A.type] = 0
			check_progress()
			return 1 //selling successful
	. = ..()
	return .

decl/hierarchy/sell_order/mining/check_progress()
	progress = max_progress
	for(var/i in wanted)
		progress -= wanted[i]
	if(progress >= max_progress) //if request complete - get reward
		reward()

decl/hierarchy/sell_order/mining/New()
	max_progress = 0
	for(var/i in wanted)
		max_progress += wanted[i]
	. = ..()
	return .

decl/hierarchy/sell_order/mining/iron
	name = "Iron Sheets"
	description = "For our new building site we need iron sheets. Please deliver them ASAP."
	wanted = list(/obj/item/stack/material/iron = 30)
	cost = 40

decl/hierarchy/sell_order/mining/osmium
	name = "Osmium Sheets"
	description = "For our new building site we need osmium sheets. Please deliver them ASAP."
	wanted = list(/obj/item/stack/material/osmium = 15)
	cost = 45

decl/hierarchy/sell_order/mining/tritium
	name = "Tritium Sheets"
	description = "For our new building site we need tritium sheets. Please deliver them ASAP."
	wanted = list(/obj/item/stack/material/tritium = 15)
	cost = 50