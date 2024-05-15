var/datum/uplink/uplink = new()

/proc/get_uplink_items(datum/component/uplink/U, allow_sales = FALSE)
	var/list/filtered_uplink_items = list()
	var/list/sale_items = list()

	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/I = new path
		if(isnull(I.path))
			continue

		if(!I.can_view(U))
			continue

		if(!filtered_uplink_items[I.category])
			filtered_uplink_items[I.category] = list()

		filtered_uplink_items[I.category][I.name] = I
		sale_items += I

	if(allow_sales)
		create_uplink_sales(6, "Discounted Gear", 1, sale_items, filtered_uplink_items)

	return filtered_uplink_items

/proc/create_uplink_sales(num, category_name, limited_stock, sale_items, uplink_items)
	if(num <= 0)
		return

	if(!uplink_items[category_name])
		uplink_items[category_name] = list()

	for(var/i in 1 to num)
		var/datum/uplink_item/I = pick_n_take(sale_items)
		if(!istype(I) || istype(I, /datum/uplink_item/item/telecrystal))
			continue

		var/datum/uplink_item/A = new I.type
		if(I.item_cost <= 1)
			continue

		var/discount = pick(90;0.9, 80;0.8, 70;0.7, 60;0.6, 50;0.5, 40;0.4, 30;0.3, 20;0.2, 10;0.1)
		var/list/disclaimer = list("Void where prohibited.", "Not recommended for children.", "Contains small parts.", "Check local laws for legality in region.", "Do not taunt.", "Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.", "Keep away from fire or flames.", "Product is provided \"as is\" without any implied or expressed warranties.", "As seen on TV.", "For recreational use only.", "Use only as directed.", "16% sales tax will be charged for orders originating within Space Nebraska.")
		if(A.item_cost >= 20)
			discount *= 0.5

		A.category = category_name
		A.item_cost = max(round(A.item_cost * discount),1)
		A.name += " ([round(((initial(A.item_cost) - A.item_cost) / initial(A.item_cost)) * 100)]% off!)"
		A.desc += " Normally item costs [initial(A.item_cost)] TC. All sales final. [pick(disclaimer)]"
		A.path = I.path
		uplink_items[category_name][A.name] = A

/datum/uplink
	var/list/items_assoc
	var/list/datum/uplink_item/items
	var/list/datum/uplink_category/categories

/datum/uplink/New()
	items_assoc = list()
	items = init_subtypes(/datum/uplink_item)
	categories = init_subtypes(/datum/uplink_category)
	categories = dd_sortedObjectList(categories)

	for(var/datum/uplink_item/item in items)
		if(!item.name)
			items -= item
			continue

		items_assoc[item.type] = item

		for(var/datum/uplink_category/category in categories)
			if(item.category == category.type)
				category.items += item
				item.category = category

	for(var/datum/uplink_category/category in categories)
		category.items = dd_sortedObjectList(category.items)

/datum/uplink_item
	var/name
	var/desc
	var/item_cost = 0
	var/list/antag_costs = list()			// Allows specific antag roles to purchase at a different cost
	var/datum/uplink_category/category		// Item category
	var/list/datum/antagonist/antag_roles = list() // Antag roles this item is displayed to. If empty, display to all.
	var/list/datum/antagonist/job_specific = list() // Jobs this item is displayed to. Contains job names, not datums.
	var/path = null

/datum/uplink_item/proc/buy(datum/component/uplink/U, mob/user)
	var/extra_args = extra_args(user)
	if(!extra_args)
		return

	if(!can_buy(U))
		return

	var/cost = cost(U.telecrystals, U)

	var/goods = get_goods(U, get_turf(user), user, extra_args)
	if(!goods)
		return

	purchase_log(U, user, cost)
	U.telecrystals -= cost
	return goods

// Any additional arguments you wish to send to the get_goods
/datum/uplink_item/proc/extra_args(mob/user)
	return 1

/datum/uplink_item/proc/can_buy(datum/component/uplink/U)
	if(cost(U.telecrystals, U) > U.telecrystals)
		return 0

	return can_view(U)

/datum/uplink_item/proc/can_view(datum/component/uplink/U)
	if(!U)
		return TRUE

	if(!U.owner)
		return FALSE

	if(length(job_specific) && !(U.owner.assigned_role in job_specific))
		return FALSE

	if(!length(antag_roles))
		return TRUE

	for(var/antag_role in antag_roles)
		var/datum/antagonist/antag = GLOB.all_antag_types_[antag_role]
		if(antag.is_antagonist(U.owner))
			return TRUE

	return FALSE

/datum/uplink_item/proc/can_view_comp(datum/component/uplink/U)
	// Making the assumption that if no uplink was supplied, then we don't care about antag roles
	if(!U)
		return TRUE

	// With no owner, there's no need to check antag status.
	if(!U.owner)
		return FALSE

	return ("Exclude" in antag_roles)

/datum/uplink_item/proc/cost(telecrystals, datum/component/uplink/U)
	. = item_cost
	if(U && U.owner)
		for(var/antag_role in antag_costs)
			var/datum/antagonist/antag = GLOB.all_antag_types_[antag_role]
			if(antag.is_antagonist(U.owner))
				. = min(antag_costs[antag_role], .)
	return max(1, .)

/datum/uplink_item/proc/name()
	return name

/datum/uplink_item/proc/description()
	return desc

// get_goods does not necessarily return physical objects, it is simply a way to acquire the uplink item without paying
/datum/uplink_item/proc/get_goods(datum/component/uplink/U, loc)
	return 0

/datum/uplink_item/proc/log_icon()
	return

/datum/uplink_item/proc/purchase_log(datum/component/uplink/U, mob/user, cost)
	feedback_add_details("traitor_uplink_items_bought", "[src]")
	log_and_message_admins("used \the [U.parent] to buy \a [src]")
	if(user)
		uplink_purchase_repository.add_entry(user.mind, src, cost)

/datum/uplink_item/dd_SortValue()
	return cost(INFINITY, null)

/********************************
*                           	*
*	Physical Uplink Entries		*
*                           	*
********************************/
/datum/uplink_item/item/buy(datum/component/uplink/U, mob/user)
	var/obj/item/I = ..()
	if(!I)
		return

	if(istype(I, /list))
		var/list/L = I
		if(L.len) I = L[1]

	if(istype(I) && ishuman(user))
		var/mob/living/carbon/human/A = user
		A.put_in_any_hand_if_possible(I)
	return I

/datum/uplink_item/item/get_goods(datum/component/uplink/U, loc)
	var/obj/item/I = new path(loc)
	return I

/datum/uplink_item/item/description()
	if(!desc)
		// Fallback description
		var/obj/temp = src.path
		desc = initial(temp.desc)
	return ..()

/datum/uplink_item/item/log_icon()
	var/obj/I = path
	return "\icon[I]"

/****************
* Support procs *
****************/
/proc/get_random_uplink_items(datum/component/uplink/U, remaining_TC, loc)
	var/list/bought_items = list()
	while(remaining_TC)
		var/datum/uplink_random_selection/uplink_selection = get_uplink_random_selection_by_type(/datum/uplink_random_selection/default)
		var/datum/uplink_item/I = uplink_selection.get_random_item(remaining_TC, U, bought_items)
		if(!I)
			break
		bought_items += I
		remaining_TC -= I.cost(remaining_TC, U)

	return bought_items
