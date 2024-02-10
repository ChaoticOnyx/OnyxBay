
// Cool full-sized RPED
/obj/item/storage/part_replacer
	name = "rapid part exchange device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	item_state = "RPED"
	w_class = ITEM_SIZE_HUGE
	can_hold = list(/obj/item/stock_parts)
	storage_slots = 50
	use_to_pickup = 1
	allow_quick_gather = 1
	allow_quick_empty = 1
	collection_mode = 1
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = 100
	var/active = TRUE

/obj/item/storage/part_replacer/proc/post_usage()
	return

// One-time-use mini RPED aka parts preserve
/obj/item/storage/part_replacer/mini
	name = "rapid machinery upgrade kit"
	desc = "Special one-time-use mechanical toolkit made to store and apply standard machine parts."
	icon_state = "RMUK"
	item_state = "buildpipe"
	w_class = ITEM_SIZE_NORMAL
	storage_slots = 10
	use_to_pickup = FALSE
	allow_quick_gather = FALSE
	allow_quick_empty = FALSE
	collection_mode = 0
	var/wasted = FALSE

/obj/item/storage/part_replacer/mini/post_usage()
	SetName("used rapid machinery upgrade kit")
	active = FALSE
	wasted = !length(contents)
	icon_state = "RMUK-[wasted ? "wasted" : "used"]"

/obj/item/storage/part_replacer/mini/_examine_text(mob/user)
	. = ..()
	if(active)
		. += "\nIt contains the following parts:"
		for(var/atom/A in contents)
			. += SPAN("notice", "\n	[A.name]")
	else
		. += "\nThis one's already been used."
		if(!wasted)
			. += "\nIt seems to still contain some spare parts that can be salvaged."

/obj/item/storage/part_replacer/mini/attackby(obj/item/I, mob/user)
	if(isWelder(I))
		var/obj/item/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			salvage()
			new /obj/item/stack/material/steel(get_turf(src))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			qdel(src)
			return

	if(isCrowbar(I))
		if(wasted)
			to_chat(user, SPAN("notice", "\The [src] is empty, it can only be salvaged for steel."))
			return

		if(salvage())
			to_chat(user, SPAN("notice", "You salvage \the [src] for spare parts."))
		return

	return ..()

/obj/item/storage/part_replacer/mini/show_to(mob/user)
	return

/obj/item/storage/part_replacer/mini/open(mob/user)
	return

/obj/item/storage/part_replacer/mini/proc/salvage()
	if(wasted)
		return FALSE

	var/turf/T = get_turf(src)
	if(!istype(T))
		return FALSE

	for(var/obj/O in contents)
		remove_from_storage(O, T)

	if(active)
		SetName("used rapid machinery upgrade kit")
		active = FALSE
	wasted = TRUE
	icon_state = "RMUK-wasted"

	return TRUE
