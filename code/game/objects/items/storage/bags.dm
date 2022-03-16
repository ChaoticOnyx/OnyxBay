/*
	Represents flexible bags that expand based on the size of their contents.
*/
/obj/item/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	use_to_pickup = 1
	slot_flags = SLOT_BELT
	use_sound = SFX_SEARCH_CLOTHES

/obj/item/storage/bag/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..()
	if(.)
		update_w_class()

/obj/item/storage/bag/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..()
	if(.)
		update_w_class()

/obj/item/storage/bag/can_be_inserted(obj/item/W, mob/user, stop_messages = 0)
	if(istype(loc, /obj/item/storage))
		if(!stop_messages)
			to_chat(user, SPAN("notice", "Take [src] out of [loc] first."))
		return FALSE //causes problems if the bag expands and becomes larger than src.loc can hold, so disallow it
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(!(H.get_inactive_hand() == src || H.get_active_hand() == src || H.belt == src))
			if(!stop_messages)
				to_chat(user, SPAN("notice", "Take [src] out first."))
			return FALSE //disallowing it because people stuff bags in their pockets and store fucking guns and plasma bombs inside
	. = ..()

/obj/item/storage/bag/proc/update_w_class()
	w_class = initial(w_class)
	for(var/obj/item/I in contents)
		w_class = max(w_class, I.w_class)

	var/cur_storage_space = storage_space_used()
	while(base_storage_capacity(w_class) < cur_storage_space)
		w_class++

/obj/item/storage/bag/get_storage_cost()
	var/used_ratio = storage_space_used() / max_storage_space
	return max(base_storage_cost(w_class), round(used_ratio * base_storage_cost(max_w_class), 1))

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag0"
	item_state = "trashbag"

	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_LARGE // storing things like backpacks inside a belt-attachable bag? no fuck you
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	can_hold = list() // any

/obj/item/storage/bag/trash/update_w_class()
	..()
	update_icon()

/obj/item/storage/bag/trash/update_icon()
	switch(w_class)
		if(2) icon_state = "trashbag0"
		if(3) icon_state = "trashbag1"
		if(4) icon_state = "trashbag2"
		if(5 to INFINITY) icon_state = "trashbag3"

// -----------------------------
//        Plastic Bag
// -----------------------------

/obj/item/storage/bag/plasticbag
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/trash.dmi'
	icon_state = "plasticbag"
	item_state = "plasticbag"

	w_class = ITEM_SIZE_TINY
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BOX_STORAGE
	can_hold = list() // any

/obj/item/storage/bag/plasticbag/attack_self(mob/user)
	quick_empty()
	to_chat(user, "You turned everything out of [src]!")
	user.drop_from_inventory(src)
	user.put_in_any_hand_if_possible(new /obj/item/clothing/mask/plasticbag)
	qdel(src)

// -----------------------------
//           Cash Bag
// -----------------------------

/obj/item/storage/bag/cash
	name = "cash bag"
	icon = 'icons/obj/storage.dmi'
	icon_state = "cashbag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	max_storage_space = 100
	max_w_class = ITEM_SIZE_HUGE
	w_class = ITEM_SIZE_SMALL
	can_hold = list(/obj/item/material/coin, /obj/item/spacecash)
